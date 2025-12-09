/// 난이도 파라미터 모델
/// 
/// 게임의 난이도를 조절하는 다양한 파라미터를 담습니다.
/// Milestone 2 - WP 2.1 (S 2.1.4)
class DifficultyParams {
  final int level;              // 난이도 레벨 (1~5)
  final int timeLimit;          // 제한 시간 (초)
  final int optionCount;        // 보기 개수
  final double gameSpeed;       // 게임 속도 (1.0 = 보통)
  final int hintCount;          // 힌트 개수
  final bool showFeedback;      // 피드백 표시 여부
  final Map<String, dynamic>? custom;  // 게임별 커스텀 파라미터

  const DifficultyParams({
    required this.level,
    required this.timeLimit,
    required this.optionCount,
    required this.gameSpeed,
    required this.hintCount,
    required this.showFeedback,
    this.custom,
  });

  DifficultyParams copyWith({
    int? level,
    int? timeLimit,
    int? optionCount,
    double? gameSpeed,
    int? hintCount,
    bool? showFeedback,
    Map<String, dynamic>? custom,
  }) {
    return DifficultyParams(
      level: level ?? this.level,
      timeLimit: timeLimit ?? this.timeLimit,
      optionCount: optionCount ?? this.optionCount,
      gameSpeed: gameSpeed ?? this.gameSpeed,
      hintCount: hintCount ?? this.hintCount,
      showFeedback: showFeedback ?? this.showFeedback,
      custom: custom ?? this.custom,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'timeLimit': timeLimit,
    'optionCount': optionCount,
    'gameSpeed': gameSpeed,
    'hintCount': hintCount,
    'showFeedback': showFeedback,
    'custom': custom,
  };

  factory DifficultyParams.fromJson(Map<String, dynamic> json) {
    final level = json['level'] as int? ?? 1;
    final defaults = DifficultyPresets.fromLevel(level);
    
    return DifficultyParams(
      level: level,
      timeLimit: json['timeLimit'] as int? ?? defaults.timeLimit,
      optionCount: json['optionCount'] as int? ?? defaults.optionCount,
      gameSpeed: (json['gameSpeed'] as num?)?.toDouble() ?? defaults.gameSpeed,
      hintCount: json['hintCount'] as int? ?? defaults.hintCount,
      showFeedback: json['showFeedback'] as bool? ?? defaults.showFeedback,
      custom: json['custom'] as Map<String, dynamic>?,
    );
  }
}

/// 난이도별 기본 파라미터
class DifficultyPresets {
  /// 레벨 1: 매우 쉬움
  static DifficultyParams get veryEasy => const DifficultyParams(
        level: 1,
        timeLimit: 10,
        optionCount: 2,
        gameSpeed: 0.7,
        hintCount: 3,
        showFeedback: true,
      );

  /// 레벨 2: 쉬움
  static DifficultyParams get easy => const DifficultyParams(
        level: 2,
        timeLimit: 8,
        optionCount: 2,
        gameSpeed: 0.85,
        hintCount: 2,
        showFeedback: true,
      );

  /// 레벨 3: 보통
  static DifficultyParams get medium => const DifficultyParams(
        level: 3,
        timeLimit: 6,
        optionCount: 3,
        gameSpeed: 1.0,
        hintCount: 1,
        showFeedback: true,
      );

  /// 레벨 4: 어려움
  static DifficultyParams get hard => const DifficultyParams(
        level: 4,
        timeLimit: 5,
        optionCount: 4,
        gameSpeed: 1.2,
        hintCount: 0,
        showFeedback: true,
      );

  /// 레벨 5: 매우 어려움
  static DifficultyParams get veryHard => const DifficultyParams(
        level: 5,
        timeLimit: 4,
        optionCount: 4,
        gameSpeed: 1.4,
        hintCount: 0,
        showFeedback: true,
      );

  /// 레벨 번호로 파라미터 가져오기
  static DifficultyParams fromLevel(int level) {
    switch (level) {
      case 1:
        return veryEasy;
      case 2:
        return easy;
      case 3:
        return medium;
      case 4:
        return hard;
      case 5:
        return veryHard;
      default:
        return medium;
    }
  }

  /// 난이도 레벨 문자열 (한국어)
  static String getLevelName(int level) {
    switch (level) {
      case 1:
        return '매우 쉬움';
      case 2:
        return '쉬움';
      case 3:
        return '보통';
      case 4:
        return '어려움';
      case 5:
        return '매우 어려움';
      default:
        return '보통';
    }
  }

  /// 난이도 레벨 아이콘
  static String getLevelEmoji(int level) {
    switch (level) {
      case 1:
        return '⭐';
      case 2:
        return '⭐⭐';
      case 3:
        return '⭐⭐⭐';
      case 4:
        return '⭐⭐⭐⭐';
      case 5:
        return '⭐⭐⭐⭐⭐';
      default:
        return '⭐⭐⭐';
    }
  }
}

/// 난이도 파라미터 확장 기능
extension DifficultyParamsX on DifficultyParams {
  /// 한 단계 쉽게
  DifficultyParams easier() {
    final newLevel = (level - 1).clamp(1, 5);
    return DifficultyPresets.fromLevel(newLevel);
  }

  /// 한 단계 어렵게
  DifficultyParams harder() {
    final newLevel = (level + 1).clamp(1, 5);
    return DifficultyPresets.fromLevel(newLevel);
  }

  /// 특정 파라미터만 조정
  DifficultyParams adjust({
    int? timeLimit,
    int? optionCount,
    double? gameSpeed,
    int? hintCount,
  }) {
    return copyWith(
      timeLimit: timeLimit ?? this.timeLimit,
      optionCount: optionCount ?? this.optionCount,
      gameSpeed: gameSpeed ?? this.gameSpeed,
      hintCount: hintCount ?? this.hintCount,
    );
  }

  /// 레벨명 가져오기
  String get levelName => DifficultyPresets.getLevelName(level);

  /// 레벨 이모지 가져오기
  String get levelEmoji => DifficultyPresets.getLevelEmoji(level);
}
