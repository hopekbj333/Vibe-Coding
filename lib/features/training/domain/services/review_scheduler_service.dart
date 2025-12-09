import 'package:flutter/foundation.dart';

import '../../data/models/review_schedule_model.dart';

/// 복습 스케줄러 서비스
/// 
/// 에빙하우스 망각 곡선 기반 복습 주기 관리
class ReviewSchedulerService extends ChangeNotifier {
  ReviewSchedule? _schedule;
  final List<WrongAnswer> _wrongAnswers = [];

  ReviewSchedule? get schedule => _schedule;
  List<WrongAnswer> get wrongAnswers => List.unmodifiable(_wrongAnswers);
  List<ReviewItem> get todayReviews => _schedule?.todayReviews ?? [];
  
  /// 마스터하지 않은 오답 목록
  List<WrongAnswer> get pendingWrongAnswers =>
      _wrongAnswers.where((w) => !w.isMastered).toList();

  /// 스케줄 초기화
  void initializeSchedule(String childId, {ReviewSchedule? existing}) {
    _schedule = existing ??
        ReviewSchedule(
          childId: childId,
          items: [],
          lastUpdated: DateTime.now(),
        );
    notifyListeners();
  }

  /// 학습 항목 추가 (새로 배운 내용)
  void addLearningItem({
    required String moduleId,
    required String moduleName,
    required String questionType,
  }) {
    if (_schedule == null) return;

    final item = ReviewItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moduleId: moduleId,
      moduleName: moduleName,
      questionType: questionType,
      learnedAt: DateTime.now(),
      nextReviewDate: DateTime.now().add(const Duration(days: 1)), // 1일 후 첫 복습
    );

    final items = List<ReviewItem>.from(_schedule!.items)..add(item);
    _schedule = _schedule!.copyWith(
      items: items,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// 복습 완료 처리
  void completeReview(String itemId, {required bool isCorrect}) {
    if (_schedule == null) return;

    final items = List<ReviewItem>.from(_schedule!.items);
    final index = items.indexWhere((i) => i.id == itemId);
    
    if (index < 0) return;

    final item = items[index];
    final newConsecutiveCorrect = isCorrect ? item.consecutiveCorrect + 1 : 0;
    
    if (newConsecutiveCorrect >= 3) {
      // 완전 학습 - 목록에서 제거하거나 상태 변경
      items[index] = item.copyWith(
        status: ReviewStatus.mastered,
        consecutiveCorrect: newConsecutiveCorrect,
      );
    } else {
      // 다음 복습 날짜 계산
      final newItem = item.copyWith(
        reviewCount: item.reviewCount + 1,
        consecutiveCorrect: newConsecutiveCorrect,
        status: ReviewStatus.completed,
      );
      items[index] = newItem.copyWith(
        nextReviewDate: newItem.calculateNextReviewDate(),
        status: ReviewStatus.pending,
      );
    }

    _schedule = _schedule!.copyWith(
      items: items,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// 오답 기록
  void recordWrongAnswer({
    required String moduleId,
    required String questionType,
    required String originalQuestion,
    required dynamic correctAnswer,
    required dynamic userAnswer,
  }) {
    final wrongAnswer = WrongAnswer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moduleId: moduleId,
      questionType: questionType,
      originalQuestion: originalQuestion,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer,
      occurredAt: DateTime.now(),
    );

    _wrongAnswers.add(wrongAnswer);
    notifyListeners();
  }

  /// 오답 재도전 결과 처리
  void recordRetryResult(String wrongAnswerId, {required bool isCorrect}) {
    final index = _wrongAnswers.indexWhere((w) => w.id == wrongAnswerId);
    if (index < 0) return;

    final wrongAnswer = _wrongAnswers[index];
    final newConsecutiveCorrect = isCorrect ? wrongAnswer.consecutiveCorrect + 1 : 0;

    _wrongAnswers[index] = wrongAnswer.copyWith(
      retryCount: wrongAnswer.retryCount + 1,
      consecutiveCorrect: newConsecutiveCorrect,
    );

    notifyListeners();
  }

  /// 오늘의 복습 문제 수
  int get todayReviewCount => todayReviews.length;

  /// 미완료 오답 문제 수
  int get pendingWrongAnswerCount => pendingWrongAnswers.length;
}

