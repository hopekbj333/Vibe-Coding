import 'package:flutter/material.dart';
import '../../data/models/tracking_models.dart';

/// S 3.6.4: 배지 컬렉션 위젯
class BadgeCollectionWidget extends StatelessWidget {
  final List<AchievementBadge> badges;
  final Function(AchievementBadge)? onBadgeTap;

  const BadgeCollectionWidget({
    super.key,
    required this.badges,
    this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    // 카테고리별 그룹화
    final groupedBadges = <BadgeCategory, List<AchievementBadge>>{};
    for (final badge in badges) {
      groupedBadges.putIfAbsent(badge.category, () => []).add(badge);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 획득 현황
          _buildSummaryCard(),
          const SizedBox(height: 20),
          
          // 카테고리별 배지
          ...groupedBadges.entries.map((entry) {
            return _buildCategorySection(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final earnedCount = badges.where((b) => b.isEarned).length;
    final totalCount = badges.length;
    final progress = totalCount > 0 ? earnedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[400]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🏆',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '내 배지 컬렉션',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$earnedCount / $totalCount 획득',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BadgeCategory category, List<AchievementBadge> categoryBadges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getCategoryEmoji(category),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              _getCategoryName(category),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categoryBadges.map((badge) {
            return _buildBadgeCard(badge);
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBadgeCard(AchievementBadge badge) {
    final isEarned = badge.isEarned;

    return GestureDetector(
      onTap: () => onBadgeTap?.call(badge),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEarned ? Colors.amber[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned ? Colors.amber : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEarned ? badge.emoji : '🔒',
              style: TextStyle(
                fontSize: 32,
                color: isEarned ? null : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isEarned ? Colors.black87 : Colors.grey[500],
              ),
            ),
            if (isEarned && badge.earnedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(badge.earnedAt!),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.streak:
        return '🔥';
      case BadgeCategory.accuracy:
        return '🎯';
      case BadgeCategory.mastery:
        return '🎮';
      case BadgeCategory.growth:
        return '📈';
      case BadgeCategory.time:
        return '⏰';
    }
  }

  String _getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.streak:
        return '연속 학습';
      case BadgeCategory.accuracy:
        return '정확도 달인';
      case BadgeCategory.mastery:
        return '게임 마스터';
      case BadgeCategory.growth:
        return '성장 왕';
      case BadgeCategory.time:
        return '학습 시간';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

