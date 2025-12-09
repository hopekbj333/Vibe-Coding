import 'dart:math';
import '../../../training/data/models/tracking_models.dart';

/// WP 3.6: 장기 추적 서비스
class TrackingService {
  // 싱글톤 패턴
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  // 메모리 저장소 (실제로는 Firestore 사용)
  final Map<String, List<LearningSessionRecord>> _sessions = {};
  final Map<String, List<AssessmentRecord>> _assessments = {};
  final Map<String, List<AchievementBadge>> _badges = {};
  final Map<String, LevelInfo> _levels = {};

  // 기본 배지 정의
  static final List<AchievementBadge> _defaultBadges = [
    // 연속 학습 배지
    AchievementBadge(
      id: 'streak_3',
      name: '3일 연속',
      description: '3일 연속으로 학습했어요!',
      emoji: '🔥',
      category: BadgeCategory.streak,
      condition: 'consecutive_days',
      requiredValue: 3,
    ),
    AchievementBadge(
      id: 'streak_7',
      name: '7일 연속',
      description: '일주일 내내 학습했어요!',
      emoji: '🔥',
      category: BadgeCategory.streak,
      condition: 'consecutive_days',
      requiredValue: 7,
    ),
    AchievementBadge(
      id: 'streak_14',
      name: '2주 연속',
      description: '2주 동안 매일 학습했어요!',
      emoji: '🔥',
      category: BadgeCategory.streak,
      condition: 'consecutive_days',
      requiredValue: 14,
    ),
    AchievementBadge(
      id: 'streak_30',
      name: '한달 연속',
      description: '한 달 동안 매일 학습했어요!',
      emoji: '🔥',
      category: BadgeCategory.streak,
      condition: 'consecutive_days',
      requiredValue: 30,
    ),

    // 정확도 배지
    AchievementBadge(
      id: 'accuracy_80',
      name: '정확도 80%',
      description: '전체 정답률 80% 달성!',
      emoji: '🎯',
      category: BadgeCategory.accuracy,
      condition: 'overall_accuracy',
      requiredValue: 80,
    ),
    AchievementBadge(
      id: 'accuracy_90',
      name: '정확도 90%',
      description: '전체 정답률 90% 달성!',
      emoji: '🎯',
      category: BadgeCategory.accuracy,
      condition: 'overall_accuracy',
      requiredValue: 90,
    ),
    AchievementBadge(
      id: 'accuracy_95',
      name: '정확도 95%',
      description: '거의 완벽해요!',
      emoji: '🎯',
      category: BadgeCategory.accuracy,
      condition: 'overall_accuracy',
      requiredValue: 95,
    ),

    // 성장 배지
    AchievementBadge(
      id: 'growth_10',
      name: '+10점 성장',
      description: '점수가 10점 올랐어요!',
      emoji: '📈',
      category: BadgeCategory.growth,
      condition: 'score_increase',
      requiredValue: 10,
    ),
    AchievementBadge(
      id: 'growth_20',
      name: '+20점 성장',
      description: '점수가 20점 올랐어요!',
      emoji: '📈',
      category: BadgeCategory.growth,
      condition: 'score_increase',
      requiredValue: 20,
    ),
    AchievementBadge(
      id: 'growth_30',
      name: '+30점 성장',
      description: '대단한 성장이에요!',
      emoji: '📈',
      category: BadgeCategory.growth,
      condition: 'score_increase',
      requiredValue: 30,
    ),

    // 학습 시간 배지
    AchievementBadge(
      id: 'time_60',
      name: '1시간 학습',
      description: '총 1시간 학습했어요!',
      emoji: '⏰',
      category: BadgeCategory.time,
      condition: 'total_minutes',
      requiredValue: 60,
    ),
    AchievementBadge(
      id: 'time_300',
      name: '5시간 학습',
      description: '총 5시간 학습했어요!',
      emoji: '⏰',
      category: BadgeCategory.time,
      condition: 'total_minutes',
      requiredValue: 300,
    ),
    AchievementBadge(
      id: 'time_600',
      name: '10시간 학습',
      description: '총 10시간 학습했어요!',
      emoji: '⏰',
      category: BadgeCategory.time,
      condition: 'total_minutes',
      requiredValue: 600,
    ),
  ];

