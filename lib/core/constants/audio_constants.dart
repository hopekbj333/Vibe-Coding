/// 오디오 재생 관련 상수
class AudioConstants {
  AudioConstants._();

  /// 기본 오디오 볼륨 (0.0 ~ 1.0)
  static const double defaultVolume = 0.7;

  /// TTS 볼륨 (0.0 ~ 1.0)
  static const double ttsVolume = 1.0;

  /// 기본 딜레이 시간 (밀리초)
  static const int defaultDelayMs = 1000;

  /// 짧은 딜레이 시간 (밀리초)
  static const int shortDelayMs = 300;

  /// 중간 딜레이 시간 (밀리초)
  static const int mediumDelayMs = 500;

  /// 오디오 재생 타임아웃 (초)
  static const int audioTimeoutSeconds = 15;

  /// 오디오 재생 추가 대기 타임아웃 (초)
  static const int audioAdditionalWaitSeconds = 10;

  /// 오디오 시퀀스 간 딜레이 (밀리초)
  static const int audioSequenceDelayMs = 1000;

  /// Duration 상수들
  static const Duration defaultDelay = Duration(milliseconds: defaultDelayMs);
  static const Duration shortDelay = Duration(milliseconds: shortDelayMs);
  static const Duration mediumDelay = Duration(milliseconds: mediumDelayMs);
  static const Duration audioTimeout = Duration(seconds: audioTimeoutSeconds);
  static const Duration audioAdditionalWait = Duration(seconds: audioAdditionalWaitSeconds);
  static const Duration audioSequenceDelay = Duration(milliseconds: audioSequenceDelayMs);
}
