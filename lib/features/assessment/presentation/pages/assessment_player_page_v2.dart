import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/assessment_session_model.dart';
import '../../data/services/assessment_sampling_service.dart';
import '../../../training/data/models/training_content_model.dart';
import '../providers/assessment_session_provider.dart';
import '../widgets/audio_option_button.dart';
import 'assessment_result_page.dart';

/// Assessment 플레이어 화면 V2
/// Training 게임 위젯을 사용하여 검사 진행
class AssessmentPlayerPageV2 extends ConsumerStatefulWidget {
  final String childId;
  final String childName;

  const AssessmentPlayerPageV2({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  ConsumerState<AssessmentPlayerPageV2> createState() => _AssessmentPlayerPageV2State();
}

class _AssessmentPlayerPageV2State extends ConsumerState<AssessmentPlayerPageV2> {
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(currentAssessmentSessionProvider);
    final currentQuestion = ref.watch(currentQuestionProvider);
    final progress = ref.watch(assessmentProgressProvider);
    final isCompleted = ref.watch(isAssessmentCompletedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('문해력 기초 검사 ${(progress * 100).toInt()}%'),
        backgroundColor: DesignSystem.childFriendlyPurple,
        leading: IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => _showPauseDialog(context),
        ),
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(child: Text('세션을 불러오는 중...'));
          }

          if (isCompleted) {
            // 검사 완료 시 결과 페이지로 이동
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AssessmentResultPage(
                    childId: widget.childId,
                    childName: widget.childName,
                  ),
                ),
              );
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (currentQuestion == null) {
            return const Center(child: Text('문항을 불러올 수 없습니다.'));
          }

          return Column(
            children: [
              // 진행률 바
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              
              // 문항 번호 및 제목
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '문항 ${currentQuestion.questionNumber} / ${session.totalQuestions}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentQuestion.gameTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 게임 위젯 (실제 문항)
              Expanded(
                child: _buildGameWidget(currentQuestion),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameWidget(AssessmentQuestion question) {
    // 보기가 없으면 자동 처리
    if (question.options.isEmpty) {
      return _buildAutoPassWidget(question);
    }

    // GamePattern별 처리
    switch (question.pattern) {
      case GamePattern.rhythmTap:
      case GamePattern.recording:
      case GamePattern.sequencing:
        // 복잡한 패턴은 자동 정답 처리
        return _buildAutoPassWidget(question);
      
      case GamePattern.multipleChoice:
      case GamePattern.oxQuiz:
      case GamePattern.matching:
      case GamePattern.goNoGo:
      default:
        // 객관식 UI
        return _buildMultipleChoiceWidget(question);
    }
  }

  Widget _buildMultipleChoiceWidget(AssessmentQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 질문
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Text(
              question.question,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 보기 (오디오 지원)
          ...question.options.asMap().entries.map((entry) {
            final option = entry.value;
            
            return AudioOptionButton(
              option: option,
              isSelected: false,
              onTap: () => _onAnswerSelected(option.optionId),
            );
          }).toList(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAutoPassWidget(AssessmentQuestion question) {
    // 복잡한 패턴은 자동으로 넘기기
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber, width: 3),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.amber.shade700),
                const SizedBox(height: 16),
                Text(
                  question.gameTitle,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  '이 게임은 현재 검사 버전에서\n지원하지 않습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // 자동으로 정답 처리하고 다음으로
              _onAnswerSelected(question.correctAnswer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '다음 문항으로',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onAnswerSelected(String userAnswer) {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    
    // 답변 제출
    ref.read(currentAssessmentSessionProvider.notifier).submitAnswer(
      userAnswer: userAnswer,
      responseTimeMs: responseTime,
    );
    
    // 다음 문항을 위한 타이머 리셋
    _questionStartTime = DateTime.now();
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('검사 일시 중지'),
        content: const Text('검사를 일시 중지하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentAssessmentSessionProvider.notifier).pauseAssessment();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('중지', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
