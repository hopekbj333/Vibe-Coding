// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionScore _$QuestionScoreFromJson(Map<String, dynamic> json) =>
    _QuestionScore(
      questionId: json['questionId'] as String,
      result: $enumDecode(_$ScoringResultEnumMap, json['result']),
      memo: json['memo'] as String?,
      scoredAt: json['scoredAt'] == null
          ? null
          : DateTime.parse(json['scoredAt'] as String),
      scoredBy: json['scoredBy'] as String?,
      autoScoredData: json['autoScoredData'],
    );

Map<String, dynamic> _$QuestionScoreToJson(_QuestionScore instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'result': _$ScoringResultEnumMap[instance.result]!,
      'memo': instance.memo,
      'scoredAt': instance.scoredAt?.toIso8601String(),
      'scoredBy': instance.scoredBy,
      'autoScoredData': instance.autoScoredData,
    };

const _$ScoringResultEnumMap = {
  ScoringResult.correct: 'correct',
  ScoringResult.partial: 'partial',
  ScoringResult.incorrect: 'incorrect',
  ScoringResult.notScored: 'notScored',
};

_AssessmentResult _$AssessmentResultFromJson(Map<String, dynamic> json) =>
    _AssessmentResult(
      id: json['id'] as String,
      assessmentId: json['assessmentId'] as String,
      childId: json['childId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      scoringStatus: $enumDecode(_$ScoringStatusEnumMap, json['scoringStatus']),
      scores: (json['scores'] as List<dynamic>)
          .map((e) => QuestionScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      scoredQuestions: (json['scoredQuestions'] as num).toInt(),
    );

Map<String, dynamic> _$AssessmentResultToJson(_AssessmentResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessmentId': instance.assessmentId,
      'childId': instance.childId,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'scoringStatus': _$ScoringStatusEnumMap[instance.scoringStatus]!,
      'scores': instance.scores,
      'totalQuestions': instance.totalQuestions,
      'scoredQuestions': instance.scoredQuestions,
    };

const _$ScoringStatusEnumMap = {
  ScoringStatus.pending: 'pending',
  ScoringStatus.inProgress: 'inProgress',
  ScoringStatus.completed: 'completed',
};
