import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stt_result_model.dart';
import '../../data/services/stt_service.dart';

/// STT 서비스 프로바이더
final sttServiceProvider = Provider<SttService>((ref) {
  return SimulatedSttService();
});

/// 자동 채점 서비스 프로바이더
final autoScoringServiceProvider = Provider<AutoScoringService>((ref) {
  final sttService = ref.watch(sttServiceProvider);
  return AutoScoringService(sttService);
});

/// 현재 STT 결과 프로바이더
final currentSttResultProvider = StateProvider<SttResult?>((ref) {
  return null;
});

/// 현재 발음 점수 프로바이더
final currentPronunciationScoreProvider = StateProvider<PronunciationScore?>((ref) {
  return null;
});

/// 자동 채점 결과 프로바이더
final autoScoringResultProvider = StateProvider<AutoScoringResult?>((ref) {
  return null;
});

/// STT 처리 상태 프로바이더
final sttProcessingStateProvider = StateProvider<SttProcessingState>((ref) {
  return SttProcessingState.idle;
});

enum SttProcessingState {
  idle,       // 대기
  recording,  // 녹음 중
  processing, // 처리 중
  completed,  // 완료
  error,      // 에러
}

/// STT 컨트롤러
class SttController {
  final Ref ref;

  SttController(this.ref);

  /// 오디오 파일 음성 인식
  Future<SttResult> transcribeAudio(String audioPath) async {
    ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.processing;

    try {
      final sttService = ref.read(sttServiceProvider);
      final result = await sttService.transcribeAudio(audioPath);
      
      ref.read(currentSttResultProvider.notifier).state = result;
      ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.completed;
      
      return result;
    } catch (e) {
      ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.error;
      rethrow;
    }
  }

  /// 발음 분석
  Future<PronunciationScore> analyzePronunciation(
    String audioPath,
    String expectedText,
  ) async {
    final sttService = ref.read(sttServiceProvider);
    final score = await sttService.analyzePronunciation(audioPath, expectedText);
    
    ref.read(currentPronunciationScoreProvider.notifier).state = score;
    
    return score;
  }

  /// 자동 채점 수행
  Future<AutoScoringResult> performAutoScoring({
    required String questionId,
    required String audioPath,
    required String expectedAnswer,
  }) async {
    ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.processing;

    try {
      final autoScoringService = ref.read(autoScoringServiceProvider);
      final result = await autoScoringService.scoreAnswer(
        questionId: questionId,
        audioPath: audioPath,
        expectedAnswer: expectedAnswer,
      );
      
      ref.read(autoScoringResultProvider.notifier).state = result;
      ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.completed;
      
      return result;
    } catch (e) {
      ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.error;
      rethrow;
    }
  }

  /// 상태 초기화
  void reset() {
    ref.read(currentSttResultProvider.notifier).state = null;
    ref.read(currentPronunciationScoreProvider.notifier).state = null;
    ref.read(autoScoringResultProvider.notifier).state = null;
    ref.read(sttProcessingStateProvider.notifier).state = SttProcessingState.idle;
  }
}

/// STT 컨트롤러 프로바이더
final sttControllerProvider = Provider<SttController>((ref) {
  return SttController(ref);
});

