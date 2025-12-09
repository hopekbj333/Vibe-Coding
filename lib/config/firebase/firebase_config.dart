import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../firebase_options.dart';
import '../app_config.dart';

/// Firebase 초기화 및 설정 관리 클래스
class FirebaseConfig {
  FirebaseConfig._();

  /// Firebase 초기화 여부
  static bool _isInitialized = false;

  /// Firebase가 초기화되었는지 확인
  static bool get isInitialized => _isInitialized;

  /// Firebase 초기화
  /// 
  /// 환경에 따라 다른 Firebase 프로젝트를 사용할 수 있도록 설계
  /// 실제 Firebase 프로젝트 생성 후 firebase_options.dart 파일이 생성되면
  /// 해당 파일을 import하여 사용하세요.
  /// 
  /// Firebase가 설정되지 않은 경우에도 앱이 실행되도록 안전하게 처리합니다.
  static Future<void> initialize() async {
    // 이미 초기화된 경우 스킵
    if (_isInitialized) {
      return;
    }

    // Firebase 초기화
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      
      // Firestore 설정 (선택사항, 연결 문제 해결을 위해 명시적 설정)
      try {
        final firestore = FirebaseFirestore.instance;
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        if (kDebugMode) {
          print('✓ Firestore settings configured');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠ Firestore settings error: $e');
        }
      }
      
      if (kDebugMode) {
        print('✓ Firebase initialized successfully');
        print('  Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
      }
    } catch (e) {
      // Firebase 초기화 실패 시에도 앱이 실행되도록 함
      if (kDebugMode) {
        print('⚠ Firebase initialization failed: $e');
        print('  App will continue without Firebase features.');
      }
      _isInitialized = false;
    }
  }

  /// Firebase 초기화 완료 후 Crashlytics 설정
  /// 
  /// Firebase가 초기화된 경우에만 호출해야 합니다.
  static void setupCrashlytics() {
    if (!_isInitialized) {
      return;
    }

    try {
      // 프로덕션 환경에서만 Crashlytics 활성화
      if (!kDebugMode && AppConfig.isProduction) {
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };
        
        // 비동기 오류 처리
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        
        if (kDebugMode) {
          print('✓ Firebase Crashlytics configured');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Crashlytics setup error: $e');
      }
    }
  }

  /// Firebase 프로젝트 ID 가져오기
  /// 
  /// 환경 변수에서 Firebase 프로젝트 ID를 읽어옵니다.
  /// .env 파일에 FIREBASE_PROJECT_ID를 추가하세요.
  static String? get projectId {
    if (!dotenv.isInitialized) {
      return null;
    }
    return dotenv.env['FIREBASE_PROJECT_ID'];
  }

  /// Firestore 데이터베이스 ID 가져오기
  /// 
  /// 기본 데이터베이스가 아닌 경우 환경 변수에서 읽어옵니다.
  /// 기본값은 '(default)'입니다.
  static String get firestoreDatabaseId {
    if (!dotenv.isInitialized) {
      return '(default)';
    }
    return dotenv.env['FIRESTORE_DATABASE_ID'] ?? '(default)';
  }

  /// Storage 버킷 이름 가져오기
  /// 
  /// 환경 변수에서 Storage 버킷 이름을 읽어옵니다.
  static String? get storageBucket {
    if (!dotenv.isInitialized) {
      return null;
    }
    return dotenv.env['FIREBASE_STORAGE_BUCKET'];
  }
}

