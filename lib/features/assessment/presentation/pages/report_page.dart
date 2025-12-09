import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/scoring_model.dart';
import '../../domain/services/score_calculator.dart';
import '../providers/scoring_providers.dart';

/// S 1.8: 결과 리포트 화면
/// 
/// 검사 결과를 시각화하고 가이드를 제공합니다.
class ReportPage extends ConsumerWidget {
  final String resultId;

  const ReportPage({
    super.key,
    required this.resultId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(assessmentResultProvider(resultId));

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray50,
      appBar: AppBar(
        title: const Text('검사 결과 리포트'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: PDF 공유 기능 (S 1.8.12)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF 공유 기능 준비 중...')),
              );
            },
            tooltip: '공유',
          ),
        ],
      ),
      body: resultAsync.when(
        data: (result) {
          final domainScores = ScoreCalculator.calculateDomainScores(result.scores);
          final overallScore = ScoreCalculator.calculateOverallScore(result.scores);
          final reactionTimeData = ScoreCalculator.analyzeReactionTimes(result.scores);
          final riskFactors = ScoreCalculator.detectRiskFactors(domainScores);
          final recommendations = ScoreCalculator.generateRecommendations(domainScores);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // S 1.8.4: 전체 점수 및 신호등 판정
                _OverallScoreCard(
                  score: overallScore,
                  level: ScoreCalculator.determineReadinessLevel(overallScore),
                ),

                const SizedBox(height: 24),

                // S 1.8.6: 영역별 점수 (차트 대신 막대로 간소화)
                _DomainScoresCard(domainScores: domainScores),

                const SizedBox(height: 24),

                // S 1.8.8: 강점/약점 요약
                _StrengthWeaknessCard(domainScores: domainScores),

                const SizedBox(height: 24),

                // S 1.8.5: 위험 징후 (있을 경우)
                if (riskFactors.isNotEmpty)
                  _RiskFactorsCard(warnings: riskFactors),

                if (riskFactors.isNotEmpty) const SizedBox(height: 24),

                // S 1.8.9: 맞춤형 권장 사항
                _RecommendationsCard(recommendations: recommendations),

                const SizedBox(height: 24),

                // S 1.8.10: 가정 내 활동 가이드
                _HomeActivitiesCard(domainScores: domainScores),

                const SizedBox(height: 24),

                // S 1.8.3: 반응 시간 분석 (데이터가 있을 경우)
                if (reactionTimeData['hasData'] == true)
                  _ReactionTimeCard(data: reactionTimeData),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류: $error'),
        ),
      ),
    );
  }
}

/// 전체 점수 카드
class _OverallScoreCard extends StatelessWidget {
  final double score;
  final ReadinessLevel level;

