/// 학습 진도 모델
/// 
/// 단계별 진도, 잠금 해제 상태 관리
class LearningProgress {
  final String childId;
  final Map<String, StageProgress> stages;
  final int totalScore;
  final DateTime lastUpdated;

  LearningProgress({
    required this.childId,
    required this.stages,
    this.totalScore = 0,
    required this.lastUpdated,
  });

  LearningProgress copyWith({
    String? childId,
    Map<String, StageProgress>? stages,
    int? totalScore,
    DateTime? lastUpdated,
  }) {
    return LearningProgress(
      childId: childId ?? this.childId,
      stages: stages ?? this.stages,
      totalScore: totalScore ?? this.totalScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 특정 스테이지 잠금 해제 여부
  bool isStageUnlocked(String stageId) {
    return stages[stageId]?.isUnlocked ?? false;
  }

  /// 특정 스테이지 완료 여부
  bool isStageCompleted(String stageId) {
    return stages[stageId]?.isCompleted ?? false;
  }

  /// 전체 진도율 (0.0 ~ 1.0)
  double get overallProgress {
    if (stages.isEmpty) return 0.0;
    final completedCount = stages.values.where((s) => s.isCompleted).length;
    return completedCount / stages.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'stages': stages.map((k, v) => MapEntry(k, v.toJson())),
      'totalScore': totalScore,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      childId: json['childId'] as String,
      stages: (json['stages'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, StageProgress.fromJson(v as Map<String, dynamic>)),
      ),
      totalScore: json['totalScore'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// 기본 진도 생성
  factory LearningProgress.initial(String childId) {
    return LearningProgress(
      childId: childId,
      stages: {
        'phonological1': StageProgress(
          stageId: 'phonological1',
          stageName: '음운 인식 1단계',
          isUnlocked: true,
          requiredScore: 0,
        ),
        'phonological2': StageProgress(
          stageId: 'phonological2',
          stageName: '음운 인식 2단계',
          isUnlocked: false,
          requiredScore: 80,
        ),
        'phonological3': StageProgress(
          stageId: 'phonological3',
          stageName: '음운 인식 3단계',
          isUnlocked: false,
          requiredScore: 80,
        ),
      },
      lastUpdated: DateTime.now(),
    );
  }
}

/// 스테이지 진도
class StageProgress {
  final String stageId;
  final String stageName;
  final bool isUnlocked;
  final bool isCompleted;
  final int currentScore;
  final int requiredScore; // 다음 단계 잠금 해제에 필요한 점수
  final int completedGames;
  final int totalGames;
  final DateTime? completedAt;

  StageProgress({
    required this.stageId,
    required this.stageName,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.currentScore = 0,
    this.requiredScore = 80,
    this.completedGames = 0,
    this.totalGames = 6, // 각 단계별 게임 수
    this.completedAt,
  });

  StageProgress copyWith({
    String? stageId,
    String? stageName,
    bool? isUnlocked,
    bool? isCompleted,
    int? currentScore,
    int? requiredScore,
    int? completedGames,
    int? totalGames,
    DateTime? completedAt,
  }) {
    return StageProgress(
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      currentScore: currentScore ?? this.currentScore,
      requiredScore: requiredScore ?? this.requiredScore,
      completedGames: completedGames ?? this.completedGames,
      totalGames: totalGames ?? this.totalGames,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 스테이지 진행률 (0.0 ~ 1.0)
  double get progress {
    if (totalGames == 0) return 0.0;
    return completedGames / totalGames;
  }

  /// 다음 단계 잠금 해제 가능 여부
  bool get canUnlockNext => currentScore >= requiredScore;

  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'stageName': stageName,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'currentScore': currentScore,
      'requiredScore': requiredScore,
      'completedGames': completedGames,
      'totalGames': totalGames,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory StageProgress.fromJson(Map<String, dynamic> json) {
    return StageProgress(
      stageId: json['stageId'] as String,
      stageName: json['stageName'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentScore: json['currentScore'] as int? ?? 0,
      requiredScore: json['requiredScore'] as int? ?? 80,
      completedGames: json['completedGames'] as int? ?? 0,
      totalGames: json['totalGames'] as int? ?? 6,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

