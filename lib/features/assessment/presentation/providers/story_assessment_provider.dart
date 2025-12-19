import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/story_assessment_model.dart';
import '../../data/services/story_assessment_service.dart';

/// 스토리 검사 서비스 Provider
final storyAssessmentServiceProvider =
    Provider<StoryAssessmentService>((ref) {
  return StoryAssessmentService();
});

/// 현재 스토리 검사 세션 Provider
final currentStorySessionProvider =
    StateNotifierProvider<StorySessionNotifier, StorySessionState>((ref) {
  final service = ref.watch(storyAssessmentServiceProvider);
  return StorySessionNotifier(service);
});

/// 스토리 세션 상태
class StorySessionState {
  final StoryAssessmentSession? session;
  final bool isLoading;
  final String? errorMessage;

  const StorySessionState({
    this.session,
    this.isLoading = false,
    this.errorMessage,
  });

  StorySessionState copyWith({
    StoryAssessmentSession? session,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StorySessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 스토리 세션 Notifier
class StorySessionNotifier extends StateNotifier<StorySessionState> {
  final StoryAssessmentService _service;

  StorySessionNotifier(this._service) : super(const StorySessionState());

  /// 새로운 스토리 검사 시작
  Future<void> startNewStoryAssessment({
    required String childId,
    StoryTheme theme = StoryTheme.hangeulLand,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final session = await _service.createStorySession(
        childId: childId,
        theme: theme,
      );

      final startedSession = _service.startSession(session);

      state = state.copyWith(
        session: startedSession,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 답변 제출
  void submitAnswer({
    required String questionId,
    required String userAnswer,
    required int responseTimeMs,
  }) {
    final currentSession = state.session;
    if (currentSession == null) return;

    final updatedSession = _service.submitAnswer(
      session: currentSession,
      questionId: questionId,
      userAnswer: userAnswer,
      responseTimeMs: responseTimeMs,
    );

    state = state.copyWith(session: updatedSession);
  }

  /// 세션 일시 중지
  void pauseSession() {
    final currentSession = state.session;
    if (currentSession == null) return;

    final pausedSession = _service.pauseSession(currentSession);
    state = state.copyWith(session: pausedSession);
  }

  /// 세션 재개
  void resumeSession() {
    final currentSession = state.session;
    if (currentSession == null) return;

    final resumedSession = _service.resumeSession(currentSession);
    state = state.copyWith(session: resumedSession);
  }

  /// 세션 중도 포기
  void abandonSession() {
    final currentSession = state.session;
    if (currentSession == null) return;

    final abandonedSession = _service.abandonSession(currentSession);
    state = state.copyWith(session: abandonedSession);
  }

  /// 세션 완료
  void completeSession() {
    final currentSession = state.session;
    if (currentSession == null) return;

    final completedSession = _service.completeSession(currentSession);
    state = state.copyWith(session: completedSession);
  }

  /// 세션 초기화
  void clearSession() {
    state = const StorySessionState();
  }

  /// 이전 문항으로 이동
  void moveToPreviousQuestion() {
    final currentSession = state.session;
    if (currentSession == null) return;

    final updatedSession = _service.moveToPreviousQuestion(currentSession);
    state = state.copyWith(session: updatedSession);
  }

  /// 다음 문항으로 이동
  void moveToNextQuestion() {
    final currentSession = state.session;
    if (currentSession == null) return;

    final updatedSession = _service.moveToNextQuestion(currentSession);
    state = state.copyWith(session: updatedSession);
  }
}