  /// 아동의 배지 목록 가져오기
  List<AchievementBadge> getBadges(String childId) {
    if (!_badges.containsKey(childId)) {
      _badges[childId] = _defaultBadges.map((b) => AchievementBadge(
        id: b.id,
        name: b.name,
        description: b.description,
        emoji: b.emoji,
        category: b.category,
        condition: b.condition,
        requiredValue: b.requiredValue,
      )).toList();
    }
    return _badges[childId]!;
  }

  /// 아동의 레벨 정보 가져오기
  LevelInfo getLevelInfo(String childId) {
    if (!_levels.containsKey(childId)) {
      _levels[childId] = LevelInfo.initial();
    }
    return _levels[childId]!;
  }

  /// XP 추가
  LevelInfo addXP(String childId, int xp) {
    final currentLevel = getLevelInfo(childId);
    final newLevel = currentLevel.addXP(xp);
    _levels[childId] = newLevel;
    return newLevel;
  }

  /// 학습 세션 기록 추가
  void addLearningSession(LearningSessionRecord session) {
    final childId = session.childId;
    if (!_sessions.containsKey(childId)) {
      _sessions[childId] = [];
    }
    _sessions[childId]!.add(session);

    // XP 부여
    addXP(childId, 10 * session.completedGames.length);

    // 배지 확인
    _checkBadges(childId);
  }

  /// 검사 결과 기록 추가
  void addAssessmentRecord(AssessmentRecord record) {
    final childId = record.childId;
    if (!_assessments.containsKey(childId)) {
      _assessments[childId] = [];
    }
    _assessments[childId]!.add(record);

    // XP 부여
    if (record.type == AssessmentType.miniTest) {
      addXP(childId, 50);
    } else {
      addXP(childId, 100);
    }

    // 배지 확인
    _checkBadges(childId);
  }

  /// 학습 세션 목록 가져오기
  List<LearningSessionRecord> getLearningSessionsForChild(String childId) {
    return _sessions[childId] ?? [];
  }

  /// 검사 결과 목록 가져오기
  List<AssessmentRecord> getAssessmentRecordsForChild(String childId) {
    return _assessments[childId] ?? [];
  }

  /// 타임라인 이벤트 생성
  List<TimelineEvent> getTimelineEvents(String childId) {
    final events = <TimelineEvent>[];

    // 검사 결과 이벤트
    final assessments = _assessments[childId] ?? [];
    for (final assessment in assessments) {
      events.add(TimelineEvent(
        id: assessment.id,
        date: assessment.date,
        type: assessment.type == AssessmentType.miniTest
            ? TimelineEventType.miniTest
            : TimelineEventType.assessment,
        title: assessment.type == AssessmentType.miniTest
            ? '미니 테스트'
            : '정기 검사',
        description: '전체 점수: ${assessment.totalScore.toStringAsFixed(0)}점',
        metadata: {'score': assessment.totalScore},
      ));
    }

    // 획득한 배지 이벤트
    final badges = _badges[childId] ?? [];
    for (final badge in badges.where((b) => b.isEarned)) {
      events.add(TimelineEvent(
        id: 'badge_${badge.id}',
        date: badge.earnedAt!,
        type: TimelineEventType.achievement,
        title: '${badge.emoji} ${badge.name} 획득!',
        description: badge.description,
      ));
    }

    // 날짜순 정렬
    events.sort((a, b) => b.date.compareTo(a.date));

    return events;
  }

