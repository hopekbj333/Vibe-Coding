import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.4.1: N-Back 게임
/// 연속으로 나오는 그림 중 "N개 전과 같으면" 터치
class NBackGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const NBackGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<NBackGame> createState() => _NBackGameState();
}

class _NBackGameState extends State<NBackGame> with TickerProviderStateMixin {
  static const List<String> _items = ['🍎', '🍌', '🍇', '🍊', '🍓', '🥝', '🍑', '🍒'];

  int _nBack = 1; // 1-Back, 2-Back, etc.
  int _currentRound = 0;
  final int _roundsPerLevel = 15;
  int _score = 0;
  int _correctHits = 0;
  int _correctMisses = 0;
  int _wrongHits = 0;
  int _missedTargets = 0;

  List<String> _sequence = [];
  int _currentIndex = -1;
  String _currentItem = '';
  
  bool _showItem = false;
  bool _canTap = false;
  bool _showFeedback = false;
  bool _wasCorrect = false;
  bool _gameEnded = false;
  bool _tapped = false;

  late AnimationController _itemController;
  late Animation<double> _itemAnimation;

  Timer? _roundTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _itemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _itemController, curve: Curves.easeOut),
    );
    _startLevel();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _itemController.dispose();
    super.dispose();
  }

  void _startLevel() {
    _currentRound = 0;
    _correctHits = 0;
    _correctMisses = 0;
    _wrongHits = 0;
    _missedTargets = 0;
    _currentIndex = -1;
    _gameEnded = false;

    // 시퀀스 생성 (약 30% 매치 확률)
    _sequence = [];
    for (int i = 0; i < _roundsPerLevel; i++) {
      if (i >= _nBack && _random.nextDouble() < 0.3) {
        // N개 전과 같은 아이템
        _sequence.add(_sequence[i - _nBack]);
      } else {
        // 다른 아이템 (N개 전과 다르게)
        String newItem;
        do {
          newItem = _items[_random.nextInt(_items.length)];
        } while (i >= _nBack && newItem == _sequence[i - _nBack]);
        _sequence.add(newItem);
      }
    }

    setState(() {});
    
    Future.delayed(const Duration(seconds: 2), _showNextItem);
  }

  void _showNextItem() {
    if (!mounted || _gameEnded) return;

    _currentIndex++;
    
    if (_currentIndex >= _sequence.length) {
      _endLevel();
      return;
    }

    _currentItem = _sequence[_currentIndex];
    _tapped = false;

    setState(() {
      _showItem = true;
      _canTap = true;
      _showFeedback = false;
    });

    _itemController.forward(from: 0);

    // 아이템 표시 시간
    _roundTimer = Timer(const Duration(milliseconds: 1500), () {
      _checkMissedTarget();
    });
  }

  void _checkMissedTarget() {
    if (!mounted || _gameEnded) return;

    final isMatch = _currentIndex >= _nBack && 
        _currentItem == _sequence[_currentIndex - _nBack];

    if (isMatch && !_tapped) {
      // 터치해야 했는데 안 함
      _missedTargets++;
      _showRoundFeedback(false, missed: true);
    } else if (!isMatch && !_tapped) {
      // 터치 안 해야 했고 안 함 - 정답
      _correctMisses++;
      _score++;
      _hideAndContinue();
    } else {
      // 이미 처리됨
      _hideAndContinue();
    }
  }

  void _onTap() {
    if (!_canTap || _tapped || _showFeedback || _gameEnded) return;

    _roundTimer?.cancel();
    _tapped = true;
    _canTap = false;

    final isMatch = _currentIndex >= _nBack && 
        _currentItem == _sequence[_currentIndex - _nBack];

    if (isMatch) {
      // 정답! 매치를 찾음
      _correctHits++;
      _score++;
      _showRoundFeedback(true);
    } else {
      // 오답! 매치 아닌데 터치함
      _wrongHits++;
      _showRoundFeedback(false);
    }
  }

  void _showRoundFeedback(bool correct, {bool missed = false}) {
    setState(() {
      _showFeedback = true;
      _wasCorrect = correct;
    });

    widget.onScoreUpdate?.call(_score, _currentRound + 1);

    Future.delayed(const Duration(milliseconds: 500), () {
      _hideAndContinue();
    });
  }

  void _hideAndContinue() {
    if (!mounted) return;

    _itemController.reverse();

    setState(() {
      _showItem = false;
      _currentRound++;
    });

    if (_currentRound >= _roundsPerLevel) {
      _endLevel();
    } else {
      Future.delayed(const Duration(milliseconds: 500), _showNextItem);
    }
  }

  void _endLevel() {
    setState(() {
      _gameEnded = true;
    });
  }

  void _nextLevel() {
    if (_nBack < 3) {
      _nBack++;
    }
    _startLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('🧠 $_nBack-Back 게임'),
        backgroundColor: const Color(0xFF16213E),
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
        child: GestureDetector(
          onTap: _onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              // 진행 표시
              _buildProgressBar(),

              // 설명
              _buildInstructions(),

              // 게임 영역
              Expanded(
                child: _gameEnded ? _buildResult() : _buildGameArea(),
              ),

              // 피드백
              if (_showFeedback && !_gameEnded) _buildFeedback(),

              const SizedBox(height: 20),
            ],
          ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4EFF), Color(0xFF9D4EDD)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_nBack-Back',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_currentRound + 1} / $_roundsPerLevel',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentRound + 1) / _roundsPerLevel,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4EFF)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    final backText = _nBack == 1 ? '바로 전' : '$_nBack개 전';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            '$backText과 같으면 화면을 터치!',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Center(
      child: AnimatedBuilder(
        animation: _itemAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _itemAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.5 + (_itemAnimation.value * 0.5),
              child: _buildItemDisplay(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemDisplay() {
    Color borderColor;
    Color bgColor;

    if (_showFeedback) {
      borderColor = _wasCorrect ? Colors.greenAccent : Colors.redAccent;
      bgColor = _wasCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2);
    } else {
      borderColor = const Color(0xFF6B4EFF);
      bgColor = Colors.white10;
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _currentItem,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _wasCorrect ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _wasCorrect ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _wasCorrect ? Icons.check_circle : Icons.cancel,
            color: _wasCorrect ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Text(
            _wasCorrect ? '정답!' : '다시 도전!',
            style: TextStyle(
              color: _wasCorrect ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final accuracy = _roundsPerLevel > 0
        ? ((_correctHits + _correctMisses) / _roundsPerLevel * 100).round()
        : 0;
    final passed = accuracy >= 70;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              passed ? '🎉 레벨 클리어!' : '💪 연습이 필요해요!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '정확도: $accuracy%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.greenAccent : Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultStat('✅ 맞춤', '$_correctHits', Colors.greenAccent),
                _buildResultStat('❌ 틀림', '$_wrongHits', Colors.redAccent),
                _buildResultStat('⏰ 놓침', '$_missedTargets', Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startLevel,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                if (passed && _nBack < 3)
                  ElevatedButton.icon(
                    onPressed: _nextLevel,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('${_nBack + 1}-Back 도전'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4EFF),
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => widget.onComplete?.call(),
                    icon: const Icon(Icons.check),
                    label: const Text('완료'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

