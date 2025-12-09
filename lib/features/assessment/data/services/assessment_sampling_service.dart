import 'dart:math';
import '../../../training/data/models/training_content_model.dart';
import '../../../training/data/models/difficulty_params_model.dart';
import '../../../training/data/services/question_loader_service.dart';

/// Assessment를 위해 Training 문항에서 샘플링하는 서비스
class AssessmentSamplingService {
  final QuestionLoaderService _questionLoader = QuestionLoaderService();
  final Random _random = Random();

  /// 50개 게임의 JSON 파일명 목록
  static const List<String> _gameFiles = [
    // Phonological (10개)
    'same_sound.json',
    'different_sound.json',
    'syllable_clap.json',
    'rhyme.json',
    'syllable_merge.json',
    'syllable_split.json',
    'rhythm_follow.json',
    'onset_separation.json',
    'phoneme_synthesis.json',
    'phoneme_substitution.json',
    
    // Auditory (10개)
    'animal_sound_story.json',
    'instrument_sequence.json',
    'rhythm_pattern.json',
    'simon_says.json',
    'sound_rule.json',
    'sound_sequence_memory.json',
    'pitch_discrimination.json',
    'volume_comparison.json',
    'tempo_sequence.json',
    'environmental_sound.json',
    
    // Visual (10개)
    'hidden_letter.json',
    'letter_direction.json',
    'mirror_symmetry.json',
    'puzzle.json',
    'shape_rotation.json',
    'spot_difference.json',
    'visual_closure.json',
    'figure_ground.json',
    'visual_tracking.json',
    'pattern_completion.json',
    
    // Working Memory (10개)
    'card_match.json',
    'instruction_follow.json',
    'n_back.json',
    'reverse_speak.json',
    'reverse_touch.json',
    'digit_span.json',
    'dual_task.json',
    'location_memory.json',
    'updating_memory.json',
    'complex_span.json',
    
    // Attention (10개)
    'auditory_attention.json',
    'flow_tracking.json',
    'focus_marathon.json',
    'stroop.json',
    'target_hunt.json',
    'go_no_go_basic.json',
    'selective_attention.json',
    'divided_attention.json',
    'sustained_attention.json',
    'visual_search.json',
  ];

  /// Assessment용 50문항 생성 (각 게임에서 1문항씩 랜덤 선택)
  Future<List<AssessmentQuestion>> generateAssessmentQuestions() async {
    final List<AssessmentQuestion> assessmentQuestions = [];
    int questionNumber = 1;

    for (final fileName in _gameFiles) {
      try {
        // 각 게임의 문항 로드
        final content = await _questionLoader.loadFromLocalJson(fileName);
        
        if (content.items.isEmpty) {
          print('⚠️ Warning: $fileName has no items');
          continue;
        }

        // 랜덤으로 1문항 선택
        final randomIndex = _random.nextInt(content.items.length);
        final selectedItem = content.items[randomIndex];

        // AssessmentQuestion으로 변환
        assessmentQuestions.add(AssessmentQuestion(
          questionNumber: questionNumber++,
          gameId: fileName.replaceAll('.json', ''),
          gameTitle: content.title,
          contentId: content.contentId,
          type: content.type,
          pattern: content.pattern,
          itemId: selectedItem.itemId,
          question: selectedItem.question,
          options: selectedItem.options,
          correctAnswer: selectedItem.correctAnswer,
          difficulty: content.difficulty,
        ));
      } catch (e) {
        print('❌ Error loading $fileName: $e');
      }
    }

    return assessmentQuestions;
  }

  /// 특정 분야만 샘플링 (예: Phonological만)
  Future<List<AssessmentQuestion>> generateAssessmentQuestionsByType(
    TrainingContentType type,
  ) async {
    final allQuestions = await generateAssessmentQuestions();
    return allQuestions.where((q) => q.type == type).toList();
  }

  /// 난이도별 샘플링
  Future<List<AssessmentQuestion>> generateAssessmentQuestionsByDifficulty(
    int minLevel,
    int maxLevel,
  ) async {
    final allQuestions = await generateAssessmentQuestions();
    return allQuestions.where((q) {
      final level = q.difficulty?.level ?? 1;
      return level >= minLevel && level <= maxLevel;
    }).toList();
  }
}

/// Assessment용 문항 모델 (Training 문항의 간소화 버전)
class AssessmentQuestion {
  final int questionNumber; // 1~50
  final String gameId; // 'same_sound'
  final String gameTitle; // '같은 소리 찾기'
  final String contentId;
  final TrainingContentType type;
  final GamePattern pattern;
  final String itemId;
  final String question;
  final List<ContentOption> options;
  final String correctAnswer;
  final DifficultyParams? difficulty;

  AssessmentQuestion({
    required this.questionNumber,
    required this.gameId,
    required this.gameTitle,
    required this.contentId,
    required this.type,
    required this.pattern,
    required this.itemId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionNumber': questionNumber,
      'gameId': gameId,
      'gameTitle': gameTitle,
      'contentId': contentId,
      'type': type.toString(),
      'pattern': pattern.toString(),
      'itemId': itemId,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'difficulty': difficulty?.toJson(),
    };
  }
}
