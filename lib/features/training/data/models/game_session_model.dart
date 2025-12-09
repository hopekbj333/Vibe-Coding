/// 학습 세션 상태
enum SessionStatus {
  idle,       // 대기 중
  loading,    // 로딩 중
  playing,    // 진행 중
  paused,     // 일시정지
  completed,  // 완료
  error,      // 오류
}

/// 게임 세션 모델
/// 
/// 아이가 학습 게임을 하는 동안의 전체 진행 상황을 관리합니다.
/// Milestone 2 - WP 2.1 (S 2.1.3)
class GameSessionModel {
  final String sessionId;           // 세션 고유 ID
  final String childId;             // 아동 ID
  final String moduleId;            // 학습 모듈 ID (예: 'phonological_basic')
  final SessionStatus status;       // 현재 상태
  final int currentLevel;           // 현재 레벨 (1부터 시작)
  final int currentQuestionIndex;   // 현재 문제 번호 (0부터 시작)
  final int totalQuestions;         // 전체 문제 수
  final int correctCount;           // 정답 수
  final int incorrectCount;         // 오답 수
  final DateTime startedAt;         // 시작 시간
  final DateTime? pausedAt;         // 일시정지 시간
  final DateTime? completedAt;      // 완료 시간
  final int currentDifficultyLevel; // 현재 난이도 (1~5)
  final Map<String, dynamic>? metadata;  // 추가 메타데이터

  const GameSessionModel({
    required this.sessionId,
    required this.childId,
    required this.moduleId,
    required this.status,
    required this.currentLevel,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.startedAt,
    this.pausedAt,
    this.completedAt,
    required this.currentDifficultyLevel,
    this.metadata,
  });

  GameSessionModel copyWith({
    String? sessionId,
    String? childId,
    String? moduleId,
    SessionStatus? status,
    int? currentLevel,
    int? currentQuestionIndex,
    int? totalQuestions,
    int? correctCount,
    int? incorrectCount,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? completedAt,
    int? currentDifficultyLevel,
    Map<String, dynamic>? metadata,
  }) {
    return GameSessionModel(
      sessionId: sessionId ?? this.sessionId,
      childId: childId ?? this.childId,
      moduleId: moduleId ?? this.moduleId,
      status: status ?? this.status,
      currentLevel: currentLevel ?? this.currentLevel,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      currentDifficultyLevel: currentDifficultyLevel ?? this.currentDifficultyLevel,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'childId': childId,
    'moduleId': moduleId,
    'status': status.name,
    'currentLevel': currentLevel,
    'currentQuestionIndex': currentQuestionIndex,
    'totalQuestions': totalQuestions,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'startedAt': startedAt.toIso8601String(),
    'pausedAt': pausedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'currentDifficultyLevel': currentDifficultyLevel,
    'metadata': metadata,
  };

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      sessionId: json['sessionId'] as String,
      childId: json['childId'] as String,
      moduleId: json['moduleId'] as String,
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
      currentLevel: json['currentLevel'] as int,
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctCount: json['correctCount'] as int,
      incorrectCount: json['incorrectCount'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      pausedAt: json['pausedAt'] != null ? DateTime.parse(json['pausedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      currentDifficultyLevel: json['currentDifficultyLevel'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (totalQuestions == 0) return 0.0;
    return currentQuestionIndex / totalQuestions;
  }

  /// 정답률 계산 (0.0 ~ 1.0)
  double get accuracy {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0.0;
    return correctCount / total;
  }

  /// 세션이 진행 중인지 확인
  bool get isPlaying => status == SessionStatus.playing;

  /// 세션이 완료되었는지 확인
  bool get isCompleted => status == SessionStatus.completed;

  /// 세션이 일시정지되었는지 확인
  bool get isPaused => status == SessionStatus.paused;

  /// 세션 시작
  GameSessionModel start() {
    return copyWith(
      status: SessionStatus.playing,
      startedAt: DateTime.now(),
    );
  }

  /// 세션 일시정지
  GameSessionModel pause() {
    return copyWith(
      status: SessionStatus.paused,
      pausedAt: DateTime.now(),
    );
  }

  /// 세션 재개
  GameSessionModel resume() {
    return copyWith(
      status: SessionStatus.playing,
      pausedAt: null,
    );
  }

  /// 다음 문제로 이동
  GameSessionModel nextQuestion() {
    return copyWith(
      currentQuestionIndex: currentQuestionIndex + 1,
    );
  }

  /// 정답 처리
  GameSessionModel addCorrect() {
    return copyWith(
      correctCount: correctCount + 1,
    );
  }

  /// 오답 처리
  GameSessionModel addIncorrect() {
    return copyWith(
      incorrectCount: incorrectCount + 1,
    );
  }

  /// 난이도 조정
  GameSessionModel adjustDifficulty(int newLevel) {
    return copyWith(
      currentDifficultyLevel: newLevel.clamp(1, 5),
    );
  }

  /// 세션 완료
  GameSessionModel complete() {
    return copyWith(
      status: SessionStatus.completed,
      completedAt: DateTime.now(),
    );
  }
}

/// 초기 세션 생성
GameSessionModel createGameSession({
  required String childId,
  required String moduleId,
  required int totalQuestions,
  int initialDifficulty = 2, // 기본 난이도는 중간(2)
}) {
  return GameSessionModel(
    sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
    childId: childId,
    moduleId: moduleId,
    status: SessionStatus.idle,
    currentLevel: 1,
    currentQuestionIndex: 0,
    totalQuestions: totalQuestions,
    correctCount: 0,
    incorrectCount: 0,
    startedAt: DateTime.now(),
    currentDifficultyLevel: initialDifficulty,
  );
}
