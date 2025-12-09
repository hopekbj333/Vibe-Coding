import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../config/firebase/firebase_config.dart';
import '../../config/firebase/firebase_repositories.dart';
import '../../config/firebase/firestore_schema.dart';
import '../../config/firebase/firebase_storage.dart';

/// 데이터 보존 기간 정책 서비스
/// 
/// 오래된 데이터를 자동으로 삭제하여 개인정보 보호 및 저장 공간을 관리합니다.
/// 
/// 정책:
/// - 음성 파일: 채점 완료 후 즉시 삭제 (PRD 요구사항)
/// - 검사 결과: 3년 보관 후 자동 삭제
/// - 오래된 검사 세션: 1년 미완료 세션 자동 삭제
class DataRetentionService {
  DataRetentionService._();

  /// 검사 결과 보존 기간 (일)
  static const int assessmentResultRetentionDays = 365 * 3; // 3년

  /// 미완료 검사 세션 보존 기간 (일)
  static const int incompleteAssessmentRetentionDays = 365; // 1년

  /// 오래된 검사 결과 삭제
  /// 
  /// [beforeDate] 이 날짜 이전의 데이터 삭제
  /// 
  /// 반환: 삭제된 문서 수
  static Future<int> deleteOldAssessmentResults(DateTime beforeDate) async {
    final db = FirebaseRepositories.firestore;
    if (db == null) {
      return 0;
    }

    try {
      final timestamp = Timestamp.fromDate(beforeDate);
      
      // 오래된 검사 결과 조회
      final resultsQuery = await db
          .collection(FirestoreSchema.assessmentResults)
          .where('completedAt', isLessThan: timestamp)
          .limit(100) // 한 번에 최대 100개씩 처리
          .get();

      int deletedCount = 0;
      for (final doc in resultsQuery.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      if (kDebugMode) {
        print('✓ Deleted $deletedCount old assessment results');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete old assessment results error: $e');
      }
      return 0;
    }
  }

  /// 미완료 검사 세션 삭제
  /// 
  /// [beforeDate] 이 날짜 이전의 미완료 세션 삭제
  /// 
  /// 반환: 삭제된 문서 수
  static Future<int> deleteIncompleteAssessments(DateTime beforeDate) async {
    final db = FirebaseRepositories.firestore;
    if (db == null) {
      return 0;
    }

    try {
      final timestamp = Timestamp.fromDate(beforeDate);
      
      // 오래된 미완료 검사 세션 조회
      final assessmentsQuery = await db
          .collection(FirestoreSchema.assessments)
          .where('status', whereIn: ['in_progress', 'paused'])
          .where('startedAt', isLessThan: timestamp)
          .limit(100)
          .get();

      int deletedCount = 0;
      for (final doc in assessmentsQuery.docs) {
        final data = doc.data();
        final assessmentId = doc.id;

        // 관련 음성 파일도 삭제
        await AudioAccessService.deleteAllAudioForAssessment(assessmentId);

        // 검사 세션 삭제
        await doc.reference.delete();
        deletedCount++;
      }

      if (kDebugMode) {
        print('✓ Deleted $deletedCount incomplete assessments');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete incomplete assessments error: $e');
      }
      return 0;
    }
  }

  /// 오래된 오디오 녹음 레코드 삭제
  /// 
  /// [beforeDate] 이 날짜 이전의 레코드 삭제
  /// 
  /// 반환: 삭제된 문서 수
  /// 
  /// 주의: 채점 완료된 음성 파일은 즉시 삭제되어야 하므로,
  /// 이 메서드는 예외적으로 남아있는 오래된 레코드를 정리하는 용도입니다.
  static Future<int> deleteOldAudioRecordings(DateTime beforeDate) async {
    final db = FirebaseRepositories.firestore;
    if (db == null) {
      return 0;
    }

    try {
      final timestamp = Timestamp.fromDate(beforeDate);
      
      // 오래된 오디오 녹음 레코드 조회
      final recordingsQuery = await db
          .collection(FirestoreSchema.audioRecordings)
          .where('recordedAt', isLessThan: timestamp)
          .limit(100)
          .get();

      int deletedCount = 0;
      for (final doc in recordingsQuery.docs) {
        final data = doc.data();
        final storagePath = data['storagePath'] as String?;

        // Storage에서 파일 삭제
        if (storagePath != null) {
          await FirebaseStorageService.deleteAudioRecording(storagePath);
        }

        // Firestore 레코드 삭제
        await doc.reference.delete();
        deletedCount++;
      }

      if (kDebugMode) {
        print('✓ Deleted $deletedCount old audio recordings');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete old audio recordings error: $e');
      }
      return 0;
    }
  }

  /// 데이터 보존 정책에 따른 자동 정리 실행
  /// 
  /// 주기적으로 실행하여 오래된 데이터를 삭제합니다.
  /// 
  /// 반환: 정리된 데이터 수
  static Future<Map<String, int>> cleanupOldData() async {
    final now = DateTime.now();
    
    // 검사 결과: 3년 이상 된 데이터 삭제
    final assessmentResultCutoff = now.subtract(
      Duration(days: assessmentResultRetentionDays),
    );
    final deletedResults = await deleteOldAssessmentResults(assessmentResultCutoff);

    // 미완료 검사: 1년 이상 된 데이터 삭제
    final incompleteAssessmentCutoff = now.subtract(
      Duration(days: incompleteAssessmentRetentionDays),
    );
    final deletedIncomplete = await deleteIncompleteAssessments(incompleteAssessmentCutoff);

    // 오디오 녹음: 1년 이상 된 레코드 삭제 (예외 케이스 정리)
    final audioCutoff = now.subtract(const Duration(days: 365));
    final deletedAudio = await deleteOldAudioRecordings(audioCutoff);

    return {
      'assessmentResults': deletedResults,
      'incompleteAssessments': deletedIncomplete,
      'audioRecordings': deletedAudio,
    };
  }

  /// 특정 아동의 모든 데이터 삭제 (개인정보 삭제 요청 시)
  /// 
  /// [childId] 아동 프로필 ID
  /// 
  /// 반환: 삭제 성공 여부
  /// 
  /// 주의: GDPR/개인정보보호법에 따른 데이터 삭제 요청 처리용
  static Future<bool> deleteAllChildData(String childId) async {
    final db = FirebaseRepositories.firestore;
    if (db == null) {
      return false;
    }

    try {
      // 해당 아동의 모든 검사 세션 조회
      final assessmentsQuery = await db
          .collection(FirestoreSchema.assessments)
          .where('childId', isEqualTo: childId)
          .get();

      // 각 검사 세션의 음성 파일 삭제
      for (final doc in assessmentsQuery.docs) {
        await AudioAccessService.deleteAllAudioForAssessment(doc.id);
      }

      // 검사 세션 삭제
      for (final doc in assessmentsQuery.docs) {
        await doc.reference.delete();
      }

      // 검사 결과 삭제
      final resultsQuery = await db
          .collection(FirestoreSchema.assessmentResults)
          .where('childId', isEqualTo: childId)
          .get();
      for (final doc in resultsQuery.docs) {
        await doc.reference.delete();
      }

      // 오디오 녹음 레코드 삭제
      final recordingsQuery = await db
          .collection(FirestoreSchema.audioRecordings)
          .where('childId', isEqualTo: childId)
          .get();
      for (final doc in recordingsQuery.docs) {
        final data = doc.data();
        final storagePath = data['storagePath'] as String?;
        if (storagePath != null) {
          await FirebaseStorageService.deleteAudioRecording(storagePath);
        }
        await doc.reference.delete();
      }

      // 채점 데이터 삭제
      final scoresQuery = await db
          .collection(FirestoreSchema.scores)
          .where('childId', isEqualTo: childId)
          .get();
      for (final doc in scoresQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('✓ Deleted all data for child: $childId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete all child data error: $e');
      }
      return false;
    }
  }
}

