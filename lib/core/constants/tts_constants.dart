/// TTS (Text-to-Speech) 관련 상수
class TtsConstants {
  TtsConstants._();

  /// 기본 언어
  static const String defaultLanguage = 'ko-KR';

  /// 아동용 기본 속도 (0.0 ~ 1.0)
  /// 느리고 또박또박하게 읽기
  static const double defaultSpeechRate = 0.4;

  /// 아동용 기본 음높이 (0.5 ~ 2.0)
  /// 약간 높게 설정하여 친근감 제공
  static const double defaultPitch = 1.1;

  /// 아동용 기본 음량 (0.0 ~ 1.0)
  static const double defaultVolume = 1.0;

  /// 지시문용 속도 (매우 느리게)
  static const double instructionSpeechRate = 0.35;

  /// 지시문용 음높이 (보통)
  static const double instructionPitch = 1.0;

  /// 피드백용 속도 (약간 느리게)
  static const double feedbackSpeechRate = 0.45;

  /// 피드백용 음높이 (높은 톤, 긍정적)
  static const double feedbackPitch = 1.2;

  /// 선택지용 속도
  static const double optionSpeechRate = 0.4;

  /// 선택지용 음높이
  static const double optionPitch = 1.1;

  /// TTS 완료 이벤트 타임아웃 계산
  /// 초당 약 5자 기준, 최소 2초, 최대 10초
  static int calculateTimeoutSeconds(int textLength) {
    return (textLength / 5.0).ceil().clamp(2, 10);
  }
}
