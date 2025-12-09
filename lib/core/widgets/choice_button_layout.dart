import 'package:flutter/material.dart';

import '../design/design_system.dart';
import 'child_friendly_button.dart';

/// 선택 버튼 레이아웃 유틸리티
/// 
/// 이선다지(N지선다) 패턴을 위한 버튼 배치를 제공합니다.
/// 
/// **S 2.2.2 요구사항:**
/// - 2개: 좌우 배치
/// - 3개: 삼각형 배치
/// - 4개: 2x2 그리드 배치
/// 
/// **사용 예시:**
/// - 그림 찾기
/// - 소리와 그림 매칭
class ChoiceButtonLayout extends StatelessWidget {
  /// 선택지 버튼 목록
  final List<Widget> buttons;

  /// 선택지 개수에 따른 자동 레이아웃
  const ChoiceButtonLayout({
    super.key,
    required this.buttons,
  }) : assert(buttons.length >= 2 && buttons.length <= 4,
          '선택지는 2~4개여야 합니다.');

  @override
  Widget build(BuildContext context) {
    switch (buttons.length) {
      case 2:
        return _buildTwoChoiceLayout();
      case 3:
        return _buildThreeChoiceLayout();
      case 4:
        return _buildFourChoiceLayout();
      default:
        return _buildTwoChoiceLayout();
    }
  }

  /// 2개 선택지: 좌우 배치
  Widget _buildTwoChoiceLayout() {
    return Row(
      children: [
        Expanded(child: buttons[0]),
        const SizedBox(width: DesignSystem.spacingMD),
        Expanded(child: buttons[1]),
      ],
    );
  }

  /// 3개 선택지: 삼각형 배치
  /// 
  /// 상단에 1개, 하단에 2개
  Widget _buildThreeChoiceLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상단 버튼
        SizedBox(
          width: double.infinity,
          child: buttons[0],
        ),
        const SizedBox(height: DesignSystem.spacingMD),
        // 하단 버튼 2개
        Row(
          children: [
            Expanded(child: buttons[1]),
            const SizedBox(width: DesignSystem.spacingMD),
            Expanded(child: buttons[2]),
          ],
        ),
      ],
    );
  }

  /// 4개 선택지: 2x2 그리드 배치
  Widget _buildFourChoiceLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상단 2개
        Row(
          children: [
            Expanded(child: buttons[0]),
            const SizedBox(width: DesignSystem.spacingMD),
            Expanded(child: buttons[1]),
          ],
        ),
        const SizedBox(height: DesignSystem.spacingMD),
        // 하단 2개
        Row(
          children: [
            Expanded(child: buttons[2]),
            const SizedBox(width: DesignSystem.spacingMD),
            Expanded(child: buttons[3]),
          ],
        ),
      ],
    );
  }
}

/// O/X 버튼 레이아웃
/// 
/// **S 2.2.1 요구사항:**
/// - 큰 버튼
/// - 명확한 색상 구분 (초록/빨강)
class OXButtonLayout extends StatelessWidget {
  /// O 버튼 콜백
  final VoidCallback? onO;

  /// X 버튼 콜백
  final VoidCallback? onX;

  /// O 버튼 이미지 (선택적)
  final Widget? oImage;

  /// X 버튼 이미지 (선택적)
  final Widget? xImage;

  /// 비활성화 여부
  final bool enabled;

  const OXButtonLayout({
    super.key,
    required this.onO,
    required this.onX,
    this.oImage,
    this.xImage,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChildFriendlyButton(
            label: 'O',
            icon: Icons.check_circle,
            image: oImage,
            type: ChildButtonType.success,
            onPressed: enabled ? onO : null,
            size: ChildButtonSize.large,
          ),
        ),
        const SizedBox(width: DesignSystem.spacingLG),
        Expanded(
          child: ChildFriendlyButton(
            label: 'X',
            icon: Icons.cancel,
            image: xImage,
            type: ChildButtonType.error,
            onPressed: enabled ? onX : null,
            size: ChildButtonSize.large,
          ),
        ),
      ],
    );
  }
}

