import 'package:flutter/foundation.dart';

import '../../data/models/learning_progress_model.dart';

/// 학습 진도 서비스
/// 
/// 단계별 잠금 해제 및 진도 관리
class LearningProgressService extends ChangeNotifier {
  LearningProgress? _progress;
  
  // 잠금 해제 콜백
  void Function(String stageId, String stageName)? onStageUnlocked;

  LearningProgress? get progress => _progress;

  /// 진도 초기화 또는 로드
  void initializeProgress(String childId, {LearningProgress? existing}) {
    _progress = existing ?? LearningProgress.initial(childId);
    notifyListeners();
  }

  /// 스테이지 점수 업데이트
  void updateStageScore(String stageId, int score, {bool isCorrect = true}) {
    if (_progress == null) return;

    final stages = Map<String, StageProgress>.from(_progress!.stages);
    final currentStage = stages[stageId];
    
    if (currentStage == null) return;

    // 점수 업데이트
    final newScore = ((currentStage.currentScore + score) / 2).round();
    stages[stageId] = currentStage.copyWith(
      currentScore: newScore.clamp(0, 100),
    );

    // 다음 단계 잠금 해제 체크
    _checkUnlockNextStage(stageId, newScore, stages);

    _progress = _progress!.copyWith(
      stages: stages,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// 게임 완료 기록
  void recordGameComplete(String stageId, {required int score}) {
    if (_progress == null) return;

    final stages = Map<String, StageProgress>.from(_progress!.stages);
    final currentStage = stages[stageId];
    
    if (currentStage == null) return;

    final newCompletedGames = currentStage.completedGames + 1;
    final newScore = ((currentStage.currentScore * currentStage.completedGames + score) /
            newCompletedGames)
        .round();

    final isCompleted = newCompletedGames >= currentStage.totalGames;

    stages[stageId] = currentStage.copyWith(
      completedGames: newCompletedGames,
      currentScore: newScore.clamp(0, 100),
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    // 다음 단계 잠금 해제 체크
    _checkUnlockNextStage(stageId, newScore, stages);

    _progress = _progress!.copyWith(
      stages: stages,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void _checkUnlockNextStage(
    String currentStageId,
    int currentScore,
    Map<String, StageProgress> stages,
  ) {
    final stageOrder = ['phonological1', 'phonological2', 'phonological3'];
    final currentIndex = stageOrder.indexOf(currentStageId);
    
    if (currentIndex < 0 || currentIndex >= stageOrder.length - 1) return;

    final nextStageId = stageOrder[currentIndex + 1];
    final nextStage = stages[nextStageId];
    
    if (nextStage == null || nextStage.isUnlocked) return;

    // 현재 단계 점수가 80점 이상이면 다음 단계 잠금 해제
    if (currentScore >= 80) {
      stages[nextStageId] = nextStage.copyWith(isUnlocked: true);
      onStageUnlocked?.call(nextStageId, nextStage.stageName);
    }
  }

  /// 특정 스테이지 잠금 해제 여부
  bool isStageUnlocked(String stageId) {
    return _progress?.isStageUnlocked(stageId) ?? false;
  }

  /// 특정 스테이지 완료 여부
  bool isStageCompleted(String stageId) {
    return _progress?.isStageCompleted(stageId) ?? false;
  }

  /// 전체 진도율
  double get overallProgress => _progress?.overallProgress ?? 0.0;
}

