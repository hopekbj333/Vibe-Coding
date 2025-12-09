import '../../domain/repositories/assessment_repository.dart';
import '../models/assessment_model.dart';
import '../models/question_model.dart';

class MockAssessmentRepository implements AssessmentRepository {
  @override
  Future<AssessmentModel> getAssessment(String id) async {
    // 네트워크 딜레이 시뮬레이션 (2초)
    await Future.delayed(const Duration(seconds: 2));

    // 검사 ID에 따라 다른 검사 반환
    switch (id) {
      case 'assessment_phonological':
        return _getPhonologicalAssessment();
      case 'assessment_sensory':
        return _getSensoryAssessment();
      default:
        return _getBasicAssessment();
    }
  }

  /// 기본 문해력 진단 (WP 1.4 + WP 1.5 + WP 1.6 통합)
  AssessmentModel _getBasicAssessment() {
    return AssessmentModel(
      id: 'assessment_001',
      title: '기초 문해력 진단 (만 6세)',
      description: '학교 가기 전 꼭 필요한 읽기 능력을 점검해요.',
      totalQuestions: 41, // WP 1.4 (16) + WP 1.5 (18) + WP 1.6 (7)
      questions: [
        // Q1: O/X 퀴즈 (소리 구분)
        const QuestionModel(
          id: 'q1',
          type: QuestionType.choice,
          promptText: '잘 들어봐. "사과"와 "상어". 첫 번째 소리가 같니?',
          promptAudioUrl: '', // TTS 사용
          optionsText: ['같아요', '달라요'],
          optionsImageUrl: [
            'assets/images/o_button.svg',
            'assets/images/x_button.svg',
          ],
          correctAnswer: 0, // 같아요 (ㅅ으로 같음)
        ),
        // Q2: 4지선다 (그림 찾기)
        const QuestionModel(
          id: 'q2',
          type: QuestionType.choice,
          promptText: '다음 중 "비행기" 그림을 눌러봐.',
          promptAudioUrl: '', // TTS 사용
          optionsText: ['자전거', '비행기', '자동차', '배'],
          optionsImageUrl: [
            'assets/images/bike.svg',
            'assets/images/plane.svg',
            'assets/images/car.svg',
            'assets/images/ship.svg',
          ],
          correctAnswer: 1, // 비행기
        ),
        // Q3: 4지선다 (과일 찾기)
        const QuestionModel(
          id: 'q3',
          type: QuestionType.choice,
          promptText: '다음 중 "사과" 그림을 찾아봐.',
          promptAudioUrl: '', // TTS 사용
          optionsText: ['사과', '바나나', '포도', '오렌지'],
          optionsImageUrl: [
            'assets/images/apple.svg',
            'assets/images/banana.svg',
            'assets/images/grape.svg',
            'assets/images/orange.svg',
          ],
          correctAnswer: 0, // 사과
        ),
        // Q4: S 1.4.1 - 소리 식별
        const QuestionModel(
          id: 'q4_sound',
          type: QuestionType.soundIdentification,
          promptText: '두 소리를 들어봐. 같은 소리야? 다른 소리야?',
          promptAudioUrl: '',
          optionsText: ['같아요', '달라요'],
          soundLabels: ['북소리', '피아노 소리'],
          soundUrls: [],
          correctAnswer: 1, // 달라요 (다른 소리)
        ),
        // Q5: S 1.4.2 - 리듬 따라하기
        const QuestionModel(
          id: 'q5_rhythm',
          type: QuestionType.rhythmTap,
          promptText: '리듬을 잘 보고, 똑같이 눌러봐!',
          promptAudioUrl: '',
          soundLabels: ['500,500,500'], // 똑-똑-똑 (500ms 간격)
          soundUrls: [],
          correctAnswer: 0, // 리듬 문제는 정답이 타이밍 데이터이므로 임의값
        ),
        // Q6: S 1.4.3 - 억양/강세 식별
        const QuestionModel(
          id: 'q6_intonation',
          type: QuestionType.intonation,
          promptText: '이 문장을 읽어봐. 어떤 느낌이야?',
          promptAudioUrl: '',
          optionsText: ['그냥 말하는 거', '물어보는 거'],
          soundLabels: ['밥 먹었어', 'question'], // [문장, 억양유형]
          soundUrls: [],
          correctAnswer: 1, // 물어보는 거 (의문문)
        ),
        // Q7: S 1.4.4 - 단어 경계 인식
        const QuestionModel(
          id: 'q7_word_boundary',
          type: QuestionType.wordBoundary,
          promptText: '이 문장을 읽어봐. 몇 단어야?',
          promptAudioUrl: '',
          optionsText: ['1', '2', '3', '4', '5'],
          soundLabels: ['나는 학교에 갔어'], // 3단어 (나는 / 학교에 / 갔어)
          soundUrls: [],
          correctAnswer: 3, // 3단어
        ),
        // Q8: S 1.4.5 - 각운/두운 찾기 (같은 소리로 시작하는 단어)
        const QuestionModel(
          id: 'q8_rhyme',
          type: QuestionType.rhyme,
          promptText: '이 단어를 읽어봐: "사과"\n이제 "사과"와 같은 소리로 시작하는 거 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['사탕', '바나나', '포도'],
          optionsImageUrl: [
            'assets/images/apple.svg', // 사탕 (임시)
            'assets/images/banana.svg',
            'assets/images/grape.svg',
          ],
          soundLabels: ['사과'], // 기준 단어
          soundUrls: [],
          correctAnswer: 0, // 사탕 (사과와 같은 ㅅ으로 시작)
        ),
        // Q9: S 1.4.6 - 음절 분해/합성
        const QuestionModel(
          id: 'q9_syllable',
          type: QuestionType.syllableBlending,
          promptText: '천천히 읽어 줄게. 소리를 합치면 뭐야?',
          promptAudioUrl: '',
          optionsText: ['나비', '나무', '비행기'],
          optionsImageUrl: [], // 그림 없이 글자만
          soundLabels: ['나-비'], // 음절 분리
          soundUrls: [],
          correctAnswer: 0, // 나비
        ),
        // Q10: S 1.4.7 - 음절 탈락
        const QuestionModel(
          id: 'q10_syllable_deletion',
          type: QuestionType.syllableDeletion,
          promptText: '"사과"에서 "과"를 빼면?',
          promptAudioUrl: '',
          optionsText: ['사', '과', '사과'],
          optionsImageUrl: [], // 그림 없이 글자만
          soundLabels: ['사과-과'], // 단어-제거할음절
          soundUrls: [],
          correctAnswer: 0, // 사
        ),
        // Q11: S 1.4.8 - 음절 뒤집기 (음성 녹음)
        const QuestionModel(
          id: 'q11_syllable_reverse',
          type: QuestionType.syllableReverse,
          promptText: '"나비"를 거꾸로 하면?',
          promptAudioUrl: '',
          optionsText: [], // 녹음이므로 선택지 없음
          optionsImageUrl: [],
          soundLabels: ['나비'], // 뒤집을 단어, 정답: 비나
          soundUrls: [],
          correctAnswer: 0, // 녹음 문제는 정답이 음성 파일이므로 임의값
        ),
        // Q12: S 1.4.9 - 초성 분리 (음성 녹음)
        const QuestionModel(
          id: 'q12_phoneme_initial',
          type: QuestionType.phonemeInitial,
          promptText: '"강아지"의 첫 소리는?',
          promptAudioUrl: '',
          optionsText: [], // 녹음이므로 선택지 없음
          optionsImageUrl: [],
          soundLabels: ['강아지'], // 단어, 정답: ㄱ
          soundUrls: [],
          correctAnswer: 0,
        ),
        // Q13: S 1.4.10 - 음소 합성/분할
        const QuestionModel(
          id: 'q13_phoneme_blending',
          type: QuestionType.phonemeBlending,
          promptText: '천천히 읽어 줄게. 소리를 합치면 뭐야?',
          promptAudioUrl: '',
          optionsText: ['가위', '나무', '다리'],
          optionsImageUrl: [], // 글자만 표시
          soundLabels: ['ㄱ-ㅏ'], // 음소 분리 (ㄱ + ㅏ = 가)
          soundUrls: [],
          correctAnswer: 0, // 가위 (가로 시작)
        ),
        // Q14: S 1.4.11 - 음소 대치/추가
        const QuestionModel(
          id: 'q14_phoneme_substitution',
          type: QuestionType.phonemeSubstitution,
          promptText: '"공"에서 "ㄱ"을 "ㅂ"으로 바꾸면?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['공,ㄱ,ㅂ'], // 원래 단어, 대치할 음소, 대치될 음소
          soundUrls: [],
          correctAnswer: 0, // 정답: 봉
        ),
        // Q15: S 1.4.12 - 비단어 따라말하기
        const QuestionModel(
          id: 'q15_nonword_repeat',
          type: QuestionType.nonwordRepeat,
          promptText: '잘 듣고 똑같이 따라 말해줘',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['두파리'], // 비단어
          soundUrls: [],
          correctAnswer: 0,
        ),
        // Q16: S 1.4.13 - 숫자 폭 기억
        const QuestionModel(
          id: 'q16_memory_span',
          type: QuestionType.memorySpan,
          promptText: '잘 듣고 순서대로 따라 말해줘',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['3-7-2'], // 숫자 시퀀스
          soundUrls: [],
          correctAnswer: 0,
        ),
        
        // === WP 1.5: 감각 처리 (Sensory Processing) ===
        // === 청각 및 순차 처리 능력 ===
        
        // Q17: S 1.5.1 - 소리 순서 기억하기 1 (3개 악기)
        const QuestionModel(
          id: 'q17_sound_seq',
          type: QuestionType.soundSequence,
          promptText: '악기 소리를 잘 들어봐. 순서대로 눌러봐!',
          promptAudioUrl: '',
          optionsText: ['북', '피아노', '벨', '기타'],
          optionsImageUrl: [],
          soundLabels: ['0,1,2'], // 북-피아노-벨
          soundUrls: [],
          correctAnswer: '0,1,2',
        ),
        
        // Q18: S 1.5.1 - 소리 순서 기억하기 2 (4개 악기)
        const QuestionModel(
          id: 'q18_sound_seq',
          type: QuestionType.soundSequence,
          promptText: '이번엔 4개야! 악기 소리 순서를 잘 기억해봐.',
          promptAudioUrl: '',
          optionsText: ['북', '피아노', '벨', '기타'],
          optionsImageUrl: [],
          soundLabels: ['2,0,3,1'], // 벨-북-기타-피아노
          soundUrls: [],
          correctAnswer: '2,0,3,1',
        ),
        
        // Q19: S 1.5.2 - 동물 소리 순서 1 (3개)
        const QuestionModel(
          id: 'q19_animal_seq',
          type: QuestionType.animalSoundSequence,
          promptText: '동물 소리를 잘 들어봐. 순서대로 눌러봐!',
          promptAudioUrl: '',
          optionsText: ['강아지', '고양이', '돼지', '소'],
          optionsImageUrl: [],
          soundLabels: ['0,1,2'], // 멍멍-야옹-꿀꿀
          soundUrls: [],
          correctAnswer: '0,1,2',
        ),
        
        // Q20: S 1.5.2 - 동물 소리 순서 2 (4개)
        const QuestionModel(
          id: 'q20_animal_seq',
          type: QuestionType.animalSoundSequence,
          promptText: '이번엔 4개야! 동물 소리 순서를 기억해봐.',
          promptAudioUrl: '',
          optionsText: ['강아지', '고양이', '돼지', '소'],
          optionsImageUrl: [],
          soundLabels: ['3,1,0,2'], // 음메-야옹-멍멍-꿀꿀
          soundUrls: [],
          correctAnswer: '3,1,0,2',
        ),
        
        // Q21: S 1.5.2 - 동물 소리 순서 3 (5개 - 난이도 상)
        const QuestionModel(
          id: 'q21_animal_seq',
          type: QuestionType.animalSoundSequence,
          promptText: '마지막이야! 5개 동물 소리를 잘 기억해봐!',
          promptAudioUrl: '',
          optionsText: ['강아지', '고양이', '돼지', '소', '오리'],
          optionsImageUrl: [],
          soundLabels: ['4,2,1,3,0'], // 꽥꽥-꿀꿀-야옹-음메-멍멍
          soundUrls: [],
          correctAnswer: '4,2,1,3,0',
        ),
        
        // Q22: S 1.5.3 - 위치 순서 1 (3칸)
        const QuestionModel(
          id: 'q22_position_seq',
          type: QuestionType.positionSequence,
          promptText: '불빛이 깜빡이는 순서를 잘 봐! 똑같이 눌러봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['0,1,2'], // 위치 0-1-2
          soundUrls: [],
          correctAnswer: '0,1,2',
          timeLimitSeconds: 15,
        ),
        
        // Q23: S 1.5.3 - 위치 순서 2 (4칸)
        const QuestionModel(
          id: 'q23_position_seq',
          type: QuestionType.positionSequence,
          promptText: '이번엔 4개야! 불빛 순서를 잘 기억해봐.',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['2,0,3,1'],
          soundUrls: [],
          correctAnswer: '2,0,3,1',
          timeLimitSeconds: 15,
        ),
        
        // Q24: S 1.5.3 - 위치 순서 3 (5칸 - 난이도 상)
        const QuestionModel(
          id: 'q24_position_seq',
          type: QuestionType.positionSequence,
          promptText: '마지막! 5개 불빛 순서를 기억해봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['4,1,3,0,2'],
          soundUrls: [],
          correctAnswer: '4,1,3,0,2',
          timeLimitSeconds: 20,
        ),
        
        // === 시각적 처리 능력 ===
        
        // Q25: S 1.5.4 - 다른 그림 찾기 1
        const QuestionModel(
          id: 'q25_find_diff',
          type: QuestionType.findDifferent,
          promptText: '다른 그림을 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['사과1', '사과2', '사과3', '사과4'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 2, // 3번째
        ),
        
        // Q26: S 1.5.4 - 다른 그림 찾기 2
        const QuestionModel(
          id: 'q26_find_diff',
          type: QuestionType.findDifferent,
          promptText: '다른 그림을 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['원1', '원2', '원3', '원4', '원5'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 2,
        ),
        
        // Q27: S 1.5.5 - 같은 형태 찾기 1
        const QuestionModel(
          id: 'q27_same_shape',
          type: QuestionType.findSameShape,
          promptText: '위에 있는 것과 같은 모양을 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['별', '원', '네모', '세모'],
          optionsImageUrl: [],
          soundLabels: ['star'], // 목표 도형
          soundUrls: [],
          correctAnswer: 0,
        ),
        
        // Q28: S 1.5.5 - 같은 형태 찾기 2
        const QuestionModel(
          id: 'q28_same_shape',
          type: QuestionType.findSameShape,
          promptText: '위에 있는 것과 같은 모양을 찾아봐! (돌아가 있을 수도 있어)',
          promptAudioUrl: '',
          optionsText: ['세모', '원', '별', '네모'],
          optionsImageUrl: [],
          soundLabels: ['triangle'],
          soundUrls: [],
          correctAnswer: 0,
        ),
        
        // Q29: S 1.5.6 - 방향이 다른 글자 1 (b와 d)
        const QuestionModel(
          id: 'q29_direction',
          type: QuestionType.findDifferentDirection,
          promptText: '다른 글자를 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['b', 'b', 'd', 'b'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 2,
        ),
        
        // Q30: S 1.5.6 - 방향이 다른 글자 2 (ㄴ과 ㄱ)
        const QuestionModel(
          id: 'q30_direction',
          type: QuestionType.findDifferentDirection,
          promptText: '다른 글자를 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['ㄴ', 'ㄴ', 'ㄴ', 'ㄱ'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 3,
        ),
        
        // Q31: S 1.5.6 - 방향이 다른 글자 3 (p와 q)
        const QuestionModel(
          id: 'q31_direction',
          type: QuestionType.findDifferentDirection,
          promptText: '다른 글자를 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['p', 'q', 'p', 'p'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 1,
        ),
        
        // Q32: S 1.5.7 - 숨은 그림 찾기 1
        const QuestionModel(
          id: 'q32_hidden',
          type: QuestionType.hiddenPicture,
          promptText: '그림 속에 숨은 별을 찾아봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['star', '100,200,50'],
          soundUrls: [],
          correctAnswer: '100,200',
          timeLimitSeconds: 30,
        ),
        
        // Q33: S 1.5.7 - 숨은 그림 찾기 2
        const QuestionModel(
          id: 'q33_hidden',
          type: QuestionType.hiddenPicture,
          promptText: '그림 속에 숨은 동그라미를 찾아봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['circle', '250,150,50'],
          soundUrls: [],
          correctAnswer: '250,150',
          timeLimitSeconds: 30,
        ),
        
        // Q34: S 1.5.7 - 숨은 그림 찾기 3
        const QuestionModel(
          id: 'q34_hidden',
          type: QuestionType.hiddenPicture,
          promptText: '그림 속에 숨은 세모를 찾아봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['triangle', '180,220,50'],
          soundUrls: [],
          correctAnswer: '180,220',
          timeLimitSeconds: 30,
        ),
        
        // === WP 1.6: 인지 제어 (Executive Functions) ===
        // === 작업 기억 능력 (Working Memory) ===
        
        // Q35: S 1.6.1 - 숫자 따라 말하기 순방향 (3자리)
        const QuestionModel(
          id: 'q35_digit_forward',
          type: QuestionType.digitSpanForward,
          promptText: '숫자를 잘 들어봐. 그대로 따라 말해줘!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['2-5-9'], // 3자리 숫자
          soundUrls: [],
          correctAnswer: 0, // 녹음 문제 (수동 채점)
        ),
        
        // Q36: S 1.6.2 - 숫자 거꾸로 말하기 역방향 (2자리)
        const QuestionModel(
          id: 'q36_digit_backward',
          type: QuestionType.digitSpanBackward,
          promptText: '숫자를 잘 들어봐. 이번엔 거꾸로 말해줘!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['3-7'], // 2자리, 정답: 7-3
          soundUrls: [],
          correctAnswer: 0, // 녹음 문제 (수동 채점)
        ),
        
        // Q37: S 1.6.3 - 단어 따라 말하기 (3개)
        const QuestionModel(
          id: 'q37_word_forward',
          type: QuestionType.wordSpanForward,
          promptText: '단어를 잘 들어봐. 그대로 따라 말해줘!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['사과-책상-구름'], // 3단어
          soundUrls: [],
          correctAnswer: 0, // 녹음 문제
        ),
        
        // Q38: S 1.6.4 - 단어 거꾸로 말하기 (2개)
        const QuestionModel(
          id: 'q38_word_backward',
          type: QuestionType.wordSpanBackward,
          promptText: '단어를 잘 들어봐. 이번엔 거꾸로 말해줘!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['나무-바다'], // 2단어, 정답: 바다-나무
          soundUrls: [],
          correctAnswer: 0, // 녹음 문제
        ),
        
        // === 주의 집중 능력 (Attention) ===
        
        // Q39: S 1.6.5 - Go/No-Go 기본 (시각)
        const QuestionModel(
          id: 'q39_gonogo',
          type: QuestionType.goNoGo,
          promptText: '토끼가 나오면 빠르게 터치! 늑대는 터치하지 마!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['rabbit,wolf,10'], // [Go자극, NoGo자극, 시행횟수]
          soundUrls: [],
          correctAnswer: 0, // 자동 채점 (정반응률, 반응시간)
          timeLimitSeconds: 60,
        ),
        
        // Q40: S 1.6.6 - Go/No-Go 청각 버전
        const QuestionModel(
          id: 'q40_gonogo_audio',
          type: QuestionType.goNoGoAuditory,
          promptText: '딩 소리가 나오면 터치! 뿡 소리는 터치하지 마!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['ding,buzz,10'], // [Go소리, NoGo소리, 시행횟수]
          soundUrls: [],
          correctAnswer: 0,
          timeLimitSeconds: 60,
        ),
        
        // Q41: S 1.6.7 - 지속적 주의력
        const QuestionModel(
          id: 'q41_continuous',
          type: QuestionType.continuousPerformance,
          promptText: '빨간 별이 나올 때만 터치해봐! 30초간 집중!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['red_star,30'], // [목표자극, 지속시간(초)]
          soundUrls: [],
          correctAnswer: 0,
          timeLimitSeconds: 35, // 30초 + 여유시간
        ),
      ],
    );
  }

