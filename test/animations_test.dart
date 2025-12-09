import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_assessment/core/animations/slow_animations.dart';
import 'package:literacy_assessment/core/constants/app_constants.dart';

void main() {
  group('SlowAnimations', () {
    test('애니메이션 지속 시간이 1.5배인지 확인', () {
      expect(SlowAnimations.duration.inMilliseconds, 300);
      expect(SlowAnimations.factor, 1.5);
    });

    test('일반 애니메이션을 느린 애니메이션으로 변환', () {
      const normalDuration = Duration(milliseconds: 200);
      final slowDuration = SlowAnimations.slow(normalDuration);
      expect(slowDuration.inMilliseconds, 300); // 200 * 1.5
    });

    test('커스텀 지속 시간 변환', () {
      const customDuration = Duration(milliseconds: 100);
      final slowDuration = SlowAnimations.slow(customDuration);
      expect(slowDuration.inMilliseconds, 150); // 100 * 1.5
    });
  });

  group('AppConstants', () {
    test('상수 값이 올바른지 확인', () {
      expect(AppConstants.slowAnimationDurationMs, 300);
      expect(AppConstants.normalAnimationDurationMs, 200);
      expect(AppConstants.animationSlowdownFactor, 1.5);
      expect(AppConstants.thinkTimeDelay.inSeconds, 1);
      expect(AppConstants.splashMinDuration.inSeconds, 1);
    });
  });
}

