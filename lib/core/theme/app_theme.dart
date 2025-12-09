import 'package:flutter/material.dart';

import '../design/design_system.dart';

/// 앱 테마 설정
/// 
/// S 1.1.5에서 디자인 시스템으로 확장 완료
class AppTheme {
  AppTheme._();

  /// 아동 친화적 느린 애니메이션 지속 시간 (1.5배 느리게)
  /// PRD 요구사항: "애니메이션과 전환 속도는 일반 앱보다 1.5배 느리게"
  static const Duration slowAnimationDuration = Duration(milliseconds: 300);
  static const Duration normalAnimationDuration = Duration(milliseconds: 200);
  
  // 1.5배 느린 애니메이션: 200ms * 1.5 = 300ms
  static const double animationSlowdownFactor = 1.5;

  /// 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignSystem.primaryBlue,
        brightness: Brightness.light,
        primary: DesignSystem.primaryBlue,
        secondary: DesignSystem.childFriendlyGreen,
        error: DesignSystem.childFriendlyRed,
      ),
      
      // 타이포그래피
      textTheme: const TextTheme(
        displayLarge: DesignSystem.textStyleLarge,
        displayMedium: DesignSystem.textStyleMedium,
        bodyLarge: DesignSystem.textStyleRegular,
        bodyMedium: DesignSystem.textStyleRegular,
        bodySmall: DesignSystem.textStyleSmall,
      ),
      
      // 아동 친화적 느린 애니메이션 (1.5배 느리게)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // 기본 애니메이션 지속 시간을 1.5배로 조정
      extensions: const <ThemeExtension<dynamic>>[
        _SlowAnimationTheme(
          duration: slowAnimationDuration,
          factor: animationSlowdownFactor,
        ),
      ],
    );
  }

  /// 다크 테마 (향후 추가)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2),
        brightness: Brightness.dark,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        _SlowAnimationTheme(
          duration: slowAnimationDuration,
          factor: animationSlowdownFactor,
        ),
      ],
    );
  }
}

/// 느린 애니메이션 테마 확장
/// 아동 친화적 UX를 위한 1.5배 느린 애니메이션 설정
class _SlowAnimationTheme extends ThemeExtension<_SlowAnimationTheme> {
  final Duration duration;
  final double factor;

  const _SlowAnimationTheme({
    required this.duration,
    required this.factor,
  });

  @override
  ThemeExtension<_SlowAnimationTheme> copyWith({
    Duration? duration,
    double? factor,
  }) {
    return _SlowAnimationTheme(
      duration: duration ?? this.duration,
      factor: factor ?? this.factor,
    );
  }

  @override
  ThemeExtension<_SlowAnimationTheme> lerp(
    ThemeExtension<_SlowAnimationTheme>? other,
    double t,
  ) {
    if (other is! _SlowAnimationTheme) {
      return this;
    }
    return _SlowAnimationTheme(
      duration: Duration(
        milliseconds: (duration.inMilliseconds +
                (other.duration.inMilliseconds - duration.inMilliseconds) * t)
            .round(),
      ),
      factor: factor + (other.factor - factor) * t,
    );
  }
}

