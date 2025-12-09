import 'package:equatable/equatable.dart';

/// 채점 상태
enum ScoringStatus {
  pending, // 채점 대기
  inProgress, // 채점 중
  completed, // 채점 완료
}

/// 채점 결과 (수동 채점용)
enum ScoringResult {
  correct, // 정답 (O)
  partial, // 부분 정답 (△)
  incorrect, // 오답 (X)
  notScored, // 미채점
}

/// 문항별 채점 정보
class QuestionScore extends Equatable {
  final String questionId;
  final ScoringResult result;
  final String? memo; // 채점자 메모
  final DateTime? scoredAt; // 채점 시각
  final String? scoredBy; // 채점자 ID
  final dynamic autoScoredData; // 자동 채점 데이터 (Go/No-Go 결과 등)

  const QuestionScore({
    required this.questionId,
    required this.result,
    this.memo,
    this.scoredAt,
    this.scoredBy,
    this.autoScoredData,
  });

  @override
  List<Object?> get props => [
        questionId,
        result,
        memo,
        scoredAt,
        scoredBy,
        autoScoredData,
      ];

  QuestionScore copyWith({
    String? questionId,
    ScoringResult? result,
    String? memo,
    DateTime? scoredAt,
    String? scoredBy,
    dynamic autoScoredData,
  }) {
    return QuestionScore(
      questionId: questionId ?? this.questionId,
      result: result ?? this.result,
      memo: memo ?? this.memo,
      scoredAt: scoredAt ?? this.scoredAt,
      scoredBy: scoredBy ?? this.scoredBy,
      autoScoredData: autoScoredData ?? this.autoScoredData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'result': result.name,
      'memo': memo,
      'scoredAt': scoredAt?.toIso8601String(),
      'scoredBy': scoredBy,
      'autoScoredData': autoScoredData,
    };
  }

  factory QuestionScore.fromJson(Map<String, dynamic> json) {
    return QuestionScore(
      questionId: json['questionId'] as String,
      result: ScoringResult.values.byName(json['result'] as String),
      memo: json['memo'] as String?,
      scoredAt: json['scoredAt'] != null
          ? DateTime.parse(json['scoredAt'] as String)
          : null,
      scoredBy: json['scoredBy'] as String?,
      autoScoredData: json['autoScoredData'],
    );
  }
}

/// 검사 결과 (전체)
class AssessmentResult extends Equatable {
  final String id;
  final String assessmentId;
  final String childId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ScoringStatus scoringStatus;
  final List<QuestionScore> scores; // 문항별 채점 결과
  final int totalQuestions;
  final int scoredQuestions; // 채점 완료된 문항 수

  const AssessmentResult({
    required this.id,
    required this.assessmentId,
    required this.childId,
    required this.startedAt,
    this.completedAt,
    required this.scoringStatus,
    required this.scores,
    required this.totalQuestions,
    required this.scoredQuestions,
  });

  @override
  List<Object?> get props => [
        id,
        assessmentId,
        childId,
        startedAt,
        completedAt,
        scoringStatus,
        scores,
        totalQuestions,
        scoredQuestions,
      ];

  /// 채점 진행률 (0.0 ~ 1.0)
  double get scoringProgress =>
      totalQuestions > 0 ? scoredQuestions / totalQuestions : 0.0;

  /// 채점 완료 여부
  bool get isScoringCompleted => scoredQuestions == totalQuestions;

  AssessmentResult copyWith({
    String? id,
    String? assessmentId,
    String? childId,
    DateTime? startedAt,
    DateTime? completedAt,
    ScoringStatus? scoringStatus,
    List<QuestionScore>? scores,
    int? totalQuestions,
    int? scoredQuestions,
  }) {
    return AssessmentResult(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      childId: childId ?? this.childId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      scoringStatus: scoringStatus ?? this.scoringStatus,
      scores: scores ?? this.scores,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      scoredQuestions: scoredQuestions ?? this.scoredQuestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessmentId': assessmentId,
      'childId': childId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'scoringStatus': scoringStatus.name,
      'scores': scores.map((s) => s.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'scoredQuestions': scoredQuestions,
    };
  }

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String,
      assessmentId: json['assessmentId'] as String,
      childId: json['childId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      scoringStatus:
          ScoringStatus.values.byName(json['scoringStatus'] as String),
      scores: (json['scores'] as List<dynamic>)
          .map((e) => QuestionScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalQuestions: json['totalQuestions'] as int,
      scoredQuestions: json['scoredQuestions'] as int,
    );
  }
}

