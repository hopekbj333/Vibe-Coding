import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/scoring_model.dart';
import '../../data/repositories/mock_scoring_repository.dart';

/// Mock Scoring Repository Provider
final scoringRepositoryProvider = Provider<MockScoringRepository>((ref) {
  return MockScoringRepository();
});

/// 채점 대기 목록 Provider
final pendingAssessmentsProvider =
    FutureProvider<List<AssessmentResult>>((ref) async {
  final repository = ref.watch(scoringRepositoryProvider);
  return repository.getPendingAssessments();
});

/// 특정 검사 결과 Provider
final assessmentResultProvider =
    FutureProvider.family<AssessmentResult, String>((ref, resultId) async {
  final repository = ref.watch(scoringRepositoryProvider);
  return repository.getAssessmentResult(resultId);
});

/// 채점 상태 관리 Provider (채점 진행 중 상태)
class ScoringState {
  final String? currentResultId;
  final int currentQuestionIndex;
  final bool isScoring;

  const ScoringState({
    this.currentResultId,
    this.currentQuestionIndex = 0,
    this.isScoring = false,
  });

  ScoringState copyWith({
    String? currentResultId,
    int? currentQuestionIndex,
    bool? isScoring,
  }) {
    return ScoringState(
      currentResultId: currentResultId ?? this.currentResultId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isScoring: isScoring ?? this.isScoring,
    );
  }
}

class ScoringNotifier extends StateNotifier<ScoringState> {
  ScoringNotifier(this.repository) : super(const ScoringState());

  final MockScoringRepository repository;

  /// 채점 시작
  void startScoring(String resultId) {
    state = ScoringState(
      currentResultId: resultId,
      currentQuestionIndex: 0,
      isScoring: true,
    );
  }

  /// 다음 문항으로 이동
  void nextQuestion() {
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  /// 문항 채점 저장
  Future<void> saveScore(QuestionScore score) async {
    if (state.currentResultId == null) return;

    await repository.saveQuestionScore(state.currentResultId!, score);
    nextQuestion();
  }

  /// 채점 완료
  Future<void> completeScoring() async {
    if (state.currentResultId == null) return;

    await repository.completeScoringStatus(state.currentResultId!);
    
    state = const ScoringState();
  }

  /// 채점 종료
  void endScoring() {
    state = const ScoringState();
  }
}

final scoringNotifierProvider =
    StateNotifierProvider<ScoringNotifier, ScoringState>((ref) {
  final repository = ref.watch(scoringRepositoryProvider);
  return ScoringNotifier(repository);
});

