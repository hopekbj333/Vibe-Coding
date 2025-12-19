// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssessmentModel _$AssessmentModelFromJson(Map<String, dynamic> json) =>
    _AssessmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
    );

Map<String, dynamic> _$AssessmentModelToJson(_AssessmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'questions': instance.questions,
      'totalQuestions': instance.totalQuestions,
    };
