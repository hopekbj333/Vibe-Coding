import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.2.3: 사이먼 세즈 (Simon Says) 게임
/// 화면 4분할, 순서대로 불빛 + 소리 재현
class SimonSaysGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const SimonSaysGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<SimonSaysGame> createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<SimonSaysGame>
    with TickerProviderStateMixin {
  // 색상 버튼 데이터
  static const List<Map<String, dynamic>> _buttons = [
    {'color': Color(0xFFE53935), 'activeColor': Color(0xFFFF6659), 'name': '빨강', 'sound': '삐!'},
    {'color': Color(0xFF1E88E5), 'activeColor': Color(0xFF6AB7FF), 'name': '파랑', 'sound': '뿅!'},
    {'color': Color(0xFF43A047), 'activeColor': Color(0xFF76D275), 'name': '초록', 'sound': '띵!'},
    {'color': Color(0xFFFDD835), 'activeColor': Color(0xFFFFFF6B), 'name': '노랑', 'sound': '땡!'},
  ];

  int _currentLevel = 1; // 시퀀스 길이 = 레벨 + 1
  int _highScore = 0;
  int _score = 0;
  int _totalAttempts = 0;
  
  List<int> _sequence = [];
  List<int> _userInput = [];
  
  bool _isPlaying = false;
  bool _isUserTurn = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isGameOver = false;
  int _activeButton = -1;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
    _startNewGame();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _currentLevel = 1;
    _score = 0;
    _isGameOver = false;
    _startNewRound();
  }

  void _startNewRound() {
    // 새로운 요소 추가
    if (_sequence.isEmpty) {
      _sequence = [_random.nextInt(4)];
    } else {
      _sequence.add(_random.nextInt(4));
    }
    
    _userInput = [];
    _isUserTurn = false;
    _showFeedback = false;
    
    setState(() {});
    
    // 시퀀스 재생 시작
    Future.delayed(const Duration(milliseconds: 800), _playSequence);
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlaying = true;
      _activeButton = -1;
    });
    
    final delay = max(300, 600 - (_currentLevel * 30));
    
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      setState(() {
        _activeButton = _sequence[i];
      });
      
      _glowController.forward();
      
      await Future.delayed(Duration(milliseconds: delay));
      
      if (!mounted) return;
      
      _glowController.reverse();
      
      setState(() {
        _activeButton = -1;
      });
    }
    
    if (!mounted) return;
    
    setState(() {
      _isPlaying = false;
      _isUserTurn = true;
    });
  }

  void _onButtonTap(int index) {
    if (!_isUserTurn || _showFeedback) return;
    
    setState(() {
      _userInput.add(index);
      _activeButton = index;
    });
    
    _glowController.forward().then((_) {
      if (mounted) {
        _glowController.reverse();
        setState(() {
          _activeButton = -1;
        });
      }
    });
    
    // 입력 검증
    final currentIndex = _userInput.length - 1;
    if (_userInput[currentIndex] != _sequence[currentIndex]) {
      // 틀림 - 게임 오버
      _handleGameOver();
    } else if (_userInput.length == _sequence.length) {
      // 완료 - 레벨 업
      _handleLevelUp();
    }
  }

  void _handleLevelUp() {
    _currentLevel++;
    _score++;
    _totalAttempts++;
    
    if (_currentLevel > _highScore) {
      _highScore = _currentLevel;
    }
    
    setState(() {
      _showFeedback = true;
      _isCorrect = true;
      _isUserTurn = false;
    });
    
    widget.onScoreUpdate?.call(_score, _totalAttempts);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _showFeedback = false;
      });
      
      // 10레벨 달성 시 게임 완료
      if (_currentLevel > 10) {
        widget.onComplete?.call();
      } else {
        _startNewRound();
      }
    });
  }

  void _handleGameOver() {
    _totalAttempts++;
    
    setState(() {
      _showFeedback = true;
      _isCorrect = false;
      _isUserTurn = false;
      _isGameOver = true;
    });
    
    widget.onScoreUpdate?.call(_score, _totalAttempts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('🎮 사이먼 세즈'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '최고: $_highScore',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 레벨 표시
            _buildLevelDisplay(),
            
            // 상태 메시지
            _buildStatusMessage(),
            
            // 게임 보드
            Expanded(child: _buildGameBoard()),
            
            // 피드백 / 게임오버
            if (_showFeedback) _buildFeedback(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B4EFF), Color(0xFF9D4EDD)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B4EFF).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '레벨 $_currentLevel',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    String message;
    Color color;
    
    if (_isPlaying) {
      message = '👀 잘 보세요! (${_sequence.length}개)';
      color = Colors.amber;
    } else if (_isUserTurn) {
      final remaining = _sequence.length - _userInput.length;
      message = '🎯 따라하세요! ($remaining개 남음)';
      color = Colors.white;
    } else if (_showFeedback && _isCorrect) {
      message = '🎉 레벨 업!';
      color = Colors.greenAccent;
    } else if (_isGameOver) {
      message = '😢 게임 오버!';
      color = Colors.redAccent;
    } else {
      message = '준비 중...';
      color = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(4, (index) => _buildColorButton(index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(int index) {
    final button = _buttons[index];
    final isActive = _activeButton == index;
    final baseColor = button['color'] as Color;
    final activeColor = button['activeColor'] as Color;
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isActive ? _glowAnimation.value : 0.0;
        
        return GestureDetector(
          onTap: () => _onButtonTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.lerp(baseColor, activeColor, glowIntensity),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: isActive ? 1.0 : 0.3,
                child: Text(
                  button['sound'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedback() {
    if (_isGameOver) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Column(
          children: [
            const Text(
              '🎮 게임 오버!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '레벨 ${_currentLevel - 1}까지 도달했어요!',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _sequence = [];
                    _startNewGame();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시작'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: widget.onComplete,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('나가기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_upward, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Text(
            '레벨 $_currentLevel로 올라가요!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}

