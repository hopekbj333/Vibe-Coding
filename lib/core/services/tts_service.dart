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
    if (_isInitialized) return;

    try {
      // 한국어 설정
      await _flutterTts.setLanguage("ko-KR");
      
      // 아동용 설정: 느리고 또박또박
      await _flutterTts.setSpeechRate(0.4); // 0.0 ~ 1.0 (느림 ~ 빠름)
      await _flutterTts.setPitch(1.1); // 음높이 약간 높게 (친근감)
      await _flutterTts.setVolume(1.0); // 음량 최대
      
      _isInitialized = true;
      print('✅ TTS 초기화 완료');
    } catch (e) {
      print('❌ TTS 초기화 실패: $e');
    }
  }

  /// 텍스트 읽기 (완료까지 대기)
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('🗣️ TTS 시작: $text');
      
      // Completer를 사용해서 재생 완료 대기
      final completer = Completer<void>();
      
      // TTS 완료 핸들러 설정
      _flutterTts.setCompletionHandler(() {
        if (!completer.isCompleted) {
          completer.complete();
          print('🗣️ TTS 완료 이벤트 수신');
        }
      });
      
      final result = await _flutterTts.speak(text);
      print('🗣️ TTS 명령 전송 완료: $result');
      
      // TTS 완료 이벤트를 기다림 (최대 10초 타임아웃)
      try {
        await completer.future.timeout(const Duration(seconds: 10));
      } on TimeoutException {
        print('⚠️ TTS 완료 이벤트 타임아웃 - 예상 시간으로 대기');
        // 타임아웃 시 예상 시간만큼 대기
        final estimatedDuration = (text.length * 0.6 * 1000).toInt();
        final waitTime = estimatedDuration.clamp(800, 5000);
        await Future.delayed(Duration(milliseconds: waitTime));
      } catch (e) {
        print('⚠️ TTS 완료 대기 중 오류: $e');
        // 오류 발생 시 예상 시간만큼 대기
        final estimatedDuration = (text.length * 0.6 * 1000).toInt();
        final waitTime = estimatedDuration.clamp(800, 5000);
        await Future.delayed(Duration(milliseconds: waitTime));
      }
      
      print('🗣️ TTS 완료');
    } catch (e, stackTrace) {
      print('❌ TTS 재생 실패: $e');
      print('스택: $stackTrace');
      // TTS 실패 시에도 계속 진행 (오디오 재생 시도)
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
