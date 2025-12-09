import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 아동 친화적 느린 애니메이션 유틸리티
/// PRD 요구사항: "애니메이션과 전환 속도는 일반 앱보다 1.5배 느리게"
class SlowAnimations {
  SlowAnimations._();

  /// 1.5배 느린 애니메이션 지속 시간 반환
  static Duration get duration => AppTheme.slowAnimationDuration;

  /// 1.5배 느린 애니메이션 지속 시간 팩터
  static double get factor => AppTheme.animationSlowdownFactor;

  /// 일반 애니메이션 지속 시간을 느린 애니메이션으로 변환
  static Duration slow(Duration normalDuration) {
    return Duration(
      milliseconds: (normalDuration.inMilliseconds * factor).round(),
    );
  }

  /// 커스텀 애니메이션 컨트롤러 생성 (1.5배 느리게)
  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration ?? SlowAnimations.duration,
    );
  }

  /// 페이드 인 애니메이션 (1.5배 느리게)
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? SlowAnimations.duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 슬라이드 애니메이션 (1.5배 느리게)
  static Widget slideIn({
    required Widget child,
    Offset begin = const Offset(0.0, 0.1),
    Offset end = Offset.zero,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration ?? SlowAnimations.duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

