// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_assessment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoryAssessmentSession _$StoryAssessmentSessionFromJson(
        Map<String, dynamic> json) =>
    _StoryAssessmentSession(
      sessionId: json['sessionId'] as String,
      childId: json['childId'] as String,
      theme: $enumDecode(_$StoryThemeEnumMap, json['theme']),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      status: $enumDecode(_$StoryProgressStatusEnumMap, json['status']),
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => StoryChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentChapterIndex: (json['currentChapterIndex'] as num).toInt(),
      currentQuestionIndex: (json['currentQuestionIndex'] as num).toInt(),
      progress:
          StoryProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoryAssessmentSessionToJson(
        _StoryAssessmentSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'childId': instance.childId,
      'theme': _$StoryThemeEnumMap[instance.theme]!,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'status': _$StoryProgressStatusEnumMap[instance.status]!,
      'chapters': instance.chapters,
      'currentChapterIndex': instance.currentChapterIndex,
      'currentQuestionIndex': instance.currentQuestionIndex,
      'progress': instance.progress,
    };

const _$StoryThemeEnumMap = {
  StoryTheme.hangeulLand: 'hangeulLand',
};

const _$StoryProgressStatusEnumMap = {
  StoryProgressStatus.notStarted: 'notStarted',
  StoryProgressStatus.inChapter: 'inChapter',
  StoryProgressStatus.chapterComplete: 'chapterComplete',
  StoryProgressStatus.completed: 'completed',
  StoryProgressStatus.paused: 'paused',
  StoryProgressStatus.abandoned: 'abandoned',
};

_StoryChapter _$StoryChapterFromJson(Map<String, dynamic> json) =>
    _StoryChapter(
      chapterId: json['chapterId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$StoryChapterTypeEnumMap, json['type']),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => StoryQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      introDialogue: json['introDialogue'] as String,
      completeDialogue: json['completeDialogue'] as String,
      reward: StoryReward.fromJson(json['reward'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoryChapterToJson(_StoryChapter instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'title': instance.title,
      'description': instance.description,
      'type': _$StoryChapterTypeEnumMap[instance.type]!,
      'questions': instance.questions,
      'introDialogue': instance.introDialogue,
      'completeDialogue': instance.completeDialogue,
      'reward': instance.reward,
    };

const _$StoryChapterTypeEnumMap = {
  StoryChapterType.phonologicalAwareness: 'phonologicalAwareness',
  StoryChapterType.phonologicalProcessing: 'phonologicalProcessing',
};

_StoryQuestion _$StoryQuestionFromJson(Map<String, dynamic> json) =>
    _StoryQuestion(
      questionId: json['questionId'] as String,
      abilityId: json['abilityId'] as String,
      abilityName: json['abilityName'] as String,
      storyContext: json['storyContext'] as String,
      characterDialogue: json['characterDialogue'] as String,
      question:
          AssessmentQuestion.fromJson(json['question'] as Map<String, dynamic>),
      stageTitle: json['stageTitle'] as String?,
      questionAudioPath: json['questionAudioPath'] as String?,
    );

Map<String, dynamic> _$StoryQuestionToJson(_StoryQuestion instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'abilityId': instance.abilityId,
      'abilityName': instance.abilityName,
      'storyContext': instance.storyContext,
      'characterDialogue': instance.characterDialogue,
      'question': instance.question,
      'stageTitle': instance.stageTitle,
      'questionAudioPath': instance.questionAudioPath,
    };

_StoryReward _$StoryRewardFromJson(Map<String, dynamic> json) => _StoryReward(
      stars: (json['stars'] as num).toInt(),
      badge: json['badge'] as String?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$StoryRewardToJson(_StoryReward instance) =>
    <String, dynamic>{
      'stars': instance.stars,
      'badge': instance.badge,
      'message': instance.message,
    };

_StoryProgress _$StoryProgressFromJson(Map<String, dynamic> json) =>
    _StoryProgress(
      completedQuestions: (json['completedQuestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      questionResults: Map<String, bool>.from(json['questionResults'] as Map),
      questionResponseTimes:
          Map<String, int>.from(json['questionResponseTimes'] as Map),
      completedChapters: (json['completedChapters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalStars: (json['totalStars'] as num).toInt(),
    );

Map<String, dynamic> _$StoryProgressToJson(_StoryProgress instance) =>
    <String, dynamic>{
      'completedQuestions': instance.completedQuestions,
      'questionResults': instance.questionResults,
      'questionResponseTimes': instance.questionResponseTimes,
      'completedChapters': instance.completedChapters,
      'totalStars': instance.totalStars,
    };
