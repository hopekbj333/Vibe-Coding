/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  /// 애니메이션 지속 시간 (밀리초)
  /// PRD 요구사항: "애니메이션과 전환 속도는 일반 앱보다 1.5배 느리게"
  static const int slowAnimationDurationMs = 300; // 200ms * 1.5
  static const int normalAnimationDurationMs = 200;
  static const double animationSlowdownFactor = 1.5;

  /// 페이지 전환 애니메이션 지속 시간
  static const Duration pageTransitionDuration = Duration(milliseconds: slowAnimationDurationMs);

  /// 페이드 인/아웃 지속 시간
  static const Duration fadeDuration = Duration(milliseconds: slowAnimationDurationMs);

  /// 딜레이 시간 (Think Time)
  /// 검사 프레임워크에서 사용: 입력 완료 후 다음 문제로 넘어가기 전 대기 시간
  static const Duration thinkTimeDelay = Duration(seconds: 1);

  /// 스플래시 화면 최소 표시 시간
  static const Duration splashMinDuration = Duration(seconds: 1);

  /// 오디오 재생 후 입력 잠금 해제 딜레이
  static const Duration audioPlaybackDelay = Duration(milliseconds: 500);
}

