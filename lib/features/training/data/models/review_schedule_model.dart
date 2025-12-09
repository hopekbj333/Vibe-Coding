/// 복습 스케줄 모델
/// 
/// 에빙하우스 망각 곡선 기반 복습 주기 관리
class ReviewSchedule {
  final String childId;
  final List<ReviewItem> items;
  final DateTime lastUpdated;

  ReviewSchedule({
    required this.childId,
    required this.items,
    required this.lastUpdated,
  });

  ReviewSchedule copyWith({
    String? childId,
    List<ReviewItem>? items,
    DateTime? lastUpdated,
  }) {
    return ReviewSchedule(
      childId: childId ?? this.childId,
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 오늘 복습해야 할 항목
  List<ReviewItem> get todayReviews {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return items.where((item) {
      final reviewDate = DateTime(
        item.nextReviewDate.year,
        item.nextReviewDate.month,
        item.nextReviewDate.day,
      );
      return reviewDate.isBefore(today) || reviewDate.isAtSameMomentAs(today);
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'items': items.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) {
    return ReviewSchedule(
      childId: json['childId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

/// 복습 항목
class ReviewItem {
  final String id;
  final String moduleId;
  final String moduleName;
  final String questionType;
  final DateTime learnedAt;
  final DateTime nextReviewDate;
  final int reviewCount;
  final int consecutiveCorrect;
  final ReviewStatus status;

  ReviewItem({
    required this.id,
    required this.moduleId,
    required this.moduleName,
    required this.questionType,
    required this.learnedAt,
    required this.nextReviewDate,
    this.reviewCount = 0,
    this.consecutiveCorrect = 0,
    this.status = ReviewStatus.pending,
  });

  ReviewItem copyWith({
    String? id,
    String? moduleId,
    String? moduleName,
    String? questionType,
    DateTime? learnedAt,
    DateTime? nextReviewDate,
    int? reviewCount,
    int? consecutiveCorrect,
    ReviewStatus? status,
  }) {
    return ReviewItem(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      moduleName: moduleName ?? this.moduleName,
      questionType: questionType ?? this.questionType,
      learnedAt: learnedAt ?? this.learnedAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      reviewCount: reviewCount ?? this.reviewCount,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      status: status ?? this.status,
    );
  }

  /// 에빙하우스 망각 곡선에 따른 다음 복습 날짜 계산
  /// 복습 간격: 1일 → 3일 → 7일 → 14일 → 30일
  DateTime calculateNextReviewDate() {
    final intervals = [1, 3, 7, 14, 30];
    final index = reviewCount.clamp(0, intervals.length - 1);
    return DateTime.now().add(Duration(days: intervals[index]));
  }

  /// 완전 학습 여부 (3회 연속 정답)
  bool get isMastered => consecutiveCorrect >= 3;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'moduleName': moduleName,
      'questionType': questionType,
      'learnedAt': learnedAt.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'reviewCount': reviewCount,
      'consecutiveCorrect': consecutiveCorrect,
      'status': status.name,
    };
  }

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      moduleName: json['moduleName'] as String,
      questionType: json['questionType'] as String,
      learnedAt: DateTime.parse(json['learnedAt'] as String),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      reviewCount: json['reviewCount'] as int? ?? 0,
      consecutiveCorrect: json['consecutiveCorrect'] as int? ?? 0,
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReviewStatus.pending,
      ),
    );
  }
}

enum ReviewStatus {
  pending,   // 대기 중
  due,       // 복습 필요
  completed, // 완료
  mastered,  // 완전 학습
}

/// 오답 문제 모델
class WrongAnswer {
  final String id;
  final String moduleId;
  final String questionType;
  final String originalQuestion;
  final dynamic correctAnswer;
  final dynamic userAnswer;
  final DateTime occurredAt;
  final int retryCount;
  final int consecutiveCorrect;

  WrongAnswer({
    required this.id,
    required this.moduleId,
    required this.questionType,
    required this.originalQuestion,
    required this.correctAnswer,
    required this.userAnswer,
    required this.occurredAt,
    this.retryCount = 0,
    this.consecutiveCorrect = 0,
  });

  WrongAnswer copyWith({
    String? id,
    String? moduleId,
    String? questionType,
    String? originalQuestion,
    dynamic correctAnswer,
    dynamic userAnswer,
    DateTime? occurredAt,
    int? retryCount,
    int? consecutiveCorrect,
  }) {
    return WrongAnswer(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      questionType: questionType ?? this.questionType,
      originalQuestion: originalQuestion ?? this.originalQuestion,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      occurredAt: occurredAt ?? this.occurredAt,
      retryCount: retryCount ?? this.retryCount,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
    );
  }

  /// 완전 학습 여부 (3회 연속 정답)
  bool get isMastered => consecutiveCorrect >= 3;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'questionType': questionType,
      'originalQuestion': originalQuestion,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'occurredAt': occurredAt.toIso8601String(),
      'retryCount': retryCount,
      'consecutiveCorrect': consecutiveCorrect,
    };
  }

  factory WrongAnswer.fromJson(Map<String, dynamic> json) {
    return WrongAnswer(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      questionType: json['questionType'] as String,
      originalQuestion: json['originalQuestion'] as String,
      correctAnswer: json['correctAnswer'],
      userAnswer: json['userAnswer'],
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      consecutiveCorrect: json['consecutiveCorrect'] as int? ?? 0,
    );
  }
}