  const _OverallScoreCard({
    required this.score,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    String levelText;
    IconData levelIcon;

    switch (level) {
      case ReadinessLevel.ready:
        levelColor = DesignSystem.semanticSuccess;
        levelText = '준비 완료';
        levelIcon = Icons.check_circle;
        break;
      case ReadinessLevel.needHelp:
        levelColor = DesignSystem.semanticWarning;
        levelText = '도움 필요';
        levelIcon = Icons.warning;
        break;
      case ReadinessLevel.needTraining:
        levelColor = DesignSystem.semanticError;
        levelText = '집중 훈련';
        levelIcon = Icons.priority_high;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor.withOpacity(0.1),
            levelColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            levelIcon,
            size: 64,
            color: levelColor,
          ),
          const SizedBox(height: 16),
          Text(
            levelText,
            style: DesignSystem.textStyleLarge.copyWith(
              color: levelColor,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '전체 점수: ${score.toStringAsFixed(1)}%',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.neutralGray700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 영역별 점수 카드
class _DomainScoresCard extends StatelessWidget {
  final List<DomainScore> domainScores;

  const _DomainScoresCard({required this.domainScores});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '영역별 점수',
            style: DesignSystem.textStyleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...domainScores.map((domain) {
            Color barColor;
            switch (domain.level) {
              case ReadinessLevel.ready:
                barColor = DesignSystem.semanticSuccess;
                break;
              case ReadinessLevel.needHelp:
                barColor = DesignSystem.semanticWarning;
                break;
              case ReadinessLevel.needTraining:
                barColor = DesignSystem.semanticError;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        domain.domainName,
                        style: DesignSystem.textStyleRegular.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${domain.correctAnswers}/${domain.totalQuestions} (${domain.percentage.toStringAsFixed(0)}%)',
                        style: DesignSystem.textStyleRegular.copyWith(
                          color: barColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: domain.percentage / 100,
                    backgroundColor: DesignSystem.neutralGray200,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 강점/약점 요약 카드
class _StrengthWeaknessCard extends StatelessWidget {
  final List<DomainScore> domainScores;

  const _StrengthWeaknessCard({required this.domainScores});

  @override
  Widget build(BuildContext context) {
    // 점수순 정렬
    final sorted = List<DomainScore>.from(domainScores)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    final strengths = sorted.where((d) => d.level == ReadinessLevel.ready).toList();
    final weaknesses = sorted.where((d) => d.level == ReadinessLevel.needTraining).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '강점 & 약점',
            style: DesignSystem.textStyleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 강점
          if (strengths.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: DesignSystem.semanticSuccess,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '잘하는 영역',
                  style: DesignSystem.textStyleMedium.copyWith(
                    color: DesignSystem.semanticSuccess,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...strengths.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 8),
                  child: Row(
                    children: [
                      const Text('• '),
                      Text(
                        '${s.domainName} (${s.percentage.toStringAsFixed(0)}%)',
                        style: DesignSystem.textStyleRegular,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // 약점
          if (weaknesses.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.trending_down,
                  color: DesignSystem.semanticError,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '보완이 필요한 영역',
                  style: DesignSystem.textStyleMedium.copyWith(
                    color: DesignSystem.semanticError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...weaknesses.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 8),
                  child: Row(
                    children: [
                      const Text('• '),
                      Text(
                        '${s.domainName} (${s.percentage.toStringAsFixed(0)}%)',
                        style: DesignSystem.textStyleRegular,
                      ),
                    ],
                  ),
                )),
          ],

          if (strengths.isEmpty && weaknesses.isEmpty)
            Text(
              '모든 영역이 보통 수준입니다.',
              style: DesignSystem.textStyleRegular.copyWith(
                color: DesignSystem.neutralGray600,
              ),
            ),
        ],
      ),
    );
  }
}

/// 위험 징후 카드
class _RiskFactorsCard extends StatelessWidget {
  final List<String> warnings;

  const _RiskFactorsCard({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.semanticError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignSystem.semanticError,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: DesignSystem.semanticError,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '주의 사항',
                style: DesignSystem.textStyleLarge.copyWith(
                  color: DesignSystem.semanticError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ '),
                    Expanded(
                      child: Text(
                        warning,
                        style: DesignSystem.textStyleRegular,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// 권장 사항 카드
class _RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;

  const _RecommendationsCard({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: DesignSystem.semanticWarning,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '맞춤형 권장 사항',
                style: DesignSystem.textStyleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  rec,
                  style: DesignSystem.textStyleRegular,
                ),
              )),
        ],
      ),
    );
  }
}

/// 가정 내 활동 가이드 카드
class _HomeActivitiesCard extends StatelessWidget {
  final List<DomainScore> domainScores;

  const _HomeActivitiesCard({required this.domainScores});

  @override
  Widget build(BuildContext context) {
    // 도움이 필요한 영역들
    final needHelpDomains = domainScores
        .where((d) => d.level != ReadinessLevel.ready)
        .toList();

    if (needHelpDomains.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home,
                color: DesignSystem.primaryBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '집에서 할 수 있는 놀이',
                style: DesignSystem.textStyleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...needHelpDomains.map((domain) {
            final activity = ScoreCalculator.getHomeActivities(domain.domainName);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain.domainName,
                    style: DesignSystem.textStyleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity['activity']!,
                    style: DesignSystem.textStyleRegular.copyWith(
                      color: DesignSystem.neutralGray700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 반응 시간 분석 카드
class _ReactionTimeCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ReactionTimeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '반응 시간 분석',
            style: DesignSystem.textStyleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TimeMetric(
                label: '평균',
                value: '${data['avgReactionTime']}ms',
                color: DesignSystem.primaryBlue,
              ),
              _TimeMetric(
                label: '최소',
                value: '${data['minReactionTime']}ms',
                color: DesignSystem.semanticSuccess,
              ),
              _TimeMetric(
                label: '최대',
                value: '${data['maxReactionTime']}ms',
                color: DesignSystem.semanticWarning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TimeMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: DesignSystem.textStyleSmall.copyWith(
            color: DesignSystem.neutralGray500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DesignSystem.textStyleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

