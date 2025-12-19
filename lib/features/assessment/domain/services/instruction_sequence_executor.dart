import 'package:literacy_assessment/core/services/audio_playback_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/audio_constants.dart';
import '../../data/models/story_assessment_model.dart';
import '../../data/services/instruction_sequence_loader_service.dart';

/// 안내 시퀀스 실행 엔진
/// JSON의 steps를 순서대로 실행
class InstructionSequenceExecutor {
  final TtsService _ttsService;
  final AudioPlaybackService _audioPlaybackService;
  final Function(String?) _playQuestionAudio;

  InstructionSequenceExecutor({
    required TtsService ttsService,
    required AudioPlaybackService audioPlaybackService,
    required Function(String?) playQuestionAudio,
  })  : _ttsService = ttsService,
        _audioPlaybackService = audioPlaybackService,
        _playQuestionAudio = playQuestionAudio;

  /// 시퀀스 실행
  Future<void> executeSequence(
    QuestionInstructionSequence sequence,
    StoryQuestion storyQuestion,
  ) async {
    // TTS 초기화
    AppLogger.debug('TTS 초기화 시작');
    await _ttsService.initialize();
    AppLogger.success('TTS 초기화 완료');

    // 각 step을 순서대로 실행
    AppLogger.sequence('시퀀스 실행 시작', data: {
      'totalSteps': sequence.steps.length,
    });
    for (int i = 0; i < sequence.steps.length; i++) {
      final step = sequence.steps[i];
      AppLogger.sequence('Step 실행', data: {
        'stepNumber': i + 1,
        'totalSteps': sequence.steps.length,
        'action': step.action,
      });
      await _executeStep(step, storyQuestion);
      AppLogger.success('Step 완료', data: {'stepNumber': i + 1});
    }
    AppLogger.success('모든 step 실행 완료');
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
        AppLogger.warning('알 수 없는 action', data: {'action': step.action});
    }
  }

  /// TTS 실행
  Future<void> _executeTts(InstructionStep step) async {
    AppLogger.tts('_executeTts 호출됨', data: {'params': step.params});
    
    final text = step.params['text'] as String?;
    if (text == null || text.isEmpty) {
      AppLogger.warning('TTS text가 없습니다', data: {'params': step.params});
      return;
    }
    
    AppLogger.tts('텍스트 확인 완료', data: {
      'text': text,
      'textLength': text.length,
    });
    
    try {
      final startTime = DateTime.now();
      await _ttsService.speak(text);
      final actualDuration = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.success('TTS 서비스 speak() 완료', data: {
        'durationMs': actualDuration,
      });
    } catch (e, stackTrace) {
      AppLogger.error(
        'TTS 실행 실패',
        error: e,
        stackTrace: stackTrace,
        data: {'text': text},
      );
      // TTS 실패해도 계속 진행
    }
  }

  /// 딜레이 실행
  Future<void> _executeDelay(InstructionStep step) async {
    final ms = step.params['ms'] as int? ?? AudioConstants.defaultDelayMs;
    AppLogger.delay('딜레이 시작', data: {'ms': ms});
    final startTime = DateTime.now();
    await Future.delayed(Duration(milliseconds: ms));
    final actualDuration = DateTime.now().difference(startTime).inMilliseconds;
    AppLogger.success('딜레이 완료', data: {
      'expectedMs': ms,
      'actualMs': actualDuration,
    });
  }

  /// 단일 오디오 재생
  Future<void> _executeAudio(
    InstructionStep step,
    StoryQuestion storyQuestion,
  ) async {
    final source = step.params['source'] as String?;
    if (source == null || source.isEmpty) {
      AppLogger.warning('audio source가 없습니다');
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
      AppLogger.warning('오디오 경로가 없습니다');
      return;
    }

    AppLogger.audio('오디오 재생', data: {'audioPath': audioPath});
    await _playQuestionAudio(audioPath);
  }

  /// 여러 오디오 순차 재생 (2번 문항용)
  Future<void> _executeAudioSequence(
    InstructionStep step,
    StoryQuestion storyQuestion,
  ) async {
    final source = step.params['source'] as String?;
    final field = step.params['field'] as String?;
    final delayBetween = step.params['delayBetween'] as int? ?? AudioConstants.audioSequenceDelayMs;

    if (source != 'options' || field == null) {
      AppLogger.warning('audio_sequence 파라미터 오류', data: {
        'source': source,
        'field': field,
      });
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
      AppLogger.warning('재생할 오디오가 없습니다');
      return;
    }

    AppLogger.audio('순차 오디오 재생 시작', data: {
      'audioCount': audioOptions.length,
    });

    for (int i = 0; i < audioOptions.length; i++) {
      final option = audioOptions[i];
      final audioPath = option.audioPath!;

      // 각 오디오 재생 전에 TTS 멘트 추가
      final ttsText = i == 0 ? '첫 번째 소리입니다.' : '두 번째 소리입니다.';
      AppLogger.tts('오디오 시퀀스: ${i + 1}번째 오디오 전 TTS 시작', data: {
        'ttsText': ttsText,
        'audioIndex': i + 1,
      });
      try {
        final ttsStartTime = DateTime.now();
        await _ttsService.speak(ttsText);
        final ttsDuration = DateTime.now().difference(ttsStartTime).inMilliseconds;
        AppLogger.success('오디오 시퀀스: ${i + 1}번째 오디오 전 TTS 완료', data: {
          'durationMs': ttsDuration,
        });
      } catch (e, stackTrace) {
        AppLogger.error(
          '오디오 시퀀스: TTS 재생 실패',
          error: e,
          stackTrace: stackTrace,
        );
        // TTS 실패해도 오디오는 재생
      }

      AppLogger.audio('오디오 시퀀스: 소리${i + 1} 재생 시작', data: {
        'audioPath': audioPath,
        'audioIndex': i + 1,
      });
      
      try {
        await _playQuestionAudio(audioPath);
        AppLogger.success('오디오 시퀀스: 소리${i + 1} 재생 완료');
        
        // 마지막이 아니면 딜레이
        if (i < audioOptions.length - 1) {
          AppLogger.delay('오디오 시퀀스: 다음 소리 전 딜레이', data: {
            'delayMs': delayBetween,
          });
          await Future.delayed(Duration(milliseconds: delayBetween));
        }
      } catch (e, stackTrace) {
        AppLogger.error(
          '오디오 시퀀스: 오디오 재생 실패',
          error: e,
          stackTrace: stackTrace,
          data: {'audioPath': audioPath},
        );
        // 계속 진행
      }
    }
    
    AppLogger.success('오디오 시퀀스: 모든 오디오 재생 완료');
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
      AppLogger.warning('알 수 없는 audioPath 파라미터', data: {
        'audioPathParam': audioPathParam,
      });
      audioPath = null;
    }

    bool audioPlayed = false;

    // 오디오 재생 시도
    if (audioPath != null && audioPath.isNotEmpty) {
      try {
        AppLogger.audio('오디오 재생 시도', data: {'audioPath': audioPath});
        await _playQuestionAudio(audioPath);
        audioPlayed = true;
        AppLogger.success('오디오 재생 완료');
      } catch (e, stackTrace) {
        AppLogger.warning('오디오 재생 실패', data: {
          'error': e.toString(),
          'audioPath': audioPath,
        });
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
        AppLogger.tts('TTS로 대체 재생', data: {'ttsText': ttsText});
        await _ttsService.speak(ttsText);
      } else {
        AppLogger.warning('TTS fallback 텍스트가 없습니다');
      }
    }
  }
}
