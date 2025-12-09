import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:literacy_assessment/core/design/design_system.dart';

void main() {
  group('DesignSystem 테스트', () {
    test('컬러 상수가 올바르게 정의되어야 함', () {
      expect(DesignSystem.primaryBlue, isA<Color>());
      expect(DesignSystem.primaryGreen, isA<Color>());
      expect(DesignSystem.primaryRed, isA<Color>());
      expect(DesignSystem.childFriendlyBlue, isA<Color>());
    });

    test('스페이싱 상수가 올바르게 정의되어야 함', () {
      expect(DesignSystem.spacingXS, 4.0);
      expect(DesignSystem.spacingSM, 8.0);
      expect(DesignSystem.spacingMD, 16.0);
      expect(DesignSystem.spacingLG, 24.0);
      expect(DesignSystem.spacingXL, 32.0);
    });

    test('버튼 크기 상수가 올바르게 정의되어야 함', () {
      expect(DesignSystem.buttonHeightChild, 72.0);
      expect(DesignSystem.buttonHeightParent, 56.0);
      expect(DesignSystem.buttonMinWidth, 120.0);
    });

    test('아이콘 크기 상수가 올바르게 정의되어야 함', () {
      expect(DesignSystem.iconSizeXS, 16.0);
      expect(DesignSystem.iconSizeSM, 24.0);
      expect(DesignSystem.iconSizeMD, 32.0);
      expect(DesignSystem.iconSizeLG, 48.0);
      expect(DesignSystem.iconSizeXL, 64.0);
    });

    test('보더 반경 상수가 올바르게 정의되어야 함', () {
      expect(DesignSystem.borderRadiusXS, 4.0);
      expect(DesignSystem.borderRadiusSM, 8.0);
      expect(DesignSystem.borderRadiusMD, 12.0);
      expect(DesignSystem.borderRadiusLG, 16.0);
      expect(DesignSystem.borderRadiusXL, 24.0);
    });

    test('애니메이션 지속 시간이 올바르게 정의되어야 함', () {
      expect(DesignSystem.slowAnimationDuration, isA<Duration>());
      expect(DesignSystem.normalAnimationDuration, isA<Duration>());
    });

    test('그림자가 올바르게 정의되어야 함', () {
      expect(DesignSystem.shadowSmall, isA<List<BoxShadow>>());
      expect(DesignSystem.shadowMedium, isA<List<BoxShadow>>());
      expect(DesignSystem.shadowLarge, isA<List<BoxShadow>>());
    });
  });
}

