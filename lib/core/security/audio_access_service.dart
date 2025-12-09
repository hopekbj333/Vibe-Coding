import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../config/firebase/firebase_config.dart';
import '../../config/firebase/firebase_repositories.dart';
import '../../config/firebase/firestore_schema.dart';

/// 음성 데이터 접근 권한 관리 서비스
/// 
/// 음성 파일에 대한 접근 권한을 관리하고 검증합니다.
/// - 부모/교사만 자신의 아동 데이터에 접근 가능
/// - 채점 완료 후 음성 파일 자동 삭제
class AudioAccessService {
  AudioAccessService._();

  /// 음성 파일 접근 권한 확인
  /// 
  /// [storagePath] Firebase Storage 경로
  /// [userId] 접근을 시도하는 사용자 UID
  /// 
  /// 반환: 접근 권한 여부
  static Future<bool> checkAccessPermission(
    String storagePath,
    String userId,
  ) async {
    try {
      // 경로에서 childId 추출
      // 경로 형식: audio_recordings/{assessmentId}/{childId}/...
      final parts = storagePath.split('/');
      if (parts.length < 3) {
        return false;
      }

      final childId = parts[2];

      // Firestore에서 아동 프로필 확인
      final db = FirebaseRepositories.firestore;
      if (db == null) {
        return false;
      }

      final childDoc = await db
          .collection(FirestoreSchema.children)
          .doc(childId)
          .get();

      if (!childDoc.exists) {
        return false;
      }

      final childData = childDoc.data();
      if (childData == null) {
        return false;
      }

      final parentId = childData['parentId'] as String?;
      
      // 부모만 접근 가능
      return parentId == userId;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Audio access check error: $e');
      }
      return false;
    }
  }

  /// 현재 사용자가 음성 파일에 접근할 수 있는지 확인
  /// 
  /// [storagePath] Firebase Storage 경로
  /// 
  /// 반환: 접근 권한 여부
  static Future<bool> canAccessAudio(String storagePath) async {
    final auth = FirebaseRepositories.auth;
    if (auth == null) {
      return false;
    }

    final user = auth.currentUser;
    if (user == null) {
      return false;
    }

    return await checkAccessPermission(storagePath, user.uid);
  }

  /// 음성 파일 다운로드 (권한 확인 후)
  /// 
  /// [storagePath] Firebase Storage 경로
  /// 
  /// 반환: 다운로드 URL (권한이 없으면 null)
  static Future<String?> downloadAudioWithPermission(String storagePath) async {
    // 권한 확인
    final hasPermission = await canAccessAudio(storagePath);
    if (!hasPermission) {
      if (kDebugMode) {
        print('⚠ Audio access denied: $storagePath');
      }
      return null;
    }

    // Firebase Storage에서 다운로드 URL 가져오기
    final storage = FirebaseStorage.instance;
    try {
      final ref = storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Audio download error: $e');
      }
      return null;
    }
  }

  /// 채점 완료된 음성 파일 삭제
  /// 
  /// [storagePath] Firebase Storage 경로
  /// [assessmentId] 검사 세션 ID
  /// 
  /// 반환: 삭제 성공 여부
  /// 
  /// 주의: PRD에 따라 채점 완료 후 음성 파일은 즉시 삭제해야 합니다.
  static Future<bool> deleteAudioAfterScoring(
    String storagePath,
    String assessmentId,
  ) async {
    try {
      // 권한 확인
      final hasPermission = await canAccessAudio(storagePath);
      if (!hasPermission) {
        return false;
      }

      // Firebase Storage에서 파일 삭제
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(storagePath);
      await ref.delete();

      // Firestore에서 오디오 녹음 레코드 삭제
      final db = FirebaseRepositories.firestore;
      if (db != null) {
        final recordingsQuery = await db
            .collection(FirestoreSchema.audioRecordings)
            .where('assessmentId', isEqualTo: assessmentId)
            .where('storagePath', isEqualTo: storagePath)
            .get();

        for (final doc in recordingsQuery.docs) {
          await doc.reference.delete();
        }
      }

      if (kDebugMode) {
        print('✓ Audio file deleted after scoring: $storagePath');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete audio after scoring error: $e');
      }
      return false;
    }
  }

  /// 검사 세션의 모든 음성 파일 삭제
  /// 
  /// [assessmentId] 검사 세션 ID
  /// 
  /// 반환: 삭제 성공 여부
  static Future<bool> deleteAllAudioForAssessment(String assessmentId) async {
    try {
      final db = FirebaseRepositories.firestore;
      if (db == null) {
        return false;
      }

      // 해당 검사의 모든 오디오 녹음 레코드 조회
      final recordingsQuery = await db
          .collection(FirestoreSchema.audioRecordings)
          .where('assessmentId', isEqualTo: assessmentId)
          .get();

      final storage = FirebaseStorage.instance;
      bool allDeleted = true;

      for (final doc in recordingsQuery.docs) {
        final data = doc.data();
        final storagePath = data['storagePath'] as String?;

        if (storagePath != null) {
          try {
            // 권한 확인
            final hasPermission = await canAccessAudio(storagePath);
            if (hasPermission) {
              final ref = storage.ref().child(storagePath);
              await ref.delete();
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠ Failed to delete audio: $storagePath, error: $e');
            }
            allDeleted = false;
          }
        }

        // Firestore 레코드 삭제
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('✓ All audio files deleted for assessment: $assessmentId');
      }

      return allDeleted;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete all audio error: $e');
      }
      return false;
    }
  }
}

