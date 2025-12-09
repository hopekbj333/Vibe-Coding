import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/design/design_system.dart';
import '../../../../core/widgets/character_widget.dart';
import '../../data/services/asset_loader_service.dart';

/// 피드백 타입
enum FeedbackType {
  correct,      // 정답
  incorrect,    // 오답
  encouragement,// 격려
  levelUp,      // 레벨업
}

/// 인터랙티브 피드백 위젯
/// 
/// 아이가 답변할 때마다 즉각적인 시각/청각 피드백을 제공합니다.
/// Milestone 2 - WP 2.1 (S 2.1.5)
class FeedbackWidget extends StatefulWidget {
  final FeedbackType type;
  final String? message;
  final VoidCallback? onComplete;
  final Duration duration;

  const FeedbackWidget({
    super.key,
    required this.type,
    this.message,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // 스케일 애니메이션 (탄성 효과)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 50,
      ),
    ]).animate(_controller);

    // 페이드 애니메이션
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_controller);

    // 효과음 재생
    _playSound();

    // 애니메이션 시작
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 효과음 재생
  void _playSound() {
    final assetLoader = AssetLoaderService();
    switch (widget.type) {
      case FeedbackType.correct:
        assetLoader.playSound('audio/correct.mp3');
        break;
      case FeedbackType.incorrect:
        assetLoader.playSound('audio/incorrect.mp3');
        break;
      case FeedbackType.encouragement:
        assetLoader.playSound('audio/encouragement.mp3');
        break;
      case FeedbackType.levelUp:
        assetLoader.playSound('audio/level_up.mp3');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _getBackgroundColor().withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아이콘/애니메이션
                    _buildIcon(),
                    const SizedBox(height: 16),
                    // 메시지
                    if (widget.message != null)
                      Text(
                        widget.message!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case FeedbackType.correct:
        return DesignSystem.semanticSuccess;
      case FeedbackType.incorrect:
        return DesignSystem.semanticError;
      case FeedbackType.encouragement:
        return DesignSystem.semanticInfo;
      case FeedbackType.levelUp:
        return DesignSystem.semanticWarning;
    }
  }

  Widget _buildIcon() {
    switch (widget.type) {
      case FeedbackType.correct:
        return _StarBurstAnimation(
          child: const CharacterWidget(
            emotion: CharacterEmotion.happy,
            size: 150,
            animate: false, // 외부 애니메이션 사용
          ),
        );
      case FeedbackType.incorrect:
        return _ShakeAnimation(
          controller: _controller,
          child: const CharacterWidget(
            emotion: CharacterEmotion.sad,
            size: 150,
            animate: false, // 외부 애니메이션 사용
          ),
        );
      case FeedbackType.encouragement:
        return const CharacterWidget(
          emotion: CharacterEmotion.neutral,
          size: 150,
          animate: false,
        );
      case FeedbackType.levelUp:
        return _LevelUpAnimation(
          child: const CharacterWidget(
            emotion: CharacterEmotion.excited,
            size: 180,
            animate: false,
          ),
        );
    }
  }
}

/// 별 터지는 애니메이션
class _StarBurstAnimation extends StatelessWidget {
  final Widget child;

  const _StarBurstAnimation({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 별들
        for (int i = 0; i < 8; i++)
          _FloatingStar(
            angle: i * math.pi / 4,
            delay: i * 50,
          ),
        // 중앙 아이콘
        child,
      ],
    );
  }
}

/// 떠다니는 별
class _FloatingStar extends StatefulWidget {
  final double angle;
  final int delay;

  const _FloatingStar({
    required this.angle,
    required this.delay,
  });

  @override
  State<_FloatingStar> createState() => _FloatingStarState();
}

class _FloatingStarState extends State<_FloatingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _moveAnimation = Tween<double>(begin: 0, end: 60)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dx = math.cos(widget.angle) * _moveAnimation.value;
        final dy = math.sin(widget.angle) * _moveAnimation.value;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: const Text(
              '⭐',
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }
}

/// 흔들리는 애니메이션
class _ShakeAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  const _ShakeAnimation({
    required this.controller,
    required this.child,
  });

  @override
  State<_ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<_ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _shakeController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 레벨업 애니메이션 (회전하는 별들 + 캐릭터)
class _LevelUpAnimation extends StatefulWidget {
  final Widget child;

  const _LevelUpAnimation({required this.child});

  @override
  State<_LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<_LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 회전하는 별들 (배경)
            Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: const Text(
                '⭐⭐⭐',
                style: TextStyle(fontSize: 80),
              ),
            ),
            // 캐릭터 (중앙)
            widget.child,
          ],
        );
      },
    );
  }
}

/// 피드백 메시지 헬퍼
class FeedbackMessages {
  static final _correctMessages = [
    '잘했어요! 👏',
    '정답이에요! 🎉',
    '멋져요! ⭐',
    '훌륭해요! 💯',
    '완벽해요! ✨',
  ];

  static final _incorrectMessages = [
    '다시 해볼까요? 💪',
    '괜찮아요! 한번 더! 🌈',
    '조금만 더 생각해봐요! 🤔',
    '힘내요! 💖',
  ];

  static final _encouragementMessages = [
    '잘하고 있어요! 😊',
    '포기하지 마세요! 🌟',
    '계속 해봐요! 🚀',
    '할 수 있어요! 💪',
  ];

  static String getRandomCorrectMessage() {
    return _correctMessages[math.Random().nextInt(_correctMessages.length)];
  }

  static String getRandomIncorrectMessage() {
    return _incorrectMessages[math.Random().nextInt(_incorrectMessages.length)];
  }

  static String getRandomEncouragementMessage() {
    return _encouragementMessages[
        math.Random().nextInt(_encouragementMessages.length)];
  }
}

