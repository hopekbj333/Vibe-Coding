// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_sampling_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssessmentQuestion _$AssessmentQuestionFromJson(Map<String, dynamic> json) =>
    _AssessmentQuestion(
      questionNumber: (json['questionNumber'] as num).toInt(),
      gameId: json['gameId'] as String,
      gameTitle: json['gameTitle'] as String,
      contentId: json['contentId'] as String,
      type: $enumDecode(_$TrainingContentTypeEnumMap, json['type']),
      pattern: $enumDecode(_$GamePatternEnumMap, json['pattern']),
      itemId: json['itemId'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => ContentOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      difficulty: json['difficulty'] == null
          ? null
          : DifficultyParams.fromJson(
              json['difficulty'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssessmentQuestionToJson(_AssessmentQuestion instance) =>
    <String, dynamic>{
      'questionNumber': instance.questionNumber,
      'gameId': instance.gameId,
      'gameTitle': instance.gameTitle,
      'contentId': instance.contentId,
      'type': _$TrainingContentTypeEnumMap[instance.type]!,
      'pattern': _$GamePatternEnumMap[instance.pattern]!,
      'itemId': instance.itemId,
      'question': instance.question,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'difficulty': instance.difficulty,
    };

const _$TrainingContentTypeEnumMap = {
  TrainingContentType.phonological: 'phonological',
  TrainingContentType.auditory: 'auditory',
  TrainingContentType.visual: 'visual',
  TrainingContentType.sensory: 'sensory',
  TrainingContentType.executive: 'executive',
  TrainingContentType.workingMemory: 'workingMemory',
  TrainingContentType.attention: 'attention',
  TrainingContentType.vocabulary: 'vocabulary',
  TrainingContentType.comprehension: 'comprehension',
};

const _$GamePatternEnumMap = {
  GamePattern.oxQuiz: 'oxQuiz',
  GamePattern.multipleChoice: 'multipleChoice',
  GamePattern.matching: 'matching',
  GamePattern.sequencing: 'sequencing',
  GamePattern.goNoGo: 'goNoGo',
  GamePattern.rhythmTap: 'rhythmTap',
  GamePattern.recording: 'recording',
};
