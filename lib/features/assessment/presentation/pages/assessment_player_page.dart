import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/child_friendly_button.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/question_model.dart';
import '../../data/services/assessment_submission_service.dart';
import '../providers/assessment_providers.dart';
import '../widgets/question/choice_question_widget.dart';
import '../widgets/question/sound_identification_widget.dart';
import '../widgets/question/rhythm_tap_widget.dart';
import '../widgets/question/intonation_widget.dart';
import '../widgets/question/word_boundary_widget.dart';
import '../widgets/question/syllable_blending_widget.dart';
import '../widgets/question/syllable_deletion_widget.dart';
import '../widgets/question/recording_widget.dart';
import '../widgets/question/phoneme_substitution_widget.dart';
import '../widgets/question/nonword_repeat_widget.dart';
import '../widgets/question/memory_span_widget.dart';
// WP 1.5: 감각 처리 위젯
import '../widgets/question/sound_sequence_widget.dart';
import '../widgets/question/animal_sound_sequence_widget.dart';
import '../widgets/question/position_sequence_widget.dart';
import '../widgets/question/find_different_widget.dart';
import '../widgets/question/find_same_shape_widget.dart';
import '../widgets/question/find_different_direction_widget.dart';
import '../widgets/question/hidden_picture_widget.dart';
// WP 1.6: 인지 제어 위젯
import '../widgets/question/digit_span_widget.dart';
import '../widgets/question/word_span_widget.dart';
import '../widgets/question/go_no_go_widget.dart';
import '../widgets/question/go_no_go_auditory_widget.dart';
import '../widgets/question/continuous_performance_widget.dart';

/// 검사 플레이어 화면
/// 
/// 실제 검사(인트로 -> 문제 -> 전환)가 진행되는 화면입니다.
/// 튜토리얼 모드에서는 정오답 피드백을 보여줍니다.
class AssessmentPlayerPage extends ConsumerStatefulWidget {
  const AssessmentPlayerPage({super.key});

  @override
  ConsumerState<AssessmentPlayerPage> createState() => _AssessmentPlayerPageState();
}

