import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.3.2: 글자 방향 훈련 게임
/// b/d, p/q, ㄴ/ㄱ 등 혼동 글자 구별 훈련 (Go/No-Go 패턴)
class LetterDirectionGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const LetterDirectionGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<LetterDirectionGame> createState() => _LetterDirectionGameState();
}

class _LetterDirectionGameState extends State<LetterDirectionGame>
    with TickerProviderStateMixin {
  // 혼동 글자 쌍
  static const List<Map<String, dynamic>> _letterPairs = [
    {'target': 'ㄱ', 'distractor': 'ㄴ', 'category': '한글'},
    {'target': 'ㄴ', 'distractor': 'ㄱ', 'category': '한글'},
    {'target': 'ㄹ', 'distractor': 'ㅂ', 'category': '한글'},
    {'target': '6', 'distractor': '9', 'category': '숫자'},
    {'target': '9', 'distractor': '6', 'category': '숫자'},
    {'target': '2', 'distractor': '5', 'category': '숫자'},
    {'target': 'b', 'distractor': 'd', 'category': '영문'},
    {'target': 'd', 'distractor': 'b', 'category': '영문'},
    {'target': 'p', 'distractor': 'q', 'category': '영문'},
  ];

  int _currentRound = 0;
  final int _totalRounds = 10;
  int _score = 0;
  int _correctTaps = 0;
  int _wrongTaps = 0;
  int _missedTargets = 0;
  
  String _targetLetter = '';
  String _distractorLetter = '';
  String _currentLetter = '';
  
  bool _isShowingLetter = false;
  bool _canTap = false;
  bool _showFeedback = false;
  bool _wasCorrect = false;
  bool _gameEnded = false;
  
  late AnimationController _letterController;
  late Animation<double> _letterAnimation;
  
  Timer? _letterTimer;
  Timer? _intervalTimer;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _letterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _letterController, curve: Curves.easeOut),
    );
    
    _startGame();
  }

  @override
  void dispose() {
    _letterTimer?.cancel();
    _intervalTimer?.cancel();
    _letterController.dispose();
    super.dispose();
  }

  void _startGame() {
    // 랜덤으로 글자 쌍 선택
    final pair = _letterPairs[_random.nextInt(_letterPairs.length)];
    _targetLetter = pair['target'] as String;
    _distractorLetter = pair['distractor'] as String;
    
    _currentRound = 0;
    _score = 0;
    _correctTaps = 0;
    _wrongTaps = 0;
    _missedTargets = 0;
    _gameEnded = false;
    
    setState(() {});
    
    // 게임 시작 대기
    Future.delayed(const Duration(seconds: 2), _showNextLetter);
  }

  void _showNextLetter() {
    if (!mounted || _gameEnded) return;
    
    // 타겟이 나올 확률 40%
    final isTarget = _random.nextDouble() < 0.4;
    _currentLetter = isTarget ? _targetLetter : _distractorLetter;
    
    setState(() {
      _isShowingLetter = true;
      _canTap = true;
      _showFeedback = false;
    });
    
    _letterController.forward(from: 0);
    
    // 글자 표시 시간 (난이도에 따라 조절)
    final displayTime = max(800, 1500 - (_currentRound * 50));
    
    _letterTimer = Timer(Duration(milliseconds: displayTime), () {
      if (!mounted || _gameEnded) return;
      
      // 시간 내에 터치하지 않음
      if (_canTap) {
        _canTap = false;
        
        if (_currentLetter == _targetLetter) {
          // 타겟을 놓침
          _missedTargets++;
          _showLetterFeedback(false, missed: true);
        } else {
          // 정상적으로 무시함
          _score++;
          _hideLetterAndContinue();
        }
      }
    });
  }

  void _onTap() {
    if (!_canTap || _showFeedback || _gameEnded) return;
    
    _canTap = false;
    _letterTimer?.cancel();
    
    if (_currentLetter == _targetLetter) {
      // 정답! 타겟을 탭함
      _correctTaps++;
      _score++;
      _showLetterFeedback(true);
    } else {
      // 오답! 비타겟을 탭함
      _wrongTaps++;
      _showLetterFeedback(false);
    }
  }

  void _showLetterFeedback(bool correct, {bool missed = false}) {
    setState(() {
      _showFeedback = true;
      _wasCorrect = correct;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _hideLetterAndContinue();
    });
  }

  void _hideLetterAndContinue() {
    if (!mounted) return;
    
    _letterController.reverse();
    
    setState(() {
      _isShowingLetter = false;
      _currentRound++;
    });
    
    widget.onScoreUpdate?.call(_score, _currentRound);
    
    if (_currentRound >= _totalRounds) {
      _endGame();
    } else {
      // 다음 글자까지 대기
      final interval = 500 + _random.nextInt(500);
      _intervalTimer = Timer(Duration(milliseconds: interval), _showNextLetter);
    }
  }

  void _endGame() {
    setState(() {
      _gameEnded = true;
    });
  }

  void _restartOrComplete() {
    if (_currentRound >= _totalRounds) {
      widget.onComplete?.call();
    } else {
      _startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('👁️ 글자 방향 찾기'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$_currentRound / $_totalRounds',
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
              
              // 타겟 글자 표시
              _buildTargetDisplay(),
              
              // 게임 영역
              Expanded(
                child: _gameEnded ? _buildResult() : _buildGameArea(),
              ),
              
              // 점수 표시
              if (!_gameEnded) _buildScoreDisplay(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: _currentRound / _totalRounds,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: Colors.blue),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              children: [
                const TextSpan(text: '찾아서 터치! → '),
                TextSpan(
                  text: _targetLetter,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Center(
      child: AnimatedBuilder(
        animation: _letterAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _letterAnimation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.5 + (_letterAnimation.value * 0.5),
              child: _buildLetterDisplay(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLetterDisplay() {
    Color backgroundColor;
    Color borderColor;
    
    if (_showFeedback) {
      backgroundColor = _wasCorrect ? Colors.green[100]! : Colors.red[100]!;
      borderColor = _wasCorrect ? Colors.green : Colors.red;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey[300]!;
    }
    
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            _currentLetter,
            style: TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: _showFeedback
                  ? (_wasCorrect ? Colors.green[700] : Colors.red[700])
                  : Colors.black87,
            ),
          ),
          if (_showFeedback)
            Positioned(
              bottom: 8,
              child: Icon(
                _wasCorrect ? Icons.check_circle : Icons.cancel,
                color: _wasCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('정답', '$_correctTaps', Colors.green),
          _buildStatItem('오답', '$_wrongTaps', Colors.red),
          _buildStatItem('놓침', '$_missedTargets', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final accuracy = _totalRounds > 0
        ? ((_correctTaps + (_totalRounds - _correctTaps - _wrongTaps - _missedTargets)) / _totalRounds * 100).round()
        : 0;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              accuracy >= 80 ? '🎉 훌륭해요!' : accuracy >= 60 ? '👍 잘했어요!' : '💪 연습해요!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '정확도: $accuracy%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: accuracy >= 80 ? Colors.green : accuracy >= 60 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultStat('✅ 정답', '$_correctTaps', Colors.green),
                _buildResultStat('❌ 오답', '$_wrongTaps', Colors.red),
                _buildResultStat('⏰ 놓침', '$_missedTargets', Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => widget.onComplete?.call(),
                  icon: const Icon(Icons.check),
                  label: const Text('완료'),
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

