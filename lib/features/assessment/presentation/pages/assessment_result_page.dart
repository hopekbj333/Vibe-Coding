import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_system.dart';
import '../providers/assessment_session_provider.dart';

/// Assessment 결과 화면
class AssessmentResultPage extends ConsumerWidget {
  final String childId;
  final String childName;

  const AssessmentResultPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentAssessmentSessionProvider);
    final stats = ref.watch(assessmentStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검사 결과'),
        backgroundColor: DesignSystem.childFriendlyPurple,
        automaticallyImplyLeading: false,
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null || stats == null) {
            return const Center(child: Text('결과를 불러올 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // 축하 메시지
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade100, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.celebration, size: 64, color: Colors.purple),
                      const SizedBox(height: 16),
                      Text(
                        '$childName님',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '검사를 완료했어요!',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 전체 점수
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('전체 정답률', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 16),
                      Text(
                        '${(stats.accuracy * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(stats.accuracy),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.correctAnswers} / ${stats.totalQuestions} 정답',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _getScoreColor(stats.accuracy).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '등급: ${stats.grade}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(stats.accuracy),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 추가 정보
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.timer,
                        title: '소요 시간',
                        value: '${stats.duration.inMinutes}분',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.speed,
                        title: '평균 응답',
                        value: '${(stats.averageResponseTime / 1000).toStringAsFixed(1)}초',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 분야별 결과
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 분야별 결과',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...stats.accuracyByType.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTypeName(entry.key),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '${(entry.value * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: entry.value,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(entry.value),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 완료 버튼
                ElevatedButton(
                  onPressed: () {
                    ref.read(currentAssessmentSessionProvider.notifier).clearSession();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                
                const SizedBox(height: 40),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getScoreColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _formatTypeName(String type) {
    // TrainingContentType enum 값을 한글로 변환
    if (type.contains('phonological')) return '음운 인식';
    if (type.contains('auditory')) return '청각 처리';
    if (type.contains('visual')) return '시각 처리';
    if (type.contains('workingMemory')) return '작업 기억';
    if (type.contains('executive')) return '인지 제어';
    if (type.contains('attention')) return '주의력';
    if (type.contains('sensory')) return '감각 처리';
    return type;
  }
}
