import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/stt_result_model.dart';

/// 발음 피드백 위젯
/// 
/// 발음 정확도 점수와 개선 피드백을 표시
class PronunciationFeedbackWidget extends StatefulWidget {
  final PronunciationScore score;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  const PronunciationFeedbackWidget({
    super.key,
    required this.score,
    this.onRetry,
    this.onContinue,
  });

  @override
  State<PronunciationFeedbackWidget> createState() =>
      _PronunciationFeedbackWidgetState();
}

class _PronunciationFeedbackWidgetState
    extends State<PronunciationFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.score.overallScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGood = widget.score.isGood;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 이모지
          Text(
            isGood ? '🎉' : '💪',
            style: const TextStyle(fontSize: 48),
          ),

          const SizedBox(height: 12),

          // 메시지
          Text(
            isGood ? '잘했어요!' : '조금 더 연습해봐요!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // 전체 점수 (원형)
          _buildOverallScore(),

          const SizedBox(height: 24),

          // 세부 점수
          _buildDetailScores(),

          // 음소별 피드백
          if (widget.score.needsFeedbackPhonemes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPhonemesFeedback(),
          ],

          const SizedBox(height: 24),

          // 액션 버튼
          _buildActionButtons(isGood),
        ],
      ),
    );
  }

  Widget _buildOverallScore() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final score = _scoreAnimation.value.round();
        final color = _getScoreColor(score);

        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '점',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailScoreItem(
          label: '정확도',
          score: widget.score.accuracyScore,
          icon: Icons.check_circle_outline,
        ),
        _buildDetailScoreItem(
          label: '유창성',
          score: widget.score.fluencyScore,
          icon: Icons.waves,
        ),
        _buildDetailScoreItem(
          label: '완전성',
          score: widget.score.completenessScore,
          icon: Icons.done_all,
        ),
      ],
    );
  }

  Widget _buildDetailScoreItem({
    required String label,
    required int score,
    required IconData icon,
  }) {
    final color = _getScoreColor(score);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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

  Widget _buildPhonemesFeedback() {
    final feedbackPhonemes = widget.score.needsFeedbackPhonemes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.semanticWarning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignSystem.semanticWarning.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: DesignSystem.semanticWarning,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '연습 포인트',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...feedbackPhonemes.map((phoneme) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getScoreColor(phoneme.score).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        phoneme.phoneme,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(phoneme.score),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        phoneme.feedback ?? '조금 더 연습해봐요!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isGood) {
    return Row(
      children: [
        if (!isGood)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 해볼래요'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (!isGood) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onContinue,
            icon: Icon(isGood ? Icons.arrow_forward : Icons.skip_next),
            label: Text(isGood ? '다음으로' : '넘어갈게요'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isGood
                  ? DesignSystem.semanticSuccess
                  : DesignSystem.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DesignSystem.semanticSuccess;
    if (score >= 60) return DesignSystem.semanticWarning;
    return DesignSystem.semanticError;
  }
}

/// 간단한 발음 점수 뱃지
class PronunciationScoreBadge extends StatelessWidget {
  final int score;
  final bool showLabel;

  const PronunciationScoreBadge({
    super.key,
    required this.score,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            const Text(
              '발음',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$score점',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            score >= 70 ? Icons.thumb_up : Icons.thumb_down,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (score >= 80) return DesignSystem.semanticSuccess;
    if (score >= 60) return DesignSystem.semanticWarning;
    return DesignSystem.semanticError;
  }
}

/// 발음 연습 힌트 위젯
class PronunciationHintWidget extends StatelessWidget {
  final String phoneme;
  final String hint;

  const PronunciationHintWidget({
    super.key,
    required this.phoneme,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              phoneme,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 발음 팁',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

