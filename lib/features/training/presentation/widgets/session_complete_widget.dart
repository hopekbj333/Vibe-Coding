import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/learning_session_model.dart';

/// 학습 종료 위젯
/// 
/// 세션 종료 시 결과 요약을 표시
class SessionCompleteWidget extends StatefulWidget {
  final LearningSession session;
  final VoidCallback? onClose;

  const SessionCompleteWidget({
    super.key,
    required this.session,
    this.onClose,
  });

  @override
  State<SessionCompleteWidget> createState() => _SessionCompleteWidgetState();
}

class _SessionCompleteWidgetState extends State<SessionCompleteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
    final accuracy = widget.session.accuracy * 100;
    final isTimeUp = widget.session.status == SessionStatus.timeUp;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 캐릭터 이모지
                  _buildCharacterAnimation(),

                  const SizedBox(height: 16),

                  // 메시지
                  Text(
                    isTimeUp ? '오늘은 여기까지!' : '잘했어요!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isTimeUp ? '내일 또 만나요! 👋' : '오늘도 열심히 했어요!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 통계
                  _buildStats(accuracy),

                  const SizedBox(height: 24),

                  // 스탬프/별
                  _buildReward(),

                  const SizedBox(height: 24),

                  // 닫기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -10 * (1 - value)),
          child: const Text(
            '🎉',
            style: TextStyle(fontSize: 80),
          ),
        );
      },
    );
  }

  Widget _buildStats(double accuracy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle_outline,
            label: '완료 문제',
            value: '${widget.session.questionsCompleted}개',
            color: DesignSystem.childFriendlyBlue,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _buildStatItem(
            icon: Icons.star_outline,
            label: '정답률',
            value: '${accuracy.toStringAsFixed(0)}%',
            color: _getAccuracyColor(accuracy),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _buildStatItem(
            icon: Icons.timer_outlined,
            label: '학습 시간',
            value: _formatDuration(widget.session.elapsedSeconds),
            color: DesignSystem.childFriendlyPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildReward() {
    final stars = _calculateStars(widget.session.accuracy);

    return Column(
      children: [
        const Text(
          '오늘의 보상',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < stars;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isEarned ? 1 : 0.3),
              duration: Duration(milliseconds: 300 + (index * 200)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: isEarned ? value : 0.8,
                    child: Icon(
                      Icons.star,
                      size: 48,
                      color: isEarned
                          ? DesignSystem.childFriendlyYellow
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  int _calculateStars(double accuracy) {
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.7) return 2;
    if (accuracy >= 0.5) return 1;
    return 0;
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return DesignSystem.semanticSuccess;
    if (accuracy >= 50) return DesignSystem.semanticWarning;
    return DesignSystem.semanticError;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes분 $secs초';
    }
    return '$secs초';
  }
}

