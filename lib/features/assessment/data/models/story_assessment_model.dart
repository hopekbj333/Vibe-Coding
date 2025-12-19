import 'package:freezed_annotation/freezed_annotation.dart';
import 'assessment_session_model.dart';
import '../services/assessment_sampling_service.dart';
import 'dart:convert';

part 'story_assessment_model.freezed.dart';
part 'story_assessment_model.g.dart';

/// 스토리 테마
enum StoryTheme {
  hangeulLand, // 한글 나라 모험
  // 추후 추가: spaceAdventure, animalKingdom 등
}

/// 스토리 챕터 타입
enum StoryChapterType {
  phonologicalAwareness, // 음운인식능력 (15개)
  phonologicalProcessing, // 음운처리능력 (20개)
}

/// 스토리 진행 상태
enum StoryProgressStatus {
  notStarted, // 시작 전
  inChapter, // 챕터 진행 중
  chapterComplete, // 챕터 완료
  completed, // 전체 완료
  paused, // 일시 중지
  abandoned, // 중도 포기
}

/// 스토리형 검사 세션
@freezed
class StoryAssessmentSession with _$StoryAssessmentSession {
  const StoryAssessmentSession._();

  const factory StoryAssessmentSession({
    required String sessionId,
    required String childId,
    required StoryTheme theme,
    required DateTime startedAt,
    DateTime? completedAt,
    required StoryProgressStatus status,
    required List<StoryChapter> chapters,
    required int currentChapterIndex,
    required int currentQuestionIndex,
    required StoryProgress progress,
  }) = _StoryAssessmentSession;

  /// 전체 문항 수 (35개)
  int get totalQuestions => 35;

  /// 완료한 문항 수
  int get completedQuestions => progress.completedQuestions.length;

  /// 진행률 (0.0 ~ 1.0)
  double get progressRatio => completedQuestions / totalQuestions;

  /// 현재 챕터
  StoryChapter? get currentChapter {
    if (currentChapterIndex >= 0 && currentChapterIndex < chapters.length) {
      return chapters[currentChapterIndex];
    }
    return null;
  }

  /// 현재 문항
  StoryQuestion? get currentQuestion {
    final chapter = currentChapter;
    if (chapter != null &&
        currentQuestionIndex >= 0 &&
        currentQuestionIndex < chapter.questions.length) {
      return chapter.questions[currentQuestionIndex];
    }
    return null;
  }

  factory StoryAssessmentSession.fromJson(Map<String, dynamic> json) =>
      _$StoryAssessmentSessionFromJson(json);
}

/// 스토리 챕터
@freezed
class StoryChapter with _$StoryChapter {
  const StoryChapter._();

  const factory StoryChapter({
    required String chapterId,
    required String title, // "소리 섬", "기억 바다" 등
    required String description,
    required StoryChapterType type,
    required List<StoryQuestion> questions,
    required String introDialogue, // 한글 캐릭터의 인트로 대사
    required String completeDialogue, // 챕터 완료 대사
    required StoryReward reward, // 완료 시 보상
  }) = _StoryChapter;

  /// 문항 수
  int get questionCount => questions.length;

  factory StoryChapter.fromJson(Map<String, dynamic> json) =>
      _$StoryChapterFromJson(json);
}

/// 스토리 문항
@freezed
class StoryQuestion with _$StoryQuestion {
  const factory StoryQuestion({
    required String questionId,
    required String abilityId, // 35개 능력 중 하나 (예: "0.1", "1.1")
    required String abilityName, // 능력명
    required String storyContext, // 스토리 맥락 설명
    required String characterDialogue, // 캐릭터 대사
    @JsonKey(toJson: _assessmentQuestionToJson, fromJson: _assessmentQuestionFromJson)
    required AssessmentQuestion question, // 실제 검사 문항
    String? stageTitle, // Stage 제목 (예: "Stage 1-1: 기초 청각 능력")
    String? questionAudioPath, // 문항 오디오 경로
  }) = _StoryQuestion;

  static Map<String, dynamic> _assessmentQuestionToJson(AssessmentQuestion question) =>
      question.toJson();
  
  static AssessmentQuestion _assessmentQuestionFromJson(Map<String, dynamic> json) =>
      AssessmentQuestion.fromJson(json);

  factory StoryQuestion.fromJson(Map<String, dynamic> json) =>
      _$StoryQuestionFromJson(json);
}

/// 스토리 보상
@freezed
class StoryReward with _$StoryReward {
  const factory StoryReward({
    required int stars, // 별 개수
    String? badge, // 배지 이름 (선택)
    required String message, // 보상 메시지
  }) = _StoryReward;

  factory StoryReward.fromJson(Map<String, dynamic> json) =>
      _$StoryRewardFromJson(json);
}

/// 스토리 진행 상황
@freezed
class StoryProgress with _$StoryProgress {
  const StoryProgress._();

  const factory StoryProgress({
    required List<String> completedQuestions, // 완료한 문항 ID 리스트
    required Map<String, bool> questionResults, // 문항별 정답 여부
    required Map<String, int> questionResponseTimes, // 문항별 응답 시간 (ms)
    required List<String> completedChapters, // 완료한 챕터 ID 리스트
    required int totalStars, // 획득한 별 총 개수
  }) = _StoryProgress;

  /// 정답 개수
  int get correctCount =>
      questionResults.values.where((isCorrect) => isCorrect).length;

  /// 정답률
  double get accuracy {
    if (questionResults.isEmpty) return 0.0;
    return correctCount / questionResults.length;
  }

  factory StoryProgress.fromJson(Map<String, dynamic> json) =>
      _$StoryProgressFromJson(json);
}

