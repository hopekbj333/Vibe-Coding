/// WP 3.6: 장기 추적 시스템 - 데이터 모델

/// 학습 세션 기록
class LearningSessionRecord {
  final String id;
  final String childId;
  final DateTime date;
  final int durationMinutes;
  final List<String> completedGames;
  final double averageAccuracy;
  final int totalQuestions;
  final int correctAnswers;

  LearningSessionRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.durationMinutes,
    required this.completedGames,
    required this.averageAccuracy,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory LearningSessionRecord.fromJson(Map<String, dynamic> json) {
    return LearningSessionRecord(
      id: json['id'] as String,
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      completedGames: List<String>.from(json['completedGames'] as List),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completedGames': completedGames,
      'averageAccuracy': averageAccuracy,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
    };
  }
}

/// 검사/테스트 결과 기록
class AssessmentRecord {
  final String id;
  final String childId;
  final DateTime date;
  final AssessmentType type;
  final Map<String, double> domainScores; // 영역별 점수
  final double totalScore;
  final String? notes;

  AssessmentRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.type,
    required this.domainScores,
    required this.totalScore,
    this.notes,
  });

  factory AssessmentRecord.fromJson(Map<String, dynamic> json) {
    return AssessmentRecord(
      id: json['id'] as String,
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      type: AssessmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssessmentType.fullAssessment,
      ),
      domainScores: Map<String, double>.from(
        (json['domainScores'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      totalScore: (json['totalScore'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'type': type.name,
      'domainScores': domainScores,
      'totalScore': totalScore,
      'notes': notes,
    };
  }
}

enum AssessmentType {
  fullAssessment,  // 정기 검사
  miniTest,        // 미니 테스트
  retest,          // 재검사
}

/// 배지/업적
class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final String condition;
  final int requiredValue;
  final DateTime? earnedAt;

  AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.condition,
    required this.requiredValue,
    this.earnedAt,
  });

  bool get isEarned => earnedAt != null;

  AchievementBadge copyWith({DateTime? earnedAt}) {
    return AchievementBadge(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      category: category,
      condition: condition,
      requiredValue: requiredValue,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  factory AchievementBadge.fromJson(Map<String, dynamic> json) {
    return AchievementBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BadgeCategory.streak,
      ),
      condition: json['condition'] as String,
      requiredValue: json['requiredValue'] as int,
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'category': category.name,
      'condition': condition,
      'requiredValue': requiredValue,
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }
}

enum BadgeCategory {
  streak,     // 연속 학습
  accuracy,   // 정확도
  mastery,    // 게임 마스터
  growth,     // 성장
  time,       // 학습 시간
}

/// 레벨 정보
class LevelInfo {
  final int currentLevel;
  final int currentXP;
  final int xpToNextLevel;
  final String characterEmoji;
  final String characterName;

  LevelInfo({
    required this.currentLevel,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.characterEmoji,
    required this.characterName,
  });

  double get progressPercent => currentXP / xpToNextLevel;

  static LevelInfo initial() {
    return LevelInfo(
      currentLevel: 1,
      currentXP: 0,
      xpToNextLevel: 100,
      characterEmoji: '🐣',
      characterName: '아기 병아리',
    );
  }

  LevelInfo addXP(int xp) {
    int newXP = currentXP + xp;
    int newLevel = currentLevel;
    int newXpToNext = xpToNextLevel;

    while (newXP >= newXpToNext) {
      newXP -= newXpToNext;
      newLevel++;
      newXpToNext = _calculateXPForLevel(newLevel);
    }

    return LevelInfo(
      currentLevel: newLevel,
      currentXP: newXP,
      xpToNextLevel: newXpToNext,
      characterEmoji: _getCharacterEmoji(newLevel),
      characterName: _getCharacterName(newLevel),
    );
  }

  static int _calculateXPForLevel(int level) {
    return 100 + (level - 1) * 25;
  }

  static String _getCharacterEmoji(int level) {
    if (level < 5) return '🐣';
    if (level < 10) return '🐥';
    if (level < 20) return '🐔';
    if (level < 30) return '🦅';
    return '🦋';
  }

  static String _getCharacterName(int level) {
    if (level < 5) return '아기 병아리';
    if (level < 10) return '노란 병아리';
    if (level < 20) return '씩씩한 닭';
    if (level < 30) return '멋진 독수리';
    return '아름다운 나비';
  }

  factory LevelInfo.fromJson(Map<String, dynamic> json) {
    return LevelInfo(
      currentLevel: json['currentLevel'] as int,
      currentXP: json['currentXP'] as int,
      xpToNextLevel: json['xpToNextLevel'] as int,
      characterEmoji: json['characterEmoji'] as String,
      characterName: json['characterName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'currentXP': currentXP,
      'xpToNextLevel': xpToNextLevel,
      'characterEmoji': characterEmoji,
      'characterName': characterName,
    };
  }
}

/// 타임라인 이벤트
class TimelineEvent {
  final String id;
  final DateTime date;
  final TimelineEventType type;
  final String title;
  final String description;
  final Map<String, dynamic>? metadata;

  TimelineEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    this.metadata,
  });
}

enum TimelineEventType {
  assessment,
  miniTest,
  achievement,
  levelUp,
  milestone,
}

/// 성장 데이터 포인트
class GrowthDataPoint {
  final DateTime date;
  final Map<String, double> domainScores;
  final double totalScore;

  GrowthDataPoint({
    required this.date,
    required this.domainScores,
    required this.totalScore,
  });
}

