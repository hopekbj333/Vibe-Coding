import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger.dart';
import '../constants/tts_constants.dart';

/// Text-to-Speech 서비스
/// 텍스트를 음성으로 변환하여 재생
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TtsService._internal();

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.info('TTS 서비스 이미 초기화됨');
      return;
    }

    AppLogger.debug('TTS 서비스 초기화 시작');
    try {
      // 한국어 설정
      await _flutterTts.setLanguage(TtsConstants.defaultLanguage);
      
      // 아동용 설정: 느리고 또박또박
      await _flutterTts.setSpeechRate(TtsConstants.defaultSpeechRate);
      await _flutterTts.setPitch(TtsConstants.defaultPitch);
      await _flutterTts.setVolume(TtsConstants.defaultVolume);
      
      _isInitialized = true;
      AppLogger.success('TTS 서비스 초기화 완료', data: {
        'language': TtsConstants.defaultLanguage,
        'speechRate': TtsConstants.defaultSpeechRate,
        'pitch': TtsConstants.defaultPitch,
        'volume': TtsConstants.defaultVolume,
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'TTS 서비스 초기화 실패',
        error: e,
        stackTrace: stackTrace,
      );
      _isInitialized = false;
    }
  }

  /// 텍스트 읽기 (완료까지 대기)
  Future<void> speak(String text) async {
    AppLogger.tts('speak() 호출됨', data: {
      'text': text,
      'textLength': text.length,
      'isInitialized': _isInitialized,
    });
    
    if (!_isInitialized) {
      AppLogger.debug('초기화되지 않음, 초기화 시작');
      await initialize();
      if (!_isInitialized) {
        AppLogger.error('초기화 실패로 speak() 중단');
        return;
      }
    }

    try {
      AppLogger.tts('TTS 재생 시작');
      
      // Completer를 사용해서 재생 완료 대기
      final completer = Completer<void>();
      
      // TTS 완료 핸들러 설정
      _flutterTts.setCompletionHandler(() {
        if (!completer.isCompleted) {
          completer.complete();
          AppLogger.success('TTS 완료 이벤트 수신');
        } else {
          AppLogger.warning('TTS 완료 이벤트 중복 수신 (무시)');
        }
      });
      
      final result = await _flutterTts.speak(text);
      AppLogger.debug('FlutterTts.speak() 완료', data: {'result': result});
      
      // TTS 완료 이벤트를 기다림
      // 타임아웃 시간을 실제 재생 시간에 맞게 조정
      final estimatedSeconds = TtsConstants.calculateTimeoutSeconds(text.length);
      AppLogger.debug('완료 이벤트 대기 시작', data: {
        'estimatedSeconds': estimatedSeconds,
        'textLength': text.length,
      });
      final waitStartTime = DateTime.now();
      
      try {
        await completer.future.timeout(Duration(seconds: estimatedSeconds));
        final waitDuration = DateTime.now().difference(waitStartTime).inMilliseconds;
        AppLogger.success('TTS 완료 이벤트 수신됨', data: {'waitDurationMs': waitDuration});
      } on TimeoutException {
        final waitDuration = DateTime.now().difference(waitStartTime).inMilliseconds;
        AppLogger.warning('TTS 완료 이벤트 타임아웃', data: {
          'waitDurationMs': waitDuration,
          'estimatedSeconds': estimatedSeconds,
        });
        AppLogger.debug('타임아웃 발생, 재생 완료로 간주하고 진행');
      } catch (e) {
        final waitDuration = DateTime.now().difference(waitStartTime).inMilliseconds;
        AppLogger.warning('TTS 완료 대기 중 오류', data: {
          'error': e.toString(),
          'waitDurationMs': waitDuration,
        });
      }
      
      AppLogger.success('TTS speak() 완료');
    } catch (e, stackTrace) {
      AppLogger.error(
        'TTS 재생 실패',
        error: e,
        stackTrace: stackTrace,
      );
      // TTS 실패 시에도 계속 진행 (오디오 재생 시도)
      rethrow; // 에러를 다시 던져서 호출자가 인지할 수 있도록
    }
  }

  /// 재생 중지
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      AppLogger.debug('TTS 중지 완료');
    } catch (e, stackTrace) {
      AppLogger.error(
        'TTS 중지 실패',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 말하는 중인지 확인
  Future<bool> get isSpeaking async {
    try {
      final status = await _flutterTts.getSpeechRateValidRange;
      return status != null;
    } catch (e) {
      return false;
    }
  }

  /// 속도 조절 (0.0 ~ 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// 음높이 조절 (0.5 ~ 2.0)
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  /// 언어 변경
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  /// 리소스 정리
  void dispose() {
    _flutterTts.stop();
  }
}

/// 아동용 TTS 프리셋
class ChildFriendlyTtsPresets {
  /// 지시문용: 천천히, 명확하게
  static Future<void> applyInstructionStyle(TtsService tts) async {
    await tts.setSpeechRate(TtsConstants.instructionSpeechRate);
    await tts.setPitch(TtsConstants.instructionPitch);
  }

  /// 피드백용: 약간 빠르게, 높은 톤
  static Future<void> applyFeedbackStyle(TtsService tts) async {
    await tts.setSpeechRate(TtsConstants.feedbackSpeechRate);
    await tts.setPitch(TtsConstants.feedbackPitch);
  }

  /// 선택지용: 보통 속도
  static Future<void> applyOptionStyle(TtsService tts) async {
    await tts.setSpeechRate(TtsConstants.optionSpeechRate);
    await tts.setPitch(TtsConstants.optionPitch);
  }
}
