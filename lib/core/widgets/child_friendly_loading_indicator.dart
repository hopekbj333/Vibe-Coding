import 'package:flutter/material.dart';

import '../design/design_system.dart';

/// 아동 친화적 로딩 인디케이터
/// 
/// **특징:**
/// - 큰 크기
/// - 명확한 시각적 피드백
/// - 느린 애니메이션 (1.5배 느리게)
/// - 캐릭터 애니메이션 (선택적)
/// 
/// **사용 예시:**
/// - 에셋 로딩 중
/// - 검사 데이터 로딩 중
/// - 네트워크 요청 중
class ChildFriendlyLoadingIndicator extends StatefulWidget {
  /// 로딩 메시지
  final String? message;

  /// 캐릭터 애니메이션 사용 여부
  final bool showCharacterAnimation;

  /// 크기
  final LoadingIndicatorSize size;

  const ChildFriendlyLoadingIndicator({
    super.key,
    this.message,
    this.showCharacterAnimation = true,
    this.size = LoadingIndicatorSize.large,
  });

  @override
  State<ChildFriendlyLoadingIndicator> createState() =>
      _ChildFriendlyLoadingIndicatorState();
}

class _ChildFriendlyLoadingIndicatorState
    extends State<ChildFriendlyLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // 아동 친화적 느린 애니메이션
    _controller = AnimationController(
      duration: DesignSystem.slowAnimationDuration * 2, // 더 느리게
      vsync: this,
    )..repeat();

    // _rotationAnimation은 현재 사용되지 않으므로 제거

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getIndicatorSize() {
    switch (widget.size) {
      case LoadingIndicatorSize.small:
        return DesignSystem.iconSizeMD;
      case LoadingIndicatorSize.medium:
        return DesignSystem.iconSizeLG;
      case LoadingIndicatorSize.large:
        return DesignSystem.iconSizeXL;
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicatorSize = _getIndicatorSize();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showCharacterAnimation)
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _bounceAnimation.value) * 10, // 위아래로 움직임
                  ),
                  child: Icon(
                    Icons.child_care,
                    size: indicatorSize,
                    color: DesignSystem.primaryBlue,
                  ),
                );
              },
            )
          else
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: const CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignSystem.primaryBlue,
                ),
              ),
            ),
          if (widget.message != null) ...[
            const SizedBox(height: DesignSystem.spacingLG),
            Text(
              widget.message!,
              style: DesignSystem.textStyleRegular,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 로딩 인디케이터 크기
enum LoadingIndicatorSize {
  /// 작은 크기
  small,

  /// 중간 크기
  medium,

  /// 큰 크기 (아동 모드용, 기본값)
  large,
}

/// 전체 화면 로딩 오버레이
class ChildFriendlyLoadingOverlay extends StatelessWidget {
  /// 로딩 메시지
  final String? message;

  /// 캐릭터 애니메이션 사용 여부
  final bool showCharacterAnimation;

  const ChildFriendlyLoadingOverlay({
    super.key,
    this.message,
    this.showCharacterAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.9),
      child: ChildFriendlyLoadingIndicator(
        message: message ?? '준비 중이에요...',
        showCharacterAnimation: showCharacterAnimation,
      ),
    );
  }
}

