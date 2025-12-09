import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/mini_test_model.dart';

/// 향상도 비교 위젯 (Before/After)
/// 
/// 막대 그래프로 이전 점수 vs 현재 점수 비교
class ProgressComparisonWidget extends StatefulWidget {
  final MiniTestResult result;
  final VoidCallback? onClose;

  const ProgressComparisonWidget({
    super.key,
    required this.result,
    this.onClose,
  });

  @override
  State<ProgressComparisonWidget> createState() => _ProgressComparisonWidgetState();
}

class _ProgressComparisonWidgetState extends State<ProgressComparisonWidget>
    with TickerProviderStateMixin {
  late AnimationController _barController;
  late AnimationController _celebrateController;
  late Animation<double> _previousBarAnimation;
  late Animation<double> _currentBarAnimation;
  late Animation<double> _improvementAnimation;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _previousBarAnimation = Tween<double>(
      begin: 0,
      end: widget.result.previousScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _barController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _currentBarAnimation = Tween<double>(
      begin: 0,
      end: widget.result.currentScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _barController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _improvementAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _barController,
      curve: const Interval(0.8, 1.0, curve: Curves.bounceOut),
    ));

    _barController.forward().then((_) {
      if (widget.result.hasImproved) {
        _celebrateController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.result.moduleName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.neutralGray800,
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // 막대 그래프
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _barController,
              builder: (context, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 이전 점수 막대
                  _buildBar(
                    label: '처음',
                    value: _previousBarAnimation.value,
                    grade: widget.result.previousGrade,
                    isHighlighted: false,
                  ),
                  const SizedBox(width: 60),
                  // 현재 점수 막대
                  _buildBar(
                    label: '지금',
                    value: _currentBarAnimation.value,
                    grade: widget.result.currentGrade,
                    isHighlighted: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 향상도 표시
          if (widget.result.hasImproved)
            AnimatedBuilder(
              animation: _improvementAnimation,
              builder: (context, child) => Opacity(
                opacity: _improvementAnimation.value,
                child: Transform.scale(
                  scale: 0.5 + (_improvementAnimation.value * 0.5),
                  child: _buildImprovementBadge(),
                ),
              ),
            )
          else
            _buildNoImprovementMessage(),

          const SizedBox(height: 24),

          // 통과 여부
          _buildPassStatus(),

          const SizedBox(height: 16),

          // 추천 메시지
          if (widget.result.recommendation != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.neutralGray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.result.recommendation!,
                style: const TextStyle(
                  fontSize: 16,
                  color: DesignSystem.neutralGray500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required ScoreGrade grade,
    required bool isHighlighted,
  }) {
    final color = _getGradeColor(grade);
    final maxHeight = 150.0;
    final barHeight = (value / 100) * maxHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 점수 라벨
        Text(
          '${value.round()}점',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        // 등급 이모지
        Text(
          _getGradeEmoji(grade),
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        // 막대
        Container(
          width: 60,
          height: barHeight,
          decoration: BoxDecoration(
            color: color.withOpacity(isHighlighted ? 1.0 : 0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        // 라벨
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: DesignSystem.neutralGray500,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementBadge() {
    return AnimatedBuilder(
      animation: _celebrateController,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3 + _celebrateController.value * 0.2),
              blurRadius: 10 + _celebrateController.value * 5,
              spreadRadius: _celebrateController.value * 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_upward, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              '+${widget.result.improvement}점 향상!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImprovementMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        widget.result.improvement == 0
            ? '점수 유지 중이에요!'
            : '다음엔 더 잘할 수 있어요!',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildPassStatus() {
    final isPassed = widget.result.isPassed;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isPassed ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPassed ? Colors.green.shade200 : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.schedule,
            color: isPassed ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            isPassed ? '통과! 🎉' : '조금 더 연습해요!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPassed ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(ScoreGrade grade) {
    switch (grade) {
      case ScoreGrade.green:
        return Colors.green;
      case ScoreGrade.yellow:
        return Colors.orange;
      case ScoreGrade.red:
        return Colors.red;
    }
  }

  String _getGradeEmoji(ScoreGrade grade) {
    switch (grade) {
      case ScoreGrade.green:
        return '🟢';
      case ScoreGrade.yellow:
        return '🟡';
      case ScoreGrade.red:
        return '🔴';
    }
  }
}

