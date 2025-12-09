import '../../data/models/scoring_model.dart';

/// 영역별 점수 결과
class DomainScore {
  final String domainName; // 영역 이름
  final int totalQuestions; // 전체 문항 수
  final int correctAnswers; // 정답 수
  final double percentage; // 정답률 (0~100)
  final ReadinessLevel level; // 준비도 수준

  const DomainScore({
    required this.domainName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.level,
  });
}

/// 준비도 수준 (신호등)
enum ReadinessLevel {
  ready, // 🟢 준비 완료 (80% 이상)
  needHelp, // 🟡 도움 필요 (50~79%)
  needTraining, // 🔴 집중 훈련 (50% 미만)
}

/// 검사 결과 점수 산출 서비스
class ScoreCalculator {
  /// 영역별 점수 계산
  /// 
  /// WP 1.4~1.6 문항들을 영역별로 그룹화하여 점수를 산출합니다.
  static List<DomainScore> calculateDomainScores(
    List<QuestionScore> scores,
  ) {
    // 영역별 문항 ID 매핑
    final domains = {
      '음운 인식': _getQuestionIdsByDomain('phonological'),
      '청각/순차 처리': _getQuestionIdsByDomain('auditory'),
      '시각 처리': _getQuestionIdsByDomain('visual'),
      '작업 기억': _getQuestionIdsByDomain('working_memory'),
      '주의 집중': _getQuestionIdsByDomain('attention'),
    };

    final domainScores = <DomainScore>[];

    for (final entry in domains.entries) {
      final domainName = entry.key;
      final questionIds = entry.value;

      // 해당 영역의 점수들 필터링
      final domainQuestionScores = scores
          .where((s) => questionIds.contains(s.questionId))
          .toList();

      if (domainQuestionScores.isEmpty) continue;

      // 정답 개수 계산
      final correctCount = domainQuestionScores
          .where((s) =>
              s.result == ScoringResult.correct ||
              s.result == ScoringResult.partial)
          .length;

      final totalCount = domainQuestionScores.length;
      final percentage = (correctCount / totalCount * 100);

      // 준비도 수준 판정
      final level = determineReadinessLevel(percentage);

      domainScores.add(DomainScore(
        domainName: domainName,
        totalQuestions: totalCount,
        correctAnswers: correctCount,
        percentage: percentage,
        level: level,
      ));
    }

    return domainScores;
  }

  /// 전체 점수 계산
  static double calculateOverallScore(List<QuestionScore> scores) {
    final validScores = scores
        .where((s) => s.result != ScoringResult.notScored)
        .toList();

    if (validScores.isEmpty) return 0.0;

    final correctCount = validScores
        .where((s) =>
            s.result == ScoringResult.correct ||
            s.result == ScoringResult.partial)
        .length;

    return (correctCount / validScores.length * 100);
  }

  /// 반응 시간 분석 (주의 집중 영역)
  static Map<String, dynamic> analyzeReactionTimes(
    List<QuestionScore> scores,
  ) {
    final reactionTimeScores = scores
        .where((s) => s.autoScoredData != null)
        .where((s) =>
            s.autoScoredData is Map &&
            s.autoScoredData['avgReactionTime'] != null)
        .toList();

    if (reactionTimeScores.isEmpty) {
      return {
        'avgReactionTime': 0,
        'minReactionTime': 0,
        'maxReactionTime': 0,
        'hasData': false,
      };
    }

    final reactionTimes = reactionTimeScores
        .map((s) => s.autoScoredData['avgReactionTime'] as int)
        .toList();

    final avg =
        reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;
    final min = reactionTimes.reduce((a, b) => a < b ? a : b);
    final max = reactionTimes.reduce((a, b) => a > b ? a : b);

    return {
      'avgReactionTime': avg.toInt(),
      'minReactionTime': min,
      'maxReactionTime': max,
      'hasData': true,
    };
  }

  /// 준비도 수준 판정
  static ReadinessLevel determineReadinessLevel(double percentage) {
    if (percentage >= 80) {
      return ReadinessLevel.ready;
    } else if (percentage >= 50) {
      return ReadinessLevel.needHelp;
    } else {
      return ReadinessLevel.needTraining;
    }
  }

