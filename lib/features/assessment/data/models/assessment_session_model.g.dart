// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssessmentSession _$AssessmentSessionFromJson(Map<String, dynamic> json) =>
    _AssessmentSession(
      sessionId: json['sessionId'] as String,
      childId: json['childId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      status: $enumDecode(_$AssessmentStatusEnumMap, json['status']),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => AssessmentQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      answers: (json['answers'] as List<dynamic>)
          .map((e) => AssessmentAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentQuestionIndex: (json['currentQuestionIndex'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
    );

Map<String, dynamic> _$AssessmentSessionToJson(_AssessmentSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'childId': instance.childId,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'status': _$AssessmentStatusEnumMap[instance.status]!,
      'questions': instance.questions,
      'answers': instance.answers,
      'currentQuestionIndex': instance.currentQuestionIndex,
      'totalQuestions': instance.totalQuestions,
    };

const _$AssessmentStatusEnumMap = {
  AssessmentStatus.notStarted: 'notStarted',
  AssessmentStatus.inProgress: 'inProgress',
  AssessmentStatus.paused: 'paused',
  AssessmentStatus.completed: 'completed',
  AssessmentStatus.abandoned: 'abandoned',
};

_AssessmentAnswer _$AssessmentAnswerFromJson(Map<String, dynamic> json) =>
    _AssessmentAnswer(
      questionIndex: (json['questionIndex'] as num).toInt(),
      questionId: json['questionId'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      responseTimeMs: (json['responseTimeMs'] as num).toInt(),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AssessmentAnswerToJson(_AssessmentAnswer instance) =>
    <String, dynamic>{
      'questionIndex': instance.questionIndex,
      'questionId': instance.questionId,
      'userAnswer': instance.userAnswer,
      'correctAnswer': instance.correctAnswer,
      'isCorrect': instance.isCorrect,
      'responseTimeMs': instance.responseTimeMs,
      'answeredAt': instance.answeredAt.toIso8601String(),
      'metadata': instance.metadata,
    };
