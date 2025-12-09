import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_state.dart';
import '../../../child/presentation/providers/child_providers.dart';
import '../../data/models/scoring_model.dart';
import '../providers/scoring_providers.dart';

/// S 1.7.1 & S 1.7.2: 채점 대기열 목록 화면
/// 
/// 채점이 필요한 검사 목록을 보여주고,
/// 선택하면 채점 화면으로 이동합니다.
class ScoringQueuePage extends ConsumerWidget {
  const ScoringQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAssessmentsAsync = ref.watch(pendingAssessmentsProvider);

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray50,
      appBar: AppBar(
        title: const Text('채점 대기 목록'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: pendingAssessmentsAsync.when(
        data: (assessments) {
          if (assessments.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingAssessmentsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assessments.length,
              itemBuilder: (context, index) {
                final assessment = assessments[index];
                return _AssessmentCard(
                  assessment: assessment,
                  onTap: () {
                    // 채점 화면으로 이동
                    context.push('/scoring/${assessment.id}');
                  },
                  onViewReport: assessment.isScoringCompleted
                      ? () {
                          // 리포트 화면으로 이동
                          context.push('/report/${assessment.id}');
                        }
                      : null,
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '데이터를 불러오는 중 오류가 발생했습니다',
                style: DesignSystem.textStyleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: DesignSystem.textStyleSmall.copyWith(
                  color: DesignSystem.neutralGray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: DesignSystem.neutralGray300,
          ),
          const SizedBox(height: 24),
          Text(
            '채점할 검사가 없습니다',
            style: DesignSystem.textStyleLarge.copyWith(
              color: DesignSystem.neutralGray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '모든 검사가 채점 완료되었습니다',
            style: DesignSystem.textStyleRegular.copyWith(
              color: DesignSystem.neutralGray500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 검사 카드 위젯
class _AssessmentCard extends ConsumerWidget {
  final dynamic assessment;
  final VoidCallback onTap;
  final VoidCallback? onViewReport;

  const _AssessmentCard({
    required this.assessment,
    required this.onTap,
    this.onViewReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아동 정보 가져오기
    final childrenAsync = ref.watch(childrenListProvider);
    final ChildModel? child = childrenAsync.whenOrNull(
      data: (children) {
        try {
          return children.firstWhere((c) => c.id == assessment.childId);
        } catch (e) {
          return children.isNotEmpty ? children.first : null;
        }
      },
    );

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final unscoredCount =
        assessment.totalQuestions - assessment.scoredQuestions;

    // 상태별 색상
    Color statusColor;
    String statusText;
    
    if (assessment.scoringStatus == ScoringStatus.pending) {
      statusColor = DesignSystem.semanticWarning;
      statusText = '채점 대기';
    } else if (assessment.scoringStatus == ScoringStatus.inProgress) {
      statusColor = DesignSystem.semanticInfo;
      statusText = '채점 중';
    } else if (assessment.scoringStatus == ScoringStatus.completed) {
      statusColor = DesignSystem.semanticSuccess;
      statusText = '채점 완료';
    } else {
      statusColor = DesignSystem.neutralGray500;
      statusText = '알 수 없음';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 아동 이름 + 상태 뱃지
              Row(
                children: [
                  // 아동 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: DesignSystem.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 아동 이름 및 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child?.name ?? '알 수 없음',
                          style: DesignSystem.textStyleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '만 ${child?.age ?? 0}세',
                          style: DesignSystem.textStyleSmall.copyWith(
                            color: DesignSystem.neutralGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 상태 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: DesignSystem.textStyleSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // 검사 정보
              Row(
                children: [
                  _InfoItem(
                    icon: Icons.calendar_today,
                    label: '검사 완료',
                    value: dateFormat.format(assessment.completedAt ??
                        assessment.startedAt),
                  ),
                  const SizedBox(width: 24),
                  _InfoItem(
                    icon: Icons.assignment,
                    label: '미채점 문항',
                    value: '$unscoredCount개',
                    valueColor: unscoredCount > 0
                        ? DesignSystem.semanticError
                        : DesignSystem.semanticSuccess,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 진행률 바
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '채점 진행률',
                        style: DesignSystem.textStyleSmall.copyWith(
                          color: DesignSystem.neutralGray600,
                        ),
                      ),
                      Text(
                        '${assessment.scoredQuestions} / ${assessment.totalQuestions}',
                        style: DesignSystem.textStyleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: assessment.scoringProgress,
                    backgroundColor: DesignSystem.neutralGray200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      assessment.isScoringCompleted
                          ? DesignSystem.semanticSuccess
                          : DesignSystem.primaryBlue,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              
              // 리포트 보기 버튼 (채점 완료 시)
              if (onViewReport != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onViewReport,
                    icon: const Icon(Icons.analytics),
                    label: const Text('리포트 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.semanticSuccess,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 정보 아이템 위젯
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: DesignSystem.neutralGray500,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: DesignSystem.textStyleSmall.copyWith(
                color: DesignSystem.neutralGray500,
              ),
            ),
            Text(
              value,
              style: DesignSystem.textStyleRegular.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? DesignSystem.neutralGray800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

