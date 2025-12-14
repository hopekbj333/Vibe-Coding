import 'dart:math';
import '../../../training/data/services/question_loader_service.dart';
import '../models/story_assessment_model.dart';
import 'assessment_sampling_service.dart';

/// 35개 능력과 게임 매핑 정보
class AbilityGameMapping {
  final String abilityId; // "0.1", "1.1" 등
  final String abilityName; // 능력명
  final String gameFileName; // JSON 파일명
  final String gameTitle; // 게임 제목
  final String storyContext; // 스토리 맥락
  final String characterDialogue; // 캐릭터 대사
  final StoryFeedback feedback; // 피드백
  final String? stageTitle; // Stage 제목

  const AbilityGameMapping({
    required this.abilityId,
    required this.abilityName,
    required this.gameFileName,
    required this.gameTitle,
    required this.storyContext,
    required this.characterDialogue,
    required this.feedback,
    this.stageTitle,
  });
}

/// 스토리 문항 매핑 서비스
/// 35개 능력 체계를 기반으로 각 능력당 1개 문항을 생성
class StoryQuestionMappingService {
  final QuestionLoaderService _questionLoader = QuestionLoaderService();
  final Random _random = Random();

  /// 35개 능력과 게임 매핑 정의
  /// Part 1: 음운인식능력 (15개) + Part 2: 음운처리능력 (20개) = 35개
  static const List<AbilityGameMapping> _abilityMappings = [
    // ========== Part 1: 음운인식능력 (15개) ==========
    
    // Stage 0: 기초 청각 (2개)
    AbilityGameMapping(
      abilityId: '0.1',
      abilityName: '환경음 식별',
      gameFileName: 'environmental_sound.json',
      gameTitle: '환경음 식별',
      storyContext: '동물 마을에서 다양한 소리가 들려. 어떤 소리인지 맞춰볼까?',
      characterDialogue: '우와! 동물 마을이야! 여기서는 다양한 소리가 들려. 들리는 소리가 뭔지 맞춰줄 수 있을까?',
      feedback: StoryFeedback(
        correctMessage: '맞아! 정확하게 구별했어!',
        incorrectMessage: '아쉽지만 괜찮아! 다시 한 번 들어볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '🎵',
      ),
      stageTitle: 'Stage 1-1: 기초 청각 능력',
    ),
    AbilityGameMapping(
      abilityId: '0.2',
      abilityName: '소리 크기/높이 변별',
      gameFileName: 'pitch_discrimination.json',
      gameTitle: '음높이 구별',
      storyContext: '이번엔 소리의 크기와 높이를 구별해볼게. 큰 소리와 작은 소리, 높은 소리와 낮은 소리를 찾아줘!',
      characterDialogue: '이제 두 가지의 소리를 들려 주겠습니다. 두 가지 중에서 어떤 소리가 더 긴지, 긴 소리를 화면에서 선택해 주세요.',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 소리의 차이를 정확히 알아챘어!',
        incorrectMessage: '조금 어려웠나? 다시 들어보면서 차이를 느껴볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 1-1: 기초 청각 능력',
    ),

    // Stage 1: 음절 인식 (5개)
    AbilityGameMapping(
      abilityId: '1.1',
      abilityName: '음절 수 세기',
      gameFileName: 'syllable_clap.json',
      gameTitle: '박수로 음절 쪼개기',
      storyContext: '음절 숲의 나무들이 말을 하고 있어. 몇 개의 음절로 나뉘는지 세어볼까?',
      characterDialogue: '이제 음절 숲에 도착했어! 음절은 말소리의 덩어리야. 예를 들어 가방은 가와 방 두 개의 음절이지.',
      feedback: StoryFeedback(
        correctMessage: '정확해! 음절을 잘 세었어!',
        incorrectMessage: '박수로 세어보면 쉬워져! 다시 해볼까?',
        correctEmoji: '🎉',
        incorrectEmoji: '👏',
      ),
      stageTitle: 'Stage 1-2: 음절 인식',
    ),
    AbilityGameMapping(
      abilityId: '1.2',
      abilityName: '음절 분절',
      gameFileName: 'syllable_split.json',
      gameTitle: '음절 분리',
      storyContext: '이번엔 단어를 음절로 나눠볼게. 가방을 가와 방으로 나눌 수 있을까?',
      characterDialogue: '단어를 음절로 나눠볼게. 가방을 가와 방으로 나눌 수 있을까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 음절을 정확히 나눴어!',
        incorrectMessage: '박수로 쪼개보면 쉬워져! 한 번 더 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 1-2: 음절 인식',
    ),
    AbilityGameMapping(
      abilityId: '1.3',
      abilityName: '음절 합성',
      gameFileName: 'syllable_merge.json',
      gameTitle: '음절 합성',
      storyContext: '반대로 음절을 합쳐서 단어를 만들어볼게. 가와 방을 합치면 뭐가 될까?',
      characterDialogue: '반대로 음절을 합쳐서 단어를 만들어볼게. 가와 방을 합치면 뭐가 될까?',
      feedback: StoryFeedback(
        correctMessage: '대단해! 음절을 잘 합쳤어!',
        incorrectMessage: '천천히 합쳐보면 돼! 다시 시도해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '🔄',
      ),
      stageTitle: 'Stage 1-2: 음절 인식',
    ),
    AbilityGameMapping(
      abilityId: '1.4',
      abilityName: '음절 변별',
      gameFileName: 'same_sound.json',
      gameTitle: '같은 소리 찾기',
      storyContext: '같은 소리와 다른 소리를 구별해볼게. 가방과 가지는 같은가요, 다른가요?',
      characterDialogue: '같은 소리와 다른 소리를 구별해볼게. 가방과 가지는 같은가요, 다른가요?',
      feedback: StoryFeedback(
        correctMessage: '정확해! 소리를 잘 구별했어!',
        incorrectMessage: '다시 들어보면서 차이를 느껴볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '🎵',
      ),
      stageTitle: 'Stage 1-2: 음절 인식',
    ),
    AbilityGameMapping(
      abilityId: '1.5',
      abilityName: '음절 탈락',
      gameFileName: 'rhyme.json',
      gameTitle: '각운 찾기',
      storyContext: '이번엔 음절을 빼는 게임이야. 가방에서 가를 빼면 뭐가 남을까?',
      characterDialogue: '이번엔 음절을 빼는 게임이야. 가방에서 가를 빼면 뭐가 남을까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 음절을 정확히 빼냈어!',
        incorrectMessage: '천천히 생각해보면 돼! 다시 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💭',
      ),
      stageTitle: 'Stage 1-2: 음절 인식',
    ),