class _AssessmentPlayerPageState extends ConsumerState<AssessmentPlayerPage> 
    with TickerProviderStateMixin {
  
  // 인트로 캐릭터 애니메이션 컨트롤러
  late AnimationController _characterController;
  
  // 피드백 애니메이션 컨트롤러 (S 1.3.6)
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScaleAnimation;

  @override
  void initState() {
    super.initState();
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // S 1.3.6: 피드백 애니메이션
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _feedbackScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    // 화면 진입 시 검사 시작 (인트로 재생)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assessmentProvider.notifier).startAssessment();
      _characterController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _characterController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assessmentProvider);
    
    // S 1.3.6: 피드백 상태일 때 애니메이션 시작
    if (state.phase == AssessmentPhase.feedback) {
      _feedbackController.forward(from: 0);
    }
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // 메인 콘텐츠
              _buildContent(context, state),

              // 상단 진행바 및 나가기 버튼
              _buildHeader(context, state),

              // 입력 차단 오버레이 (S 1.3.2, S 1.3.4)
              if (state.isInputBlocked && state.phase != AssessmentPhase.feedback)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
              // S 1.3.6: 튜토리얼 피드백 오버레이
              if (state.phase == AssessmentPhase.feedback && 
                  state.mode == AssessmentMode.tutorial)
                _buildFeedbackOverlay(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AssessmentState state) {
    switch (state.phase) {
      case AssessmentPhase.intro:
        return _buildIntroView(state);
      
      case AssessmentPhase.question:
      case AssessmentPhase.awaitingInput:
      case AssessmentPhase.feedback: // 피드백 중에도 문제 화면 유지
      case AssessmentPhase.transition:
        return _buildQuestionView(state);
        
      case AssessmentPhase.complete:
        return _buildCompleteView(state);
        
      default:
        return const SizedBox.shrink();
    }
  }

  /// S 1.3.2 인트로 가이드 화면
  Widget _buildIntroView(AssessmentState state) {
    // 튜토리얼/본 검사 모드에 따라 다른 메시지
    final introText = state.mode == AssessmentMode.tutorial
        ? '안녕? 지금부터 연습 문제를 풀어볼 거야.\n잘 듣고 따라와 줘!'
        : '안녕? 지금부터 재미있는 놀이를 할 거야.\n잘 듣고 따라와 줘!';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _characterController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_characterController.value * 0.05),
                child: child,
              );
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.neutralGray50,
              ),
              child: const Icon(
                Icons.face,
                size: 120,
                color: DesignSystem.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingXL),
          
          // 튜토리얼 모드 뱃지
          if (state.mode == AssessmentMode.tutorial)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingMD,
                vertical: DesignSystem.spacingXS,
              ),
              margin: const EdgeInsets.only(bottom: DesignSystem.spacingMD),
              decoration: BoxDecoration(
                color: DesignSystem.semanticInfo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
                border: Border.all(color: DesignSystem.semanticInfo),
              ),
              child: Text(
                '🎓 연습 모드',
                style: DesignSystem.textStyleSmall.copyWith(
                  color: DesignSystem.semanticInfo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingMD),
            decoration: BoxDecoration(
              color: DesignSystem.neutralGray100,
              borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
            ),
            child: Text(
              introText,
              style: DesignSystem.textStyleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMD),
          
          if (state.isInputBlocked)
            const Text(
              '🔒 설명 중에는 터치할 수 없어요',
              style: TextStyle(
                color: DesignSystem.semanticInfo,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  /// S 1.3.3, S 1.3.4 문제 제시 및 입력 대기 화면
  Widget _buildQuestionView(AssessmentState state) {
    final currentQuestion = state.assessment?.questions[state.currentQuestionIndex];
    if (currentQuestion == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: state.showQuestionContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 80,
          left: DesignSystem.spacingMD,
          right: DesignSystem.spacingMD,
          bottom: DesignSystem.spacingMD,
        ),
        child: Column(
          children: [
            // 입력 대기 상태 표시 (S 1.3.4)
            if (state.phase == AssessmentPhase.awaitingInput)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingMD,
                  vertical: DesignSystem.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
                  border: Border.all(color: DesignSystem.semanticSuccess),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DesignSystem.semanticSuccess,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '이제 선택해 봐!',
                      style: DesignSystem.textStyleSmall.copyWith(
                        color: DesignSystem.semanticSuccess,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // S 1.3.6: 튜토리얼 모드에서 시도 횟수 표시
                    if (state.mode == AssessmentMode.tutorial && state.currentAttemptCount > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        '(${state.currentAttemptCount}번째 시도)',
                        style: DesignSystem.textStyleSmall.copyWith(
                          color: DesignSystem.neutralGray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            
            const SizedBox(height: DesignSystem.spacingMD),
            
            // 문제 위젯
            Expanded(
              child: _buildQuestionByType(currentQuestion, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionByType(QuestionModel question, AssessmentState state) {
    final canInteract = state.phase == AssessmentPhase.awaitingInput;
    
    switch (question.type) {
      case QuestionType.choice:
        return ChoiceQuestionWidget(
          question: question,
          isInputBlocked: !canInteract,
          onOptionSelected: (index) {
            ref.read(assessmentProvider.notifier).submitAnswer(index);
          },
        );
      
      case QuestionType.ordering:
        return const Center(child: Text("순서 배열형 문제는 준비 중이야!"));
        
      case QuestionType.recording:
      case QuestionType.syllableReverse: // S 1.4.8: 음절 뒤집기
      case QuestionType.phonemeInitial: // S 1.4.9: 초성 분리
        return RecordingWidget(
          question: question,
          isInputBlocked: !canInteract,
          onRecordingCompleted: (recordingPath) {
            // 녹음 파일 경로를 답변으로 제출
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );

      // S 1.4.11: 음소 대치/추가
      case QuestionType.phonemeSubstitution:
        return PhonemeSubstitutionWidget(
          question: question,
          isInputBlocked: !canInteract,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );

      // S 1.4.12: 비단어 따라말하기
      case QuestionType.nonwordRepeat:
        return NonwordRepeatWidget(
          question: question,
          isInputBlocked: !canInteract,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );

      // S 1.4.13: 숫자/단어 폭 기억
      case QuestionType.memorySpan:
        return MemorySpanWidget(
          question: question,
          isInputBlocked: !canInteract,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );
      
      // S 1.4.1: 소리 식별
      case QuestionType.soundIdentification:
        return SoundIdentificationWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.4.2: 리듬 따라하기
      case QuestionType.rhythmTap:
        return RhythmTapWidget(
          question: question,
          isInputBlocked: !canInteract,
          onRhythmCompleted: (tapTimings) {
            // 탭 타이밍을 답변으로 제출
            ref.read(assessmentProvider.notifier).submitAnswer(tapTimings);
          },
        );
      
      // S 1.4.3: 억양/강세 식별
      case QuestionType.intonation:
        return IntonationWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.4.4: 단어 경계 인식
      case QuestionType.wordBoundary:
        return WordBoundaryWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.4.5: 각운/두운 찾기 (choice와 동일한 UI 사용)
      case QuestionType.rhyme:
        return ChoiceQuestionWidget(
          question: question,
          isInputBlocked: !canInteract,
          onOptionSelected: (index) {
            ref.read(assessmentProvider.notifier).submitAnswer(index);
          },
        );
      
      // S 1.4.6: 음절 분해/합성
      case QuestionType.syllableBlending:
      case QuestionType.phonemeBlending: // S 1.4.10: 음소 합성 (동일한 UI)
        return SyllableBlendingWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.4.7: 음절 탈락
      case QuestionType.syllableDeletion:
        return SyllableDeletionWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // === WP 1.5: 감각 처리 (Sensory Processing) ===
      
      // S 1.5.1: 소리 순서 기억하기
      case QuestionType.soundSequence:
        return SoundSequenceWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.5.2: 동물 소리 순서 맞추기
      case QuestionType.animalSoundSequence:
        return AnimalSoundSequenceWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.5.3: 위치 순서 기억하기 (Simon Says)
      case QuestionType.positionSequence:
        return PositionSequenceWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.5.4: 다른 그림 찾기
      case QuestionType.findDifferent:
        return FindDifferentWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.5.5: 같은 형태 찾기
      case QuestionType.findSameShape:
        return FindSameShapeWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.5.6: 방향이 다른 글자 찾기
      case QuestionType.findDifferentDirection:
        return FindDifferentDirectionWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // S 1.5.7: 숨은 그림 찾기
      case QuestionType.hiddenPicture:
        return HiddenPictureWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (answer) {
            ref.read(assessmentProvider.notifier).submitAnswer(answer);
          },
        );
      
      // === WP 1.6: 인지 제어 (Executive Functions) ===
      
      // S 1.6.1: 숫자 따라 말하기 순방향
      case QuestionType.digitSpanForward:
        return DigitSpanWidget(
          question: question,
          isInputBlocked: !canInteract,
          isBackward: false,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );
      
      // S 1.6.2: 숫자 거꾸로 말하기 역방향
      case QuestionType.digitSpanBackward:
        return DigitSpanWidget(
          question: question,
          isInputBlocked: !canInteract,
          isBackward: true,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );
      
      // S 1.6.3: 단어 따라 말하기
      case QuestionType.wordSpanForward:
        return WordSpanWidget(
          question: question,
          isInputBlocked: !canInteract,
          isBackward: false,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );
      
      // S 1.6.4: 단어 거꾸로 말하기
      case QuestionType.wordSpanBackward:
        return WordSpanWidget(
          question: question,
          isInputBlocked: !canInteract,
          isBackward: true,
          onRecordingCompleted: (recordingPath) {
            ref.read(assessmentProvider.notifier).submitAnswer(recordingPath);
          },
        );
      
      // S 1.6.5: Go/No-Go 기본
      case QuestionType.goNoGo:
        return GoNoGoWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (result) {
            ref.read(assessmentProvider.notifier).submitAnswer(result);
          },
        );
      
      // S 1.6.6: Go/No-Go 청각 버전
      case QuestionType.goNoGoAuditory:
        return GoNoGoAuditoryWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (result) {
            ref.read(assessmentProvider.notifier).submitAnswer(result);
          },
        );
      
      // S 1.6.7: 지속적 주의력
      case QuestionType.continuousPerformance:
        return ContinuousPerformanceWidget(
          question: question,
          isInputBlocked: !canInteract,
          onAnswerSelected: (result) {
            ref.read(assessmentProvider.notifier).submitAnswer(result);
          },
        );
    }
  }

  /// S 1.3.6: 튜토리얼 피드백 오버레이 (정답/오답 표시)
  Widget _buildFeedbackOverlay(AssessmentState state) {
    final isCorrect = state.lastAnswerCorrect ?? false;
    
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: ScaleTransition(
            scale: _feedbackScaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // O/X 마크
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect 
                        ? DesignSystem.semanticSuccess 
                        : DesignSystem.semanticError,
                    boxShadow: DesignSystem.shadowLarge,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingLG),
                // 피드백 텍스트
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacingLG,
                    vertical: DesignSystem.spacingMD,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                  ),
                  child: Text(
                    isCorrect 
                        ? '잘했어! 정답이야! 🎉' 
                        : state.currentAttemptCount < AssessmentNotifier.maxTutorialAttempts
                            ? '아쉽다! 다시 해보자! 💪'
                            : '괜찮아! 다음 문제로 가자! 😊',
                    style: DesignSystem.textStyleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCorrect 
                          ? DesignSystem.semanticSuccess 
                          : DesignSystem.neutralGray800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteView(AssessmentState state) {
    // S 1.3.7: 튜토리얼 완료 후 본 검사 진입 조건
    final canStartTest = state.mode == AssessmentMode.tutorial &&
        state.tutorialCorrectCount >= AssessmentNotifier.minCorrectForTestEntry;
    
    final completeText = state.mode == AssessmentMode.tutorial
        ? (canStartTest ? '연습 끝! 이제 진짜 시작해볼까?' : '연습 끝! 정말 잘했어!')
        : '와! 정말 잘했어!';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // S 1.3.10: 폭죽 애니메이션 (완료 시 큰 보상)
          _buildCelebrationAnimation(state),
          const SizedBox(height: DesignSystem.spacingLG),
          Text(
            completeText,
            style: DesignSystem.textStyleLarge,
            textAlign: TextAlign.center,
          ),
          // 튜토리얼 모드에서 정답 개수 표시
          if (state.mode == AssessmentMode.tutorial) ...[
            const SizedBox(height: DesignSystem.spacingSM),
            Text(
              '${state.assessment?.totalQuestions ?? 0}개 중 ${state.tutorialCorrectCount}개 맞았어!',
              style: DesignSystem.textStyleMedium.copyWith(
                color: DesignSystem.neutralGray600,
              ),
            ),
          ],
          // S 1.3.10: 본 검사 모드에서 제출 상태 표시
          if (state.mode == AssessmentMode.test) ...[
            const SizedBox(height: DesignSystem.spacingSM),
            _buildSubmissionStatus(state),
          ],
          const SizedBox(height: DesignSystem.spacingXL),
          
          // S 1.3.7: 튜토리얼 완료 후 본 검사 시작 버튼
          if (canStartTest) ...[
            ChildFriendlyButton(
              label: '🚀 진짜 검사 시작!',
              onPressed: () {
                ref.read(assessmentProvider.notifier).startTestMode();
              },
              size: ChildButtonSize.large,
              type: ChildButtonType.primary,
            ),
            const SizedBox(height: DesignSystem.spacingMD),
          ],
          
          // 연습 다시하기 버튼 (튜토리얼 모드에서 조건 미달 시)
          if (state.mode == AssessmentMode.tutorial && !canStartTest) ...[
            ChildFriendlyButton(
              label: '🎓 다시 연습하기',
              onPressed: () {
                // 연습 다시 시작
                ref.read(assessmentProvider.notifier).loadAssessment('assessment_001');
                ref.read(assessmentProvider.notifier).setMode(AssessmentMode.tutorial);
              },
              size: ChildButtonSize.large,
              color: DesignSystem.semanticInfo,
            ),
            const SizedBox(height: DesignSystem.spacingMD),
          ],
          
          ChildFriendlyButton(
            label: '홈으로 가기',
            onPressed: () => context.go('/home'),
            size: ChildButtonSize.medium,
            type: ChildButtonType.neutral,
          ),
        ],
      ),
    );
  }

  /// S 1.3.10: 폭죽 애니메이션 (터지는 효과)
  Widget _buildCelebrationAnimation(AssessmentState state) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 퍼져나가는 파동 원들
          ...List.generate(3, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 800 + (index * 300)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: (1 - value).clamp(0.0, 0.5),
                  child: Container(
                    width: 80 + (value * 150) + (index * 20),
                    height: 80 + (value * 150) + (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: [
                          DesignSystem.semanticWarning,
                          DesignSystem.primaryBlue,
                          DesignSystem.semanticSuccess,
                        ][index],
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // 터지는 별들 (8방향으로 퍼짐)
          ...List.generate(12, (index) {
            final angle = (index * 30) * pi / 180;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (index % 4) * 100),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final radius = value * (80 + (index % 3) * 20);
                return Positioned(
                  left: 125 + radius * cos(angle) - 10,
                  top: 125 + radius * sin(angle) - 10,
                  child: Opacity(
                    opacity: value < 0.8 ? 1.0 : (1 - (value - 0.8) * 5),
                    child: Transform.rotate(
                      angle: value * pi,
                      child: Icon(
                        index % 2 == 0 ? Icons.star_rounded : Icons.auto_awesome,
                        size: 20 - (value * 8),
                        color: [
                          DesignSystem.semanticWarning,
                          DesignSystem.primaryBlue,
                          DesignSystem.semanticSuccess,
                          Colors.pink,
                          Colors.purple,
                        ][index % 5],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // 터지는 동그라미들
          ...List.generate(8, (index) {
            final angle = (index * 45 + 22.5) * pi / 180;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 700 + (index % 3) * 150),
              curve: Curves.easeOutQuad,
              builder: (context, value, child) {
                final radius = value * (60 + (index % 2) * 30);
                return Positioned(
                  left: 125 + radius * cos(angle) - 6,
                  top: 125 + radius * sin(angle) - 6,
                  child: Opacity(
                    opacity: value < 0.7 ? 1.0 : (1 - (value - 0.7) * 3.3),
                    child: Container(
                      width: 12 - (value * 4),
                      height: 12 - (value * 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: [
                          DesignSystem.semanticWarning,
                          DesignSystem.primaryBlue,
                          DesignSystem.semanticSuccess,
                          Colors.pink,
                        ][index % 4],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // 메인 아이콘 (탄성 효과)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignSystem.semanticWarning,
                        Colors.orange.shade600,
                      ],
                    ),
                    boxShadow: DesignSystem.shadowLarge,
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// S 1.3.10: 제출 상태 표시
  Widget _buildSubmissionStatus(AssessmentState state) {
    final submissionResult = state.submissionResult;
    
    if (submissionResult == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('결과 저장 중...'),
        ],
      );
    }
    
    switch (submissionResult) {
      case SubmissionResult.success:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_done_rounded,
              color: DesignSystem.semanticSuccess,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '결과가 저장되었어요!',
              style: DesignSystem.textStyleSmall.copyWith(
                color: DesignSystem.semanticSuccess,
              ),
            ),
          ],
        );
      case SubmissionResult.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: DesignSystem.semanticWarning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '인터넷 연결 시 자동 저장돼요',
              style: DesignSystem.textStyleSmall.copyWith(
                color: DesignSystem.semanticWarning,
              ),
            ),
          ],
        );
      case SubmissionResult.error:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DesignSystem.semanticError,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '저장 실패 - 나중에 다시 시도해요',
              style: DesignSystem.textStyleSmall.copyWith(
                color: DesignSystem.semanticError,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildHeader(BuildContext context, AssessmentState state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingMD),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // 진행률 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacingSM,
                    vertical: DesignSystem.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.neutralGray100,
                    borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
                  ),
                  child: Text(
                    '${state.currentQuestionIndex + 1} / ${state.assessment?.totalQuestions ?? 0}',
                    style: DesignSystem.textStyleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.neutralGray600,
                    ),
                  ),
                ),
                // 튜토리얼 모드 표시
                if (state.mode == AssessmentMode.tutorial) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingSM,
                      vertical: DesignSystem.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: DesignSystem.semanticInfo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
                    ),
                    child: Text(
                      '연습',
                      style: DesignSystem.textStyleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.semanticInfo,
                      ),
                    ),
                  ),
                ],
                // 개발 모드 전용: 스킵 버튼
                if (kDebugMode && state.phase == AssessmentPhase.awaitingInput) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // 임의의 답변으로 다음 문제로 스킵
                      ref.read(assessmentProvider.notifier).submitAnswer(0);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacingSM,
                        vertical: DesignSystem.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.semanticWarning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
                        border: Border.all(color: DesignSystem.semanticWarning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.skip_next_rounded,
                            color: DesignSystem.semanticWarning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '스킵',
                            style: DesignSystem.textStyleSmall.copyWith(
                              color: DesignSystem.semanticWarning,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // 나가기 버튼 (길게 누르면 나가기)
            GestureDetector(
              onLongPress: () => _showExitConfirmation(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingSM,
                  vertical: DesignSystem.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.neutralGray100,
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.exit_to_app_rounded,
                      color: DesignSystem.neutralGray600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '꾹 눌러 나가기',
                      style: DesignSystem.textStyleSmall.copyWith(
                        color: DesignSystem.neutralGray600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그만할까?'),
        content: const Text('지금 나가면 처음부터 다시 해야 해.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('계속할래'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            style: TextButton.styleFrom(
              foregroundColor: DesignSystem.semanticError,
            ),
            child: const Text('나갈래'),
          ),
        ],
      ),
    );
  }
}
