import 'package:flutter/material.dart';

import '../design/design_system.dart';

/// 아동 친화적 버튼
/// 
/// **특징:**
/// - 큰 터치 영역 (최소 72px 높이)
/// - 명확한 색상 구분
/// - 느린 애니메이션 (1.5배 느리게)
/// - 이미지/아이콘 중심 (Zero-Text Interface)
/// 
/// **사용 예시:**
/// - O/X 버튼 (S 2.2.1)
/// - 이선다지 선택 버튼 (S 2.2.2)
/// - 확인/취소 버튼
class ChildFriendlyButton extends StatefulWidget {
  /// 버튼 텍스트 (부모 모드용, 아동 모드에서는 최소한만 사용)
  final String? label;

  /// 아이콘 (아동 모드에서 주로 사용)
  final IconData? icon;

  /// 이미지 (아동 모드에서 주로 사용)
  final Widget? image;

  /// 버튼 색상
  final Color? color;

  /// 버튼 타입
  final ChildButtonType type;

  /// 클릭 콜백
  final VoidCallback? onPressed;

  /// 비활성화 여부
  final bool enabled;

  /// 전체 너비 사용 여부
  final bool fullWidth;

  /// 크기
  final ChildButtonSize size;

  const ChildFriendlyButton({
    super.key,
    this.label,
    this.icon,
    this.image,
    this.color,
    this.type = ChildButtonType.primary,
    this.onPressed,
    this.enabled = true,
    this.fullWidth = false,
    this.size = ChildButtonSize.large,
  }) : assert(
          label != null || icon != null || image != null,
          'label, icon, 또는 image 중 하나는 필수입니다.',
        );

  @override
  State<ChildFriendlyButton> createState() => _ChildFriendlyButtonState();
}

class _ChildFriendlyButtonState extends State<ChildFriendlyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 아동 친화적 느린 애니메이션
    _controller = AnimationController(
      duration: DesignSystem.slowAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignSystem.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      // 즉각적인 시각적 피드백 (S 1.3.4 요구사항)
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      // 느린 복귀 애니메이션 (아동 친화적)
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  Color _getButtonColor() {
    if (widget.color != null) {
      return widget.color!;
    }

    switch (widget.type) {
      case ChildButtonType.primary:
        return DesignSystem.primaryBlue;
      case ChildButtonType.success:
        return DesignSystem.childFriendlyGreen;
      case ChildButtonType.error:
        return DesignSystem.childFriendlyRed;
      case ChildButtonType.warning:
        return DesignSystem.childFriendlyYellow;
      case ChildButtonType.neutral:
        return DesignSystem.neutralGray400;
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ChildButtonSize.small:
        return DesignSystem.buttonHeightParent;
      case ChildButtonSize.medium:
        return 64.0;
      case ChildButtonSize.large:
        return DesignSystem.buttonHeightChild;
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ChildButtonSize.small:
        return DesignSystem.buttonPaddingParent;
      case ChildButtonSize.medium:
      case ChildButtonSize.large:
        return DesignSystem.buttonPaddingChild;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = _getButtonColor();
    final buttonHeight = _getButtonHeight();
    final buttonPadding = _getButtonPadding();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: buttonHeight,
              constraints: const BoxConstraints(
                minWidth: DesignSystem.buttonMinWidth,
              ),
              padding: buttonPadding,
              decoration: BoxDecoration(
                color: widget.enabled
                    ? buttonColor
                    : buttonColor.withValues(alpha: DesignSystem.opacityDisabled),
                borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                boxShadow: widget.enabled ? DesignSystem.shadowMedium : null,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.image != null) ...[
                      // 이미지 버튼: 적절한 크기로 제한 (Zero-Text Interface)
                      SizedBox(
                        width: DesignSystem.iconSizeLG,
                        height: DesignSystem.iconSizeLG,
                        child: widget.image!,
                      ),
                      if (widget.label != null || widget.icon != null)
                        const SizedBox(width: DesignSystem.spacingSM),
                    ],
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: DesignSystem.iconSizeMD,
                      ),
                      if (widget.label != null)
                        const SizedBox(width: DesignSystem.spacingSM),
                    ],
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: DesignSystem.textStyleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 버튼 타입
enum ChildButtonType {
  /// 기본 (파란색)
  primary,

  /// 성공 (초록색)
  success,

  /// 오류 (빨간색)
  error,

  /// 경고 (노란색)
  warning,

  /// 중성 (회색)
  neutral,
}

/// 버튼 크기
enum ChildButtonSize {
  /// 작은 버튼 (부모 모드용)
  small,

  /// 중간 버튼
  medium,

  /// 큰 버튼 (아동 모드용, 기본값)
  large,
}

