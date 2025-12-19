import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용하는 통합 로깅 시스템
/// 
/// 프로덕션 빌드에서는 자동으로 로그가 비활성화되며,
/// 디버그 빌드에서만 로그가 출력됩니다.
class AppLogger {
  /// 디버그 로그 (상세한 디버깅 정보)
  static void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '🔍 [DEBUG]';
      _log(prefix, message, data: data);
    }
  }

  /// 정보 로그 (일반적인 정보)
  static void info(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = 'ℹ️ [INFO]';
      _log(prefix, message, data: data);
    }
  }

  /// 성공 로그 (성공적인 작업 완료)
  static void success(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '✅ [SUCCESS]';
      _log(prefix, message, data: data);
    }
  }

  /// 경고 로그 (잠재적 문제)
  static void warning(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '⚠️ [WARNING]';
      _log(prefix, message, data: data);
    }
  }

  /// 에러 로그 (오류 발생)
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode) {
      final prefix = '❌ [ERROR]';
      _log(prefix, message, data: data);
      
      if (error != null) {
        print('  - 에러: $error');
        print('  - 에러 타입: ${error.runtimeType}');
      }
      
      if (stackTrace != null) {
        print('  - 스택 트레이스: $stackTrace');
      }
    }
  }

  /// TTS 관련 로그
  static void tts(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '🗣️ [TTS]';
      _log(prefix, message, data: data);
    }
  }

  /// 오디오 관련 로그
  static void audio(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '🎵 [AUDIO]';
      _log(prefix, message, data: data);
    }
  }

  /// 시퀀스 관련 로그
  static void sequence(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '🎬 [SEQUENCE]';
      _log(prefix, message, data: data);
    }
  }

  /// 딜레이 관련 로그
  static void delay(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final prefix = '⏳ [DELAY]';
      _log(prefix, message, data: data);
    }
  }

  /// 내부 로그 출력 메서드
  static void _log(
    String prefix,
    String message, {
    Map<String, dynamic>? data,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer();
    buffer.write('$prefix $message');

    if (data != null && data.isNotEmpty) {
      buffer.write('\n  - 데이터:');
      data.forEach((key, value) {
        buffer.write('\n    $key: $value');
      });
    }

    print(buffer.toString());
  }
}
