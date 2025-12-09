import 'package:uuid/uuid.dart';
import '../../data/models/assessment_session_model.dart';
import '../../data/services/assessment_sampling_service.dart';

/// Assessment 실행 엔진
/// 검사 생성, 진행, 완료 관리
class AssessmentEngine {
  final AssessmentSamplingService _samplingService = AssessmentSamplingService();
  final Uuid _uuid = const Uuid();

  /// 새 Assessment 세션 생성
  Future<AssessmentSession> createSession(String childId) async {
    // 1. 50문항 샘플링
    final questions = await _samplingService.generateAssessmentQuestions();

    if (questions.isEmpty) {
      throw Exception('문항 생성 실패: 샘플링된 문항이 없습니다.');
    }

    // 2. 세션 생성
    return AssessmentSession(
      sessionId: _uuid.v4(),
      childId: childId,
      startedAt: DateTime.now(),
      status: AssessmentStatus.notStarted,
      questions: questions,
      answers: [],
      currentQuestionIndex: 0,
      totalQuestions: questions.length,
    );
  }

  /// Assessment 시작
  AssessmentSession startSession(AssessmentSession session) {
    return session.copyWith(
      status: AssessmentStatus.inProgress,
    );
  }

  /// 답변 제출
  AssessmentSession submitAnswer({
    required AssessmentSession session,
    required String userAnswer,
    required int responseTimeMs,
    Map<String, dynamic>? metadata,
  }) {
    final currentQuestion = session.questions[session.currentQuestionIndex];
    final isCorrect = userAnswer == currentQuestion.correctAnswer;

    final answer = AssessmentAnswer(
      questionIndex: session.currentQuestionIndex,
      questionId: currentQuestion.itemId,
      userAnswer: userAnswer,
      correctAnswer: currentQuestion.correctAnswer,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      answeredAt: DateTime.now(),
      metadata: metadata,
    );

    // 다음 문항으로 이동
    final newAnswers = [...session.answers, answer];
    final nextIndex = session.currentQuestionIndex + 1;

    // 마지막 문항인지 확인
    final isLastQuestion = nextIndex >= session.totalQuestions;

    return session.copyWith(
      answers: newAnswers,
      currentQuestionIndex: isLastQuestion ? session.currentQuestionIndex : nextIndex,
      status: isLastQuestion ? AssessmentStatus.completed : session.status,
      completedAt: isLastQuestion ? DateTime.now() : null,
    );
  }

  /// 일시 중지
  AssessmentSession pauseSession(AssessmentSession session) {
    return session.copyWith(
      status: AssessmentStatus.paused,
    );
  }

  /// 재개
  AssessmentSession resumeSession(AssessmentSession session) {
    return session.copyWith(
      status: AssessmentStatus.inProgress,
    );
  }

  /// 중도 포기
  AssessmentSession abandonSession(AssessmentSession session) {
    return session.copyWith(
      status: AssessmentStatus.abandoned,
      completedAt: DateTime.now(),
    );
  }

  /// 세션 완료 여부
  bool isSessionCompleted(AssessmentSession session) {
    return session.status == AssessmentStatus.completed;
  }

  /// 현재 문항 가져오기
  AssessmentQuestion? getCurrentQuestion(AssessmentSession session) {
    if (session.currentQuestionIndex >= session.questions.length) {
      return null;
    }
    return session.questions[session.currentQuestionIndex];
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double calculateProgress(AssessmentSession session) {
    return session.progress;
  }

  /// 통계 계산
  AssessmentStats calculateStats(AssessmentSession session) {
    return AssessmentStats(
      totalQuestions: session.totalQuestions,
      answeredQuestions: session.answers.length,
      correctAnswers: session.correctCount,
      accuracy: session.accuracy,
      averageResponseTime: session.averageResponseTime,
      accuracyByType: session.accuracyByType,
      duration: session.completedAt != null
          ? session.completedAt!.difference(session.startedAt)
          : DateTime.now().difference(session.startedAt),
    );
  }
}

/// Assessment 통계
class AssessmentStats {
  final int totalQuestions; // 전체 문항 수
  final int answeredQuestions; // 답변한 문항 수
  final int correctAnswers; // 정답 수
  final double accuracy; // 정답률 (0.0 ~ 1.0)
  final double averageResponseTime; // 평균 응답 시간 (ms)
  final Map<String, double> accuracyByType; // 분야별 정답률
  final Duration duration; // 소요 시간

  AssessmentStats({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.averageResponseTime,
    required this.accuracyByType,
    required this.duration,
  });

  /// 등급 계산 (A+ ~ F)
  String get grade {
    if (accuracy >= 0.95) return 'A+';
    if (accuracy >= 0.90) return 'A';
    if (accuracy >= 0.85) return 'B+';
    if (accuracy >= 0.80) return 'B';
    if (accuracy >= 0.75) return 'C+';
    if (accuracy >= 0.70) return 'C';
    if (accuracy >= 0.60) return 'D';
    return 'F';
  }

  /// 강점 분야 (정답률 높은 순)
  List<MapEntry<String, double>> get strengths {
    final sortedEntries = accuracyByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).toList();
  }

  /// 약점 분야 (정답률 낮은 순)
  List<MapEntry<String, double>> get weaknesses {
    final sortedEntries = accuracyByType.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sortedEntries.take(3).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'averageResponseTime': averageResponseTime,
      'accuracyByType': accuracyByType,
      'duration': duration.inSeconds,
      'grade': grade,
    };
  }
}