  /// 성장 그래프 데이터 생성
  List<GrowthDataPoint> getGrowthData(String childId, {int months = 6}) {
    final assessments = _assessments[childId] ?? [];
    final cutoffDate = DateTime.now().subtract(Duration(days: months * 30));

    return assessments
        .where((a) => a.date.isAfter(cutoffDate))
        .map((a) => GrowthDataPoint(
              date: a.date,
              domainScores: a.domainScores,
              totalScore: a.totalScore,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 일별 학습 데이터 가져오기 (캘린더용)
  Map<DateTime, LearningSessionRecord?> getCalendarData(
    String childId,
    DateTime month,
  ) {
    final sessions = _sessions[childId] ?? [];
    final result = <DateTime, LearningSessionRecord?>{};

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    for (var day = startOfMonth;
        day.isBefore(endOfMonth.add(const Duration(days: 1)));
        day = day.add(const Duration(days: 1))) {
      final dayKey = DateTime(day.year, day.month, day.day);
      final session = sessions.firstWhere(
        (s) =>
            s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day,
        orElse: () => LearningSessionRecord(
          id: '',
          childId: childId,
          date: day,
          durationMinutes: 0,
          completedGames: [],
          averageAccuracy: 0,
          totalQuestions: 0,
          correctAnswers: 0,
        ),
      );
      result[dayKey] = session.id.isEmpty ? null : session;
    }

    return result;
  }

  /// 배지 확인 및 업데이트
  void _checkBadges(String childId) {
    final badges = getBadges(childId);
    final sessions = _sessions[childId] ?? [];
    final assessments = _assessments[childId] ?? [];

    // 총 학습 시간 계산
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );

    // 연속 학습 일수 계산
    final consecutiveDays = _calculateConsecutiveDays(sessions);

    // 평균 정확도 계산
    final avgAccuracy = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (sum, s) => sum + s.averageAccuracy) /
            sessions.length;

    // 성장 점수 계산 (첫 검사와 마지막 검사 비교)
    double scoreIncrease = 0;
    if (assessments.length >= 2) {
      final sorted = assessments.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      scoreIncrease = sorted.last.totalScore - sorted.first.totalScore;
    }

    // 배지 업데이트
    for (int i = 0; i < badges.length; i++) {
      final badge = badges[i];
      if (badge.isEarned) continue;

      bool earned = false;

      switch (badge.condition) {
        case 'consecutive_days':
          earned = consecutiveDays >= badge.requiredValue;
          break;
        case 'overall_accuracy':
          earned = avgAccuracy >= badge.requiredValue;
          break;
        case 'score_increase':
          earned = scoreIncrease >= badge.requiredValue;
          break;
        case 'total_minutes':
          earned = totalMinutes >= badge.requiredValue;
          break;
      }

      if (earned) {
        badges[i] = badge.copyWith(earnedAt: DateTime.now());
        // 배지 획득 시 XP 보너스
        addXP(childId, 25);
      }
    }
  }

  /// 연속 학습 일수 계산
  int _calculateConsecutiveDays(List<LearningSessionRecord> sessions) {
    if (sessions.isEmpty) return 0;

    final sortedDates = sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    DateTime lastDate = sortedDates.first;

    // 오늘 또는 어제 학습했는지 확인
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (lastDate != todayDate && lastDate != yesterday) {
      return 0; // 연속 끊김
    }

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = lastDate.difference(sortedDates[i]).inDays;
      if (diff == 1) {
        streak++;
        lastDate = sortedDates[i];
      } else {
        break;
      }
    }

    return streak;
  }

  /// 샘플 데이터 생성 (테스트용)
  void generateSampleData(String childId) {
    final random = Random();
    final now = DateTime.now();

    // 지난 3개월간 학습 세션 생성
    for (int i = 90; i >= 0; i--) {
      if (random.nextDouble() > 0.3) continue; // 30% 확률로 학습

      final date = now.subtract(Duration(days: i));
      addLearningSession(LearningSessionRecord(
        id: 'session_${childId}_$i',
        childId: childId,
        date: date,
        durationMinutes: 15 + random.nextInt(30),
        completedGames: ['game1', 'game2'],
        averageAccuracy: 60 + random.nextDouble() * 35,
        totalQuestions: 20 + random.nextInt(10),
        correctAnswers: 15 + random.nextInt(10),
      ));
    }

    // 검사 결과 생성
    final assessmentDates = [90, 60, 30, 0];
    double baseScore = 45;
    for (final daysAgo in assessmentDates) {
      final score = baseScore + random.nextDouble() * 10;
      addAssessmentRecord(AssessmentRecord(
        id: 'assessment_${childId}_$daysAgo',
        childId: childId,
        date: now.subtract(Duration(days: daysAgo)),
        type: daysAgo == 0
            ? AssessmentType.miniTest
            : AssessmentType.fullAssessment,
        domainScores: {
          'phonological': score + random.nextDouble() * 10 - 5,
          'visual': score + random.nextDouble() * 10 - 5,
          'auditory': score + random.nextDouble() * 10 - 5,
          'memory': score + random.nextDouble() * 10 - 5,
          'attention': score + random.nextDouble() * 10 - 5,
        },
        totalScore: score,
      ));
      baseScore = score + 5;
    }
  }
}

