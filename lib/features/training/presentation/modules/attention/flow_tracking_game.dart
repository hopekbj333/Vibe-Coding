import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.5.5: 흐름 따라가기 게임
/// 천천히 움직이는 목표물을 계속 따라가며 터치
class FlowTrackingGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const FlowTrackingGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<FlowTrackingGame> createState() => _FlowTrackingGameState();
}

class _FlowTrackingGameState extends State<FlowTrackingGame>
    with TickerProviderStateMixin {
  // 테마
  static const List<Map<String, dynamic>> _themes = [
    {'emoji': '🐌', 'name': '달팽이', 'color': Color(0xFFE8F5E9)},
    {'emoji': '🎈', 'name': '풍선', 'color': Color(0xFFE3F2FD)},
    {'emoji': '🐠', 'name': '물고기', 'color': Color(0xFFE0F7FA)},
    {'emoji': '🦋', 'name': '나비', 'color': Color(0xFFFFF3E0)},
  ];

  // 게임 설정
  final int _gameDurationSeconds = 60;

  // 상태
  int _timeRemaining = 60;
  double _targetX = 0.5;
  double _targetY = 0.5;
  double _targetDx = 0.002;
  double _targetDy = 0.001;
  bool _isTracking = false;
  int _trackingTime = 0; // 추적한 총 시간 (밀리초)
  int _breakCount = 0;

  bool _gameStarted = false;
  bool _gameEnded = false;

  late Map<String, dynamic> _currentTheme;
  Timer? _gameTimer;
  Timer? _moveTimer;
  Timer? _trackingTimer;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentTheme = _themes[_random.nextInt(_themes.length)];
    _timeRemaining = _gameDurationSeconds;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameEnded = false;
      _timeRemaining = _gameDurationSeconds;
      _trackingTime = 0;
      _breakCount = 0;
      _targetX = 0.5;
      _targetY = 0.5;
    });

    // 메인 타이머
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining <= 0) {
        _endGame();
      }
    });

    // 목표물 이동
    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateTargetPosition();
    });

    // 추적 시간 카운터
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isTracking) {
        setState(() {
          _trackingTime += 100;
        });
      }
    });
  }

  void _updateTargetPosition() {
    if (!mounted || _gameEnded) return;

    setState(() {
      // 난이도에 따른 속도 조절
      final elapsedPercent = 1 - (_timeRemaining / _gameDurationSeconds);
      final speedMultiplier = 1.0 + (elapsedPercent * 0.5);

      _targetX += _targetDx * speedMultiplier;
      _targetY += _targetDy * speedMultiplier;

      // 벽 충돌
      if (_targetX < 0.1 || _targetX > 0.9) {
        _targetDx = -_targetDx;
        // 약간의 랜덤성 추가
        _targetDy += (_random.nextDouble() - 0.5) * 0.001;
      }
      if (_targetY < 0.15 || _targetY > 0.75) {
        _targetDy = -_targetDy;
        _targetDx += (_random.nextDouble() - 0.5) * 0.001;
      }

      // 속도 제한
      _targetDx = _targetDx.clamp(-0.004, 0.004);
      _targetDy = _targetDy.clamp(-0.003, 0.003);
    });
  }

  void _onPanStart(DragStartDetails details) {
    _checkTracking(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _checkTracking(details.globalPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isTracking) {
      setState(() {
        _isTracking = false;
        _breakCount++;
      });
    }
  }

  void _checkTracking(Offset fingerPosition) {
    if (!_gameStarted || _gameEnded) return;

    final size = MediaQuery.of(context).size;
    final targetPosition = Offset(
      _targetX * size.width,
      _targetY * size.height,
    );

    final distance = (fingerPosition - targetPosition).distance;
    final isNearTarget = distance < 60;

    if (isNearTarget && !_isTracking) {
      setState(() {
        _isTracking = true;
      });
    } else if (!isNearTarget && _isTracking) {
      setState(() {
        _isTracking = false;
        _breakCount++;
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    _trackingTimer?.cancel();

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
      backgroundColor: _currentTheme['color'] as Color,
      appBar: AppBar(
        title: Text('👆 ${_currentTheme['name']} 따라가기'),
        backgroundColor: (_currentTheme['color'] as Color).withOpacity(0.8),
        foregroundColor: Colors.black87,
        elevation: 0,
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
            Text(
              _currentTheme['emoji'] as String,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              '${_currentTheme['name']}를 따라가세요!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '손가락으로 계속 따라가며\n터치하고 있으세요!\n\n손을 떼면 점수가 떨어져요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
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

  Widget _buildGameScreen() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // 상태 표시
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildStatusBar(),
          ),

          // 목표물
          Positioned(
            left: _targetX * MediaQuery.of(context).size.width - 40,
            top: _targetY * MediaQuery.of(context).size.height - 40,
            child: _buildTarget(),
          ),

          // 추적 안내
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildTrackingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final trackingPercent = _gameDurationSeconds > 0
        ? (_trackingTime / (_gameDurationSeconds * 1000) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 타이머
          Row(
            children: [
              const Icon(Icons.timer, size: 20),
              const SizedBox(width: 4),
              Text(
                '$_timeRemaining초',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // 추적률
          Row(
            children: [
              Icon(
                _isTracking ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _isTracking ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${(_trackingTime / 1000).toStringAsFixed(1)}초',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isTracking ? Colors.green : Colors.black87,
                ),
              ),
            ],
          ),
          // 끊김 횟수
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 20, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '$_breakCount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _isTracking
            ? Colors.greenAccent.withOpacity(0.3)
            : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: _isTracking ? Colors.green : Colors.grey,
          width: 4,
        ),
        boxShadow: _isTracking
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          _currentTheme['emoji'] as String,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Widget _buildTrackingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isTracking
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isTracking ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isTracking ? Icons.touch_app : Icons.pan_tool,
            color: _isTracking ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            _isTracking
                ? '잘하고 있어요! 계속 따라가세요!'
                : '${_currentTheme['name']}에 손가락을 대세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isTracking ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final totalTimeMs = _gameDurationSeconds * 1000;
    final trackingPercent = ((_trackingTime / totalTimeMs) * 100).round();
    final isGood = trackingPercent >= 70;

    return Scaffold(
      backgroundColor: _currentTheme['color'] as Color,
      appBar: AppBar(
        title: const Text('🏆 결과'),
        backgroundColor: (_currentTheme['color'] as Color).withOpacity(0.8),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                Text(
                  isGood ? '🎉 훌륭해요!' : '💪 더 연습해요!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // 집중 점수
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isGood
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : [Colors.orange[400]!, Colors.orange[600]!],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$trackingPercent%',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          '집중 점수',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 통계
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '추적 시간',
                      '${(_trackingTime / 1000).toStringAsFixed(1)}초',
                      Colors.blue,
                    ),
                    _buildStatItem(
                      '끊김 횟수',
                      '$_breakCount회',
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
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
}

