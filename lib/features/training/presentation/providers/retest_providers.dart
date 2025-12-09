import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mini_test_model.dart';
import '../../domain/services/mini_test_service.dart';

/// 미니 테스트 서비스 프로바이더
final miniTestServiceProvider = ChangeNotifierProvider<MiniTestService>((ref) {
  return MiniTestService();
});

/// 단계 승급 서비스 프로바이더
final stagePromotionServiceProvider =
    ChangeNotifierProvider<StagePromotionService>((ref) {
  return StagePromotionService();
});

/// 현재 미니 테스트 프로바이더
final currentMiniTestProvider = Provider<MiniTest?>((ref) {
  return ref.watch(miniTestServiceProvider).currentTest;
});

/// 테스트 결과 히스토리 프로바이더
final testResultsProvider = Provider<List<MiniTestResult>>((ref) {
  return ref.watch(miniTestServiceProvider).testResults;
});

/// 특정 모듈의 테스트 결과 프로바이더
final moduleTestResultsProvider =
    Provider.family<List<MiniTestResult>, String>((ref, moduleId) {
  return ref.watch(miniTestServiceProvider).getResultsForModule(moduleId);
});

/// 단계 잠금 해제 상태 프로바이더
final stageUnlockedProvider = Provider.family<bool, String>((ref, stageId) {
  return ref.watch(stagePromotionServiceProvider).isStageUnlocked(stageId);
});

/// 승급 기준 프로바이더
final promotionThresholdProvider = Provider<int>((ref) {
  return ref.watch(stagePromotionServiceProvider).promotionThreshold;
});

/// 샘플 성장 리포트 생성
GrowthReport createSampleGrowthReport({
  required String childId,
  required String childName,
}) {
  return GrowthReport(
    childId: childId,
    childName: childName,
    periodStart: DateTime.now().subtract(const Duration(days: 21)),
    periodEnd: DateTime.now(),
    skillProgresses: [
      SkillProgress(
        skillId: 'syllable_split',
        skillName: '음절 쪼개기',
        initialScore: 50,
        currentScore: 80,
        improvement: 30,
      ),
      SkillProgress(
        skillId: 'syllable_merge',
        skillName: '음절 합치기',
        initialScore: 60,
        currentScore: 75,
        improvement: 15,
      ),
      SkillProgress(
        skillId: 'rhyme',
        skillName: '끝소리 찾기',
        initialScore: 45,
        currentScore: 70,
        improvement: 25,
      ),
    ],
    learningStats: LearningStats(
      totalSessions: 7,
      totalMinutes: 105,
      averageMinutesPerDay: 15,
      favoriteGame: '음절 블록 쪼개기',
      favoriteGamePlayCount: 12,
    ),
    teacherComment: '꾸준히 잘 하고 있어요! 계속 이렇게만 하면 한글 배우기가 쉬울 거예요.',
  );
}

