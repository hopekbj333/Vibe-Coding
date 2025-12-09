import 'package:flutter/foundation.dart';

import '../../data/models/learning_progress_model.dart';
import '../../data/models/review_schedule_model.dart';

/// 학습 추천 서비스
/// 
/// 검사 결과 연동 및 오늘의 학습 자동 구성
class LearningRecommendationService extends ChangeNotifier {
  LearningProgress? _progress;
  ReviewSchedule? _schedule;
  Map<String, int>? _assessmentScores; // 검사 결과 점수

  TodayLearningPlan? _todayPlan;
  TodayLearningPlan? get todayPlan => _todayPlan;

  /// 데이터 설정
  void setData({
    LearningProgress? progress,
    ReviewSchedule? schedule,
    Map<String, int>? assessmentScores,
  }) {
    _progress = progress;
    _schedule = schedule;
    _assessmentScores = assessmentScores;
    notifyListeners();
  }

  /// 검사 결과 설정 (Milestone 1 연동)
  void setAssessmentScores(Map<String, int> scores) {
    _assessmentScores = scores;
    notifyListeners();
  }

  /// 약점 영역 분석
  List<WeakArea> analyzeWeakAreas() {
    if (_assessmentScores == null) return [];

    final weakAreas = <WeakArea>[];
    
    _assessmentScores!.forEach((area, score) {
      if (score < 70) {
        weakAreas.add(WeakArea(
          areaId: area,
          areaName: _getAreaName(area),
          score: score,
          severity: score < 50 ? WeakSeverity.high : WeakSeverity.medium,
          recommendedModules: _getRecommendedModules(area),
        ));
      }
    });

    // 심각도 순으로 정렬
    weakAreas.sort((a, b) => a.score.compareTo(b.score));
    return weakAreas;
  }

  /// 오늘의 학습 계획 생성
  TodayLearningPlan generateTodayPlan({int totalMinutes = 15}) {
    final weakAreas = analyzeWeakAreas();
    final todayReviews = _schedule?.todayReviews ?? [];
    
    final activities = <LearningActivity>[];
    
    // 40% - 약점 영역 집중
    final weakMinutes = (totalMinutes * 0.4).round();
    if (weakAreas.isNotEmpty) {
      final topWeak = weakAreas.first;
      activities.add(LearningActivity(
        type: ActivityType.weakness,
        moduleId: topWeak.recommendedModules.first,
        moduleName: _getModuleName(topWeak.recommendedModules.first),
        durationMinutes: weakMinutes,
        description: '${topWeak.areaName} 집중 연습',
        priority: 1,
      ));
    } else {
      // 약점이 없으면 신규 학습으로 대체
      activities.add(LearningActivity(
        type: ActivityType.newContent,
        moduleId: _getNextModule(),
        moduleName: _getModuleName(_getNextModule()),
        durationMinutes: weakMinutes,
        description: '새로운 내용 학습',
        priority: 1,
      ));
    }

    // 30% - 복습
    final reviewMinutes = (totalMinutes * 0.3).round();
    if (todayReviews.isNotEmpty) {
      activities.add(LearningActivity(
        type: ActivityType.review,
        moduleId: todayReviews.first.moduleId,
        moduleName: todayReviews.first.moduleName,
        durationMinutes: reviewMinutes,
        description: '복습: ${todayReviews.first.moduleName}',
        priority: 2,
      ));
    } else {
      // 복습할 게 없으면 신규 학습으로
      activities.add(LearningActivity(
        type: ActivityType.newContent,
        moduleId: _getNextModule(),
        moduleName: _getModuleName(_getNextModule()),
        durationMinutes: reviewMinutes,
        description: '새로운 내용 학습',
        priority: 2,
      ));
    }

    // 30% - 신규 학습
    final newMinutes = totalMinutes - weakMinutes - reviewMinutes;
    activities.add(LearningActivity(
      type: ActivityType.newContent,
      moduleId: _getNextModule(),
      moduleName: _getModuleName(_getNextModule()),
      durationMinutes: newMinutes,
      description: '새로운 도전!',
      priority: 3,
    ));

    _todayPlan = TodayLearningPlan(
      activities: activities,
      totalMinutes: totalMinutes,
      generatedAt: DateTime.now(),
    );
    
    notifyListeners();
    return _todayPlan!;
  }

