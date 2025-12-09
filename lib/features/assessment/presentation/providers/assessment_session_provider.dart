import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_session_model.dart';
import '../../domain/services/assessment_engine.dart';
import '../../data/services/assessment_sampling_service.dart';

/// Assessment Engine Provider
final assessmentEngineProvider = Provider<AssessmentEngine>((ref) {
  return AssessmentEngine();
});

/// 현재 Assessment Session Provider
final currentAssessmentSessionProvider =
    StateNotifierProvider<AssessmentSessionNotifier, AsyncValue<AssessmentSession?>>((ref) {
  final engine = ref.watch(assessmentEngineProvider);
  return AssessmentSessionNotifier(engine);
});

/// Assessment Session Notifier
class AssessmentSessionNotifier extends StateNotifier<AsyncValue<AssessmentSession?>> {
  final AssessmentEngine _engine;

  AssessmentSessionNotifier(this._engine) : super(const AsyncValue.data(null));

  /// 새 Assessment 시작
  Future<void> startNewAssessment(String childId) async {
    state = const AsyncValue.loading();
    
    try {
      // 1. 세션 생성
      var session = await _engine.createSession(childId);
      
      // 2. 세션 시작
      session = _engine.startSession(session);
      
      state = AsyncValue.data(session);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 답변 제출
  void submitAnswer({
    required String userAnswer,
    required int responseTimeMs,
    Map<String, dynamic>? metadata,
  }) {
    final currentSession = state.value;
    if (currentSession == null) return;

    final updatedSession = _engine.submitAnswer(
      session: currentSession,
      userAnswer: userAnswer,
      responseTimeMs: responseTimeMs,
      metadata: metadata,
    );

    state = AsyncValue.data(updatedSession);
  }

  /// 일시 중지
  void pauseAssessment() {
    final currentSession = state.value;
    if (currentSession == null) return;

    final updatedSession = _engine.pauseSession(currentSession);
    state = AsyncValue.data(updatedSession);
  }

  /// 재개
  void resumeAssessment() {
    final currentSession = state.value;
    if (currentSession == null) return;

    final updatedSession = _engine.resumeSession(currentSession);
    state = AsyncValue.data(updatedSession);
  }

  /// 중도 포기
  void abandonAssessment() {
    final currentSession = state.value;
    if (currentSession == null) return;

    final updatedSession = _engine.abandonSession(currentSession);
    state = AsyncValue.data(updatedSession);
  }

  /// 세션 초기화
  void clearSession() {
    state = const AsyncValue.data(null);
  }
}

/// 현재 문항 Provider
final currentQuestionProvider = Provider<AssessmentQuestion?>((ref) {
  final sessionAsync = ref.watch(currentAssessmentSessionProvider);
  final engine = ref.watch(assessmentEngineProvider);

  return sessionAsync.when(
    data: (session) {
      if (session == null) return null;
      return engine.getCurrentQuestion(session);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 진행률 Provider
final assessmentProgressProvider = Provider<double>((ref) {
  final sessionAsync = ref.watch(currentAssessmentSessionProvider);
  final engine = ref.watch(assessmentEngineProvider);

  return sessionAsync.when(
    data: (session) {
      if (session == null) return 0.0;
      return engine.calculateProgress(session);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// 통계 Provider
final assessmentStatsProvider = Provider<AssessmentStats?>((ref) {
  final sessionAsync = ref.watch(currentAssessmentSessionProvider);
  final engine = ref.watch(assessmentEngineProvider);

  return sessionAsync.when(
    data: (session) {
      if (session == null) return null;
      return engine.calculateStats(session);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// 완료 여부 Provider
final isAssessmentCompletedProvider = Provider<bool>((ref) {
  final sessionAsync = ref.watch(currentAssessmentSessionProvider);
  final engine = ref.watch(assessmentEngineProvider);

  return sessionAsync.when(
    data: (session) {
      if (session == null) return false;
      return engine.isSessionCompleted(session);
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
