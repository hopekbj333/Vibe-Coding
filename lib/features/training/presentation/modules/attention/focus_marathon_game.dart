import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.5.4: 집중력 마라톤 게임 (CPT 변형)
/// 2~3분간 단순 과제 지속 수행
class FocusMarathonGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const FocusMarathonGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<FocusMarathonGame> createState() => _FocusMarathonGameState();
}

class _FocusMarathonGameState extends State<FocusMarathonGame>
    with TickerProviderStateMixin {
  // 도형들
  static const List<Map<String, dynamic>> _shapes = [
    {'emoji': '⭐', 'name': '별', 'isTarget': true},
    {'emoji': '🔴', 'name': '빨간 원', 'isTarget': false},
    {'emoji': '🔵', 'name': '파란 원', 'isTarget': false},
    {'emoji': '🔺', 'name': '삼각형', 'isTarget': false},
    {'emoji': '🟩', 'name': '녹색 네모', 'isTarget': false},
  ];

  // 게임 설정
  final int _gameDurationSeconds = 120; // 2분
  final int _shapeIntervalMs = 1200; // 1.2초마다 새 도형

  // 상태
  int _timeRemaining = 120;
  int _totalShapes = 0;
  int _correctHits = 0; // 목표 터치
  int _misses = 0; // 목표 놓침
  int _falseAlarms = 0; // 잘못 터치

  Map<String, dynamic>? _currentShape;
  bool _showShape = false;
  bool _canTap = false;
  bool _tapped = false;
  bool _showFeedback = false;
  bool _wasCorrect = false;
  bool _gameStarted = false;
  bool _gameEnded = false;

  // 시간대별 정확도 추적
  final List<Map<String, dynamic>> _performanceLog = [];
  int _currentSegmentCorrect = 0;
  int _currentSegmentTotal = 0;

  Timer? _gameTimer;
  Timer? _shapeTimer;

  late AnimationController _shapeController;
  late Animation<double> _shapeAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _shapeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shapeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shapeController, curve: Curves.easeOut),
    );
    _timeRemaining = _gameDurationSeconds;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shapeTimer?.cancel();
    _shapeController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _timeRemaining = _gameDurationSeconds;
      _totalShapes = 0;
      _correctHits = 0;
      _misses = 0;
      _falseAlarms = 0;
      _performanceLog.clear();
      _currentSegmentCorrect = 0;
      _currentSegmentTotal = 0;
    });

    // 타이머 시작
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _timeRemaining--;

        // 30초마다 성과 기록
        if ((_gameDurationSeconds - _timeRemaining) % 30 == 0 &&
            _timeRemaining != _gameDurationSeconds) {
          _recordSegment();
        }
      });

      if (_timeRemaining <= 0) {
        _endGame();
      }
    });

    // 도형 표시 시작
    _showNextShape();
  }

  void _recordSegment() {
    final accuracy = _currentSegmentTotal > 0
        ? (_currentSegmentCorrect / _currentSegmentTotal * 100).round()
        : 0;

    _performanceLog.add({
      'time': _gameDurationSeconds - _timeRemaining,
      'accuracy': accuracy,
      'correct': _currentSegmentCorrect,
      'total': _currentSegmentTotal,
    });

    _currentSegmentCorrect = 0;
    _currentSegmentTotal = 0;
  }

  void _showNextShape() {
    if (!_gameStarted || _gameEnded) return;

    // 목표 확률 약 25%
    final isTarget = _random.nextDouble() < 0.25;
    
    if (isTarget) {
      _currentShape = _shapes.first; // 별
    } else {
      final nonTargets = _shapes.where((s) => !(s['isTarget'] as bool)).toList();
      _currentShape = nonTargets[_random.nextInt(nonTargets.length)];
    }

    _tapped = false;
    _showFeedback = false;
    _totalShapes++;
    _currentSegmentTotal++;

    setState(() {
      _showShape = true;
      _canTap = true;
    });

    _shapeController.forward(from: 0);

    // 다음 도형까지 대기
    _shapeTimer = Timer(Duration(milliseconds: _shapeIntervalMs - 200), () {
      _handleShapeTimeout();
    });
  }

  void _handleShapeTimeout() {
    if (!mounted || _gameEnded) return;

    final isTarget = _currentShape?['isTarget'] == true;

    if (isTarget && !_tapped) {
      // 목표인데 안 눌렀음
      _misses++;
      _showTemporaryFeedback(false);
    } else if (!isTarget && !_tapped) {
      // 목표 아닌데 안 눌렀음 - 정답
      _currentSegmentCorrect++;
    }

    _hideShapeAndContinue();
  }

  void _onTap() {
    if (!_canTap || _tapped || _gameEnded) return;

    _shapeTimer?.cancel();
    _tapped = true;
    _canTap = false;

    final isTarget = _currentShape?['isTarget'] == true;

    if (isTarget) {
      // 정답!
      _correctHits++;
      _currentSegmentCorrect++;
      _showTemporaryFeedback(true);
    } else {
      // 오답
      _falseAlarms++;
      _showTemporaryFeedback(false);
    }

    widget.onScoreUpdate?.call(_correctHits, _totalShapes);

    _hideShapeAndContinue();
  }

  void _showTemporaryFeedback(bool correct) {
    setState(() {
      _showFeedback = true;
      _wasCorrect = correct;
    });
  }

  void _hideShapeAndContinue() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      setState(() {
        _showShape = false;
        _showFeedback = false;
      });

      Future.delayed(const Duration(milliseconds: 100), _showNextShape);
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _shapeTimer?.cancel();

    // 마지막 세그먼트 기록
    if (_currentSegmentTotal > 0) {
      _recordSegment();
    }

    setState(() {
      _gameEnded = true;
      _gameStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameEnded) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      appBar: AppBar(
        title: const Text('🏃 집중력 마라톤'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _gameStarted
            ? _buildGameScreen()
            : _buildStartScreen(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⭐ 별이 나오면 터치!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '2분 동안 집중해서\n⭐만 터치하세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShapePreview('⭐', '터치!', Colors.green),
                const SizedBox(width: 16),
                _buildShapePreview('🔴🔵🔺', '무시', Colors.red),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text('시작!', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapePreview(String emoji, String label, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // 타이머 및 진행 상황
          _buildTimerBar(),

          // 게임 영역
          Expanded(child: _buildGameArea()),

          // 하단 안내
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    final progress = _timeRemaining / _gameDurationSeconds;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$minutes:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '⭐ $_correctHits',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.3 ? Colors.white : Colors.amber,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Center(
      child: AnimatedBuilder(
        animation: _shapeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _showShape ? _shapeAnimation.value.clamp(0.0, 1.0) : 0.0,
            child: Transform.scale(
              scale: 0.5 + (_shapeAnimation.value * 0.5),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _showFeedback
                      ? (_wasCorrect
                          ? Colors.greenAccent.withOpacity(0.3)
                          : Colors.redAccent.withOpacity(0.3))
                      : Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _showFeedback
                        ? (_wasCorrect ? Colors.greenAccent : Colors.redAccent)
                        : Colors.white54,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _currentShape?['emoji'] ?? '',
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, color: Colors.white70),
          const SizedBox(width: 8),
          const Text(
            '⭐가 나오면 화면 터치!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final totalTargets = _correctHits + _misses;
    final accuracy = totalTargets > 0
        ? (_correctHits / totalTargets * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      appBar: AppBar(
        title: const Text('🏆 결과'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 종합 결과
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      accuracy >= 80 ? '🎉 훌륭해요!' : accuracy >= 60 ? '👍 잘했어요!' : '💪 더 연습해요!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultStat('정확도', '$accuracy%', Colors.blue),
                        _buildResultStat('맞음', '$_correctHits', Colors.green),
                        _buildResultStat('놓침', '$_misses', Colors.orange),
                        _buildResultStat('잘못 누름', '$_falseAlarms', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 시간대별 집중력 그래프
              if (_performanceLog.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 시간대별 집중력',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPerformanceChart(),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _gameEnded = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => widget.onComplete?.call(),
                    icon: const Icon(Icons.check),
                    label: const Text('완료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _performanceLog.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final accuracy = data['accuracy'] as int;
          final time = data['time'] as int;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$accuracy%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: (accuracy * 0.7).toDouble(), // 스케일링: 최대 70px
                    decoration: BoxDecoration(
                      color: accuracy >= 80
                          ? Colors.green
                          : accuracy >= 60
                              ? Colors.orange
                              : Colors.red,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${time}s',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

