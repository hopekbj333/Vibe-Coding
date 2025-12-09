import 'difficulty_params_model.dart';

/// 학습 콘텐츠 타입
enum TrainingContentType {
  phonological,    // 음운 인식
  auditory,        // 청각 처리
  visual,          // 시각 처리
  sensory,         // 감각 처리
  executive,       // 인지 제어
  workingMemory,   // 작업 기억
  attention,       // 주의력
  vocabulary,      // 어휘력
  comprehension,   // 이해력
}

/// 게임 패턴 타입 (WP 2.2에서 구현)
enum GamePattern {
  oxQuiz,          // O/X 퀴즈
  multipleChoice,  // 객관식 (이선다지/삼선다지)
  matching,        // 짝맞추기
  sequencing,      // 순서 맞추기
  goNoGo,          // Go/No-Go
  rhythmTap,       // 리듬 탭
  recording,       // 녹음/음성
}

/// 학습 콘텐츠 모델
/// 
/// 개별 학습 문제/게임의 정보를 담습니다.
/// Milestone 2 - WP 2.1
class TrainingContentModel {
  final String contentId;              // 콘텐츠 ID
  final String moduleId;               // 모듈 ID (예: 'phonological_basic')
  final TrainingContentType type;      // 콘텐츠 타입
  final GamePattern pattern;           // 게임 패턴
  final String title;                  // 제목 (관리자용)
  final String instruction;            // 지시문 (텍스트)
  final String? instructionAudioPath;  // 지시 음성 경로
  final List<ContentItem> items;       // 문제 항목들
  final DifficultyParams difficulty;   // 난이도 파라미터
  final Map<String, dynamic>? metadata;// 추가 메타데이터