  /// S 1.4.1: 음운 인식 검사 - 청각적 주의 및 운율 + S 1.5: 감각 처리
  AssessmentModel _getPhonologicalAssessment() {
    return AssessmentModel(
      id: 'assessment_phonological',
      title: '소리 듣기 검사',
      description: '소리를 잘 들어보고 맞춰봐요!',
      totalQuestions: 44, // WP 1.4 (26문항) + WP 1.5 (18문항)
      questions: [
        // S 1.4.1 - 소리 식별 1: 같은 소리
        const QuestionModel(
          id: 'ph_q1',
          type: QuestionType.soundIdentification,
          promptText: '두 소리를 들어봐. 같은 소리야? 다른 소리야?',
          promptAudioUrl: '',
          optionsText: ['같아요', '달라요'],
          soundLabels: ['강아지 소리', '강아지 소리'],
          soundUrls: [],
          correctAnswer: 0, // 같아요
        ),
        // S 1.4.1 - 소리 식별 2: 다른 소리
        const QuestionModel(
          id: 'ph_q2',
          type: QuestionType.soundIdentification,
          promptText: '두 소리를 들어봐. 같은 소리야? 다른 소리야?',
          promptAudioUrl: '',
          optionsText: ['같아요', '달라요'],
          soundLabels: ['북소리', '피아노 소리'],
          soundUrls: [],
          correctAnswer: 1, // 달라요
        ),
        // S 1.4.1 - 소리 식별 3: 같은 소리
        const QuestionModel(
          id: 'ph_q3',
          type: QuestionType.soundIdentification,
          promptText: '두 소리를 들어봐. 같은 소리야? 다른 소리야?',
          promptAudioUrl: '',
          optionsText: ['같아요', '달라요'],
          soundLabels: ['뻐꾸기 소리', '뻐꾸기 소리'],
          soundUrls: [],
          correctAnswer: 0, // 같아요
        ),
        // S 1.4.2 - 리듬 따라하기 1: 느린 리듬
        const QuestionModel(
          id: 'ph_q4',
          type: QuestionType.rhythmTap,
          promptText: '리듬을 잘 보고, 똑같이 눌러봐!',
          promptAudioUrl: '',
          soundLabels: ['600,600,600'], // 똑 - 똑 - 똑 (느린 리듬)
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.2 - 리듬 따라하기 2: 빠른 리듬
        const QuestionModel(
          id: 'ph_q5',
          type: QuestionType.rhythmTap,
          promptText: '이번엔 조금 빠르게! 똑같이 눌러봐!',
          promptAudioUrl: '',
          soundLabels: ['400,400,400,400'], // 똑똑똑똑 (빠른 리듬, 4번)
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.3 - 억양 식별 1: 의문문
        const QuestionModel(
          id: 'ph_q6',
          type: QuestionType.intonation,
          promptText: '이 문장을 읽어봐. 어떤 느낌이야?',
          promptAudioUrl: '',
          optionsText: ['그냥 말하는 거', '물어보는 거'],
          soundLabels: ['밥 먹었어?', 'question'], // [문장, 억양유형]
          soundUrls: [],
          correctAnswer: 1, // 물어보는 거
        ),
        // S 1.4.3 - 억양 식별 2: 평서문
        const QuestionModel(
          id: 'ph_q7',
          type: QuestionType.intonation,
          promptText: '이 문장을 읽어봐. 어떤 느낌이야?',
          promptAudioUrl: '',
          optionsText: ['그냥 말하는 거', '물어보는 거'],
          soundLabels: ['학교 갔어.', 'statement'], // [문장, 억양유형]
          soundUrls: [],
          correctAnswer: 0, // 그냥 말하는 거
        ),
        // S 1.4.4 - 단어 경계 1: 2단어
        const QuestionModel(
          id: 'ph_q8',
          type: QuestionType.wordBoundary,
          promptText: '이 문장을 읽어봐. 몇 단어야?',
          promptAudioUrl: '',
          optionsText: ['1', '2', '3', '4', '5'],
          soundLabels: ['엄마 왔어'], // 2단어
          soundUrls: [],
          correctAnswer: 2,
        ),
        // S 1.4.4 - 단어 경계 2: 3단어
        const QuestionModel(
          id: 'ph_q9',
          type: QuestionType.wordBoundary,
          promptText: '이 문장을 읽어봐. 몇 단어야?',
          promptAudioUrl: '',
          optionsText: ['1', '2', '3', '4', '5'],
          soundLabels: ['고양이가 물을 마셔'], // 3단어 (고양이가 / 물을 / 마셔)
          soundUrls: [],
          correctAnswer: 3,
        ),
        // S 1.4.5 - 각운/두운 1: 첫소리 같은 것 찾기 (ㅅ)
        const QuestionModel(
          id: 'ph_q10',
          type: QuestionType.rhyme,
          promptText: '이 단어를 읽어봐: "사과"\n이제 "사과"와 같은 소리로 시작하는 거 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['사탕', '바나나', '포도'],
          optionsImageUrl: [
            'assets/images/apple.svg', // 사탕 (임시)
            'assets/images/banana.svg',
            'assets/images/grape.svg',
          ],
          soundLabels: ['사과'], // 기준 단어
          soundUrls: [],
          correctAnswer: 0, // 사탕 (ㅅ으로 시작)
        ),
        // S 1.4.5 - 각운/두운 2: 첫소리 같은 것 찾기 (ㄱ)
        const QuestionModel(
          id: 'ph_q11',
          type: QuestionType.rhyme,
          promptText: '이 단어를 읽어봐: "고양이"\n이제 "고양이"와 같은 소리로 시작하는 거 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['강아지', '토끼', '오리'],
          optionsImageUrl: [
            'assets/images/apple.svg', // 강아지 (임시)
            'assets/images/banana.svg', // 토끼 (임시)
            'assets/images/orange.svg', // 오리 (임시)
          ],
          soundLabels: ['고양이'], // 기준 단어
          soundUrls: [],
          correctAnswer: 0, // 강아지 (ㄱ으로 시작)
        ),
        // S 1.4.6 - 음절 합성 1: 2음절
        const QuestionModel(
          id: 'ph_q12',
          type: QuestionType.syllableBlending,
          promptText: '천천히 읽어 줄게. 소리를 합치면 뭐야?',
          promptAudioUrl: '',
          optionsText: ['나비', '나무', '비행기'],
          optionsImageUrl: [], // 그림 없이 글자만
          soundLabels: ['나-비'], // 음절 분리
          soundUrls: [],
          correctAnswer: 0, // 나비
        ),
        // S 1.4.6 - 음절 합성 2: 3음절
        const QuestionModel(
          id: 'ph_q13',
          type: QuestionType.syllableBlending,
          promptText: '천천히 읽어 줄게. 소리를 합치면 뭐야?',
          promptAudioUrl: '',
          optionsText: ['바나나', '사과', '포도'],
          optionsImageUrl: [], // 그림 없이 글자만
          soundLabels: ['바-나-나'], // 음절 분리 (3음절)
          soundUrls: [],
          correctAnswer: 0, // 바나나
        ),
        // S 1.4.7 - 음절 탈락 1: 2음절에서 1음절 제거
        const QuestionModel(
          id: 'ph_q14',
          type: QuestionType.syllableDeletion,
          promptText: '"사과"에서 "과"를 빼면?',
          promptAudioUrl: '',
          optionsText: ['사', '과', '사과'],
          optionsImageUrl: [],
          soundLabels: ['사과-과'], // 단어-제거할음절
          soundUrls: [],
          correctAnswer: 0, // 사
        ),
        // S 1.4.7 - 음절 탈락 2: 3음절에서 1음절 제거
        const QuestionModel(
          id: 'ph_q15',
          type: QuestionType.syllableDeletion,
          promptText: '"바나나"에서 "나"를 빼면?',
          promptAudioUrl: '',
          optionsText: ['바', '나', '바나'],
          optionsImageUrl: [],
          soundLabels: ['바나나-나'], // 단어-제거할음절 (뒤의 "나" 제거)
          soundUrls: [],
          correctAnswer: 2, // 바나
        ),
        // S 1.4.8 - 음절 뒤집기 1: 2음절 뒤집기
        const QuestionModel(
          id: 'ph_q16',
          type: QuestionType.syllableReverse,
          promptText: '"나비"를 거꾸로 하면?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['나비'], // 정답: 비나
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.8 - 음절 뒤집기 2: 2음절 뒤집기
        const QuestionModel(
          id: 'ph_q17',
          type: QuestionType.syllableReverse,
          promptText: '"고기"를 거꾸로 하면?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['고기'], // 정답: 기고
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.9 - 초성 분리 1
        const QuestionModel(
          id: 'ph_q18',
          type: QuestionType.phonemeInitial,
          promptText: '"강아지"의 첫 소리는?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['강아지'], // 정답: ㄱ
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.9 - 초성 분리 2
        const QuestionModel(
          id: 'ph_q19',
          type: QuestionType.phonemeInitial,
          promptText: '"사과"의 첫 소리는?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['사과'], // 정답: ㅅ
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.10 - 음소 합성 1: ㄱ-ㅏ
        const QuestionModel(
          id: 'ph_q20',
          type: QuestionType.phonemeBlending,
          promptText: '천천히 읽어 줄게. 소리를 합치면 뭐야?',
          promptAudioUrl: '',
          optionsText: ['가위', '나무', '다리'],
          optionsImageUrl: [],
          soundLabels: ['ㄱ-ㅏ'], // 음소 분리 (가)
          soundUrls: [],
          correctAnswer: 0, // 가위
        ),
        // S 1.4.10 - 음소 합성 2: ㄴ-ㅏ
        const QuestionModel(
          id: 'ph_q21',
          type: QuestionType.phonemeBlending,
          promptText: '천천히 읽어 줄게. 소리를 합치면 뭐야?',
          promptAudioUrl: '',
          optionsText: ['나무', '다리', '가위'],
          optionsImageUrl: [],
          soundLabels: ['ㄴ-ㅏ'], // 음소 분리 (나)
          soundUrls: [],
          correctAnswer: 0, // 나무
        ),
        // S 1.4.11 - 음소 대치 1: 공 → 봉
        const QuestionModel(
          id: 'ph_q22',
          type: QuestionType.phonemeSubstitution,
          promptText: '"공"에서 "ㄱ"을 "ㅂ"으로 바꾸면?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['공,ㄱ,ㅂ'],
          soundUrls: [],
          correctAnswer: 0, // 봉
        ),
        // S 1.4.11 - 음소 대치 2: 달 → 말
        const QuestionModel(
          id: 'ph_q23',
          type: QuestionType.phonemeSubstitution,
          promptText: '"달"에서 "ㄷ"을 "ㅁ"으로 바꾸면?',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['달,ㄷ,ㅁ'],
          soundUrls: [],
          correctAnswer: 0, // 말
        ),
        // S 1.4.12 - 비단어 1
        const QuestionModel(
          id: 'ph_q24',
          type: QuestionType.nonwordRepeat,
          promptText: '잘 듣고 똑같이 따라 말해줘',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['두파리'],
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.12 - 비단어 2
        const QuestionModel(
          id: 'ph_q25',
          type: QuestionType.nonwordRepeat,
          promptText: '잘 듣고 똑같이 따라 말해줘',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['가토미'],
          soundUrls: [],
          correctAnswer: 0,
        ),
        // S 1.4.13 - 숫자 폭 기억
        const QuestionModel(
          id: 'ph_q26',
          type: QuestionType.memorySpan,
          promptText: '잘 듣고 순서대로 따라 말해줘',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['3-7-2'],
          soundUrls: [],
          correctAnswer: 0,
        ),
      ],
    );
  }

  /// WP 1.5: 감각 처리 (Sensory Processing) 검사
  AssessmentModel _getSensoryAssessment() {
    return AssessmentModel(
      id: 'assessment_sensory',
      title: '감각 처리 검사',
      description: '소리와 그림을 잘 기억하고 찾아봐요!',
      totalQuestions: 18,
      questions: [
        // === 청각 및 순차 처리 능력 ===
        
        // S 1.5.1 - 소리 순서 기억하기 1: 3개 악기
        const QuestionModel(
          id: 'sen_q1',
          type: QuestionType.soundSequence,
          promptText: '악기 소리를 잘 들어봐. 순서대로 눌러봐!',
          promptAudioUrl: '',
          optionsText: ['북', '피아노', '벨', '기타'],
          optionsImageUrl: [
            'assets/images/instruments/drum.svg',
            'assets/images/instruments/piano.svg',
            'assets/images/instruments/bell.svg',
            'assets/images/instruments/guitar.svg',
          ],
          soundLabels: ['0,1,2'], // 북-피아노-벨 순서 (인덱스)
          soundUrls: [],
          correctAnswer: '0,1,2', // 정답 순서
        ),
        // S 1.5.1 - 소리 순서 기억하기 2: 4개 악기
        const QuestionModel(
          id: 'sen_q2',
          type: QuestionType.soundSequence,
          promptText: '이번엔 4개야! 악기 소리 순서를 잘 기억해봐.',
          promptAudioUrl: '',
          optionsText: ['북', '피아노', '벨', '기타'],
          optionsImageUrl: [
            'assets/images/instruments/drum.svg',
            'assets/images/instruments/piano.svg',
            'assets/images/instruments/bell.svg',
            'assets/images/instruments/guitar.svg',
          ],
          soundLabels: ['2,0,3,1'], // 벨-북-기타-피아노
          soundUrls: [],
          correctAnswer: '2,0,3,1',
        ),
        
        // S 1.5.2 - 동물 소리 순서 맞추기 1: 3개
        const QuestionModel(
          id: 'sen_q3',
          type: QuestionType.animalSoundSequence,
          promptText: '동물 소리를 잘 들어봐. 순서대로 눌러봐!',
          promptAudioUrl: '',
          optionsText: ['강아지', '고양이', '돼지', '소'],
          optionsImageUrl: [
            'assets/images/animals/dog.svg',
            'assets/images/animals/cat.svg',
            'assets/images/animals/pig.svg',
            'assets/images/animals/cow.svg',
          ],
          soundLabels: ['0,1,2'], // 멍멍-야옹-꿀꿀
          soundUrls: [],
          correctAnswer: '0,1,2',
        ),
        // S 1.5.2 - 동물 소리 순서 맞추기 2: 4개
        const QuestionModel(
          id: 'sen_q4',
          type: QuestionType.animalSoundSequence,
          promptText: '이번엔 4개야! 동물 소리 순서를 기억해봐.',
          promptAudioUrl: '',
          optionsText: ['강아지', '고양이', '돼지', '소'],
          optionsImageUrl: [
            'assets/images/animals/dog.svg',
            'assets/images/animals/cat.svg',
            'assets/images/animals/pig.svg',
            'assets/images/animals/cow.svg',
          ],
          soundLabels: ['3,1,0,2'], // 음메-야옹-멍멍-꿀꿀
          soundUrls: [],
          correctAnswer: '3,1,0,2',
        ),
        // S 1.5.2 - 동물 소리 순서 맞추기 3: 5개 (난이도 상)
        const QuestionModel(
          id: 'sen_q5',
          type: QuestionType.animalSoundSequence,
          promptText: '마지막이야! 5개 동물 소리를 잘 기억해봐!',
          promptAudioUrl: '',
          optionsText: ['강아지', '고양이', '돼지', '소', '오리'],
          optionsImageUrl: [
            'assets/images/animals/dog.svg',
            'assets/images/animals/cat.svg',
            'assets/images/animals/pig.svg',
            'assets/images/animals/cow.svg',
            'assets/images/animals/duck.svg',
          ],
          soundLabels: ['4,2,1,3,0'], // 꽥꽥-꿀꿀-야옹-음메-멍멍
          soundUrls: [],
          correctAnswer: '4,2,1,3,0',
        ),
        
        // S 1.5.3 - 위치 순서 기억하기 1: 3칸
        const QuestionModel(
          id: 'sen_q6',
          type: QuestionType.positionSequence,
          promptText: '불빛이 깜빡이는 순서를 잘 봐! 똑같이 눌러봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['0,1,2'], // 위치 0-1-2 순서로 깜빡임 (3x3 그리드 기준)
          soundUrls: [],
          correctAnswer: '0,1,2',
          timeLimitSeconds: 15,
        ),
        // S 1.5.3 - 위치 순서 기억하기 2: 4칸
        const QuestionModel(
          id: 'sen_q7',
          type: QuestionType.positionSequence,
          promptText: '이번엔 4개야! 불빛 순서를 잘 기억해봐.',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['2,0,3,1'], // 위치 순서
          soundUrls: [],
          correctAnswer: '2,0,3,1',
          timeLimitSeconds: 15,
        ),
        // S 1.5.3 - 위치 순서 기억하기 3: 5칸 (난이도 상)
        const QuestionModel(
          id: 'sen_q8',
          type: QuestionType.positionSequence,
          promptText: '마지막! 5개 불빛 순서를 기억해봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: [],
          soundLabels: ['4,1,3,0,2'], // 위치 순서
          soundUrls: [],
          correctAnswer: '4,1,3,0,2',
          timeLimitSeconds: 20,
        ),
        
        // === 시각적 처리 능력 ===
        
        // S 1.5.4 - 다른 그림 찾기 1: 색이 다른 사과
        const QuestionModel(
          id: 'sen_q9',
          type: QuestionType.findDifferent,
          promptText: '다른 그림을 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['사과1', '사과2', '사과3', '사과4'],
          optionsImageUrl: [
            'assets/images/apple.svg', // 빨간 사과
            'assets/images/apple.svg', // 빨간 사과
            'assets/images/apple_green.svg', // 초록 사과 (다름)
            'assets/images/apple.svg', // 빨간 사과
          ],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 2, // 3번째 (초록 사과)
        ),
        // S 1.5.4 - 다른 그림 찾기 2: 크기가 다른 원
        const QuestionModel(
          id: 'sen_q10',
          type: QuestionType.findDifferent,
          promptText: '다른 그림을 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['원1', '원2', '원3', '원4', '원5'],
          optionsImageUrl: [
            'assets/images/shapes/circle_medium.svg',
            'assets/images/shapes/circle_medium.svg',
            'assets/images/shapes/circle_small.svg', // 작은 원 (다름)
            'assets/images/shapes/circle_medium.svg',
            'assets/images/shapes/circle_medium.svg',
          ],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 2,
        ),
        
        // S 1.5.5 - 같은 형태 찾기 1: 별 찾기
        const QuestionModel(
          id: 'sen_q11',
          type: QuestionType.findSameShape,
          promptText: '위에 있는 것과 같은 모양을 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['별', '원', '네모', '세모'],
          optionsImageUrl: [
            'assets/images/shapes/star.svg',
            'assets/images/shapes/circle.svg',
            'assets/images/shapes/square.svg',
            'assets/images/shapes/triangle.svg',
          ],
          soundLabels: ['star'], // 목표 도형: 별
          soundUrls: [],
          correctAnswer: 0, // 별
        ),
        // S 1.5.5 - 같은 형태 찾기 2: 회전된 세모 찾기
        const QuestionModel(
          id: 'sen_q12',
          type: QuestionType.findSameShape,
          promptText: '위에 있는 것과 같은 모양을 찾아봐! (돌아가 있을 수도 있어)',
          promptAudioUrl: '',
          optionsText: ['세모', '원', '별', '네모'],
          optionsImageUrl: [
            'assets/images/shapes/triangle_rotated.svg', // 회전된 세모
            'assets/images/shapes/circle.svg',
            'assets/images/shapes/star.svg',
            'assets/images/shapes/square.svg',
          ],
          soundLabels: ['triangle'], // 목표 도형: 세모
          soundUrls: [],
          correctAnswer: 0, // 회전된 세모
        ),
        
        // S 1.5.6 - 방향이 다른 글자 찾기 1: b와 d 구별
        const QuestionModel(
          id: 'sen_q13',
          type: QuestionType.findDifferentDirection,
          promptText: '다른 글자를 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['b', 'b', 'd', 'b'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 2, // 'd'
        ),
        // S 1.5.6 - 방향이 다른 글자 찾기 2: ㄴ과 ㄱ 구별
        const QuestionModel(
          id: 'sen_q14',
          type: QuestionType.findDifferentDirection,
          promptText: '다른 글자를 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['ㄴ', 'ㄴ', 'ㄴ', 'ㄱ'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 3, // 'ㄱ'
        ),
        // S 1.5.6 - 방향이 다른 글자 찾기 3: p와 q 구별
        const QuestionModel(
          id: 'sen_q15',
          type: QuestionType.findDifferentDirection,
          promptText: '다른 글자를 찾아봐!',
          promptAudioUrl: '',
          optionsText: ['p', 'q', 'p', 'p'],
          optionsImageUrl: [],
          soundLabels: [],
          soundUrls: [],
          correctAnswer: 1, // 'q'
        ),
        
        // S 1.5.7 - 숨은 그림 찾기 1: 별 찾기
        const QuestionModel(
          id: 'sen_q16',
          type: QuestionType.hiddenPicture,
          promptText: '그림 속에 숨은 별을 찾아봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: ['assets/images/hidden/scene1.svg'], // 복잡한 배경 이미지
          soundLabels: ['star', '100,200,50'], // [찾을 도형, 정답 영역: x,y,radius]
          soundUrls: [],
          correctAnswer: '100,200', // 별의 위치 (x, y)
          timeLimitSeconds: 30,
        ),
        // S 1.5.7 - 숨은 그림 찾기 2: 원 찾기
        const QuestionModel(
          id: 'sen_q17',
          type: QuestionType.hiddenPicture,
          promptText: '그림 속에 숨은 동그라미를 찾아봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: ['assets/images/hidden/scene2.svg'],
          soundLabels: ['circle', '250,150,50'], // [찾을 도형, 정답 영역]
          soundUrls: [],
          correctAnswer: '250,150',
          timeLimitSeconds: 30,
        ),
        // S 1.5.7 - 숨은 그림 찾기 3: 세모 찾기
        const QuestionModel(
          id: 'sen_q18',
          type: QuestionType.hiddenPicture,
          promptText: '그림 속에 숨은 세모를 찾아봐!',
          promptAudioUrl: '',
          optionsText: [],
          optionsImageUrl: ['assets/images/hidden/scene3.svg'],
          soundLabels: ['triangle', '180,220,50'],
          soundUrls: [],
          correctAnswer: '180,220',
          timeLimitSeconds: 30,
        ),
      ],
    );
  }
}
