import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_model.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/mock_assessment_repository.dart';
import '../../data/services/assessment_storage_service.dart';
import '../../data/services/assessment_submission_service.dart';
import '../../domain/repositories/assessment_repository.dart';

// --- States ---

/// 검사 로딩 상태
enum AssessmentLoadStatus {
  initial,
  loading,
  loaded,
  error,
}

/// 검사 진행 단계 (Phase)
enum AssessmentPhase {
  ready, // 대기 (출발하기 전)
  intro, // 인트로 (S 1.3.2)
  question, // 문제 제시 (S 1.3.3)
  awaitingInput, // 입력 대기 (S 1.3.4) - 오디오 끝나고 입력 가능 상태
  feedback, // 정오답 피드백 (S 1.3.6: 튜토리얼 모드에서만 사용)
  transition, // 다음 문제 전환 (S 1.3.5)
  complete, // 전체 완료
}

/// 검사 모드 (S 1.3.6, S 1.3.7)
enum AssessmentMode {
  tutorial, // 연습 모드: 피드백 있음, 재시도 가능
  test, // 본 검사 모드: 피드백 없음
}

class AssessmentState {
  final AssessmentLoadStatus loadStatus;
  final AssessmentPhase phase;
  final AssessmentMode mode;
  final AssessmentModel? assessment;
  final String? errorMessage;
  final int currentQuestionIndex;
  
  /// 입력 차단 여부 (S 1.3.2, S 1.3.3)
  final bool isInputBlocked;

  /// 문제 화면 페이드인 여부 (S 1.3.3)
  final bool showQuestionContent;

  /// 입력 대기 시작 시각 (S 1.3.4: 반응 시간 측정용)
  final DateTime? inputStartTime;

  /// 현재까지 수집된 답변 데이터 (S 1.3.4)
  final List<AnswerData> answers;

  /// 마지막 정답 여부 (S 1.3.6: 튜토리얼 피드백용)
  final bool? lastAnswerCorrect;

  /// 현재 문제 시도 횟수 (S 1.3.6: 재시도 카운트)
  final int currentAttemptCount;

  /// 튜토리얼 정답 횟수 (S 1.3.7: 본 검사 진입 조건)
  final int tutorialCorrectCount;

  /// S 1.3.10: 결과 제출 상태
  final SubmissionResult? submissionResult;

  const AssessmentState({
    this.loadStatus = AssessmentLoadStatus.initial,
    this.phase = AssessmentPhase.ready,
    this.mode = AssessmentMode.tutorial,
    this.assessment,
    this.errorMessage,
    this.currentQuestionIndex = 0,
    this.isInputBlocked = false,
    this.showQuestionContent = false,
    this.inputStartTime,
    this.answers = const [],
    this.lastAnswerCorrect,
    this.currentAttemptCount = 0,
    this.tutorialCorrectCount = 0,
    this.submissionResult,
  });

  AssessmentState copyWith({
    AssessmentLoadStatus? loadStatus,
    AssessmentPhase? phase,
    AssessmentMode? mode,
    AssessmentModel? assessment,
    String? errorMessage,
    int? currentQuestionIndex,
    bool? isInputBlocked,
    bool? showQuestionContent,
    DateTime? inputStartTime,
    List<AnswerData>? answers,
    bool? lastAnswerCorrect,
    int? currentAttemptCount,
    int? tutorialCorrectCount,
    SubmissionResult? submissionResult,
  }) {
    return AssessmentState(
      loadStatus: loadStatus ?? this.loadStatus,
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      assessment: assessment ?? this.assessment,
      errorMessage: errorMessage,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isInputBlocked: isInputBlocked ?? this.isInputBlocked,
      showQuestionContent: showQuestionContent ?? this.showQuestionContent,
      inputStartTime: inputStartTime ?? this.inputStartTime,
      answers: answers ?? this.answers,
      lastAnswerCorrect: lastAnswerCorrect,
      currentAttemptCount: currentAttemptCount ?? this.currentAttemptCount,
      tutorialCorrectCount: tutorialCorrectCount ?? this.tutorialCorrectCount,
      submissionResult: submissionResult,
    );
  }
}

// --- Providers ---

/// 검사 리포지토리 Provider (Mock 사용)
final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return MockAssessmentRepository();
});

/// 검사 상태 관리 Provider
final assessmentProvider = StateNotifierProvider<AssessmentNotifier, AssessmentState>((ref) {
  final repository = ref.watch(assessmentRepositoryProvider);
  return AssessmentNotifier(repository);
});

