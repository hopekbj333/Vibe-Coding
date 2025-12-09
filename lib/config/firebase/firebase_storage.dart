import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../core/security/audio_access_service.dart';
import 'firebase_config.dart';

/// Firebase Storage 연동 유틸리티
/// 
/// 음성 파일 저장 및 관리에 사용됩니다.
/// 주로 작업 기억 검사(Executive Functions)에서 녹음 파일을 저장합니다.
class FirebaseStorageService {
  FirebaseStorageService._();

  /// Storage 인스턴스 가져오기
  /// 
  /// Firebase가 초기화되지 않은 경우 null을 반환합니다.
  static FirebaseStorage? get _storage {
    if (!FirebaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠ Firebase Storage: Firebase not initialized');
      }
      return null;
    }
    return FirebaseStorage.instance;
  }

  /// 오디오 녹음 파일 업로드
  /// 
  /// [localFilePath] 로컬 파일 경로
  /// [assessmentId] 검사 세션 ID
  /// [childId] 아동 프로필 ID
  /// [module] 모듈 이름 (예: 'executive', 'phonological')
  /// [step] 단계 이름
  /// [questionId] 문제 ID
  /// 
  /// 반환: Storage 경로 (예: 'audio_recordings/assessmentId/childId/module/step/questionId.wav')
  static Future<String?> uploadAudioRecording({
    required String localFilePath,
    required String assessmentId,
    required String childId,
    required String module,
    required String step,
    required String questionId,
  }) async {
    final storage = _storage;
    if (storage == null) {
      return null;
    }

    try {
      // Storage 경로 생성
      final fileName = '$questionId.wav';
      final path = 'audio_recordings/$assessmentId/$childId/$module/$step/$fileName';
      
      final ref = storage.ref().child(path);
      
      // 파일 업로드
      final file = File(localFilePath);
      if (!await file.exists()) {
        throw Exception('File not found: $localFilePath');
      }
      
      await ref.putFile(file);
      
      if (kDebugMode) {
        print('✓ Audio file uploaded: $path');
      }
      
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Audio upload error: $e');
      }
      return null;
    }
  }

  /// 오디오 파일 다운로드 URL 가져오기 (권한 확인 포함)
  /// 
  /// [storagePath] Storage 경로
  /// 
  /// 반환: 다운로드 URL (권한이 없으면 null)
  static Future<String?> getDownloadUrl(String storagePath) async {
    // 접근 권한 확인
    final hasPermission = await AudioAccessService.canAccessAudio(storagePath);
    if (!hasPermission) {
      if (kDebugMode) {
        print('⚠ Audio access denied: $storagePath');
      }
      return null;
    }

    final storage = _storage;
    if (storage == null) {
      return null;
    }

    try {
      final ref = storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Get download URL error: $e');
      }
      return null;
    }
  }

  /// 오디오 파일 삭제
  /// 
  /// 채점 완료 후 음성 파일을 삭제하는 데 사용됩니다.
  /// 
  /// [storagePath] Storage 경로
  static Future<bool> deleteAudioRecording(String storagePath) async {
    final storage = _storage;
    if (storage == null) {
      return false;
    }

    try {
      final ref = storage.ref().child(storagePath);
      await ref.delete();
      
      if (kDebugMode) {
        print('✓ Audio file deleted: $storagePath');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Delete audio error: $e');
      }
      return false;
    }
  }

  /// Storage 경로 생성 헬퍼
  /// 
  /// 일관된 경로 형식을 생성합니다.
  static String buildAudioPath({
    required String assessmentId,
    required String childId,
    required String module,
    required String step,
    required String questionId,
    String extension = 'wav',
  }) {
    return 'audio_recordings/$assessmentId/$childId/$module/$step/$questionId.$extension';
  }
}

