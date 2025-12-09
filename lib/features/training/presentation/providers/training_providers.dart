import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/game_session_model.dart';
import '../../data/models/training_content_model.dart';
import '../../data/models/difficulty_params_model.dart';
import '../../domain/services/difficulty_adjuster.dart';
import '../../domain/services/progress_tracker.dart';
import '../../data/services/asset_loader_service.dart';

/// 에셋 로더 서비스 Provider
final assetLoaderProvider = Provider<AssetLoaderService>((ref) {
  return AssetLoaderService();
});

/// 에셋 로딩 상태 Provider
final assetLoadingStateProvider = StateProvider<AssetLoadingState>((ref) {
  return AssetLoadingState.idle;
});

/// 진도 추적 서비스 Provider
final progressTrackerProvider = Provider<ProgressTracker>((ref) {
  return ProgressTracker();
});

/// 현재 게임 세션 Provider
final currentGameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSessionModel?>(
  (ref) => GameSessionNotifier(),
);

/// 게임 세션 상태 관리자
class GameSessionNotifier extends StateNotifier<GameSessionModel?> {
  GameSessionNotifier() : super(null);

  /// 새 세션 시작
  void startSession({
    required String childId,
    required String moduleId,
    required int totalQuestions,
    int initialDifficulty = 2,
  }) {
    state = createGameSession(
      childId: childId,
      moduleId: moduleId,
      totalQuestions: totalQuestions,
      initialDifficulty: initialDifficulty,
    ).start();
  }

  /// 세션 업데이트
  void updateSession(GameSessionModel session) {
    state = session;
  }

  /// 정답 처리
  void addCorrect() {
    if (state != null) {
      state = state!.addCorrect();
    }
  }

  /// 오답 처리
  void addIncorrect() {
    if (state != null) {
      state = state!.addIncorrect();
    }
  }

  /// 다음 문제로 이동
  void nextQuestion() {
    if (state != null) {
      state = state!.nextQuestion();
    }
  }

  /// 난이도 조정
  void adjustDifficulty(int newLevel) {
    if (state != null) {
      state = state!.adjustDifficulty(newLevel);
    }
  }

  /// 일시정지
  void pause() {
    if (state != null) {
      state = state!.pause();
    }
  }

  /// 재개
  void resume() {
    if (state != null) {
      state = state!.resume();
    }
  }

  /// 세션 완료
  void complete() {
    if (state != null) {
      state = state!.complete();
    }
  }

  /// 세션 종료
  void endSession() {
    state = null;
  }
}

/// 난이도 조절기 Provider (세션별)
final difficultyAdjusterProvider =
    Provider.family<DifficultyAdjuster, String>((ref, moduleId) {
  // 모듈별로 별도의 난이도 조절기 인스턴스 생성
  return DifficultyAdjuster(
    initialDifficulty: DifficultyPresets.easy,
  );
});

/// 현재 학습 콘텐츠 Provider (Mock 데이터)
/// 실제로는 Repository에서 가져옴
final currentTrainingContentProvider =
    Provider.family<TrainingContentModel?, String>((ref, moduleId) {
  // TODO: 실제 Repository에서 데이터 로드
  // 현재는 Mock 데이터 반환
  return _getMockTrainingContent(moduleId);
});

/// Mock 학습 콘텐츠 생성
TrainingContentModel? _getMockTrainingContent(String moduleId) {
  if (moduleId == 'phonological_basic') {
    return TrainingContentModel(
      contentId: 'content_001',
      moduleId: moduleId,
      type: TrainingContentType.phonological,
      pattern: GamePattern.multipleChoice,
      title: '음운 인식 기초',
      instruction: '같은 소리로 시작하는 그림을 골라주세요',
      instructionAudioPath: 'audio/instructions/phonological_basic.mp3',
      items: [
        // Mock 문제 1
        const ContentItem(
          itemId: 'item_001',
          question: '고양이',
          questionAudioPath: 'audio/words/cat.mp3',
          questionImagePath: 'assets/images/cat.png',
          options: [
            ContentOption(
              optionId: 'opt_1',
              label: '강아지',
              imagePath: 'assets/images/dog.png',
              audioPath: 'audio/words/dog.mp3',
            ),
            ContentOption(
              optionId: 'opt_2',
              label: '코끼리',
              imagePath: 'assets/images/elephant.png',
              audioPath: 'audio/words/elephant.mp3',
            ),
          ],
          correctAnswer: 'opt_2', // 같은 'ㄱ' 소리
        ),
        // Mock 문제 2
        const ContentItem(
          itemId: 'item_002',
          question: '바나나',
          questionAudioPath: 'audio/words/banana.mp3',
          questionImagePath: 'assets/images/banana.png',
          options: [
            ContentOption(
              optionId: 'opt_1',
              label: '버스',
              imagePath: 'assets/images/bus.png',
              audioPath: 'audio/words/bus.mp3',
            ),
            ContentOption(
              optionId: 'opt_2',
              label: '사과',
              imagePath: 'assets/images/apple.png',
              audioPath: 'audio/words/apple.mp3',
            ),
          ],
          correctAnswer: 'opt_1', // 같은 'ㅂ' 소리
        ),
      ],
      difficulty: DifficultyPresets.easy,
    );
  }

  return null;
}

/// 특정 아동의 진도 정보 Provider
final childProgressProvider =
    Provider.family<Map<String, dynamic>, String>((ref, childId) {
  final tracker = ref.watch(progressTrackerProvider);
  return tracker.getSummary(childId);
});

/// 모듈 추천 Provider
final recommendedModulesProvider =
    Provider.family<List<String>, String>((ref, childId) {
  final tracker = ref.watch(progressTrackerProvider);
  return tracker.recommendModules(childId: childId, count: 3);
});

/// 에셋 프리로드 액션
Future<void> preloadGameAssets(WidgetRef ref) async {
  final assetLoader = ref.read(assetLoaderProvider);
  final stateNotifier = ref.read(assetLoadingStateProvider.notifier);

  stateNotifier.state = AssetLoadingState.loading;

  try {
    await assetLoader.loadGameAssets();
    stateNotifier.state = AssetLoadingState.loaded;
  } catch (e) {
    stateNotifier.state = AssetLoadingState.error;
    rethrow;
  }
}

/// 모듈별 에셋 로드
Future<void> loadModuleAssets(WidgetRef ref, String moduleId) async {
  final assetLoader = ref.read(assetLoaderProvider);
  await assetLoader.loadModuleAssets(moduleId);
}

