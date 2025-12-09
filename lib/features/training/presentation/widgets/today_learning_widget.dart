import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/services/learning_recommendation_service.dart';

/// 오늘의 학습 위젯
/// 
/// 맞춤형 학습 계획을 표시
class TodayLearningWidget extends StatelessWidget {
  final TodayLearningPlan plan;
  final void Function(LearningActivity activity)? onActivityTap;
  final VoidCallback? onStartAll;

  const TodayLearningWidget({
    super.key,
    required this.plan,
    this.onActivityTap,
    this.onStartAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignSystem.childFriendlyBlue,
            DesignSystem.childFriendlyPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.childFriendlyBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '📚',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 학습',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${plan.totalMinutes}분 코스',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onStartAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: DesignSystem.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '시작!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 활동 목록
          ...plan.activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(LearningActivity activity) {
    return GestureDetector(
      onTap: () => onActivityTap?.call(activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(activity.isCompleted ? 0.5 : 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 타입 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getActivityColor(activity.type).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getActivityEmoji(activity.type),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getActivityColor(activity.type).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getActivityTypeText(activity.type),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getActivityColor(activity.type),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${activity.durationMinutes}분',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.moduleName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: activity.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 상태
            activity.isCompleted
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DesignSystem.semanticSuccess.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 20,
                      color: DesignSystem.semanticSuccess,
                    ),
                  )
                : Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
          ],
        ),
      ),
    );
  }

  String _getActivityEmoji(ActivityType type) {
    switch (type) {
      case ActivityType.weakness:
        return '🎯';
      case ActivityType.review:
        return '🔄';
      case ActivityType.newContent:
        return '✨';
    }
  }

  String _getActivityTypeText(ActivityType type) {
    switch (type) {
      case ActivityType.weakness:
        return '집중 연습';
      case ActivityType.review:
        return '복습';
      case ActivityType.newContent:
        return '새로운 학습';
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.weakness:
        return Colors.red;
      case ActivityType.review:
        return Colors.orange;
      case ActivityType.newContent:
        return Colors.green;
    }
  }
}

/// 추천 모듈 카드 위젯
class RecommendedModuleCard extends StatelessWidget {
  final RecommendedModule module;
  final VoidCallback? onTap;

  const RecommendedModuleCard({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 우선순위 배지
            if (module.priority == 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticError.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '추천',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.semanticError,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            Text(
              module.moduleName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              module.reason,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: DesignSystem.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