// --- Notifier ---

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  final AssessmentRepository _repository;

  /// 튜토리얼 모드에서 최대 재시도 횟수
  static const int maxTutorialAttempts = 3;

  /// S 1.3.7: 본 검사 진입을 위한 최소 정답 횟수
  static const int minCorrectForTestEntry = 2;

  /// S 1.3.8: 현재 검사 중인 아동 ID (저장용)
  String? _currentChildId;

  AssessmentNotifier(this._repository) : super(const AssessmentState());

  /// 검사 모드 설정
  void setMode(AssessmentMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// S 1.3.8: 현재 아동 ID 설정
  void setChildId(String childId) {
    _currentChildId = childId;
  }

  /// S 1.3.8: 진행 상태 자동 저장
  Future<void> _autoSaveProgress() async {
    if (_currentChildId == null || state.assessment == null) return;
    
    await AssessmentStorageService.saveProgress(
      childId: _currentChildId!,
      assessmentId: state.assessment!.id,
      currentQuestionIndex: state.currentQuestionIndex,
      mode: state.mode,
      answers: state.answers,
      tutorialCorrectCount: state.tutorialCorrectCount,
    );
  }

  /// S 1.3.8: 저장된 진행 상태 불러오기
  Future<bool> loadSavedProgress(String childId) async {
    final saved = await AssessmentStorageService.loadProgress(childId);
    if (saved == null) return false;
    
    // 저장된 검사 데이터 로드
    try {
      final assessment = await _repository.getAssessment(saved.assessmentId);
      
      state = state.copyWith(
        loadStatus: AssessmentLoadStatus.loaded,
        phase: AssessmentPhase.ready,
        mode: saved.mode,
        assessment: assessment,
        currentQuestionIndex: saved.currentQuestionIndex,
        answers: saved.answers,
        tutorialCorrectCount: saved.tutorialCorrectCount,
        isInputBlocked: false,
        showQuestionContent: false,
      );
      
      _currentChildId = childId;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// S 1.3.8: 저장된 진행 상태 삭제
  Future<void> clearSavedProgress() async {
    if (_currentChildId != null) {
      await AssessmentStorageService.clearProgress(_currentChildId!);
    }
  }

  /// 검사 데이터 로딩 및 초기화
  Future<void> loadAssessment(String assessmentId) async {
    state = state.copyWith(loadStatus: AssessmentLoadStatus.loading);

    try {
      final assessment = await _repository.getAssessment(assessmentId);
      
      state = state.copyWith(
        loadStatus: AssessmentLoadStatus.loaded,
        phase: AssessmentPhase.ready,
        mode: AssessmentMode.tutorial, // 기본: 튜토리얼 모드로 시작
        assessment: assessment,
        currentQuestionIndex: 0,
        isInputBlocked: false,
        showQuestionContent: false,
        answers: [],
        currentAttemptCount: 0,
        tutorialCorrectCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        loadStatus: AssessmentLoadStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 검사 시작 및 인트로 재생 (S 1.3.2)
  Future<void> startAssessment() async {
    state = state.copyWith(
      phase: AssessmentPhase.intro,
      isInputBlocked: true,
      showQuestionContent: false,
    );

    // 인트로 메시지 표시 시간 (5초 - 읽을 시간 충분히 제공)
    await Future.delayed(const Duration(seconds: 5));

    await _presentCurrentQuestion();
  }

  /// 현재 문제 제시 시퀀스 (S 1.3.3)
  Future<void> _presentCurrentQuestion() async {
    state = state.copyWith(
      phase: AssessmentPhase.question,
      isInputBlocked: true,
      showQuestionContent: false,
      currentAttemptCount: 0, // 새 문제 시작 시 시도 횟수 초기화
    );

    await Future.delayed(const Duration(milliseconds: 100));
    state = state.copyWith(showQuestionContent: true);

    // 문제 제시 애니메이션 대기
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      phase: AssessmentPhase.awaitingInput,
      isInputBlocked: false,
      inputStartTime: DateTime.now(),
    );
  }

  /// 답변 선택 처리 (S 1.3.4, S 1.3.6)
  Future<void> submitAnswer(dynamic answer) async {
    if (state.isInputBlocked) return;
    if (state.phase != AssessmentPhase.awaitingInput) return;

    final reactionTimeMs = state.inputStartTime != null
        ? DateTime.now().difference(state.inputStartTime!).inMilliseconds
        : 0;

    final currentQuestion = state.assessment?.questions[state.currentQuestionIndex];
    if (currentQuestion == null) return;

    // 정답 여부 확인
    final isCorrect = answer == currentQuestion.correctAnswer;

    // 답변 데이터 생성
    final answerData = AnswerData(
      questionId: currentQuestion.id,
      selectedAnswer: answer,
      reactionTimeMs: reactionTimeMs,
      answeredAt: DateTime.now(),
    );

    state = state.copyWith(
      isInputBlocked: true,
      answers: [...state.answers, answerData],
      lastAnswerCorrect: isCorrect,
      currentAttemptCount: state.currentAttemptCount + 1,
    );

    // S 1.3.8: 답변 후 자동 저장
    await _autoSaveProgress();

    // S 1.3.6: 튜토리얼 모드에서는 피드백 제공
    if (state.mode == AssessmentMode.tutorial) {
      await _handleTutorialFeedback(isCorrect);
    } else {
      // 본 검사 모드: 피드백 없이 다음 문제로
      await _goToNextQuestion();
    }
  }

  /// S 1.3.6: 튜토리얼 모드 피드백 처리
  Future<void> _handleTutorialFeedback(bool isCorrect) async {
    // 피드백 상태로 전환 (lastAnswerCorrect 유지)
    state = state.copyWith(
      phase: AssessmentPhase.feedback,
      isInputBlocked: true,
      lastAnswerCorrect: isCorrect, // 명시적으로 유지
    );

    if (isCorrect) {
      // 정답 피드백
      // 정답 횟수 증가 (lastAnswerCorrect 유지)
      state = state.copyWith(
        tutorialCorrectCount: state.tutorialCorrectCount + 1,
        lastAnswerCorrect: true, // 명시적으로 유지
      );

      // 피드백 표시 시간
      await Future.delayed(const Duration(milliseconds: 1500));

      // 다음 문제로 이동
      await _goToNextQuestion();
    } else {
      // 오답 피드백
      if (state.currentAttemptCount < maxTutorialAttempts) {
        // 재시도 가능
        await Future.delayed(const Duration(milliseconds: 1500));

        // 같은 문제 다시 제시 (S 1.3.6: Re-try 로직)
        await _retryCurrentQuestion();
      } else {
        // 최대 시도 횟수 초과: 정답 알려주고 다음으로
        await Future.delayed(const Duration(milliseconds: 1500));

        await _goToNextQuestion();
      }
    }
  }

  /// S 1.3.6: 같은 문제 재시도
  Future<void> _retryCurrentQuestion() async {
    state = state.copyWith(
      phase: AssessmentPhase.question,
      isInputBlocked: true,
      showQuestionContent: true,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      phase: AssessmentPhase.awaitingInput,
      isInputBlocked: false,
      inputStartTime: DateTime.now(),
    );
  }

  /// 다음 문제로 이동 (S 1.3.5)
  Future<void> _goToNextQuestion() async {
    if (state.assessment == null) return;
    
    if (state.currentQuestionIndex < state.assessment!.totalQuestions - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        phase: AssessmentPhase.transition,
        showQuestionContent: false,
        lastAnswerCorrect: null,
      );

      await Future.delayed(const Duration(seconds: 1));

      await _presentCurrentQuestion();
    } else {
      // 모든 문제 완료
      state = state.copyWith(
        phase: AssessmentPhase.complete,
        isInputBlocked: false,
        lastAnswerCorrect: null,
      );
      
      // S 1.3.8: 검사 완료 시 저장된 진행 상태 삭제
      await clearSavedProgress();
      
      // S 1.3.10: 본 검사 모드일 때만 결과 제출
      if (state.mode == AssessmentMode.test) {
        await _submitAssessmentResult();
      }
      
      // 완료 메시지 시뮬레이션 (1초)
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// S 1.3.10: 검사 결과 제출
  Future<void> _submitAssessmentResult() async {
    if (_currentChildId == null || state.assessment == null) return;
    
    final result = await AssessmentSubmissionService.submitAssessmentResult(
      childId: _currentChildId!,
      assessmentId: state.assessment!.id,
      mode: state.mode,
      answers: state.answers,
      tutorialCorrectCount: state.tutorialCorrectCount,
      totalQuestions: state.assessment!.totalQuestions,
    );
    
    state = state.copyWith(submissionResult: result);
  }

  /// S 1.3.7: 본 검사 시작 (튜토리얼 완료 후)
  Future<void> startTestMode() async {
    // 상태 초기화하고 본 검사 모드로 전환
    state = state.copyWith(
      mode: AssessmentMode.test,
      phase: AssessmentPhase.ready,
      currentQuestionIndex: 0,
      answers: [],
      currentAttemptCount: 0,
      tutorialCorrectCount: 0,
      showQuestionContent: false,
    );
    
    // 본 검사 시작
    await startAssessment();
  }

  /// 다음 문제로 이동 (외부 호출용)
  Future<void> nextQuestion() async {
    await _goToNextQuestion();
  }
}
