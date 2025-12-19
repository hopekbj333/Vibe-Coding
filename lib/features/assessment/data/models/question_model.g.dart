// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    _QuestionModel(
      id: json['id'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      promptText: json['promptText'] as String,
      promptAudioUrl: json['promptAudioUrl'] as String,
      optionsImageUrl:
          (json['optionsImageUrl'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      optionsText:
          (json['optionsText'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctAnswer: json['correctAnswer'],
      timeLimitSeconds: (json['timeLimitSeconds'] as num?)?.toInt() ?? 10,
      soundUrls:
          (json['soundUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      soundLabels:
          (json['soundLabels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QuestionModelToJson(_QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'promptText': instance.promptText,
      'promptAudioUrl': instance.promptAudioUrl,
      'optionsImageUrl': instance.optionsImageUrl,
      'optionsText': instance.optionsText,
      'correctAnswer': instance.correctAnswer,
      'timeLimitSeconds': instance.timeLimitSeconds,
      'soundUrls': instance.soundUrls,
      'soundLabels': instance.soundLabels,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.choice: 'choice',
  QuestionType.ordering: 'ordering',
  QuestionType.recording: 'recording',
  QuestionType.soundIdentification: 'soundIdentification',
  QuestionType.rhythmTap: 'rhythmTap',
  QuestionType.intonation: 'intonation',
  QuestionType.wordBoundary: 'wordBoundary',
  QuestionType.rhyme: 'rhyme',
  QuestionType.syllableBlending: 'syllableBlending',
  QuestionType.syllableDeletion: 'syllableDeletion',
  QuestionType.syllableReverse: 'syllableReverse',
  QuestionType.phonemeInitial: 'phonemeInitial',
  QuestionType.phonemeBlending: 'phonemeBlending',
  QuestionType.phonemeSubstitution: 'phonemeSubstitution',
  QuestionType.nonwordRepeat: 'nonwordRepeat',
  QuestionType.memorySpan: 'memorySpan',
  QuestionType.soundSequence: 'soundSequence',
  QuestionType.animalSoundSequence: 'animalSoundSequence',
  QuestionType.positionSequence: 'positionSequence',
  QuestionType.findDifferent: 'findDifferent',
  QuestionType.findSameShape: 'findSameShape',
  QuestionType.findDifferentDirection: 'findDifferentDirection',
  QuestionType.hiddenPicture: 'hiddenPicture',
  QuestionType.digitSpanForward: 'digitSpanForward',
  QuestionType.digitSpanBackward: 'digitSpanBackward',
  QuestionType.wordSpanForward: 'wordSpanForward',
  QuestionType.wordSpanBackward: 'wordSpanBackward',
  QuestionType.goNoGo: 'goNoGo',
  QuestionType.goNoGoAuditory: 'goNoGoAuditory',
  QuestionType.continuousPerformance: 'continuousPerformance',
};

_AnswerData _$AnswerDataFromJson(Map<String, dynamic> json) => _AnswerData(
  questionId: json['questionId'] as String,
  selectedAnswer: json['selectedAnswer'],
  reactionTimeMs: (json['reactionTimeMs'] as num).toInt(),
  answeredAt: DateTime.parse(json['answeredAt'] as String),
  recordingPath: json['recordingPath'] as String?,
);

Map<String, dynamic> _$AnswerDataToJson(_AnswerData instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'selectedAnswer': instance.selectedAnswer,
      'reactionTimeMs': instance.reactionTimeMs,
      'answeredAt': instance.answeredAt.toIso8601String(),
      'recordingPath': instance.recordingPath,
    };
