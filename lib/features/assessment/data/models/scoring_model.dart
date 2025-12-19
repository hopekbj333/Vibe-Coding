import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoring_model.freezed.dart';
part 'scoring_model.g.dart';

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
@freezed
class QuestionScore with _$QuestionScore {
  const factory QuestionScore({
    required String questionId,
    required ScoringResult result,
    String? memo, // 채점자 메모
    DateTime? scoredAt, // 채점 시각
    String? scoredBy, // 채점자 ID
    @JsonKey() dynamic autoScoredData, // 자동 채점 데이터 (Go/No-Go 결과 등)
  }) = _QuestionScore;

  factory QuestionScore.fromJson(Map<String, dynamic> json) =>
      _$QuestionScoreFromJson(json);
}

/// 검사 결과 (전체)
@freezed
class AssessmentResult with _$AssessmentResult {
  const AssessmentResult._();

  const factory AssessmentResult({
    required String id,
    required String assessmentId,
    required String childId,
    required DateTime startedAt,
    DateTime? completedAt,
    required ScoringStatus scoringStatus,
    required List<QuestionScore> scores, // 문항별 채점 결과
    required int totalQuestions,
    required int scoredQuestions, // 채점 완료된 문항 수
  }) = _AssessmentResult;

  /// 채점 진행률 (0.0 ~ 1.0)
  double get scoringProgress =>
      totalQuestions > 0 ? scoredQuestions / totalQuestions : 0.0;

  /// 채점 완료 여부
  bool get isScoringCompleted => scoredQuestions == totalQuestions;

  factory AssessmentResult.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResultFromJson(json);
}

