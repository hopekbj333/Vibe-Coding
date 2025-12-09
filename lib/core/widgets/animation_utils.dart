import 'package:flutter/material.dart';

import '../design/design_system.dart';

/// 애니메이션 유틸리티
/// 
/// 아동 친화적 느린 애니메이션 (1.5배 느리게)을 쉽게 적용할 수 있는 헬퍼 함수들
class AnimationUtils {
  AnimationUtils._();

  /// 아동 친화적 느린 애니메이션 지속 시간
  static Duration get slowDuration => DesignSystem.slowAnimationDuration;

  /// 일반 애니메이션 지속 시간
  static Duration get normalDuration => DesignSystem.normalAnimationDuration;

  /// 페이드 인 애니메이션
  /// 
  /// [delay] 애니메이션 시작 전 딜레이 (S 1.3.3: 시각 요소 등장 후 0.5초 딜레이)
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) {
    if (delay != null && delay.inMilliseconds > 0) {
      return _DelayedAnimation(
        delay: delay,
        child: _FadeInAnimation(
          duration: duration ?? slowDuration,
          curve: curve ?? DesignSystem.defaultCurve,
          child: child,
        ),
      );
    }
    
    return _FadeInAnimation(
      duration: duration ?? slowDuration,
      curve: curve ?? DesignSystem.defaultCurve,
      child: child,
    );
  }
  
  /// 페이드 인 애니메이션 (내부 구현)
  static Widget _FadeInAnimation({
    required Widget child,
    required Duration duration,
    required Curve curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
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
  
  /// 딜레이 애니메이션 래퍼
  static Widget _DelayedAnimation({
    required Duration delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: delay,
      builder: (context, value, child) {
        if (value < 1.0) {
          return const SizedBox.shrink();
        }
        return child!;
      },
      child: child,
    );
  }

  /// 페이드 아웃 애니메이션
  static Widget fadeOut({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration ?? slowDuration,
      curve: curve ?? DesignSystem.defaultCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 슬라이드 인 애니메이션 (위에서 아래로)
  /// 
  /// [delay] 애니메이션 시작 전 딜레이
  static Widget slideInFromTop({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double offset = 50.0,
  }) {
    Widget animation = TweenAnimationBuilder<Offset>(
      tween: Tween(
        begin: Offset(0, -offset),
        end: Offset.zero,
      ),
      duration: duration ?? slowDuration,
      curve: curve ?? DesignSystem.defaultCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
    
    if (delay != null && delay.inMilliseconds > 0) {
      return _DelayedAnimation(delay: delay, child: animation);
    }
    
    return animation;
  }

  /// 슬라이드 인 애니메이션 (아래에서 위로)
  /// 
  /// [delay] 애니메이션 시작 전 딜레이
  static Widget slideInFromBottom({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double offset = 50.0,
  }) {
    Widget animation = TweenAnimationBuilder<Offset>(
      tween: Tween(
        begin: Offset(0, offset),
        end: Offset.zero,
      ),
      duration: duration ?? slowDuration,
      curve: curve ?? DesignSystem.defaultCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
    
    if (delay != null && delay.inMilliseconds > 0) {
      return _DelayedAnimation(delay: delay, child: animation);
    }
    
    return animation;
  }

  /// 스케일 인 애니메이션
  static Widget scaleIn({
    required Widget child,
    Duration? duration,
    Curve? curve,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration ?? slowDuration,
      curve: curve ?? DesignSystem.bounceCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 바운스 애니메이션
  static Widget bounce({
    required Widget child,
    Duration? duration,
    double intensity = 0.1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? slowDuration,
      curve: DesignSystem.bounceCurve,
      builder: (context, value, child) {
        final bounceValue = (value * 2 - 1).abs(); // 0 -> 1 -> 0
        return Transform.scale(
          scale: 1.0 + bounceValue * intensity,
          child: child,
        );
      },
      child: child,
    );
  }

  /// 페이지 전환 애니메이션 (느린 페이드)
  static PageRouteBuilder<T> fadeRoute<T extends Object?>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? slowDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// 페이지 전환 애니메이션 (슬라이드)
  static PageRouteBuilder<T> slideRoute<T extends Object?>({
    required Widget page,
    Duration? duration,
    Axis direction = Axis.horizontal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? slowDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

