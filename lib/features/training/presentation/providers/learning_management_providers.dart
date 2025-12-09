import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/learning_progress_model.dart';
import '../../data/models/learning_session_model.dart';
import '../../data/models/review_schedule_model.dart';
import '../../domain/services/learning_progress_service.dart';
import '../../domain/services/learning_recommendation_service.dart';
import '../../domain/services/review_scheduler_service.dart';
import '../../domain/services/session_timer_service.dart';

/// 세션 타이머 프로바이더
final sessionTimerProvider = ChangeNotifierProvider<SessionTimerService>((ref) {
  return SessionTimerService();
});

/// 학습 진도 프로바이더
final learningProgressProvider = ChangeNotifierProvider<LearningProgressService>((ref) {
  return LearningProgressService();
});

/// 복습 스케줄러 프로바이더
final reviewSchedulerProvider = ChangeNotifierProvider<ReviewSchedulerService>((ref) {
  return ReviewSchedulerService();
});

/// 학습 추천 프로바이더
final learningRecommendationProvider = ChangeNotifierProvider<LearningRecommendationService>((ref) {
  return LearningRecommendationService();
});

/// 현재 세션 상태 프로바이더
final currentSessionProvider = Provider<LearningSession?>((ref) {
  return ref.watch(sessionTimerProvider).currentSession;
});

/// 남은 시간 프로바이더
final remainingTimeProvider = Provider<int>((ref) {
  return ref.watch(sessionTimerProvider).remainingSeconds;
});

/// 세션 진행률 프로바이더
final sessionProgressProvider = Provider<double>((ref) {
  return ref.watch(sessionTimerProvider).progress;
});

/// 오늘의 학습 계획 프로바이더
final todayLearningPlanProvider = Provider<TodayLearningPlan?>((ref) {
  return ref.watch(learningRecommendationProvider).todayPlan;
});

/// 오늘의 복습 목록 프로바이더
final todayReviewsProvider = Provider<List<ReviewItem>>((ref) {
  return ref.watch(reviewSchedulerProvider).todayReviews;
});

/// 미완료 오답 목록 프로바이더
final pendingWrongAnswersProvider = Provider<List<WrongAnswer>>((ref) {
  return ref.watch(reviewSchedulerProvider).pendingWrongAnswers;
});

/// 전체 진도율 프로바이더
final overallProgressProvider = Provider<double>((ref) {
  return ref.watch(learningProgressProvider).overallProgress;
});

/// 학습 진도 데이터 프로바이더
final progressDataProvider = Provider<LearningProgress?>((ref) {
  return ref.watch(learningProgressProvider).progress;
});

/// 특정 스테이지 잠금 해제 여부 프로바이더
final stageUnlockedProvider = Provider.family<bool, String>((ref, stageId) {
  return ref.watch(learningProgressProvider).isStageUnlocked(stageId);
});

/// 학습 관리 초기화 유틸리티
class LearningManagementInitializer {
  final WidgetRef ref;

  LearningManagementInitializer(this.ref);

  /// 아동의 학습 데이터 초기화
  void initializeForChild(String childId) {
    // 진도 초기화
    ref.read(learningProgressProvider).initializeProgress(childId);
    
    // 복습 스케줄 초기화
    ref.read(reviewSchedulerProvider).initializeSchedule(childId);
    
    // 추천 서비스 데이터 설정
    final progress = ref.read(learningProgressProvider).progress;
    final schedule = ref.read(reviewSchedulerProvider).schedule;
    
    ref.read(learningRecommendationProvider).setData(
      progress: progress,
      schedule: schedule,
    );
  }

  /// 세션 시작
  void startSession(String childId, {int durationMinutes = 15}) {
    ref.read(sessionTimerProvider).startSession(
      childId: childId,
      durationMinutes: durationMinutes,
    );
  }

  /// 세션 종료
  LearningSession? endSession() {
    return ref.read(sessionTimerProvider).stopSession();
  }

  /// 문제 결과 기록
  void recordAnswer({
    required String moduleId,
    required bool isCorrect,
    String? questionType,
    String? originalQuestion,
    dynamic correctAnswer,
    dynamic userAnswer,
  }) {
    // 세션에 기록
    ref.read(sessionTimerProvider).recordQuestionComplete(isCorrect: isCorrect);

    // 오답이면 복습 스케줄에 추가
    if (!isCorrect && questionType != null && originalQuestion != null) {
      ref.read(reviewSchedulerProvider).recordWrongAnswer(
        moduleId: moduleId,
        questionType: questionType,
        originalQuestion: originalQuestion,
        correctAnswer: correctAnswer,
        userAnswer: userAnswer,
      );
    }
  }

  /// 오늘의 학습 계획 생성
  TodayLearningPlan generateTodayPlan({int totalMinutes = 15}) {
    return ref.read(learningRecommendationProvider).generateTodayPlan(
      totalMinutes: totalMinutes,
    );
  }
}