  /// 추천 모듈 목록
  List<RecommendedModule> getRecommendedModules() {
    final recommendations = <RecommendedModule>[];
    final weakAreas = analyzeWeakAreas();

    // 약점 기반 추천
    for (final weak in weakAreas.take(3)) {
      for (final moduleId in weak.recommendedModules.take(2)) {
        recommendations.add(RecommendedModule(
          moduleId: moduleId,
          moduleName: _getModuleName(moduleId),
          reason: '${weak.areaName} 향상을 위해 추천',
          priority: weak.severity == WeakSeverity.high ? 1 : 2,
        ));
      }
    }

    // 진도 기반 추천
    if (_progress != null) {
      final unlockedStages = _progress!.stages.values
          .where((s) => s.isUnlocked && !s.isCompleted)
          .toList();
      
      for (final stage in unlockedStages) {
        recommendations.add(RecommendedModule(
          moduleId: stage.stageId,
          moduleName: stage.stageName,
          reason: '진행 중인 학습',
          priority: 3,
        ));
      }
    }

    return recommendations;
  }

  String _getAreaName(String areaId) {
    const areaNames = {
      'phonological_awareness': '음운 인식',
      'syllable_manipulation': '음절 조작',
      'auditory_attention': '청각 주의',
      'rhythm_perception': '리듬 인식',
    };
    return areaNames[areaId] ?? areaId;
  }

  List<String> _getRecommendedModules(String areaId) {
    const moduleMap = {
      'phonological_awareness': ['phonological1', 'phonological2'],
      'syllable_manipulation': ['phonological3'],
      'auditory_attention': ['phonological1'],
      'rhythm_perception': ['phonological1', 'phonological2'],
    };
    return moduleMap[areaId] ?? ['phonological1'];
  }

  String _getNextModule() {
    if (_progress == null) return 'phonological1';
    
    // 잠금 해제되었지만 완료되지 않은 첫 번째 단계
    for (final stage in _progress!.stages.values) {
      if (stage.isUnlocked && !stage.isCompleted) {
        return stage.stageId;
      }
    }
    return 'phonological1';
  }

  String _getModuleName(String moduleId) {
    const moduleNames = {
      'phonological1': '음운 인식 1단계',
      'phonological2': '음운 인식 2단계',
      'phonological3': '음운 인식 3단계',
    };
    return moduleNames[moduleId] ?? moduleId;
  }
}

/// 오늘의 학습 계획
class TodayLearningPlan {
  final List<LearningActivity> activities;
  final int totalMinutes;
  final DateTime generatedAt;

  TodayLearningPlan({
    required this.activities,
    required this.totalMinutes,
    required this.generatedAt,
  });
}

/// 학습 활동
class LearningActivity {
  final ActivityType type;
  final String moduleId;
  final String moduleName;
  final int durationMinutes;
  final String description;
  final int priority;
  bool isCompleted;

  LearningActivity({
    required this.type,
    required this.moduleId,
    required this.moduleName,
    required this.durationMinutes,
    required this.description,
    required this.priority,
    this.isCompleted = false,
  });
}

enum ActivityType {
  weakness,    // 약점 보완
  review,      // 복습
  newContent,  // 신규 학습
}

/// 약점 영역
class WeakArea {
  final String areaId;
  final String areaName;
  final int score;
  final WeakSeverity severity;
  final List<String> recommendedModules;

  WeakArea({
    required this.areaId,
    required this.areaName,
    required this.score,
    required this.severity,
    required this.recommendedModules,
  });
}

enum WeakSeverity {
  high,   // 50점 미만
  medium, // 50~70점
}

/// 추천 모듈
class RecommendedModule {
  final String moduleId;
  final String moduleName;
  final String reason;
  final int priority;

  RecommendedModule({
    required this.moduleId,
    required this.moduleName,
    required this.reason,
    required this.priority,
  });
}

