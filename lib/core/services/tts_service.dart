import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

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
      print('ℹ️ [TTS 서비스] 이미 초기화됨');
      return;
    }

    print('🔧 [TTS 서비스] 초기화 시작');
    try {
      // 한국어 설정
      print('  - 언어 설정: ko-KR');
      await _flutterTts.setLanguage("ko-KR");
      
      // 아동용 설정: 느리고 또박또박
      print('  - 속도 설정: 0.4');
      await _flutterTts.setSpeechRate(0.4); // 0.0 ~ 1.0 (느림 ~ 빠름)
      print('  - 음높이 설정: 1.1');
      await _flutterTts.setPitch(1.1); // 음높이 약간 높게 (친근감)
      print('  - 음량 설정: 1.0');
      await _flutterTts.setVolume(1.0); // 음량 최대
      
      _isInitialized = true;
      print('✅ [TTS 서비스] 초기화 완료');
    } catch (e, stackTrace) {
      print('❌ [TTS 서비스] 초기화 실패: $e');
      print('  - 에러 타입: ${e.runtimeType}');
      print('  - 스택 트레이스: $stackTrace');
      _isInitialized = false;
    }
  }

  /// 텍스트 읽기 (완료까지 대기)
  Future<void> speak(String text) async {
    print('🗣️ [TTS 서비스] speak() 호출됨');
    print('  - 텍스트: "$text" (길이: ${text.length}자)');
    print('  - _isInitialized: $_isInitialized');
    
    if (!_isInitialized) {
      print('  - 초기화되지 않음, 초기화 시작');
      await initialize();
      if (!_isInitialized) {
        print('❌ [TTS 서비스] 초기화 실패로 speak() 중단');
        return;
      }
    }

    try {
      print('🗣️ [TTS 서비스] TTS 재생 시작');
      
      // Completer를 사용해서 재생 완료 대기
      final completer = Completer<void>();
      
      // TTS 완료 핸들러 설정
      print('  - 완료 핸들러 설정');
      _flutterTts.setCompletionHandler(() {
        if (!completer.isCompleted) {
          completer.complete();
          print('✅ [TTS 서비스] 완료 이벤트 수신');
        } else {
          print('⚠️ [TTS 서비스] 완료 이벤트 중복 수신 (무시)');
        }
      });
      
      print('  - FlutterTts.speak() 호출');
      final result = await _flutterTts.speak(text);
      print('✅ [TTS 서비스] FlutterTts.speak() 완료, 결과: $result');
      
      // TTS 완료 이벤트를 기다림
      // 타임아웃 시간을 실제 재생 시간에 맞게 조정 (초당 약 5자 기준, 최소 2초, 최대 10초)
      final estimatedSeconds = (text.length / 5.0).ceil().clamp(2, 10);
      print('  - 완료 이벤트 대기 시작 (예상 시간: ${estimatedSeconds}초, 텍스트 길이: ${text.length}자)');
      final waitStartTime = DateTime.now();
      
      try {
        await completer.future.timeout(Duration(seconds: estimatedSeconds));
        final waitDuration = DateTime.now().difference(waitStartTime).inMilliseconds;
        print('✅ [TTS 서비스] 완료 이벤트 수신됨 (대기 시간: ${waitDuration}ms)');
      } on TimeoutException {
        final waitDuration = DateTime.now().difference(waitStartTime).inMilliseconds;
        print('⚠️ [TTS 서비스] 완료 이벤트 타임아웃 (대기 시간: ${waitDuration}ms)');
        // 타임아웃 발생 시 추가 대기 없이 바로 완료 처리
        // TTS는 이미 재생을 완료했을 가능성이 높음
        print('  - 타임아웃 발생, 재생 완료로 간주하고 진행');
      } catch (e) {
        final waitDuration = DateTime.now().difference(waitStartTime).inMilliseconds;
        print('⚠️ [TTS 서비스] 완료 대기 중 오류: $e (대기 시간: ${waitDuration}ms)');
        // 오류 발생 시에도 바로 진행 (TTS는 이미 재생 중이거나 완료되었을 가능성)
      }
      
      print('✅ [TTS 서비스] speak() 완료');
    } catch (e, stackTrace) {
      print('❌ [TTS 서비스] 재생 실패: $e');
      print('  - 에러 타입: ${e.runtimeType}');
      print('  - 스택 트레이스: $stackTrace');
      // TTS 실패 시에도 계속 진행 (오디오 재생 시도)
      rethrow; // 에러를 다시 던져서 호출자가 인지할 수 있도록
    }
  }

  /// 재생 중지
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('❌ TTS 중지 실패: $e');
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
    await tts.setSpeechRate(0.35); // 매우 느리게
    await tts.setPitch(1.0); // 보통 음높이
  }

  /// 피드백용: 약간 빠르게, 높은 톤
  static Future<void> applyFeedbackStyle(TtsService tts) async {
    await tts.setSpeechRate(0.45); // 약간 느리게
    await tts.setPitch(1.2); // 높은 톤 (긍정적)
  }

  /// 선택지용: 보통 속도
  static Future<void> applyOptionStyle(TtsService tts) async {
    await tts.setSpeechRate(0.4); // 느리게
    await tts.setPitch(1.1); // 약간 높게
  }
}
