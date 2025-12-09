import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// 디자인 시스템
/// 
/// 앱 전체에서 사용할 일관된 디자인 토큰을 정의합니다.
/// 
/// **목적:**
/// - 아동 친화적 UX (큰 버튼, 명확한 색상, 느린 애니메이션)
/// - Zero-Text Interface 지원 (이미지/아이콘 중심)
/// - Cognitive Ease (화면당 하나의 정보, 명확한 시각적 구분)
class DesignSystem {
  DesignSystem._();

  // ==================== 컬러 시스템 ====================

  /// 기본 컬러 팔레트
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryGreen = Color(0xFF52C41A);
  static const Color primaryRed = Color(0xFFF5222D);
  static const Color primaryOrange = Color(0xFFFA8C16);
  static const Color primaryYellow = Color(0xFFFADB14);

  /// 중성 컬러
  static const Color neutralGray50 = Color(0xFFFAFAFA);
  static const Color neutralGray100 = Color(0xFFF5F5F5);
  static const Color neutralGray200 = Color(0xFFE8E8E8);
  static const Color neutralGray300 = Color(0xFFD9D9D9);
  static const Color neutralGray400 = Color(0xFFBFBFBF);
  static const Color neutralGray500 = Color(0xFF8C8C8C);
  static const Color neutralGray600 = Color(0xFF595959);
  static const Color neutralGray700 = Color(0xFF434343);
  static const Color neutralGray800 = Color(0xFF262626);
  static const Color neutralGray900 = Color(0xFF1F1F1F);

  /// 의미론적 컬러
  static const Color semanticSuccess = primaryGreen;
  static const Color semanticError = primaryRed;
  static const Color semanticWarning = primaryOrange;
  static const Color semanticInfo = primaryBlue;

  /// 아동 친화적 컬러 (밝고 명확한 색상)
  static const Color childFriendlyBlue = Color(0xFF1890FF);
  static const Color childFriendlyGreen = Color(0xFF52C41A);
  static const Color childFriendlyRed = Color(0xFFFF4D4F);
  static const Color childFriendlyYellow = Color(0xFFFFC53D);
  static const Color childFriendlyPurple = Color(0xFF9254DE);

  // ==================== 타이포그래피 ====================

  /// 텍스트 스타일 (아동 모드에서는 최소한만 사용)
  static const TextStyle textStyleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle textStyleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.3,
  );

  static const TextStyle textStyleRegular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const TextStyle textStyleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// 부모 모드용 텍스트 스타일 (더 많은 정보 표시)
  static const TextStyle parentTextStyleTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle parentTextStyleBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // ==================== 스페이싱 ====================

  /// 간격 시스템 (8px 기준)
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// 패딩 시스템
  static const EdgeInsets paddingXS = EdgeInsets.all(4.0);
  static const EdgeInsets paddingSM = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMD = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLG = EdgeInsets.all(24.0);
  static const EdgeInsets paddingXL = EdgeInsets.all(32.0);

  /// 버튼 패딩 (아동 친화적 큰 버튼)
  static const EdgeInsets buttonPaddingChild = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 20.0,
  );

  static const EdgeInsets buttonPaddingParent = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );

  // ==================== 크기 시스템 ====================

  /// 아이콘 크기
  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 24.0;
  static const double iconSizeMD = 32.0;
  static const double iconSizeLG = 48.0;
  static const double iconSizeXL = 64.0;
  static const double iconSizeXXL = 96.0;

  /// 버튼 크기 (아동 친화적 큰 버튼)
  static const double buttonHeightChild = 72.0; // 최소 터치 영역 48px보다 큼
  static const double buttonHeightParent = 56.0;
  static const double buttonMinWidth = 120.0;

  /// 이미지 크기
  static const double imageSizeSmall = 64.0;
  static const double imageSizeMedium = 128.0;
  static const double imageSizeLarge = 256.0;

  // ==================== 보더 및 라운드 ====================

  /// 보더 반경
  static const double borderRadiusXS = 4.0;
  static const double borderRadiusSM = 8.0;
  static const double borderRadiusMD = 12.0;
  static const double borderRadiusLG = 16.0;
  static const double borderRadiusXL = 24.0;
  static const double borderRadiusRound = 999.0; // 완전히 둥근 모서리

  /// 보더 두께
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 4.0;

  // ==================== 그림자 ====================

  /// 그림자 시스템
  static const List<BoxShadow> shadowSmall = [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ];

  static const List<BoxShadow> shadowMedium = [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ];

  static const List<BoxShadow> shadowLarge = [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ];

  // ==================== 애니메이션 ====================

  /// 아동 친화적 느린 애니메이션 지속 시간 (1.5배 느리게)
  static Duration get slowAnimationDuration =>
      const Duration(milliseconds: AppConstants.slowAnimationDurationMs);

  static Duration get normalAnimationDuration =>
      const Duration(milliseconds: AppConstants.normalAnimationDurationMs);

  /// 애니메이션 커브
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  // ==================== 오퍼시티 ====================

  static const double opacityDisabled = 0.4;
  static const double opacityHover = 0.8;
  static const double opacityPressed = 0.6;
  static const double opacityOverlay = 0.5;

  // ==================== Z-Index ====================

  static const int zIndexBase = 0;
  static const int zIndexElevated = 10;
  static const int zIndexOverlay = 100;
  static const int zIndexModal = 1000;
}

