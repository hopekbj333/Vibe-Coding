import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.5.2: 색깔-단어 게임 (스트룹 변형)
/// 아동용 단순화: 색깔과 그림이 일치하면 O
class StroopGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const StroopGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<StroopGame> createState() => _StroopGameState();
}

class _StroopQuestion {
  final String emoji;
  final Color displayColor;
  final Color correctColor;
  final bool isMatch;

  const _StroopQuestion({
    required this.emoji,
    required this.displayColor,
    required this.correctColor,
    required this.isMatch,
  });
}

class _StroopGameState extends State<StroopGame> with TickerProviderStateMixin {
  // 이모지와 올바른 색깔 매핑
  static const Map<String, Color> _itemColors = {
    '🍎': Colors.red,
    '🍊': Colors.orange,
    '🍋': Colors.yellow,
    '🥒': Colors.green,
    '🫐': Colors.blue,
    '🍇': Colors.purple,
    '☀️': Colors.yellow,
    '🌿': Colors.green,
    '❤️': Colors.red,
    '💙': Colors.blue,
  };

  int _currentRound = 0;
  final int _totalRounds = 12;
  int _score = 0;
  int _correct = 0;
  int _incorrect = 0;

  _StroopQuestion? _currentQuestion;
  bool _showFeedback = false;
  bool _wasCorrect = false;
  bool _answered = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final items = _itemColors.entries.toList();
    final item = items[_random.nextInt(items.length)];

    // 매치 여부 결정 (약 50% 확률로 매치)
    final isMatch = _random.nextBool();

    Color displayColor;
    if (isMatch) {
      displayColor = item.value;
    } else {
      // 다른 색깔 선택
      final otherColors = _itemColors.values
          .where((c) => c != item.value)
          .toList();
      displayColor = otherColors[_random.nextInt(otherColors.length)];
    }

    _currentQuestion = _StroopQuestion(
      emoji: item.key,
      displayColor: displayColor,
      correctColor: item.value,
      isMatch: isMatch,
    );

    _answered = false;
    _showFeedback = false;

    setState(() {});
    _scaleController.forward(from: 0);
  }

  void _onAnswer(bool isO) {
    if (_answered || _currentQuestion == null) return;

    _answered = true;
    final correct = isO == _currentQuestion!.isMatch;

    setState(() {
      _showFeedback = true;
      _wasCorrect = correct;

      if (correct) {
        _correct++;
        _score += 10;
      } else {
        _incorrect++;
      }
    });

    widget.onScoreUpdate?.call(_score, _currentRound + 1);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      _currentRound++;

      if (_currentRound >= _totalRounds) {
        widget.onComplete?.call();
      } else {
        _generateQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('🎨 색깔 맞추기'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '점수: $_score',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행 표시
            _buildProgressBar(),

            // 질문 카드
            Expanded(child: _buildQuestionCard()),

            // O/X 버튼
            _buildAnswerButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '정답: $_correct  오답: $_incorrect',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${_currentRound + 1} / $_totalRounds',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentRound + 1) / _totalRounds,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    if (_currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _showFeedback
                    ? (_wasCorrect ? Colors.green[50] : Colors.red[50])
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _showFeedback
                      ? (_wasCorrect ? Colors.green : Colors.red)
                      : Colors.grey[300]!,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '이 색깔이 맞나요?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 색깔이 적용된 이모지
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _currentQuestion!.displayColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentQuestion!.displayColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _currentQuestion!.displayColor,
                            _currentQuestion!.displayColor,
                          ],
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          _currentQuestion!.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 피드백
                  if (_showFeedback) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _wasCorrect ? Icons.check_circle : Icons.cancel,
                          color: _wasCorrect ? Colors.green : Colors.red,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _wasCorrect ? '정답!' : '틀렸어요',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _wasCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (!_currentQuestion!.isMatch)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '원래 색깔과 달라요!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // X 버튼
          Expanded(
            child: GestureDetector(
              onTap: _answered ? null : () => _onAnswer(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 80,
                decoration: BoxDecoration(
                  color: _answered
                      ? Colors.grey[200]
                      : Colors.red[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _answered ? Colors.grey : Colors.red,
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '❌',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // O 버튼
          Expanded(
            child: GestureDetector(
              onTap: _answered ? null : () => _onAnswer(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 80,
                decoration: BoxDecoration(
                  color: _answered
                      ? Colors.grey[200]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _answered ? Colors.grey : Colors.green,
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '⭕',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

