import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/mini_test_model.dart';
import '../providers/retest_providers.dart';
import '../widgets/growth_report_widget.dart';
import 'mini_test_page.dart';

/// 재검사 시스템 데모 페이지
/// 
/// 미니 테스트, 향상도 비교, 성장 리포트, 단계 승급 시스템 데모
class RetestDemoPage extends ConsumerStatefulWidget {
  final String childId;

  const RetestDemoPage({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<RetestDemoPage> createState() => _RetestDemoPageState();
}

class _RetestDemoPageState extends ConsumerState<RetestDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재검사 시스템'),
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              _buildHeader(),
              const SizedBox(height: 32),

              // 미니 테스트 섹션
              _buildSectionTitle('📝 미니 테스트'),
              const SizedBox(height: 16),
              _buildMiniTestSection(),
              const SizedBox(height: 32),

              // 단계 잠금 해제 상태
              _buildSectionTitle('🔓 단계 잠금 해제 상태'),
              const SizedBox(height: 16),
              _buildStageStatusSection(),
              const SizedBox(height: 32),

              // 승급 기준 설정
              _buildSectionTitle('⚙️ 승급 기준 설정'),
              const SizedBox(height: 16),
              _buildPromotionThresholdSection(),
              const SizedBox(height: 32),

              // 성장 리포트
              _buildSectionTitle('📊 성장 리포트'),
              const SizedBox(height: 16),
              _buildGrowthReportButton(),
              const SizedBox(height: 32),

              // 테스트 결과 히스토리
              _buildSectionTitle('📋 테스트 결과 히스토리'),
              const SizedBox(height: 16),
              _buildTestHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.white, size: 40),
              SizedBox(width: 16),
              Text(
                '재검사 시스템',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '학습 효과를 측정하는 미니 테스트 시스템입니다.\n짧은 테스트로 실력 향상을 확인하세요!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: DesignSystem.neutralGray800,
      ),
    );
  }

  Widget _buildMiniTestSection() {
    final modules = [
      {'id': 'phonological1', 'name': '음운 인식 1단계', 'icon': Icons.hearing},
      {'id': 'phonological2', 'name': '음운 인식 2단계', 'icon': Icons.record_voice_over},
      {'id': 'phonological3', 'name': '음운 인식 3단계', 'icon': Icons.view_module},
    ];

    return Column(
      children: modules.map((module) {
        final isUnlocked = ref.watch(stageUnlockedProvider(module['id'] as String));
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUnlocked
                  ? () => _startMiniTest(
                        module['id'] as String,
                        module['name'] as String,
                      )
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked
                        ? Colors.teal.shade200
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.teal.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        module['icon'] as IconData,
                        size: 28,
                        color: isUnlocked
                            ? Colors.teal.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? DesignSystem.neutralGray800
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUnlocked ? '미니 테스트 가능' : '🔒 잠금됨',
                            style: TextStyle(
                              fontSize: 14,
                              color: isUnlocked
                                  ? Colors.teal.shade600
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isUnlocked ? Icons.play_circle : Icons.lock,
                      size: 32,
                      color: isUnlocked
                          ? Colors.teal.shade600
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStageStatusSection() {
    final stages = ['phonological1', 'phonological2', 'phonological3'];
    final stageNames = ['1단계', '2단계', '3단계'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(stages.length, (index) {
          final isUnlocked = ref.watch(stageUnlockedProvider(stages[index]));
          
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  border: Border.all(
                    color: isUnlocked
                        ? Colors.green.shade400
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                ),
                child: Icon(
                  isUnlocked ? Icons.check : Icons.lock,
                  size: 30,
                  color: isUnlocked
                      ? Colors.green.shade600
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stageNames[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? Colors.green.shade600
                      : Colors.grey.shade500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPromotionThresholdSection() {
    final threshold = ref.watch(promotionThresholdProvider);
    final promotionService = ref.read(stagePromotionServiceProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '승급 기준 점수',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$threshold점',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: threshold.toDouble(),
            min: 70,
            max: 90,
            divisions: 4,
            activeColor: Colors.teal,
            label: '$threshold점',
            onChanged: (value) {
              promotionService.setPromotionThreshold(value.toInt());
            },
          ),
          const Text(
            '아이의 수준에 맞게 승급 기준을 조절할 수 있습니다',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.neutralGray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthReportButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showGrowthReport,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 40),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3주간 성장 리포트 보기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '아이의 성장 과정을 한눈에 확인하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestHistorySection() {
    final results = ref.watch(testResultsProvider);

    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '아직 테스트 기록이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: results.map((result) => _buildResultCard(result)).toList(),
    );
  }

  Widget _buildResultCard(MiniTestResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isPassed
              ? Colors.green.shade200
              : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: result.isPassed
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
            ),
            child: Center(
              child: Text(
                '${result.currentScore}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: result.isPassed
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.moduleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result.hasImproved
                      ? '+${result.improvement}점 향상'
                      : '점수 유지',
                  style: TextStyle(
                    fontSize: 12,
                    color: result.hasImproved
                        ? Colors.green.shade600
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            result.isPassed ? Icons.check_circle : Icons.pending,
            color: result.isPassed ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  void _startMiniTest(String moduleId, String moduleName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MiniTestPage(
          childId: widget.childId,
          moduleId: moduleId,
          moduleName: moduleName,
        ),
      ),
    );
  }

  void _showGrowthReport() {
    final report = createSampleGrowthReport(
      childId: widget.childId,
      childName: '철수',
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GrowthReportWidget(
          report: report,
          onClose: () => Navigator.of(context).pop(),
          onShare: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('리포트 공유 기능 (개발 중)')),
            );
          },
        ),
      ),
    );
  }
}

