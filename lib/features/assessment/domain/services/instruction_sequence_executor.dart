import 'package:audioplayers/audioplayers.dart';
import '../../../../core/services/tts_service.dart';
import '../../data/models/story_assessment_model.dart';
import '../../data/services/instruction_sequence_loader_service.dart';

/// 안내 시퀀스 실행 엔진
/// JSON의 steps를 순서대로 실행
class InstructionSequenceExecutor {
  final TtsService _ttsService;
  final AudioPlayer _audioPlayer;
  final Function(String?) _playQuestionAudio;

  InstructionSequenceExecutor({
    required TtsService ttsService,
    required AudioPlayer audioPlayer,
    required Function(String?) playQuestionAudio,
  })  : _ttsService = ttsService,
        _audioPlayer = audioPlayer,
        _playQuestionAudio = playQuestionAudio;

  /// 시퀀스 실행
  Future<void> executeSequence(
    QuestionInstructionSequence sequence,
    StoryQuestion storyQuestion,
  ) async {
    // TTS 초기화
    print('🔧 TTS 초기화 시작');
    await _ttsService.initialize();
    print('✅ TTS 초기화 완료');

    // 각 step을 순서대로 실행
    print('📋 총 ${sequence.steps.length}개 step 실행 시작');
    for (int i = 0; i < sequence.steps.length; i++) {
      final step = sequence.steps[i];
      print('▶️ Step ${i + 1}/${sequence.steps.length} 실행: ${step.action}');
      await _executeStep(step, storyQuestion);
      print('✅ Step ${i + 1} 완료');
    }
    print('✅ 모든 step 실행 완료');
  }

  /// 단일 step 실행
  Future<void> _executeStep(
    InstructionStep step,
    StoryQuestion storyQuestion,
  ) async {
    switch (step.action) {
      case 'tts':
        await _executeTts(step);
        break;

      case 'delay':
        await _executeDelay(step);
        break;

      case 'audio':
        await _executeAudio(step, storyQuestion);
        break;

      case 'audio_sequence':
        await _executeAudioSequence(step, storyQuestion);
        break;

      case 'audio_or_tts':
        await _executeAudioOrTts(step, storyQuestion);
        break;

      default:
        print('⚠️ 알 수 없는 action: ${step.action}');
    }
  }

  /// TTS 실행
  Future<void> _executeTts(InstructionStep step) async {
    print('🗣️ [TTS] _executeTts 호출됨');
    print('  - step.params: ${step.params}');
    
    final text = step.params['text'] as String?;
    if (text == null || text.isEmpty) {
      print('❌ [TTS 중단] TTS text가 없습니다');
      print('  - step.params: ${step.params}');
      return;
    }
    
    print('🗣️ [TTS] 텍스트 확인 완료: "$text" (길이: ${text.length}자)');
    
    try {
      print('🗣️ [TTS] TTS 서비스 speak() 호출 시작');
      final startTime = DateTime.now();
      await _ttsService.speak(text);
      final actualDuration = DateTime.now().difference(startTime).inMilliseconds;
      print('✅ [TTS] TTS 서비스 speak() 완료 (소요 시간: ${actualDuration}ms)');
    } catch (e, stackTrace) {
      print('❌ [TTS 실패] TTS 실행 실패: "$text"');
      print('  - 에러 타입: ${e.runtimeType}');
      print('  - 에러 메시지: $e');
      print('  - 스택 트레이스: $stackTrace');
      // TTS 실패해도 계속 진행
    }
  }

  /// 딜레이 실행
  Future<void> _executeDelay(InstructionStep step) async {
    final ms = step.params['ms'] as int? ?? 1000;
    print('⏳ [딜레이] 시작: ${ms}ms');
    final startTime = DateTime.now();
    await Future.delayed(Duration(milliseconds: ms));
    final actualDuration = DateTime.now().difference(startTime).inMilliseconds;
    print('✅ [딜레이] 완료: 예상 ${ms}ms, 실제 ${actualDuration}ms');
  }

  /// 단일 오디오 재생
  Future<void> _executeAudio(
    InstructionStep step,
    StoryQuestion storyQuestion,
  ) async {
    final source = step.params['source'] as String?;
    if (source == null || source.isEmpty) {
      print('⚠️ audio source가 없습니다');
      return;
    }

    String? audioPath;
    
    // source에 따라 경로 결정
    if (source == 'questionAudioPath') {
      audioPath = storyQuestion.questionAudioPath;
    } else {
      // source가 직접 경로인 경우 (예: "assets/environment/dog.mp3")
      audioPath = source;
    }

    if (audioPath == null || audioPath.isEmpty) {
      print('⚠️ 오디오 경로가 없습니다');
      return;
    }

    print('🎵 오디오 재생: $audioPath');
    await _playQuestionAudio(audioPath);
  }

