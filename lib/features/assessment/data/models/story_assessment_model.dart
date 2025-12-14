import 'package:equatable/equatable.dart';
import 'assessment_session_model.dart';
import '../services/assessment_sampling_service.dart';

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
class StoryAssessmentSession extends Equatable {
  final String sessionId;
  final String childId;
  final StoryTheme theme;
  final DateTime startedAt;
  final DateTime? completedAt;
  final StoryProgressStatus status;
  final List<StoryChapter> chapters;
  final int currentChapterIndex;
  final int currentQuestionIndex;
  final StoryProgress progress;

  const StoryAssessmentSession({
    required this.sessionId,
    required this.childId,
    required this.theme,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.chapters,
    required this.currentChapterIndex,
    required this.currentQuestionIndex,
    required this.progress,
  });

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

  @override
  List<Object?> get props => [
        sessionId,
        childId,
        theme,
        startedAt,
        completedAt,
        status,
        chapters,
        currentChapterIndex,
        currentQuestionIndex,
        progress,
      ];

  StoryAssessmentSession copyWith({
    String? sessionId,
    String? childId,
    StoryTheme? theme,
    DateTime? startedAt,
    DateTime? completedAt,
    StoryProgressStatus? status,
    List<StoryChapter>? chapters,
    int? currentChapterIndex,
    int? currentQuestionIndex,
    StoryProgress? progress,
  }) {
    return StoryAssessmentSession(
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      theme: theme ?? this.theme,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'childId': childId,
      'theme': theme.toString(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.toString(),
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'currentChapterIndex': currentChapterIndex,
      'currentQuestionIndex': currentQuestionIndex,
      'progress': progress.toJson(),
    };
  }

  factory StoryAssessmentSession.fromJson(Map<String, dynamic> json) {
    return StoryAssessmentSession(
      sessionId: json['sessionId'] as String,
      childId: json['childId'] as String,
      theme: StoryTheme.values.firstWhere(
        (e) => e.toString() == json['theme'],
        orElse: () => StoryTheme.hangeulLand,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      status: StoryProgressStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => StoryProgressStatus.notStarted,
      ),
      chapters: (json['chapters'] as List)
          .map((c) => StoryChapter.fromJson(c as Map<String, dynamic>))
          .toList(),
      currentChapterIndex: json['currentChapterIndex'] as int,
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      progress: StoryProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );
  }
}

/// 스토리 챕터
class StoryChapter extends Equatable {
  final String chapterId;
  final String title; // "소리 섬", "기억 바다" 등
  final String description;
  final StoryChapterType type;
  final List<StoryQuestion> questions;
  final String introDialogue; // 한글 캐릭터의 인트로 대사
  final String completeDialogue; // 챕터 완료 대사
  final StoryReward reward; // 완료 시 보상

  const StoryChapter({
    required this.chapterId,
    required this.title,
    required this.description,
    required this.type,
    required this.questions,
    required this.introDialogue,
    required this.completeDialogue,
    required this.reward,
  });

  /// 문항 수
  int get questionCount => questions.length;

  @override
  List<Object?> get props => [
        chapterId,
        title,
        description,
        type,
        questions,
        introDialogue,
        completeDialogue,
        reward,
      ];

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'introDialogue': introDialogue,
      'completeDialogue': completeDialogue,
      'reward': reward.toJson(),
    };
  }

  factory StoryChapter.fromJson(Map<String, dynamic> json) {
    return StoryChapter(
      chapterId: json['chapterId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: StoryChapterType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => StoryChapterType.phonologicalAwareness,
      ),
      questions: (json['questions'] as List)
          .map((q) => StoryQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      introDialogue: json['introDialogue'] as String,
      completeDialogue: json['completeDialogue'] as String,
      reward: StoryReward.fromJson(json['reward'] as Map<String, dynamic>),
    );
  }
}

/// 스토리 문항
class StoryQuestion extends Equatable {
  final String questionId;
  final String abilityId; // 35개 능력 중 하나 (예: "0.1", "1.1")
  final String abilityName; // 능력명
  final String storyContext; // 스토리 맥락 설명
  final String characterDialogue; // 캐릭터 대사
  final AssessmentQuestion question; // 실제 검사 문항
  final StoryFeedback feedback; // 피드백 메시지
  final String? stageTitle; // Stage 제목 (예: "Stage 1-1: 기초 청각 능력")
  final String? questionAudioPath; // 문항 오디오 경로

  const StoryQuestion({
    required this.questionId,
    required this.abilityId,
    required this.abilityName,
    required this.storyContext,
    required this.characterDialogue,
    required this.question,
    required this.feedback,
    this.stageTitle,
    this.questionAudioPath,
  });

