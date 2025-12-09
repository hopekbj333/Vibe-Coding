import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models/difficulty_params_model.dart';
import '../../data/models/training_content_model.dart';
import '../../domain/services/difficulty_adjuster.dart';

/// 게임 상태
enum GameState {
  loading,      // 로딩 중
  ready,        // 준비 완료
  playing,      // 플레이 중
  paused,       // 일시정지
  showingFeedback, // 피드백 표시 중
  completed,    // 완료
}

/// 학습 게임 베이스 클래스
/// 
/// 모든 학습 게임이 상속받는 기본 클래스입니다.
/// Flame Engine의 FlameGame을 확장합니다.
/// 
/// Milestone 2 - WP 2.1 (S 2.1.1)
abstract class BaseTrainingGame extends FlameGame {
  /// 게임 상태
  GameState _gameState = GameState.loading;
  GameState get gameState => _gameState;

  /// 현재 문제 인덱스
  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  /// 전체 콘텐츠
  final TrainingContentModel content;

  /// 난이도 조절기
  final DifficultyAdjuster difficultyAdjuster;

  /// 정답 수
  int _correctCount = 0;
  int get correctCount => _correctCount;

  /// 오답 수
  int _incorrectCount = 0;
  int get incorrectCount => _incorrectCount;

  /// 시작 시간
  DateTime? _questionStartTime;

  /// 게임 콜백
  final Function(bool isCorrect, int responseTime)? onAnswerSubmitted;
  final Function()? onGameCompleted;
  final Function(String error)? onGameError;

  BaseTrainingGame({
    required this.content,
    DifficultyAdjuster? difficultyAdjuster,
    this.onAnswerSubmitted,
    this.onGameCompleted,
    this.onGameError,
  }) : difficultyAdjuster = difficultyAdjuster ??
            DifficultyAdjuster(
              initialDifficulty: content.difficulty,
            );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // 게임 초기화
      await initializeGame();

      // 첫 문제 로드
      await loadQuestion(_currentQuestionIndex);

      _gameState = GameState.ready;
    } catch (e) {
      _gameState = GameState.loading;
      onGameError?.call('게임 초기화 실패: $e');
    }
  }

  /// 게임별 초기화 로직 (하위 클래스에서 구현)
  Future<void> initializeGame();

  /// 문제 로드 (하위 클래스에서 구현)
  Future<void> loadQuestion(int index);

  /// 게임 시작
  void startGame() {
    if (_gameState != GameState.ready && _gameState != GameState.paused) {
      return;
    }

    _gameState = GameState.playing;
    _questionStartTime = DateTime.now();
    onGameStarted();
  }

  /// 게임 시작 시 호출 (하위 클래스에서 오버라이드)
  void onGameStarted() {}

  /// 게임 일시정지
  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      onGamePaused();
    }
  }

  /// 게임 일시정지 시 호출 (하위 클래스에서 오버라이드)
  void onGamePaused() {}

  /// 게임 재개
  void resumeGame() {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      onGameResumed();
    }
  }

  /// 게임 재개 시 호출 (하위 클래스에서 오버라이드)
  void onGameResumed() {}

  /// 답변 제출
  Future<void> submitAnswer(String answer) async {
    if (_gameState != GameState.playing) {
      return;
    }

    final currentItem = content.items[_currentQuestionIndex];
    final isCorrect = answer == currentItem.correctAnswer;

    // 반응 시간 계산
    final responseTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : 0;

    // 통계 업데이트
    if (isCorrect) {
      _correctCount++;
    } else {
      _incorrectCount++;
    }

    // 난이도 조절
    final difficultyChanged = difficultyAdjuster.recordAnswer(isCorrect);
    if (difficultyChanged) {
      await onDifficultyChanged(difficultyAdjuster.currentParams);
    }

    // 피드백 표시
    _gameState = GameState.showingFeedback;
    await showFeedback(isCorrect, currentItem);

    // 콜백 호출
    onAnswerSubmitted?.call(isCorrect, responseTime);

    // 다음 문제로 이동
    await _moveToNextQuestion();
  }

  /// 피드백 표시 (하위 클래스에서 구현)
  Future<void> showFeedback(bool isCorrect, ContentItem item);

  /// 난이도 변경 시 호출 (하위 클래스에서 오버라이드)
  Future<void> onDifficultyChanged(DifficultyParams newParams) async {
    // 기본적으로는 아무것도 하지 않음
    // 하위 클래스에서 필요 시 구현
  }

  /// 다음 문제로 이동
  Future<void> _moveToNextQuestion() async {
    _currentQuestionIndex++;

    if (_currentQuestionIndex >= content.items.length) {
      // 게임 완료
      _gameState = GameState.completed;
      onGameCompleted?.call();
    } else {
      // 다음 문제 로드
      await loadQuestion(_currentQuestionIndex);
      _gameState = GameState.playing;
      _questionStartTime = DateTime.now();
    }
  }

  /// 현재 난이도 파라미터
  DifficultyParams get currentDifficulty => difficultyAdjuster.currentParams;

  /// 현재 문제
  ContentItem get currentItem => content.items[_currentQuestionIndex];

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (content.items.isEmpty) return 0.0;
    return _currentQuestionIndex / content.items.length;
  }

  /// 정답률 (0.0 ~ 1.0)
  double get accuracy {
    final total = _correctCount + _incorrectCount;
    if (total == 0) return 0.0;
    return _correctCount / total;
  }

  @override
  void onRemove() {
    // 정리 작업
    super.onRemove();
  }
}

/// 게임 오버레이 위젯 베이스
/// 
/// 게임 위에 표시되는 UI (점수, 진행바 등)
class GameOverlayWidget extends StatelessWidget {
  final BaseTrainingGame game;

  const GameOverlayWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // 상단 진행 정보
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTopBar(context),
          ),

          // 하단 컨트롤 (일시정지 등)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // 진행률
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game.currentQuestionIndex + 1} / ${game.content.items.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: game.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 정답 수
          _buildScoreChip('✓ ${game.correctCount}', Colors.green),
          const SizedBox(width: 8),
          // 오답 수
          _buildScoreChip('✗ ${game.incorrectCount}', Colors.red),
        ],
      ),
    );
  }

  Widget _buildScoreChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 일시정지 버튼
        if (game.gameState == GameState.playing)
          ElevatedButton.icon(
            onPressed: () => game.pauseGame(),
            icon: const Icon(Icons.pause),
            label: const Text('일시정지'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }
}

