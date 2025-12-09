import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/mini_test_model.dart';
import '../providers/retest_providers.dart';
import '../widgets/progress_comparison_widget.dart';
import '../widgets/promotion_result_widget.dart';

/// 미니 테스트 페이지
/// 
/// 학습 효과를 측정하는 짧은 테스트
class MiniTestPage extends ConsumerStatefulWidget {
  final String childId;
  final String moduleId;
  final String moduleName;

  const MiniTestPage({
    super.key,
    required this.childId,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  ConsumerState<MiniTestPage> createState() => _MiniTestPageState();
}

class _MiniTestPageState extends ConsumerState<MiniTestPage> {
  int _currentQuestionIndex = 0;
  DateTime? _questionStartTime;
  bool _showResult = false;
  MiniTestResult? _result;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    final service = ref.read(miniTestServiceProvider);
    service.generateMiniTest(
      childId: widget.childId,
      moduleId: widget.moduleId,
      moduleName: widget.moduleName,
      questionCount: 5,
    );
    service.startTest();
    _questionStartTime = DateTime.now();
  }

  void _submitAnswer(dynamic answer) {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final service = ref.read(miniTestServiceProvider);
    
    service.submitAnswer(
      questionIndex: _currentQuestionIndex,
      answer: answer,
      responseTimeMs: responseTime,
    );

    final test = service.currentTest;
    if (test != null && _currentQuestionIndex < test.totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _questionStartTime = DateTime.now();
      });
    } else {
      // 테스트 완료
      _completeTest();
    }
  }

  void _completeTest() {
    final service = ref.read(miniTestServiceProvider);
    final result = service.completeTest();
    
    setState(() {
      _result = result;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final test = ref.watch(currentMiniTestProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: _showResult && _result != null
              ? _buildResultView()
              : test != null
                  ? _buildTestView(test)
                  : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildTestView(MiniTest test) {
    final question = test.questions[_currentQuestionIndex];

    return Column(
      children: [
        // 상단 바
        _buildHeader(test),
        
        // 진행 바
        _buildProgressBar(test),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                
                // 문항
                _buildQuestion(question),
                
                const SizedBox(height: 48),
                
                // 선택지
                _buildOptions(question),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(MiniTest test) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitConfirmDialog(),
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: Text(
              test.moduleName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentQuestionIndex + 1}/${test.totalQuestions}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: DesignSystem.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MiniTest test) {
    final progress = (_currentQuestionIndex + 1) / test.totalQuestions;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildQuestion(MiniTestQuestion question) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 문항 유형 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignSystem.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getQuestionIcon(question.questionType),
              size: 40,
              color: DesignSystem.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          // 문항 텍스트
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DesignSystem.neutralGray800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(MiniTestQuestion question) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: List.generate(
        question.options.length,
        (index) => _buildOptionButton(
          option: question.options[index],
          index: index,
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String option,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _submitAnswer(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 140,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              option,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignSystem.neutralGray800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 닫기 버튼
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),

          // 향상도 비교
          Padding(
            padding: const EdgeInsets.all(24),
            child: ProgressComparisonWidget(
              result: _result!,
              onClose: () => _showPromotionResult(),
            ),
          ),
        ],
      ),
    );
  }

  void _showPromotionResult() {
    final promotionService = ref.read(stagePromotionServiceProvider);
    final promotionResult = promotionService.checkPromotion(
      currentStageId: widget.moduleId,
      testScore: _result!.currentScore,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PromotionResultWidget(
          result: promotionResult,
          onProceedToNextStage: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            // TODO: 다음 단계로 네비게이션
          },
          onRetry: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onClose: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('테스트 중단'),
          ],
        ),
        content: const Text('테스트를 중단하면 진행 상황이 저장되지 않습니다.\n정말 나가시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  IconData _getQuestionIcon(String type) {
    switch (type) {
      case 'same_sound':
        return Icons.hearing;
      case 'different_sound':
        return Icons.compare_arrows;
      case 'rhythm':
        return Icons.music_note;
      case 'tempo':
        return Icons.speed;
      case 'emotion':
        return Icons.emoji_emotions;
      case 'word_count':
        return Icons.format_list_numbered;
      case 'alliteration':
        return Icons.first_page;
      case 'rhyme':
        return Icons.last_page;
      case 'syllable_count':
        return Icons.view_module;
      case 'syllable_split':
        return Icons.call_split;
      case 'syllable_merge':
        return Icons.merge;
      default:
        return Icons.quiz;
    }
  }
}