  /// 여러 오디오 순차 재생 (2번 문항용)
  Future<void> _executeAudioSequence(
    InstructionStep step,
    StoryQuestion storyQuestion,
  ) async {
    final source = step.params['source'] as String?;
    final field = step.params['field'] as String?;
    final delayBetween = step.params['delayBetween'] as int? ?? 1000;

    if (source != 'options' || field == null) {
      print('⚠️ audio_sequence 파라미터 오류: source=$source, field=$field');
      return;
    }

    // options에서 audioPath가 있는 것들만 필터링
    final audioOptions = storyQuestion.question.options
        .where((opt) {
          if (field == 'audioPath') {
            return opt.audioPath != null && opt.audioPath!.isNotEmpty;
          }
          return false;
        })
        .toList();

    if (audioOptions.isEmpty) {
      print('⚠️ 재생할 오디오가 없습니다');
      return;
    }

    print('🎵 순차 오디오 재생 시작: ${audioOptions.length}개');

    for (int i = 0; i < audioOptions.length; i++) {
      final option = audioOptions[i];
      final audioPath = option.audioPath!;

      // 각 오디오 재생 전에 TTS 멘트 추가
      final ttsText = i == 0 ? '첫 번째 소리입니다.' : '두 번째 소리입니다.';
      print('🗣️ [오디오 시퀀스] ${i + 1}번째 오디오 전 TTS 시작: "$ttsText"');
      try {
        final ttsStartTime = DateTime.now();
        await _ttsService.speak(ttsText);
        final ttsDuration = DateTime.now().difference(ttsStartTime).inMilliseconds;
        print('✅ [오디오 시퀀스] ${i + 1}번째 오디오 전 TTS 완료 (소요 시간: ${ttsDuration}ms)');
      } catch (e, stackTrace) {
        print('❌ [오디오 시퀀스] TTS 재생 실패: $e');
        print('  - 스택 트레이스: $stackTrace');
        // TTS 실패해도 오디오는 재생
      }

      print('🎵 [오디오 시퀀스] 소리${i + 1} 재생 시작: $audioPath');
      
      try {
        await _playQuestionAudio(audioPath);
        print('✅ [오디오 시퀀스] 소리${i + 1} 재생 완료');
        
        // 마지막이 아니면 딜레이
        if (i < audioOptions.length - 1) {
          print('⏳ [오디오 시퀀스] 다음 소리 전 딜레이: ${delayBetween}ms');
          await Future.delayed(Duration(milliseconds: delayBetween));
        }
      } catch (e, stackTrace) {
        print('❌ [오디오 시퀀스] 오디오 재생 실패: $audioPath - $e');
        print('  - 스택 트레이스: $stackTrace');
        // 계속 진행
      }
    }
    
    print('✅ [오디오 시퀀스] 모든 오디오 재생 완료');
  }

  /// 오디오 시도, 실패 시 TTS (3번 문항용)
  Future<void> _executeAudioOrTts(
    InstructionStep step,
    StoryQuestion storyQuestion,
  ) async {
    final audioPathParam = step.params['audioPath'] as String?;
    final ttsFallback = step.params['ttsFallback'] as String?;

    String? audioPath;
    
    // audioPath 파라미터에 따라 경로 결정
    if (audioPathParam == 'questionAudioPath') {
      audioPath = storyQuestion.questionAudioPath;
    } else {
      print('⚠️ 알 수 없는 audioPath 파라미터: $audioPathParam');
      audioPath = null;
    }

    bool audioPlayed = false;

    // 오디오 재생 시도
    if (audioPath != null && audioPath.isNotEmpty) {
      try {
        print('🎵 오디오 재생 시도: $audioPath');
        await _playQuestionAudio(audioPath);
        audioPlayed = true;
        print('✅ 오디오 재생 완료');
      } catch (e) {
        print('⚠️ 오디오 재생 실패: $e');
      }
    }

    // 오디오 재생 실패하거나 경로가 없으면 TTS로 대체
    if (!audioPlayed) {
      String? ttsText;
      
      // ttsFallback 파라미터에 따라 텍스트 결정
      if (ttsFallback == 'question.question') {
        ttsText = storyQuestion.question.question;
      } else if (ttsFallback != null && ttsFallback.isNotEmpty) {
        ttsText = ttsFallback;
      }

      if (ttsText != null && ttsText.isNotEmpty) {
        print('🔄 TTS로 대체 재생: $ttsText');
        await _ttsService.speak(ttsText);
      } else {
        print('⚠️ TTS fallback 텍스트가 없습니다');
      }
    }
  }
}
