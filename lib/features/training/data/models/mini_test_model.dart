/// 미니 테스트 모델
/// 
/// 학습 효과를 측정하는 짧은 테스트 데이터
class MiniTest {
  final String id;
  final String childId;
  final String moduleId;       // 학습 모듈 ID
  final String moduleName;     // 학습 모듈 이름
  final List<MiniTestQuestion> questions;
  final int totalQuestions;
  final DateTime createdAt;
  final DateTime? completedAt;
  final MiniTestStatus status;

  MiniTest({
    required this.id,
    required this.childId,
    required this.moduleId,
    required this.moduleName,
    required this.questions,
    required this.totalQuestions,
    required this.createdAt,
    this.completedAt,
    this.status = MiniTestStatus.pending,
  });

  MiniTest copyWith({
    String? id,
    String? childId,
    String? moduleId,
    String? moduleName,
    List<MiniTestQuestion>? questions,
    int? totalQuestions,
    DateTime? createdAt,
    DateTime? completedAt,
    MiniTestStatus? status,
  }) {
    return MiniTest(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      questions: questions ?? this.questions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }

  /// 완료된 문항 수
  int get answeredCount => questions.where((q) => q.isAnswered).length;

  /// 정답 수
  int get correctCount => questions.where((q) => q.isCorrect == true).length;

  /// 점수 (0-100)
  int get score {
    if (answeredCount == 0) return 0;
    return ((correctCount / totalQuestions) * 100).round();
  }

  /// 통과 여부 (80점 이상)
  bool get isPassed => score >= 80;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
    };
  }

  factory MiniTest.fromJson(Map<String, dynamic> json) {
    return MiniTest(
      id: json['id'] as String,
      childId: json['childId'] as String,
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => MiniTestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      totalQuestions: json['totalQuestions'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      status: MiniTestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MiniTestStatus.pending,
      ),
    );
  }
}

/// 미니 테스트 문항
class MiniTestQuestion {
  final String id;
  final String questionType;
  final String questionText;
  final List<String> options;
  final dynamic correctAnswer;
  final dynamic userAnswer;
  final bool? isCorrect;
  final int? responseTimeMs;

  MiniTestQuestion({
    required this.id,
    required this.questionType,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
    this.responseTimeMs,
  });

  MiniTestQuestion copyWith({
    String? id,
    String? questionType,
    String? questionText,
    List<String>? options,
    dynamic correctAnswer,
    dynamic userAnswer,
    bool? isCorrect,
    int? responseTimeMs,
  }) {
    return MiniTestQuestion(
      id: id ?? this.id,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
    );
  }

  bool get isAnswered => userAnswer != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionType': questionType,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'responseTimeMs': responseTimeMs,
    };
  }

  factory MiniTestQuestion.fromJson(Map<String, dynamic> json) {
    return MiniTestQuestion(
      id: json['id'] as String,
      questionType: json['questionType'] as String,
      questionText: json['questionText'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'],
      userAnswer: json['userAnswer'],
      isCorrect: json['isCorrect'] as bool?,
      responseTimeMs: json['responseTimeMs'] as int?,
    );
  }
}

enum MiniTestStatus {
  pending,    // 대기
  inProgress, // 진행 중
  completed,  // 완료
  passed,     // 통과
  failed,     // 미통과
}

/// 미니 테스트 결과
class MiniTestResult {
  final String testId;
  final String childId;
  final String moduleId;
  final String moduleName;
  final int currentScore;        // 현재 점수
  final int previousScore;       // 이전 점수
  final int improvement;         // 향상도
  final bool isPassed;           // 통과 여부
  final DateTime completedAt;
  final String? recommendation;  // 추천 메시지

  MiniTestResult({
    required this.testId,
    required this.childId,
    required this.moduleId,
    required this.moduleName,
    required this.currentScore,
    required this.previousScore,
    required this.improvement,
    required this.isPassed,
    required this.completedAt,
    this.recommendation,
  });

  /// 향상 여부
  bool get hasImproved => improvement > 0;

  /// 점수 등급
  ScoreGrade get currentGrade => _getGrade(currentScore);
  ScoreGrade get previousGrade => _getGrade(previousScore);

  ScoreGrade _getGrade(int score) {
    if (score >= 80) return ScoreGrade.green;
    if (score >= 50) return ScoreGrade.yellow;
    return ScoreGrade.red;
  }

  /// 등급이 상승했는지
  bool get hasGradeImproved {
    return currentGrade.index > previousGrade.index;
  }

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'childId': childId,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'currentScore': currentScore,
      'previousScore': previousScore,
      'improvement': improvement,
      'isPassed': isPassed,
      'completedAt': completedAt.toIso8601String(),
      'recommendation': recommendation,
    };
  }

  factory MiniTestResult.fromJson(Map<String, dynamic> json) {
    return MiniTestResult(
      testId: json['testId'] as String,
      childId: json['childId'] as String,
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      currentScore: json['currentScore'] as int,
      previousScore: json['previousScore'] as int,
      improvement: json['improvement'] as int,
      isPassed: json['isPassed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      recommendation: json['recommendation'] as String?,
    );
  }
}

enum ScoreGrade {
  red,    // 50점 미만
  yellow, // 50-79점
  green,  // 80점 이상
}

/// 성장 리포트
class GrowthReport {
  final String childId;
  final String childName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<SkillProgress> skillProgresses;
  final LearningStats learningStats;
  final String? teacherComment;

  GrowthReport({
    required this.childId,
    required this.childName,
    required this.periodStart,
    required this.periodEnd,
    required this.skillProgresses,
    required this.learningStats,
    this.teacherComment,
  });

  /// 가장 많이 향상된 영역
  SkillProgress? get mostImprovedSkill {
    if (skillProgresses.isEmpty) return null;
    return skillProgresses.reduce(
      (a, b) => a.improvement > b.improvement ? a : b,
    );
  }

  /// 전체 평균 향상도
  int get averageImprovement {
    if (skillProgresses.isEmpty) return 0;
    return (skillProgresses.map((s) => s.improvement).reduce((a, b) => a + b) /
            skillProgresses.length)
        .round();
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'childName': childName,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'skillProgresses': skillProgresses.map((s) => s.toJson()).toList(),
      'learningStats': learningStats.toJson(),
      'teacherComment': teacherComment,
    };
  }
}

/// 스킬별 진행 상황
class SkillProgress {
  final String skillId;
  final String skillName;
  final int initialScore;
  final int currentScore;
  final int improvement;

  SkillProgress({
    required this.skillId,
    required this.skillName,
    required this.initialScore,
    required this.currentScore,
    required this.improvement,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'skillName': skillName,
      'initialScore': initialScore,
      'currentScore': currentScore,
      'improvement': improvement,
    };
  }
}

/// 학습 통계
class LearningStats {
  final int totalSessions;
  final int totalMinutes;
  final int averageMinutesPerDay;
  final String favoriteGame;
  final int favoriteGamePlayCount;

  LearningStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageMinutesPerDay,
    required this.favoriteGame,
    required this.favoriteGamePlayCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'averageMinutesPerDay': averageMinutesPerDay,
      'favoriteGame': favoriteGame,
      'favoriteGamePlayCount': favoriteGamePlayCount,
    };
  }
}

