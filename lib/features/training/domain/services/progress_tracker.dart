import '../../data/models/game_session_model.dart';
import '../../data/models/training_content_model.dart';

/// 학습 진도 추적 모델
class LearningProgress {
  final String childId;
  final String moduleId;
  final int completedSessions;    // 완료한 세션 수
  final int totalAttempts;        // 총 시도 횟수
  final int totalCorrect;         // 총 정답 수
  final int totalIncorrect;       // 총 오답 수
  final int currentStreak;        // 현재 연속 학습일
  final int maxStreak;            // 최대 연속 학습일
  final DateTime? lastPlayedAt;   // 마지막 플레이 시간
  final int highestDifficulty;    // 도달한 최고 난이도
  final Map<String, int> masteredSkills; // 숙달한 스킬 (skillId: level)

  LearningProgress({
    required this.childId,
    required this.moduleId,
    this.completedSessions = 0,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    this.totalIncorrect = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastPlayedAt,
    this.highestDifficulty = 1,
    this.masteredSkills = const {},
  });

  /// 전체 정답률
  double get overallAccuracy {
    if (totalAttempts == 0) return 0.0;
    return totalCorrect / totalAttempts;
  }

  /// 숙달도 (0.0 ~ 1.0)
  /// 정답률과 난이도를 고려한 종합 지표
  double get masteryLevel {
    final accuracyScore = overallAccuracy;
    final difficultyScore = highestDifficulty / 5.0;
    return (accuracyScore * 0.7 + difficultyScore * 0.3);
  }

  /// 진도율 (0.0 ~ 1.0)
  /// 전체 모듈 대비 완료 비율
  double progressPercentage(int totalSessions) {
    if (totalSessions == 0) return 0.0;
    return (completedSessions / totalSessions).clamp(0.0, 1.0);
  }

  /// 학습 빈도 (일주일 평균)
  double get weeklyFrequency {
    if (completedSessions == 0) return 0.0;
    // 간단한 추정: 완료 세션 수 / 7일
    return (completedSessions / 7).clamp(0.0, 7.0);
  }

  /// 복사본 생성
  LearningProgress copyWith({
    int? completedSessions,
    int? totalAttempts,
    int? totalCorrect,
    int? totalIncorrect,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastPlayedAt,
    int? highestDifficulty,
    Map<String, int>? masteredSkills,
  }) {
    return LearningProgress(
      childId: childId,
      moduleId: moduleId,
      completedSessions: completedSessions ?? this.completedSessions,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      highestDifficulty: highestDifficulty ?? this.highestDifficulty,
      masteredSkills: masteredSkills ?? this.masteredSkills,
    );
  }
}

/// 진도 추적 서비스
/// 
/// 아이의 학습 진도를 추적하고 분석합니다.
/// Milestone 2 - WP 2.1 (S 2.1.3)
class ProgressTracker {
  /// 아이별, 모듈별 진도 데이터
  final Map<String, Map<String, LearningProgress>> _progressData = {};

  /// 진도 가져오기
  LearningProgress getProgress({
    required String childId,
    required String moduleId,
  }) {
    if (!_progressData.containsKey(childId)) {
      _progressData[childId] = {};
    }

    if (!_progressData[childId]!.containsKey(moduleId)) {
      _progressData[childId]![moduleId] = LearningProgress(
        childId: childId,
        moduleId: moduleId,
      );
    }

    return _progressData[childId]![moduleId]!;
  }

