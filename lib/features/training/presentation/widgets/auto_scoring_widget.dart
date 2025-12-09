import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/stt_result_model.dart';

/// 자동 채점 결과 위젯
/// 
/// STT 기반 자동 채점 결과를 표시하고 확인/수정 옵션 제공
class AutoScoringWidget extends StatelessWidget {
  final AutoScoringResult result;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onManualScore;

  const AutoScoringWidget({
    super.key,
    required this.result,
    this.onPlayAudio,
    this.onConfirm,
    this.onReject,
    this.onManualScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              _buildDecisionIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDecisionText(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getDecisionColor(),
                      ),
                    ),
                    Text(
                      result.reason ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 정답 비교
          _buildComparisonSection(),

          const SizedBox(height: 16),

          // 신뢰도 표시
          _buildConfidenceBar(),

          const SizedBox(height: 20),

          // 액션 버튼들
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDecisionIcon() {
    IconData icon;
    Color color;

    switch (result.decision) {
      case AutoScoringDecision.autoCorrect:
        icon = Icons.check_circle;
        color = DesignSystem.semanticSuccess;
        break;
      case AutoScoringDecision.autoIncorrect:
        icon = Icons.cancel;
        color = DesignSystem.semanticError;
        break;
      case AutoScoringDecision.manualReview:
        icon = Icons.help_outline;
        color = DesignSystem.semanticWarning;
        break;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  String _getDecisionText() {
    switch (result.decision) {
      case AutoScoringDecision.autoCorrect:
        return '✅ 자동 정답 처리';
      case AutoScoringDecision.autoIncorrect:
        return '❌ 자동 오답 처리';
      case AutoScoringDecision.manualReview:
        return '⚠️ 수동 확인 필요';
    }
  }

  Color _getDecisionColor() {
    switch (result.decision) {
      case AutoScoringDecision.autoCorrect:
        return DesignSystem.semanticSuccess;
      case AutoScoringDecision.autoIncorrect:
        return DesignSystem.semanticError;
      case AutoScoringDecision.manualReview:
        return DesignSystem.semanticWarning;
    }
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 정답
          Expanded(
            child: _buildComparisonItem(
              label: '정답',
              value: result.expectedAnswer,
              color: DesignSystem.semanticSuccess,
            ),
          ),
          
          // 비교 화살표
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              result.isMatch ? Icons.check : Icons.close,
              color: result.isMatch
                  ? DesignSystem.semanticSuccess
                  : DesignSystem.semanticError,
              size: 28,
            ),
          ),

          // 인식 결과
          Expanded(
            child: _buildComparisonItem(
              label: 'STT 인식',
              value: result.sttResult.transcript,
              color: result.isMatch
                  ? DesignSystem.semanticSuccess
                  : DesignSystem.semanticError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBar() {
    final confidence = result.sttResult.confidence;
    final matchScore = result.matchScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '신뢰도',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getConfidenceColor(confidence),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getConfidenceColor(confidence),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '일치율',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(matchScore * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getConfidenceColor(matchScore),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: matchScore,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getConfidenceColor(matchScore),
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double value) {
    if (value >= 0.85) return DesignSystem.semanticSuccess;
    if (value >= 0.7) return DesignSystem.semanticWarning;
    return DesignSystem.semanticError;
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 재생 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPlayAudio,
            icon: const Icon(Icons.play_arrow),
            label: const Text('재생'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 확정/수정 버튼
        if (result.decision == AutoScoringDecision.manualReview) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check),
              label: const Text('정답'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.semanticSuccess,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close),
              label: const Text('오답'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.semanticError,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onManualScore,
              icon: const Icon(Icons.edit),
              label: const Text('수정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 간소화된 채점 확인 위젯 (빠른 확정용)
class QuickScoringWidget extends StatelessWidget {
  final String expectedAnswer;
  final SttResult sttResult;
  final VoidCallback? onConfirmCorrect;
  final VoidCallback? onConfirmIncorrect;
  final VoidCallback? onPlayAudio;

  const QuickScoringWidget({
    super.key,
    required this.expectedAnswer,
    required this.sttResult,
    this.onConfirmCorrect,
    this.onConfirmIncorrect,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final isMatch = sttResult.transcript.trim().toLowerCase() ==
        expectedAnswer.trim().toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMatch
            ? DesignSystem.semanticSuccess.withOpacity(0.1)
            : DesignSystem.semanticWarning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatch
              ? DesignSystem.semanticSuccess.withOpacity(0.3)
              : DesignSystem.semanticWarning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // STT 결과
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'STT: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      sttResult.transcript,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(sttResult.confidence),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${sttResult.confidencePercent}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isMatch)
                  Text(
                    '정답: $expectedAnswer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // 재생 버튼
          IconButton(
            onPressed: onPlayAudio,
            icon: const Icon(Icons.volume_up),
            color: Colors.grey.shade600,
          ),

          // 빠른 확인 버튼들
          Row(
            children: [
              _QuickButton(
                icon: Icons.check,
                color: DesignSystem.semanticSuccess,
                onPressed: onConfirmCorrect,
              ),
              const SizedBox(width: 8),
              _QuickButton(
                icon: Icons.close,
                color: DesignSystem.semanticError,
                onPressed: onConfirmIncorrect,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return DesignSystem.semanticSuccess;
    if (confidence >= 0.7) return DesignSystem.semanticWarning;
    return DesignSystem.semanticError;
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _QuickButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

