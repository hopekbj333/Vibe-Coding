import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱 환경 타입
enum AppEnvironment {
  development,
  staging,
  production,
}

/// 앱 설정 관리 클래스
class AppConfig {
  AppConfig._();

  /// 현재 환경 타입
  /// 주의: dotenv.load() 이후에만 정확한 값을 반환합니다.
  static AppEnvironment get environment {
    // dotenv가 로드되지 않았으면 기본값 반환
    if (!dotenv.isInitialized) {
      return AppEnvironment.development;
    }
    
    final envString = dotenv.env['ENVIRONMENT']?.toLowerCase() ?? 'development';
    switch (envString) {
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }

  /// 환경 변수 파일명
  /// 주의: 이 메서드는 dotenv.load() 이후에만 정확한 값을 반환합니다.
  /// main.dart에서 빌드 시 전달된 ENV_FILE을 우선 사용합니다.
  static String get envFileName {
    // 빌드 시 전달된 환경 변수 파일명이 있으면 사용
    const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '');
    if (envFile.isNotEmpty) {
      return envFile;
    }
    
    // 없으면 환경 타입에 따라 결정
    switch (environment) {
      case AppEnvironment.production:
        return '.env.prod';
      case AppEnvironment.staging:
        return '.env.staging';
      case AppEnvironment.development:
        return '.env.dev';
    }
  }

  /// 앱 이름
  static String get appName {
    if (!dotenv.isInitialized) {
      return '문해력 기초 검사';
    }
    return dotenv.env['APP_NAME'] ?? '문해력 기초 검사';
  }

  /// 앱 버전
  static String get appVersion {
    if (!dotenv.isInitialized) {
      return '1.0.0';
    }
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  /// API 베이스 URL (향후 Firebase 연동 시 사용)
  static String? get apiBaseUrl {
    if (!dotenv.isInitialized) {
      return null;
    }
    return dotenv.env['API_BASE_URL'];
  }

  /// 디버그 모드 여부
  static bool get isDebugMode => kDebugMode;

  /// 프로덕션 환경 여부
  static bool get isProduction => environment == AppEnvironment.production;

  /// 스테이징 환경 여부
  static bool get isStaging => environment == AppEnvironment.staging;

  /// 개발 환경 여부
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// 환경 정보 출력 (디버그용)
  static void printEnvironment() {
    if (kDebugMode) {
      print('=== App Configuration ===');
      print('Environment: $environment');
      print('App Name: $appName');
      print('App Version: $appVersion');
      print('API Base URL: $apiBaseUrl');
      print('Debug Mode: $isDebugMode');
      print('========================');
    }
  }
}