  @override
  List<Object?> get props => [
        questionId,
        abilityId,
        abilityName,
        storyContext,
        characterDialogue,
        question,
        feedback,
        stageTitle,
        questionAudioPath,
      ];

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'abilityId': abilityId,
      'abilityName': abilityName,
      'storyContext': storyContext,
      'characterDialogue': characterDialogue,
      'question': question.toJson(),
      'feedback': feedback.toJson(),
      'stageTitle': stageTitle,
      'questionAudioPath': questionAudioPath,
    };
  }

  factory StoryQuestion.fromJson(Map<String, dynamic> json) {
    return StoryQuestion(
      questionId: json['questionId'] as String,
      abilityId: json['abilityId'] as String,
      abilityName: json['abilityName'] as String,
      storyContext: json['storyContext'] as String,
      characterDialogue: json['characterDialogue'] as String,
      question: AssessmentQuestion.fromJson(
        json['question'] as Map<String, dynamic>,
      ),
      feedback: StoryFeedback.fromJson(
        json['feedback'] as Map<String, dynamic>,
      ),
      stageTitle: json['stageTitle'] as String?,
      questionAudioPath: json['questionAudioPath'] as String?,
    );
  }
}

/// 스토리 피드백
class StoryFeedback extends Equatable {
  final String correctMessage; // 정답 시 메시지
  final String incorrectMessage; // 오답 시 메시지
  final String? correctEmoji; // 정답 시 이모지
  final String? incorrectEmoji; // 오답 시 이모지

  const StoryFeedback({
    required this.correctMessage,
    required this.incorrectMessage,
    this.correctEmoji,
    this.incorrectEmoji,
  });

  @override
  List<Object?> get props => [
        correctMessage,
        incorrectMessage,
        correctEmoji,
        incorrectEmoji,
      ];

  Map<String, dynamic> toJson() {
    return {
      'correctMessage': correctMessage,
      'incorrectMessage': incorrectMessage,
      'correctEmoji': correctEmoji,
      'incorrectEmoji': incorrectEmoji,
    };
  }

  factory StoryFeedback.fromJson(Map<String, dynamic> json) {
    return StoryFeedback(
      correctMessage: json['correctMessage'] as String,
      incorrectMessage: json['incorrectMessage'] as String,
      correctEmoji: json['correctEmoji'] as String?,
      incorrectEmoji: json['incorrectEmoji'] as String?,
    );
  }
}

/// 스토리 보상
class StoryReward extends Equatable {
  final int stars; // 별 개수
  final String? badge; // 배지 이름 (선택)
  final String message; // 보상 메시지

  const StoryReward({
    required this.stars,
    this.badge,
    required this.message,
  });

  @override
  List<Object?> get props => [stars, badge, message];

  Map<String, dynamic> toJson() {
    return {
      'stars': stars,
      'badge': badge,
      'message': message,
    };
  }

  factory StoryReward.fromJson(Map<String, dynamic> json) {
    return StoryReward(
      stars: json['stars'] as int,
      badge: json['badge'] as String?,
      message: json['message'] as String,
    );
  }
}

/// 스토리 진행 상황
class StoryProgress extends Equatable {
  final List<String> completedQuestions; // 완료한 문항 ID 리스트
  final Map<String, bool> questionResults; // 문항별 정답 여부
  final Map<String, int> questionResponseTimes; // 문항별 응답 시간 (ms)
  final List<String> completedChapters; // 완료한 챕터 ID 리스트
  final int totalStars; // 획득한 별 총 개수

  const StoryProgress({
    required this.completedQuestions,
    required this.questionResults,
    required this.questionResponseTimes,
    required this.completedChapters,
    required this.totalStars,
  });

  /// 정답 개수
  int get correctCount =>
      questionResults.values.where((isCorrect) => isCorrect).length;

  /// 정답률
  double get accuracy {
    if (questionResults.isEmpty) return 0.0;
    return correctCount / questionResults.length;
  }

  @override
  List<Object?> get props => [
        completedQuestions,
        questionResults,
        questionResponseTimes,
        completedChapters,
        totalStars,
      ];

  StoryProgress copyWith({
    List<String>? completedQuestions,
    Map<String, bool>? questionResults,
    Map<String, int>? questionResponseTimes,
    List<String>? completedChapters,
    int? totalStars,
  }) {
    return StoryProgress(
      completedQuestions: completedQuestions ?? this.completedQuestions,
      questionResults: questionResults ?? this.questionResults,
      questionResponseTimes: questionResponseTimes ?? this.questionResponseTimes,
      completedChapters: completedChapters ?? this.completedChapters,
      totalStars: totalStars ?? this.totalStars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedQuestions': completedQuestions,
      'questionResults': questionResults,
      'questionResponseTimes': questionResponseTimes,
      'completedChapters': completedChapters,
      'totalStars': totalStars,
    };
  }

  factory StoryProgress.fromJson(Map<String, dynamic> json) {
    return StoryProgress(
      completedQuestions: List<String>.from(json['completedQuestions'] as List),
      questionResults: Map<String, bool>.from(
        json['questionResults'] as Map,
      ),
      questionResponseTimes: Map<String, int>.from(
        json['questionResponseTimes'] as Map,
      ),
      completedChapters: List<String>.from(json['completedChapters'] as List),
      totalStars: json['totalStars'] as int,
    );
  }
}

