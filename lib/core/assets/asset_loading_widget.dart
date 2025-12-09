import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'asset_manager.dart';
import 'asset_loading_providers.dart';

/// 에셋 로딩 인디케이터 위젯
/// 
/// 에셋 로딩 중일 때 표시되는 위젯입니다.
/// 아동 친화적인 디자인으로 지루하지 않은 애니메이션을 제공합니다.
class AssetLoadingIndicator extends ConsumerWidget {
  /// 로딩 메시지
  final String? message;

  /// 캐릭터 애니메이션 사용 여부
  final bool showCharacterAnimation;

  const AssetLoadingIndicator({
    super.key,
    this.message,
    this.showCharacterAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(assetLoadingStatusProvider);
    final progress = ref.watch(assetLoadingProgressProvider);

    if (status != AssetLoadingStatus.loading) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 캐릭터 애니메이션 (준비 운동하는 캐릭터)
          if (showCharacterAnimation)
            _CharacterAnimation(
              progress: progress,
            )
          else
            CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 4.0,
            ),
          
          const SizedBox(height: 24),
          
          // 진행률 표시
          if (progress > 0)
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 캐릭터 애니메이션 위젯
/// 
/// 아동 친화적인 캐릭터가 준비 운동을 하는 애니메이션
class _CharacterAnimation extends StatefulWidget {
  final double progress;

  const _CharacterAnimation({
    required this.progress,
  });

  @override
  State<_CharacterAnimation> createState() => _CharacterAnimationState();
}

class _CharacterAnimationState extends State<_CharacterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // 아동 친화적 느린 애니메이션 (1.5배 느리게)
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppConstants.slowAnimationDurationMs),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Column(
            children: [
              // 향후 캐릭터 이미지로 교체
              Icon(
                Icons.child_care,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              
              // 진행률 바
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 전체 화면 로딩 오버레이
/// 
/// 에셋 로딩 중 전체 화면을 덮는 오버레이
class AssetLoadingOverlay extends ConsumerWidget {
  final String? message;
  final bool showCharacterAnimation;

  const AssetLoadingOverlay({
    super.key,
    this.message,
    this.showCharacterAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(assetLoadingStatusProvider);

    if (status != AssetLoadingStatus.loading) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white.withValues(alpha: 0.9),
      child: AssetLoadingIndicator(
        message: message ?? '준비 중이에요...',
        showCharacterAnimation: showCharacterAnimation,
      ),
    );
  }
}