  const TrainingContentModel({
    required this.contentId,
    required this.moduleId,
    required this.type,
    required this.pattern,
    required this.title,
    required this.instruction,
    this.instructionAudioPath,
    required this.items,
    required this.difficulty,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'contentId': contentId,
    'moduleId': moduleId,
    'type': type.name,
    'pattern': pattern.name,
    'title': title,
    'instruction': instruction,
    'instructionAudioPath': instructionAudioPath,
    'items': items.map((e) => e.toJson()).toList(),
    'difficulty': difficulty.toJson(),
    'metadata': metadata,
  };

  factory TrainingContentModel.fromJson(Map<String, dynamic> json) {
    return TrainingContentModel(
      contentId: json['contentId'] as String,
      moduleId: json['moduleId'] as String,
      type: TrainingContentType.values.firstWhere((e) => e.name == json['type']),
      pattern: GamePattern.values.firstWhere((e) => e.name == json['pattern']),
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      instructionAudioPath: json['instructionAudioPath'] as String?,
      items: (json['items'] as List).map((e) => ContentItem.fromJson(e as Map<String, dynamic>)).toList(),
      difficulty: DifficultyParams.fromJson(json['difficulty'] as Map<String, dynamic>),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 콘텐츠 항목 (개별 문제)
class ContentItem {
  final String itemId;              // 항목 ID
  final String question;            // 질문/자극
  final String? questionAudioPath;  // 질문 음성 경로
  final String? questionImagePath;  // 질문 이미지 경로
  final List<ContentOption> options;// 선택지 목록
  final String correctAnswer;       // 정답 (optionId)
  final String? explanation;        // 설명 (정답 후 표시)
  final String? explanationAudioPath;// 설명 음성 경로
  final Map<String, dynamic>? itemData;// 항목별 데이터

  const ContentItem({
    required this.itemId,
    required this.question,
    this.questionAudioPath,
    this.questionImagePath,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.explanationAudioPath,
    this.itemData,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'question': question,
    'questionAudioPath': questionAudioPath,
    'questionImagePath': questionImagePath,
    'options': options.map((e) => e.toJson()).toList(),
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'explanationAudioPath': explanationAudioPath,
    'itemData': itemData,
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      itemId: json['itemId'] as String,
      question: json['question'] as String,
      questionAudioPath: json['questionAudioPath'] as String?,
      questionImagePath: json['questionImagePath'] as String?,
      options: (json['options'] as List).map((e) => ContentOption.fromJson(e as Map<String, dynamic>)).toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String?,
      explanationAudioPath: json['explanationAudioPath'] as String?,
      itemData: json['itemData'] as Map<String, dynamic>?,
    );
  }
}

/// 콘텐츠 선택지
class ContentOption {
  final String optionId;         // 선택지 ID
  final String label;            // 레이블 (텍스트)
  final String? imagePath;       // 이미지 경로
  final String? audioPath;       // 오디오 경로
  final Map<String, dynamic>? optionData; // 선택지별 데이터

  const ContentOption({
    required this.optionId,
    required this.label,
    this.imagePath,
    this.audioPath,
    this.optionData,
  });

  Map<String, dynamic> toJson() => {
    'optionId': optionId,
    'label': label,
    'imagePath': imagePath,
    'audioPath': audioPath,
    'optionData': optionData,
  };

  factory ContentOption.fromJson(Map<String, dynamic> json) {
    return ContentOption(
      optionId: json['optionId'] as String,
      label: json['label'] as String,
      imagePath: json['imagePath'] as String?,
      audioPath: json['audioPath'] as String?,
      optionData: json['optionData'] as Map<String, dynamic>?,
    );
  }
}

/// 학습 결과 모델
class TrainingResultModel {
  final String resultId;            // 결과 ID
  final String sessionId;           // 세션 ID
  final String childId;             // 아동 ID
  final String moduleId;            // 모듈 ID
  final DateTime startedAt;         // 시작 시간
  final DateTime completedAt;       // 완료 시간
  final int totalQuestions;         // 전체 문제 수
  final int correctCount;           // 정답 수
  final int incorrectCount;         // 오답 수
  final List<QuestionResult> questionResults; // 문제별 결과
  final int finalDifficultyLevel;   // 최종 난이도
  final Map<String, dynamic>? analytics;     // 분석 데이터

  const TrainingResultModel({
    required this.resultId,
    required this.sessionId,
    required this.childId,
    required this.moduleId,
    required this.startedAt,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.questionResults,
    required this.finalDifficultyLevel,
    this.analytics,
  });

  Map<String, dynamic> toJson() => {
    'resultId': resultId,
    'sessionId': sessionId,
    'childId': childId,
    'moduleId': moduleId,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    'totalQuestions': totalQuestions,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'questionResults': questionResults.map((e) => e.toJson()).toList(),
    'finalDifficultyLevel': finalDifficultyLevel,
    'analytics': analytics,
  };

  factory TrainingResultModel.fromJson(Map<String, dynamic> json) {
    return TrainingResultModel(
      resultId: json['resultId'] as String,
      sessionId: json['sessionId'] as String,
      childId: json['childId'] as String,
      moduleId: json['moduleId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      totalQuestions: json['totalQuestions'] as int,
      correctCount: json['correctCount'] as int,
      incorrectCount: json['incorrectCount'] as int,
      questionResults: (json['questionResults'] as List).map((e) => QuestionResult.fromJson(e as Map<String, dynamic>)).toList(),
      finalDifficultyLevel: json['finalDifficultyLevel'] as int,
      analytics: json['analytics'] as Map<String, dynamic>?,
    );
  }
}

/// 문제별 결과
class QuestionResult {
  final String itemId;           // 항목 ID
  final String userAnswer;       // 사용자 답변
  final String correctAnswer;    // 정답
  final bool isCorrect;          // 정답 여부
  final int responseTime;        // 반응 시간 (ms)
  final int difficultyLevel;     // 문제의 난이도
  final DateTime? answeredAt;    // 답변 시간
  final int? attemptCount;       // 시도 횟수 (재시도한 경우)

  const QuestionResult({
    required this.itemId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.responseTime,
    required this.difficultyLevel,
    this.answeredAt,
    this.attemptCount,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'userAnswer': userAnswer,
    'correctAnswer': correctAnswer,
    'isCorrect': isCorrect,
    'responseTime': responseTime,
    'difficultyLevel': difficultyLevel,
    'answeredAt': answeredAt?.toIso8601String(),
    'attemptCount': attemptCount,
  };

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      itemId: json['itemId'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      responseTime: json['responseTime'] as int,
      difficultyLevel: json['difficultyLevel'] as int,
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt'] as String) : null,
      attemptCount: json['attemptCount'] as int?,
    );
  }
}

/// 콘텐츠 타입별 한글명
extension TrainingContentTypeX on TrainingContentType {
  String get koreanName {
    switch (this) {
      case TrainingContentType.phonological:
        return '음운 인식';
      case TrainingContentType.auditory:
        return '청각 처리';
      case TrainingContentType.visual:
        return '시각 처리';
      case TrainingContentType.sensory:
        return '감각 처리';
      case TrainingContentType.executive:
        return '인지 제어';
      case TrainingContentType.workingMemory:
        return '작업 기억';
      case TrainingContentType.attention:
        return '주의력';
      case TrainingContentType.vocabulary:
        return '어휘력';
      case TrainingContentType.comprehension:
        return '이해력';
    }
  }

  String get description {
    switch (this) {
      case TrainingContentType.phonological:
        return '소리를 듣고 구별하는 능력';
      case TrainingContentType.auditory:
        return '소리 정보를 처리하는 능력';
      case TrainingContentType.visual:
        return '시각 정보를 처리하는 능력';
      case TrainingContentType.sensory:
        return '감각 정보를 처리하는 능력';
      case TrainingContentType.executive:
        return '집중력과 자기 조절 능력';
      case TrainingContentType.workingMemory:
        return '정보를 기억하고 조작하는 능력';
      case TrainingContentType.attention:
        return '집중하고 선택적으로 반응하는 능력';
      case TrainingContentType.vocabulary:
        return '낱말의 의미를 이해하는 능력';
      case TrainingContentType.comprehension:
        return '글의 내용을 이해하는 능력';
    }
  }
}

/// 게임 패턴별 한글명
extension GamePatternX on GamePattern {
  String get koreanName {
    switch (this) {
      case GamePattern.oxQuiz:
        return 'O/X 퀴즈';
      case GamePattern.multipleChoice:
        return '고르기';
      case GamePattern.matching:
        return '짝맞추기';
      case GamePattern.sequencing:
        return '순서 맞추기';
      case GamePattern.goNoGo:
        return '반응하기';
      case GamePattern.rhythmTap:
        return '리듬 따라하기';
      case GamePattern.recording:
        return '녹음하기';
    }
  }
}