  /// 세션 완료 후 진도 업데이트
  LearningProgress updateProgress({
    required GameSessionModel session,
    required TrainingResultModel result,
  }) {
    final current = getProgress(
      childId: session.childId,
      moduleId: session.moduleId,
    );

    // 연속 학습일 계산
    final now = DateTime.now();
    int newStreak = current.currentStreak;
    int newMaxStreak = current.maxStreak;

    if (current.lastPlayedAt != null) {
      final daysSinceLastPlay = now.difference(current.lastPlayedAt!).inDays;
      if (daysSinceLastPlay == 1) {
        // 어제 플레이했으면 연속 +1
        newStreak = current.currentStreak + 1;
      } else if (daysSinceLastPlay > 1) {
        // 연속 끊김
        newStreak = 1;
      }
      // daysSinceLastPlay == 0이면 오늘 이미 플레이함, 유지
    } else {
      // 첫 플레이
      newStreak = 1;
    }

    if (newStreak > newMaxStreak) {
      newMaxStreak = newStreak;
    }

    // 최고 난이도 업데이트
    final newHighestDifficulty = current.highestDifficulty > result.finalDifficultyLevel
        ? current.highestDifficulty
        : result.finalDifficultyLevel;

    // 숙달 스킬 업데이트 (정답률 90% 이상이면 숙달로 간주)
    final accuracy = result.correctCount / result.totalQuestions;
    final newMasteredSkills = Map<String, int>.from(current.masteredSkills);
    if (accuracy >= 0.9) {
      newMasteredSkills[session.moduleId] = result.finalDifficultyLevel;
    }

    final updated = current.copyWith(
      completedSessions: current.completedSessions + 1,
      totalAttempts: current.totalAttempts + result.totalQuestions,
      totalCorrect: current.totalCorrect + result.correctCount,
      totalIncorrect: current.totalIncorrect + result.incorrectCount,
      currentStreak: newStreak,
      maxStreak: newMaxStreak,
      lastPlayedAt: now,
      highestDifficulty: newHighestDifficulty,
      masteredSkills: newMasteredSkills,
    );

    // 저장
    _progressData[session.childId]![session.moduleId] = updated;

    return updated;
  }

  /// 아이의 전체 진도 가져오기
  Map<String, LearningProgress> getAllProgress(String childId) {
    return _progressData[childId] ?? {};
  }

  /// 모듈 추천
  /// 
  /// 아이의 약점 영역을 분석해서 추천할 모듈을 반환합니다.
  List<String> recommendModules({
    required String childId,
    int count = 3,
  }) {
    final allProgress = getAllProgress(childId);

    if (allProgress.isEmpty) {
      // 처음이면 기본 추천
      return ['phonological_basic', 'sensory_basic', 'executive_basic'];
    }

    // 정답률이 낮은 모듈 우선 추천
    final sortedModules = allProgress.entries.toList()
      ..sort((a, b) =>
          a.value.overallAccuracy.compareTo(b.value.overallAccuracy));

    return sortedModules.take(count).map((e) => e.key).toList();
  }

  /// 학습 통계 요약
  Map<String, dynamic> getSummary(String childId) {
    final allProgress = getAllProgress(childId);

    if (allProgress.isEmpty) {
      return {
        'totalSessions': 0,
        'totalQuestions': 0,
        'overallAccuracy': 0.0,
        'currentStreak': 0,
        'maxStreak': 0,
        'masteredModules': 0,
      };
    }

    int totalSessions = 0;
    int totalQuestions = 0;
    int totalCorrect = 0;
    int maxStreak = 0;
    int currentStreak = 0;
    int masteredModules = 0;

    for (final progress in allProgress.values) {
      totalSessions += progress.completedSessions;
      totalQuestions += progress.totalAttempts;
      totalCorrect += progress.totalCorrect;
      if (progress.maxStreak > maxStreak) {
        maxStreak = progress.maxStreak;
      }
      if (progress.currentStreak > currentStreak) {
        currentStreak = progress.currentStreak;
      }
      if (progress.masteryLevel >= 0.8) {
        masteredModules++;
      }
    }

    final overallAccuracy = totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;

    return {
      'totalSessions': totalSessions,
      'totalQuestions': totalQuestions,
      'overallAccuracy': overallAccuracy,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'masteredModules': masteredModules,
    };
  }

  /// 데이터 초기화 (테스트용)
  void clear() {
    _progressData.clear();
  }

  /// 디버그 정보
  String getDebugInfo(String childId) {
    final allProgress = getAllProgress(childId);
    if (allProgress.isEmpty) {
      return '아직 학습 기록이 없습니다.';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== 학습 진도 (아동: $childId) ===');

    for (final entry in allProgress.entries) {
      final moduleId = entry.key;
      final progress = entry.value;

      buffer.writeln('\n[모듈: $moduleId]');
      buffer.writeln('  완료 세션: ${progress.completedSessions}회');
      buffer.writeln('  정답률: ${(progress.overallAccuracy * 100).toStringAsFixed(1)}%');
      buffer.writeln('  숙달도: ${(progress.masteryLevel * 100).toStringAsFixed(1)}%');
      buffer.writeln('  최고 난이도: ${progress.highestDifficulty}');
      buffer.writeln('  연속 학습: ${progress.currentStreak}일');
      buffer.writeln('  최대 연속: ${progress.maxStreak}일');
      if (progress.lastPlayedAt != null) {
        buffer.writeln('  마지막 플레이: ${progress.lastPlayedAt}');
      }
    }

    return buffer.toString();
  }
}