  /// 영역별 문항 ID 목록
  static List<String> _getQuestionIdsByDomain(String domain) {
    switch (domain) {
      case 'phonological':
        // WP 1.4: 음운 인식 (q4~q16)
        return [
          'q4_sound',
          'q5_rhythm',
          'q6_intonation',
          'q7_word_boundary',
          'q8_rhyme',
          'q9_syllable',
          'q10_syllable_deletion',
          'q11_syllable_reverse',
          'q12_phoneme_initial',
          'q13_phoneme_blending',
          'q14_phoneme_substitution',
          'q15_nonword_repeat',
          'q16_memory_span',
        ];

      case 'auditory':
        // WP 1.5: 청각/순차 처리 (q17~q24)
        return [
          'q17_sound_seq',
          'q18_sound_seq',
          'q19_animal_seq',
          'q20_animal_seq',
          'q21_animal_seq',
          'q22_position_seq',
          'q23_position_seq',
          'q24_position_seq',
        ];

      case 'visual':
        // WP 1.5: 시각 처리 (q25~q34)
        return [
          'q25_find_diff',
          'q26_find_diff',
          'q27_same_shape',
          'q28_same_shape',
          'q29_direction',
          'q30_direction',
          'q31_direction',
          'q32_hidden',
          'q33_hidden',
          'q34_hidden',
        ];

      case 'working_memory':
        // WP 1.6: 작업 기억 (q35~q38)
        return [
          'q35_digit_forward',
          'q36_digit_backward',
          'q37_word_forward',
          'q38_word_backward',
        ];

      case 'attention':
        // WP 1.6: 주의 집중 (q39~q41)
        return [
          'q39_gonogo',
          'q40_gonogo_audio',
          'q41_continuous',
        ];

      default:
        return [];
    }
  }

  /// 위험 징후 감지
  static List<String> detectRiskFactors(List<DomainScore> domainScores) {
    final warnings = <String>[];

    for (final domain in domainScores) {
      // 음운 인식 영역이 매우 낮으면
      if (domain.domainName == '음운 인식' && domain.percentage < 30) {
        warnings.add('음운 인식 능력이 매우 낮습니다. 난독증 전문 평가를 권장합니다.');
      }

      // 청각 처리가 극저점이면
      if (domain.domainName == '청각/순차 처리' && domain.percentage < 20) {
        warnings.add('청각 주의력이 매우 낮습니다. 청력 검사를 권유합니다.');
      }

      // 주의 집중이 낮으면
      if (domain.domainName == '주의 집중' && domain.percentage < 40) {
        warnings.add('주의 집중 능력 향상이 필요합니다. ADHD 전문가 상담을 권장합니다.');
      }
    }

    return warnings;
  }

  /// 맞춤형 권장 사항 생성
  static List<String> generateRecommendations(List<DomainScore> domainScores) {
    final recommendations = <String>[];

    for (final domain in domainScores) {
      switch (domain.level) {
        case ReadinessLevel.ready:
          recommendations.add(
            '${domain.domainName}: 훌륭해요! 다음 단계 학습을 시작해도 좋습니다. 🟢',
          );
          break;

        case ReadinessLevel.needHelp:
          recommendations.add(
            '${domain.domainName}: 앱 내 훈련 콘텐츠로 보완해보세요. 🟡',
          );
          break;

        case ReadinessLevel.needTraining:
          recommendations.add(
            '${domain.domainName}: 집중적인 훈련이 필요합니다. 전문가 상담을 권장합니다. 🔴',
          );
          break;
      }
    }

    return recommendations;
  }

  /// 가정 내 활동 가이드
  static Map<String, String> getHomeActivities(String domainName) {
    final activities = {
      '음운 인식': '박수 치며 단어 쪼개기 놀이, 같은 소리로 시작하는 단어 찾기',
      '청각/순차 처리': '소리 순서 기억하기 놀이, 동요 부르며 리듬 맞추기',
      '시각 처리': '그림 찾기 놀이, 퍼즐 맞추기, 미로 찾기',
      '작업 기억': '숫자 따라 말하기, 심부름 기억하기 놀이',
      '주의 집중': 'Simon Says 게임, 특정 물건만 찾기 놀이',
    };

    return {
      'activity': activities[domainName] ?? '다양한 놀이를 시도해보세요',
    };
  }
}

