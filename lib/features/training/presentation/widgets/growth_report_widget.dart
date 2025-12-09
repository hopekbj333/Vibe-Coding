import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/mini_test_model.dart';

/// 성장 리포트 위젯
/// 
/// 부모/교사용 종합 성장 리포트
class GrowthReportWidget extends StatelessWidget {
  final GrowthReport report;
  final VoidCallback? onClose;
  final VoidCallback? onShare;

  const GrowthReportWidget({
    super.key,
    required this.report,
    this.onClose,
    this.onShare,
  });

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(),
            const SizedBox(height: 24),

            // 기간 정보
            _buildPeriodInfo(),
            const SizedBox(height: 24),

            // 집중 연습 영역
            _buildFocusSection(),
            const SizedBox(height: 20),

            // 함께 향상된 영역
            _buildImprovementSection(),
            const SizedBox(height: 20),

            // 학습 시간
            _buildLearningTimeSection(),
            const SizedBox(height: 20),

            // 가장 좋아한 게임
            _buildFavoriteGameSection(),
            const SizedBox(height: 20),

            // 선생님 한마디
            if (report.teacherComment != null) ...[
              _buildTeacherComment(),
              const SizedBox(height: 20),
            ],

            // 공유 버튼
            if (onShare != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('리포트 공유하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 40,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${report.childName}의 성장 리포트',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.neutralGray800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '평균 ${report.averageImprovement}점 향상 🎉',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }

  Widget _buildPeriodInfo() {
    final days = report.periodEnd.difference(report.periodStart).inDays;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, color: DesignSystem.neutralGray500),
          const SizedBox(width: 8),
          Text(
            '${_formatDate(report.periodStart)} ~ ${_formatDate(report.periodEnd)}',
            style: const TextStyle(
              fontSize: 16,
              color: DesignSystem.neutralGray500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$days일간',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: DesignSystem.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSection() {
    final mostImproved = report.mostImprovedSkill;
    if (mostImproved == null) return const SizedBox.shrink();

    return _buildSection(
      icon: '🎯',
      title: '집중 연습한 영역',
      child: _buildSkillProgressItem(mostImproved, isHighlighted: true),
    );
  }

  Widget _buildImprovementSection() {
    final otherSkills = report.skillProgresses
        .where((s) => s != report.mostImprovedSkill)
        .toList();

    if (otherSkills.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      icon: '💪',
      title: '함께 향상된 영역',
      child: Column(
        children: otherSkills
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildSkillProgressItem(s),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLearningTimeSection() {
    return _buildSection(
      icon: '⏰',
      title: '학습 시간',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '총 학습',
            '${report.learningStats.totalSessions}회',
            Icons.play_circle,
          ),
          _buildStatItem(
            '총 시간',
            '${report.learningStats.totalMinutes}분',
            Icons.timer,
          ),
          _buildStatItem(
            '하루 평균',
            '${report.learningStats.averageMinutesPerDay}분',
            Icons.today,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteGameSection() {
    return _buildSection(
      icon: '🎮',
      title: '가장 좋아한 게임',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.pink, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.learningStats.favoriteGame,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.neutralGray800,
                    ),
                  ),
                  Text(
                    '${report.learningStats.favoriteGamePlayCount}회 플레이',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherComment() {
    return _buildSection(
      icon: '📝',
      title: '선생님 한마디',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          report.teacherComment!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.shade700,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignSystem.neutralGray800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSkillProgressItem(SkillProgress skill, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.amber.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: Colors.amber.shade300, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              skill.skillName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${skill.initialScore}점',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, color: DesignSystem.neutralGray500),
          ),
          Text(
            '${skill.currentScore}점',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DesignSystem.neutralGray800,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${skill.improvement}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: DesignSystem.primaryBlue, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DesignSystem.neutralGray800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: DesignSystem.neutralGray500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