    // Stage 2: 본체-종성 인식 (4개) - 한글 특수
    AbilityGameMapping(
      abilityId: '2.1',
      abilityName: '초성 인식',
      gameFileName: 'onset_separation.json',
      gameTitle: '초성 분리',
      storyContext: '동굴 안에서 첫소리를 찾아볼게. 곰의 첫소리는 뭘까?',
      characterDialogue: '와! 특별한 동굴이야! 이 동굴은 한글만의 특별한 구조를 가지고 있어. 본체와 종성이라는 개념이지.',
      feedback: StoryFeedback(
        correctMessage: '정확해! 첫소리를 잘 찾았어!',
        incorrectMessage: '첫소리를 천천히 발음해보면 돼! 다시 해볼까?',
        correctEmoji: '🎉',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 1-3: 본체-종성 인식',
    ),
    AbilityGameMapping(
      abilityId: '2.2',
      abilityName: '중성 인식',
      gameFileName: 'onset_separation.json', // 중성 변형 필요
      gameTitle: '중성 인식',
      storyContext: '이번엔 가운데소리야. 곰의 가운데소리는 뭘까?',
      characterDialogue: '이번엔 가운데소리야. 곰의 가운데소리는 뭘까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 가운데소리를 잘 찾았어!',
        incorrectMessage: '가운데소리를 천천히 발음해보면 돼!',
        correctEmoji: '✨',
        incorrectEmoji: '🔄',
      ),
      stageTitle: 'Stage 1-3: 본체-종성 인식',
    ),
    AbilityGameMapping(
      abilityId: '2.3',
      abilityName: '종성 인식',
      gameFileName: 'onset_separation.json', // 종성 변형 필요
      gameTitle: '종성 인식',
      storyContext: '마지막으로 끝소리야. 곰의 끝소리는 뭘까?',
      characterDialogue: '마지막으로 끝소리야. 곰의 끝소리는 뭘까?',
      feedback: StoryFeedback(
        correctMessage: '대단해! 끝소리를 잘 찾았어!',
        incorrectMessage: '끝소리를 천천히 발음해보면 돼! 다시 해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '💭',
      ),
      stageTitle: 'Stage 1-3: 본체-종성 인식',
    ),
    AbilityGameMapping(
      abilityId: '2.4',
      abilityName: '본체-종성 분리',
      gameFileName: 'onset_separation.json',
      gameTitle: '초성 분리',
      storyContext: '이제 본체와 종성을 나눠볼게. 곰을 고와 ㅁ으로 나눌 수 있을까?',
      characterDialogue: '이제 본체와 종성을 나눠볼게. 곰을 고와 ㅁ으로 나눌 수 있을까?',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 한글의 특별한 구조를 이해했어!',
        incorrectMessage: '한글만의 특별한 구조라 조금 어려울 수 있어. 천천히 해볼까?',
        correctEmoji: '🌟',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 1-3: 본체-종성 인식',
    ),

