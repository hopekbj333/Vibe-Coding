import '../models/scoring_model.dart';

/// Mock 채점 데이터 Repository
/// 
/// 실제 환경에서는 Firebase에서 데이터를 가져오지만,
/// 개발 중에는 이 Mock 데이터를 사용합니다.
class MockScoringRepository {
  /// 채점 대기 중인 검사 결과 목록 조회
  Future<List<AssessmentResult>> getPendingAssessments() async {
    // 네트워크 딜레이 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    // Mock 데이터 반환
    return [
      AssessmentResult(
        id: 'result_001',
        assessmentId: 'assessment_001',
        childId: 'child_001',
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        scoringStatus: ScoringStatus.pending,
        scores: [
          // WP 1.4: 기본 문항들 (q1~q3)
          QuestionScore(
            questionId: 'q1',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            autoScoredData: {'selectedAnswer': 0, 'correctAnswer': 0},
          ),
          QuestionScore(
            questionId: 'q2',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            autoScoredData: {'selectedAnswer': 1, 'correctAnswer': 1},
          ),
          QuestionScore(
            questionId: 'q3',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            autoScoredData: {'selectedAnswer': 0, 'correctAnswer': 0},
          ),
          // WP 1.4: 음운 인식 (q4~q16)
          QuestionScore(
            questionId: 'q4_sound',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q5_rhythm',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q6_intonation',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q7_word_boundary',
            result: ScoringResult.partial,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q8_rhyme',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q9_syllable',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q10_syllable_deletion',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          // 녹음 문항들 (채점 완료)
          QuestionScore(
            questionId: 'q11_syllable_reverse',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            memo: '정확하게 발음',
          ),
          QuestionScore(
            questionId: 'q12_phoneme_initial',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q13_phoneme_blending',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q14_phoneme_substitution',
            result: ScoringResult.partial,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            memo: 'ㄱ과 ㅋ 약간 혼동',
          ),
          QuestionScore(
            questionId: 'q15_nonword_repeat',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q16_memory_span',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          
          // WP 1.5: 청각/순차 처리 (q17~q24)
          QuestionScore(
            questionId: 'q17_sound_seq',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q18_sound_seq',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q19_animal_seq',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q20_animal_seq',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q21_animal_seq',
            result: ScoringResult.partial,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q22_position_seq',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q23_position_seq',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q24_position_seq',
            result: ScoringResult.incorrect,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          
          // WP 1.5: 시각 처리 (q25~q34)
          QuestionScore(
            questionId: 'q25_find_diff',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q26_find_diff',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q27_same_shape',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q28_same_shape',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q29_direction',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q30_direction',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q31_direction',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q32_hidden',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q33_hidden',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q34_hidden',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          
          // WP 1.6: 작업 기억 (q35~q38)
          QuestionScore(
            questionId: 'q35_digit_forward',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q36_digit_backward',
            result: ScoringResult.incorrect,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            memo: '거꾸로 말하기 어려워함',
          ),
          QuestionScore(
            questionId: 'q37_word_forward',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          QuestionScore(
            questionId: 'q38_word_backward',
            result: ScoringResult.partial,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          
          // WP 1.6: 주의 집중 (q39~q41)
          QuestionScore(
            questionId: 'q39_gonogo',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            autoScoredData: {
              'correctResponses': 8,
              'incorrectResponses': 1,
              'missedResponses': 1,
              'avgReactionTime': 450,
              'accuracy': '80.0',
            },
          ),
          QuestionScore(
            questionId: 'q40_gonogo_audio',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            autoScoredData: {
              'correctResponses': 9,
              'incorrectResponses': 0,
              'missedResponses': 1,
              'avgReactionTime': 380,
              'accuracy': '90.0',
            },
          ),
          QuestionScore(
            questionId: 'q41_continuous',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 1)),
            autoScoredData: {
              'totalTargets': 12,
              'correctHits': 11,
              'incorrectHits': 2,
              'accuracy': '91.7',
            },
          ),
        ],
        totalQuestions: 41,
        scoredQuestions: 41, // 모두 채점 완료
      ),
      AssessmentResult(
        id: 'result_002',
        assessmentId: 'assessment_001',
        childId: 'child_002',
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
        scoringStatus: ScoringStatus.inProgress,
        scores: [
          QuestionScore(
            questionId: 'q11_syllable_reverse',
            result: ScoringResult.correct,
            scoredAt: DateTime.now().subtract(const Duration(hours: 2)),
            scoredBy: 'teacher_001',
            memo: '정확하게 잘 따라함',
          ),
          const QuestionScore(
            questionId: 'q12_phoneme_initial',
            result: ScoringResult.notScored,
          ),
        ],
        totalQuestions: 41,
        scoredQuestions: 33, // 일부 채점 진행 중
      ),
    ];
  }

  /// 특정 검사 결과 상세 조회
  Future<AssessmentResult> getAssessmentResult(String resultId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final results = await getPendingAssessments();
    return results.firstWhere(
      (r) => r.id == resultId,
      orElse: () => results.first,
    );
  }

  /// 문항 채점 저장
  Future<void> saveQuestionScore(
    String resultId,
    QuestionScore score,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 실제로는 Firebase에 저장
    print('💾 채점 저장: $resultId - ${score.questionId} = ${score.result.name}');
  }

  /// 채점 완료 처리
  Future<void> completeScoringStatus(String resultId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('✅ 채점 완료 처리: $resultId');
  }

  /// 녹음 파일 삭제
  Future<void> deleteRecordingFile(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('🗑️ 녹음 파일 삭제: $filePath');
  }
}

