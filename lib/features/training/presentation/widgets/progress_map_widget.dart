import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/learning_progress_model.dart';

/// 학습 진도 맵 위젯
/// 
/// 단계별 진도를 지도/여정 형태로 시각화
class ProgressMapWidget extends StatelessWidget {
  final LearningProgress progress;
  final void Function(String stageId)? onStageTap;

  const ProgressMapWidget({
    super.key,
    required this.progress,
    this.onStageTap,
  });

  @override
  Widget build(BuildContext context) {
    final stages = progress.stages.values.toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // 헤더
          Row(
            children: [
              const Text(
                '🗺️',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '학습 여정',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '진행률: ${(progress.overallProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 진도 맵
          Row(
            children: [
              for (int i = 0; i < stages.length; i++) ...[
                Expanded(child: _buildStageNode(stages[i], i)),
                if (i < stages.length - 1)
                  _buildPath(stages[i].isCompleted),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 전체 진행률 바
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildStageNode(StageProgress stage, int index) {
    final isUnlocked = stage.isUnlocked;
    final isCompleted = stage.isCompleted;
    final isCurrent = isUnlocked && !isCompleted;

    return GestureDetector(
      onTap: isUnlocked ? () => onStageTap?.call(stage.stageId) : null,
      child: Column(
        children: [
          // 스테이지 아이콘
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStageColor(isUnlocked, isCompleted, isCurrent),
              border: Border.all(
                color: isCurrent
                    ? DesignSystem.primaryBlue
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: DesignSystem.primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: _buildStageIcon(isUnlocked, isCompleted, isCurrent, index),
            ),
          ),

          const SizedBox(height: 8),

          // 스테이지 이름
          Text(
            '${index + 1}단계',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black : Colors.grey,
            ),
          ),

          // 상태 텍스트
          Text(
            _getStatusText(isUnlocked, isCompleted, isCurrent),
            style: TextStyle(
              fontSize: 10,
              color: _getStatusColor(isUnlocked, isCompleted),
            ),
          ),

          // 진행률 (현재 단계만)
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${(stage.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageIcon(bool isUnlocked, bool isCompleted, bool isCurrent, int index) {
    if (isCompleted) {
      return const Icon(Icons.check, color: Colors.white, size: 28);
    }
    if (!isUnlocked) {
      return const Icon(Icons.lock, color: Colors.white, size: 24);
    }
    if (isCurrent) {
      return const Text('👦', style: TextStyle(fontSize: 24));
    }
    return Text(
      '${index + 1}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Color _getStageColor(bool isUnlocked, bool isCompleted, bool isCurrent) {
    if (isCompleted) return DesignSystem.semanticSuccess;
    if (isCurrent) return Colors.white;
    if (!isUnlocked) return Colors.grey.shade400;
    return DesignSystem.childFriendlyBlue;
  }

  String _getStatusText(bool isUnlocked, bool isCompleted, bool isCurrent) {
    if (isCompleted) return '완료! ✓';
    if (isCurrent) return '진행 중';
    if (!isUnlocked) return '잠금 🔒';
    return '준비됨';
  }

  Color _getStatusColor(bool isUnlocked, bool isCompleted) {
    if (isCompleted) return DesignSystem.semanticSuccess;
    if (!isUnlocked) return Colors.grey;
    return Colors.black87;
  }

  Widget _buildPath(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isCompleted
              ? DesignSystem.semanticSuccess
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '전체 진행률',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress.overallProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: DesignSystem.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.overallProgress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              DesignSystem.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}

/// 잠금 해제 축하 다이얼로그
class UnlockCelebrationDialog extends StatefulWidget {
  final String stageName;
  final VoidCallback? onContinue;

  const UnlockCelebrationDialog({
    super.key,
    required this.stageName,
    this.onContinue,
  });

  @override
  State<UnlockCelebrationDialog> createState() => _UnlockCelebrationDialogState();
}

class _UnlockCelebrationDialogState extends State<UnlockCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 자물쇠 → 열림 애니메이션
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: const Text(
                    '🔓',
                    style: TextStyle(fontSize: 72),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          const Text(
            '새로운 모험이 열렸어요!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            '${widget.stageName}에 도전할 수 있어요!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // 축하 애니메이션 효과 (별 떨어지는 것 등)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 200 + (index * 100)),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * (1 - value)),
                      child: const Text('⭐', style: TextStyle(fontSize: 24)),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onContinue?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '좋아요!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

