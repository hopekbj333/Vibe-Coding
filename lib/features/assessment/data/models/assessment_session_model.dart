import 'package:equatable/equatable.dart';
import '../services/assessment_sampling_service.dart';

/// Assessment 세션 상태
enum AssessmentStatus {
  notStarted, // 시작 전
  inProgress, // 진행 중
  paused, // 일시 중지
  completed, // 완료
  abandoned, // 중도 포기
}

/// Assessment 세션 모델
class AssessmentSession extends Equatable {
  final String sessionId; // 세션 고유 ID
  final String childId; // 아동 ID
  final DateTime startedAt; // 시작 시간
  final DateTime? completedAt; // 완료 시간
  final AssessmentStatus status; // 세션 상태
  final List<AssessmentQuestion> questions; // 전체 문항 (50개)
  final List<AssessmentAnswer> answers; // 답변 기록
  final int currentQuestionIndex; // 현재 문항 번호 (0-based)
  final int totalQuestions; // 전체 문항 수 (50)

  const AssessmentSession({
    required this.sessionId,
    required this.childId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.questions,
    required this.answers,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  /// 진행률 (0.0 ~ 1.0)
  double get progress => currentQuestionIndex / totalQuestions;

  /// 정답 개수
  int get correctCount => answers.where((a) => a.isCorrect).length;

  /// 정답률
  double get accuracy => answers.isEmpty ? 0.0 : correctCount / answers.length;

  /// 평균 응답 시간 (밀리초)
  double get averageResponseTime {
    if (answers.isEmpty) return 0.0;
    final totalTime = answers.fold<int>(0, (sum, a) => sum + a.responseTimeMs);
    return totalTime / answers.length;
  }

  /// 분야별 정답률
  Map<String, double> get accuracyByType {
    final Map<String, List<bool>> typeResults = {};
    
    for (final answer in answers) {
      final question = questions[answer.questionIndex];
      final type = question.type.toString();
      typeResults[type] = [...(typeResults[type] ?? []), answer.isCorrect];
    }

    return typeResults.map((type, results) {
      final correctCount = results.where((r) => r).length;
      return MapEntry(type, correctCount / results.length);
    });
  }

  @override
  List<Object?> get props => [
        sessionId,
        childId,
        startedAt,
        completedAt,
        status,
        questions,
        answers,
        currentQuestionIndex,
        totalQuestions,
      ];

  AssessmentSession copyWith({
    String? sessionId,
    String? childId,
    DateTime? startedAt,
    DateTime? completedAt,
    AssessmentStatus? status,
    List<AssessmentQuestion>? questions,
    List<AssessmentAnswer>? answers,
    int? currentQuestionIndex,
    int? totalQuestions,
  }) {
    return AssessmentSession(
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'childId': childId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.toString(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
    };
  }

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSession(
      sessionId: json['sessionId'] as String,
      childId: json['childId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      status: AssessmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      questions: [], // 재로드 필요
      answers: (json['answers'] as List)
          .map((a) => AssessmentAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      totalQuestions: json['totalQuestions'] as int,
    );
  }
}

/// Assessment 답변 모델
class AssessmentAnswer extends Equatable {
  final int questionIndex; // 문항 번호 (0-based)
  final String questionId; // 문항 ID (itemId)
  final String userAnswer; // 사용자 답변
  final String correctAnswer; // 정답
  final bool isCorrect; // 정답 여부
  final int responseTimeMs; // 응답 시간 (밀리초)
  final DateTime answeredAt; // 답변 시간
  final Map<String, dynamic>? metadata; // 추가 데이터 (예: 터치 좌표)

  const AssessmentAnswer({
    required this.questionIndex,
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.answeredAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        questionIndex,
        questionId,
        userAnswer,
        correctAnswer,
        isCorrect,
        responseTimeMs,
        answeredAt,
        metadata,
      ];

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'questionId': questionId,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'responseTimeMs': responseTimeMs,
      'answeredAt': answeredAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) {
    return AssessmentAnswer(
      questionIndex: json['questionIndex'] as int,
      questionId: json['questionId'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      responseTimeMs: json['responseTimeMs'] as int,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