    // Stage 3: 음소 인식 (4개)
    AbilityGameMapping(
      abilityId: '3.1',
      abilityName: '음소 분리',
      gameFileName: 'phoneme_synthesis.json', // 분리 변형 필요
      gameTitle: '음소 분리',
      storyContext: '음소 성에서 가장 작은 소리로 나눠볼게. 가를 ㄱ과 ㅏ로 나눌 수 있을까?',
      characterDialogue: '드디어 소리 섬의 최고봉 음소 성에 도착했어! 음소는 가장 작은 소리 단위야.',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 음소를 정확히 나눴어!',
        incorrectMessage: '가장 작은 소리 단위라 조금 어려울 수 있어. 천천히 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💭',
      ),
      stageTitle: 'Stage 1-4: 음소 인식',
    ),
    AbilityGameMapping(
      abilityId: '3.2',
      abilityName: '음소 합성',
      gameFileName: 'phoneme_synthesis.json',
      gameTitle: '음소 합성',
      storyContext: '반대로 음소를 합쳐볼게. ㄱ과 ㅏ를 합치면 뭐가 될까?',
      characterDialogue: '반대로 음소를 합쳐볼게. ㄱ과 ㅏ를 합치면 뭐가 될까?',
      feedback: StoryFeedback(
        correctMessage: '대단해! 음소를 잘 합쳤어!',
        incorrectMessage: '천천히 합쳐보면 돼! 다시 시도해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '🔄',
      ),
      stageTitle: 'Stage 1-4: 음소 인식',
    ),
    AbilityGameMapping(
      abilityId: '3.3',
      abilityName: '음소 대치',
      gameFileName: 'phoneme_substitution.json',
      gameTitle: '음소 대치',
      storyContext: '이번엔 음소를 바꿔볼게. 가방의 첫소리를 ㄴ으로 바꾸면 뭐가 될까?',
      characterDialogue: '이번엔 음소를 바꿔볼게. 가방의 첫소리를 ㄴ으로 바꾸면 뭐가 될까?',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 음소를 정확히 바꿨어!',
        incorrectMessage: '음소를 바꾸는 게 조금 어려울 수 있어. 천천히 해볼까?',
        correctEmoji: '🌟',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 1-4: 음소 인식',
    ),
    AbilityGameMapping(
      abilityId: '3.4',
      abilityName: '음소 탈락',
      gameFileName: 'phoneme_substitution.json', // 탈락 변형 필요
      gameTitle: '음소 탈락',
      storyContext: '마지막으로 음소를 빼는 게임이야. 밥에서 ㅂ을 빼면 뭐가 남을까?',
      characterDialogue: '마지막으로 음소를 빼는 게임이야. 밥에서 ㅂ을 빼면 뭐가 남을까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 음소를 정확히 빼냈어!',
        incorrectMessage: '가장 작은 소리 단위라 조금 어려울 수 있어. 천천히 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💭',
      ),
      stageTitle: 'Stage 1-4: 음소 인식',
    ),

    // ========== Part 2: 음운처리능력 (20개) ==========
    // 음운 기억 (3개) + 빠른 이름 대기 (4개) + 인지 기초 (13개) = 20개
    
    // 음운 기억 (3개)
    AbilityGameMapping(
      abilityId: 'PM1',
      abilityName: '단어 반복',
      gameFileName: 'reverse_speak.json', // 단어 버전
      gameTitle: '거꾸로 말하기',
      storyContext: '기억 섬의 파도 소리가 단어를 말하고 있어. 똑같이 따라 말해볼까?',
      characterDialogue: '첫 번째 섬은 기억 섬이야! 여기서는 소리를 듣고 기억하는 실력을 테스트해볼게.',
      feedback: StoryFeedback(
        correctMessage: '정확해! 단어를 잘 기억하고 따라 말했어!',
        incorrectMessage: '다시 한 번 들어보고 따라 말해볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '🎵',
      ),
      stageTitle: 'Stage 2-1: 음운 기억',
    ),
    AbilityGameMapping(
      abilityId: 'PM2',
      abilityName: '비단어 반복',
      gameFileName: 'reverse_speak.json', // 비단어 버전
      gameTitle: '거꾸로 말하기',
      storyContext: '이번엔 의미 없는 소리야. 타비, 무카 같은 소리를 따라 말해볼까?',
      characterDialogue: '이번엔 의미 없는 소리야. 타비, 무카 같은 소리를 따라 말해볼까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 의미 없는 소리도 잘 기억했어!',
        incorrectMessage: '의미 없는 소리는 조금 어려울 수 있어. 천천히 따라 말해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 2-1: 음운 기억',
    ),
    AbilityGameMapping(
      abilityId: 'PM3',
      abilityName: '숫자 폭',
      gameFileName: 'digit_span.json',
      gameTitle: '숫자 외우기',
      storyContext: '마지막으로 숫자를 기억해볼게. 3-7-2를 듣고 똑같이 말해볼까?',
      characterDialogue: '마지막으로 숫자를 기억해볼게. 3-7-2를 듣고 똑같이 말해볼까?',
      feedback: StoryFeedback(
        correctMessage: '대단해! 숫자를 정확히 기억했어!',
        incorrectMessage: '숫자가 많아지면 어려울 수 있어. 천천히 따라 말해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '🔄',
      ),
      stageTitle: 'Stage 2-1: 음운 기억',
    ),

    // 빠른 이름 대기 (4개) - RAN
    AbilityGameMapping(
      abilityId: 'RAN1',
      abilityName: '사물 빠른 이름대기',
      gameFileName: 'spot_difference.json', // 이름대기 버전
      gameTitle: '틀린 그림 찾기',
      storyContext: '빠름 섬에 그림들이 나타났어! 사과, 책, 공, 자동차를 빠르게 이름 말해볼까?',
      characterDialogue: '다음 섬은 빠름 섬이야! 여기서는 그림을 보고 빠르게 이름을 말하는 실력을 테스트해볼게.',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 빠르게 이름을 말했어!',
        incorrectMessage: '천천히 정확하게 말하는 것도 중요해! 다시 해볼까?',
        correctEmoji: '⚡',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 2-2: 빠른 이름 대기',
    ),
    AbilityGameMapping(
      abilityId: 'RAN2',
      abilityName: '색상 빠른 이름대기',
      gameFileName: 'visual_tracking.json', // 색상 버전
      gameTitle: '시각 추적',
      storyContext: '이번엔 색깔이야! 빨강, 파랑, 노랑, 초록을 빠르게 이름 말해볼까?',
      characterDialogue: '이번엔 색깔이야! 빨강, 파랑, 노랑, 초록을 빠르게 이름 말해볼까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 색깔을 빠르게 구별했어!',
        incorrectMessage: '색깔 이름을 천천히 말해보면 돼! 다시 해볼까?',
        correctEmoji: '🌈',
        incorrectEmoji: '🔄',
      ),
      stageTitle: 'Stage 2-2: 빠른 이름 대기',
    ),
    AbilityGameMapping(
      abilityId: 'RAN3',
      abilityName: '숫자 빠른 이름대기',
      gameFileName: 'visual_tracking.json', // 숫자 버전
      gameTitle: '시각 추적',
      storyContext: '마지막으로 숫자야! 2, 5, 8, 1을 빠르게 이름 말해볼까?',
      characterDialogue: '마지막으로 숫자야! 2, 5, 8, 1을 빠르게 이름 말해볼까?',
      feedback: StoryFeedback(
        correctMessage: '대단해! 숫자를 빠르게 말했어!',
        incorrectMessage: '숫자 이름을 천천히 말해보면 돼! 다시 해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '💭',
      ),
      stageTitle: 'Stage 2-2: 빠른 이름 대기',
    ),
    AbilityGameMapping(
      abilityId: 'RAN4',
      abilityName: '문자 빠른 이름대기',
      gameFileName: 'letter_direction.json',
      gameTitle: '글자 방향 구별',
      storyContext: '이번엔 글자야! ㄱ, ㄴ, ㅁ, ㅅ을 빠르게 이름 말해볼까?',
      characterDialogue: '이번엔 글자야! ㄱ, ㄴ, ㅁ, ㅅ을 빠르게 이름 말해볼까?',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 글자를 빠르게 읽었어!',
        incorrectMessage: '글자 이름을 천천히 말해보면 돼! 다시 해볼까?',
        correctEmoji: '🌟',
        incorrectEmoji: '💪',
      ),
      stageTitle: 'Stage 2-2: 빠른 이름 대기',
    ),

    // 인지 기초 (13개) - 시각 처리, 작업 기억, 주의력, 실행 기능
    // 시각 처리 (4개)
    AbilityGameMapping(
      abilityId: 'V1',
      abilityName: '시각 변별',
      gameFileName: 'spot_difference.json',
      gameTitle: '틀린 그림 찾기',
      storyContext: '숲 속 퀴즈에서 다른 그림을 찾아볼게. 어떤 그림이 다른가요?',
      characterDialogue: '마지막은 숲 속 퀴즈야. 집중력과 기억력을 테스트해볼게.',
      feedback: StoryFeedback(
        correctMessage: '정확해! 다른 그림을 잘 찾았어!',
        incorrectMessage: '자세히 살펴보면 찾을 수 있어! 다시 해볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '🔍',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'V2',
      abilityName: '시각 순서',
      gameFileName: 'pattern_completion.json',
      gameTitle: '패턴 완성',
      storyContext: '패턴을 보고 다음 그림을 찾아볼게. 어떤 순서로 이어질까?',
      characterDialogue: '패턴을 보고 다음 그림을 찾아볼게. 어떤 순서로 이어질까?',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 순서를 정확히 찾았어!',
        incorrectMessage: '패턴을 자세히 보면 알 수 있어! 다시 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '💭',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'V3',
      abilityName: '시각 공간 처리',
      gameFileName: 'shape_rotation.json',
      gameTitle: '도형 회전',
      storyContext: '도형을 돌려서 같은 모양을 찾아볼게. 어떤 방향으로 돌려야 할까?',
      characterDialogue: '도형을 돌려서 같은 모양을 찾아볼게. 어떤 방향으로 돌려야 할까?',
      feedback: StoryFeedback(
        correctMessage: '대단해! 공간을 잘 이해했어!',
        incorrectMessage: '도형을 머릿속으로 돌려보면 돼! 다시 해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '🔄',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'V4',
      abilityName: '시각 기억',
      gameFileName: 'visual_closure.json',
      gameTitle: '부분으로 전체 추측',
      storyContext: '일부만 보이는 그림을 보고 전체를 맞춰볼게. 무엇일까?',
      characterDialogue: '일부만 보이는 그림을 보고 전체를 맞춰볼게. 무엇일까?',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 기억을 잘 활용했어!',
        incorrectMessage: '자세히 보면 알 수 있어! 다시 해볼까?',
        correctEmoji: '🌟',
        incorrectEmoji: '💪',
      ),
    ),

    // 작업 기억 (3개)
    AbilityGameMapping(
      abilityId: 'WM1',
      abilityName: '단어 기억 폭',
      gameFileName: 'card_match.json',
      gameTitle: '카드 짝 맞추기',
      storyContext: '카드를 뒤집어서 같은 그림을 찾아볼게. 기억해야 해!',
      characterDialogue: '카드를 뒤집어서 같은 그림을 찾아볼게. 기억해야 해!',
      feedback: StoryFeedback(
        correctMessage: '정확해! 기억을 잘 활용했어!',
        incorrectMessage: '기억하는 게 중요해! 다시 해볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '💭',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'WM2',
      abilityName: '지시 따르기',
      gameFileName: 'instruction_follow.json',
      gameTitle: '지시 따르기',
      storyContext: '지시를 듣고 순서대로 행동해볼게. 잘 기억해야 해!',
      characterDialogue: '지시를 듣고 순서대로 행동해볼게. 잘 기억해야 해!',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 지시를 잘 따랐어!',
        incorrectMessage: '순서를 기억하는 게 중요해! 다시 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '🔄',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'WM3',
      abilityName: '업데이트 기억',
      gameFileName: 'updating_memory.json',
      gameTitle: '업데이트 기억',
      storyContext: '기억을 계속 업데이트해야 해. 새로운 정보를 기억해볼게!',
      characterDialogue: '기억을 계속 업데이트해야 해. 새로운 정보를 기억해볼게!',
      feedback: StoryFeedback(
        correctMessage: '대단해! 기억을 잘 업데이트했어!',
        incorrectMessage: '새로운 정보를 기억하는 게 중요해! 다시 해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '💪',
      ),
    ),

    // 주의력 (3개)
    AbilityGameMapping(
      abilityId: 'AT1',
      abilityName: '선택적 주의',
      gameFileName: 'selective_attention.json',
      gameTitle: '선택적 주의',
      storyContext: '중요한 것만 집중해서 찾아볼게. 다른 것은 무시해야 해!',
      characterDialogue: '중요한 것만 집중해서 찾아볼게. 다른 것은 무시해야 해!',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 집중을 잘했어!',
        incorrectMessage: '집중하는 게 중요해! 다시 해볼까?',
        correctEmoji: '🌟',
        incorrectEmoji: '🔍',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'AT2',
      abilityName: '지속적 주의',
      gameFileName: 'sustained_attention.json',
      gameTitle: '지속적 주의',
      storyContext: '오랫동안 집중해야 해. 끝까지 집중해볼게!',
      characterDialogue: '오랫동안 집중해야 해. 끝까지 집중해볼게!',
      feedback: StoryFeedback(
        correctMessage: '정확해! 끝까지 집중했어!',
        incorrectMessage: '끝까지 집중하는 게 중요해! 다시 해볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '💪',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'AT3',
      abilityName: '분할 주의',
      gameFileName: 'divided_attention.json',
      gameTitle: '분할 주의',
      storyContext: '두 가지를 동시에 해야 해. 여러 가지를 동시에 집중해볼게!',
      characterDialogue: '두 가지를 동시에 해야 해. 여러 가지를 동시에 집중해볼게!',
      feedback: StoryFeedback(
        correctMessage: '완벽해! 여러 가지를 잘 처리했어!',
        incorrectMessage: '동시에 집중하는 게 중요해! 다시 해볼까?',
        correctEmoji: '✨',
        incorrectEmoji: '🔄',
      ),
    ),

    // 실행 기능 (3개)
    AbilityGameMapping(
      abilityId: 'EF1',
      abilityName: '억제 제어',
      gameFileName: 'go_no_go_basic.json',
      gameTitle: 'Go/No-Go 기본',
      storyContext: '해야 할 것과 하지 말아야 할 것을 구별해볼게. 참는 것도 중요해!',
      characterDialogue: '해야 할 것과 하지 말아야 할 것을 구별해볼게. 참는 것도 중요해!',
      feedback: StoryFeedback(
        correctMessage: '대단해! 잘 참았어!',
        incorrectMessage: '참는 것도 연습이 필요해! 다시 해볼까?',
        correctEmoji: '🎊',
        incorrectEmoji: '💪',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'EF2',
      abilityName: '인지 전환',
      gameFileName: 'stroop.json',
      gameTitle: '스트룹 과제',
      storyContext: '규칙이 바뀌었어. 빠르게 바꿔야 해!',
      characterDialogue: '규칙이 바뀌었어. 빠르게 바꿔야 해!',
      feedback: StoryFeedback(
        correctMessage: '훌륭해! 빠르게 바꿨어!',
        incorrectMessage: '규칙을 빠르게 바꾸는 게 중요해! 다시 해볼까?',
        correctEmoji: '🌟',
        incorrectEmoji: '🔄',
      ),
    ),
    AbilityGameMapping(
      abilityId: 'EF3',
      abilityName: '계획 수립',
      gameFileName: 'puzzle.json',
      gameTitle: '퍼즐',
      storyContext: '퍼즐을 맞추려면 계획이 필요해. 어떻게 맞출까?',
      characterDialogue: '퍼즐을 맞추려면 계획이 필요해. 어떻게 맞출까?',
      feedback: StoryFeedback(
        correctMessage: '정확해! 계획을 잘 세웠어!',
        incorrectMessage: '계획을 세우는 게 중요해! 다시 해볼까?',
        correctEmoji: '👏',
        incorrectEmoji: '💭',
      ),
    ),
  ];

  /// 35개 능력에 대한 스토리 문항 생성
  Future<List<StoryQuestion>> generateStoryQuestions() async {
    final List<StoryQuestion> storyQuestions = [];

    for (final mapping in _abilityMappings) {
      try {
        // 게임 파일에서 문항 로드
        final content = await _questionLoader.loadFromLocalJson(
          mapping.gameFileName,
        );

        if (content.items.isEmpty) {
          print('⚠️ Warning: ${mapping.gameFileName} has no items - skipping ability ${mapping.abilityId}');
          // 문항이 없어도 빈 문항을 추가하여 순서 유지
          // 또는 에러를 더 명확하게 처리
          continue;
        }

        // 고정으로 첫 번째 문항 선택 (검사 일관성을 위해)
        final selectedItem = content.items[0];

        // AssessmentQuestion으로 변환
        final assessmentQuestion = AssessmentQuestion(
          questionNumber: storyQuestions.length + 1,
          gameId: mapping.gameFileName.replaceAll('.json', ''),
          gameTitle: mapping.gameTitle,
          contentId: content.contentId,
          type: content.type,
          pattern: content.pattern,
          itemId: selectedItem.itemId,
          question: selectedItem.question,
          options: selectedItem.options,
          correctAnswer: selectedItem.correctAnswer,
          difficulty: content.difficulty,
        );

        // StoryQuestion으로 변환
        // #region agent log
        print('📝 StoryQuestion 생성: abilityId=${mapping.abilityId}, audioPath=${selectedItem.questionAudioPath}');
        // #endregion
        
        storyQuestions.add(StoryQuestion(
          questionId: 'story_${mapping.abilityId}_${selectedItem.itemId}',
          abilityId: mapping.abilityId,
          abilityName: mapping.abilityName,
          storyContext: mapping.storyContext,
          characterDialogue: mapping.characterDialogue,
          question: assessmentQuestion,
          feedback: mapping.feedback,
          stageTitle: mapping.stageTitle,
          questionAudioPath: selectedItem.questionAudioPath,
        ));
      } catch (e) {
        print('❌ Error loading ${mapping.gameFileName} for ability ${mapping.abilityId}: $e');
        // 에러 발생 시에도 계속 진행 (다음 문항 로드 시도)
      }
    }

    print('✅ Generated ${storyQuestions.length} story questions (expected: 35)');
    if (storyQuestions.length != 35) {
      print('⚠️ Warning: Expected 35 questions but got ${storyQuestions.length}');
    }

    return storyQuestions;
  }

  /// 특정 챕터 타입에 대한 문항만 생성
  Future<List<StoryQuestion>> generateStoryQuestionsByChapterType(
    StoryChapterType chapterType,
  ) async {
    final allQuestions = await generateStoryQuestions();
    
    // 능력 ID로 필터링
    return allQuestions.where((q) {
      if (chapterType == StoryChapterType.phonologicalAwareness) {
        // Part 1: 0.1 ~ 3.4 (15개)
        return q.abilityId.startsWith('0.') ||
            q.abilityId.startsWith('1.') ||
            q.abilityId.startsWith('2.') ||
            q.abilityId.startsWith('3.');
      } else {
        // Part 2: PM1~PM3, RAN1~RAN4, V1~V4, WM1~WM3, AT1~AT3, EF1~EF3 (20개)
        return q.abilityId.startsWith('PM') ||
            q.abilityId.startsWith('RAN') ||
            q.abilityId.startsWith('V') ||
            q.abilityId.startsWith('WM') ||
            q.abilityId.startsWith('AT') ||
            q.abilityId.startsWith('EF');
      }
    }).toList();
  }
}

