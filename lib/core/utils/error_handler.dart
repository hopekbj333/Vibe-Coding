import 'package:flutter/foundation.dart';
import 'logger.dart';

/// 에러 처리 유틸리티
/// 
/// 일관된 에러 처리 패턴을 제공하여 코드 중복을 줄이고
/// 에러 추적을 용이하게 합니다.
class ErrorHandler {
  /// 비동기 작업의 에러 처리
  /// 
  /// [action]: 실행할 비동기 작업
  /// [context]: 에러 발생 컨텍스트 (에러 메시지에 포함)
  /// [defaultValue]: 에러 발생 시 반환할 기본값 (null이면 에러를 다시 던짐)
  /// [onError]: 에러 발생 시 추가 처리할 콜백
  static Future<T> handleAsync<T>(
    Future<T> Function() action, {
    String? context,
    T? defaultValue,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      final errorMessage = context != null
          ? '$context: $e'
          : '에러 발생: $e';

      AppLogger.error(
        errorMessage,
        error: e,
        stackTrace: stackTrace,
        data: {'context': context},
      );

      if (onError != null) {
        onError(e, stackTrace);
      }

      if (defaultValue != null) {
        return defaultValue;
      }

      rethrow;
    }
  }

  /// 동기 작업의 에러 처리
  /// 
  /// [action]: 실행할 동기 작업
  /// [context]: 에러 발생 컨텍스트 (에러 메시지에 포함)
  /// [defaultValue]: 에러 발생 시 반환할 기본값 (null이면 에러를 다시 던짐)
  /// [onError]: 에러 발생 시 추가 처리할 콜백
  static T handleSync<T>(
    T Function() action, {
    String? context,
    T? defaultValue,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return action();
    } catch (e, stackTrace) {
      final errorMessage = context != null
          ? '$context: $e'
          : '에러 발생: $e';

      AppLogger.error(
        errorMessage,
        error: e,
        stackTrace: stackTrace,
        data: {'context': context},
      );

      if (onError != null) {
        onError(e, stackTrace);
      }

      if (defaultValue != null) {
        return defaultValue;
      }

      rethrow;
    }
  }

  /// 에러를 무시하고 계속 진행 (경고만 로깅)
  /// 
  /// 주의: 이 메서드는 에러를 무시하므로 신중하게 사용해야 합니다.
  /// 중요한 에러는 [handleAsync] 또는 [handleSync]를 사용하세요.
  static Future<void> ignoreAsync(
    Future<void> Function() action, {
    String? context,
  }) async {
    try {
      await action();
    } catch (e, stackTrace) {
      AppLogger.warning(
        context != null ? '$context: $e' : '에러 발생 (무시됨): $e',
        data: {'error': e.toString(), 'context': context},
      );
    }
  }

  /// 동기 작업의 에러를 무시하고 계속 진행
  static void ignoreSync(
    void Function() action, {
    String? context,
  }) {
    try {
      action();
    } catch (e, stackTrace) {
      AppLogger.warning(
        context != null ? '$context: $e' : '에러 발생 (무시됨): $e',
        data: {'error': e.toString(), 'context': context},
      );
    }
  }
}
