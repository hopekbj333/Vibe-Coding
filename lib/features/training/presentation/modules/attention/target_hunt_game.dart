import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.5.1: 목표물 사냥 게임
/// 여러 물체가 움직이는 화면에서 목표물만 터치
class TargetHuntGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const TargetHuntGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<TargetHuntGame> createState() => _TargetHuntGameState();
}

class _MovingObject {
  double x;
  double y;
  double dx;
  double dy;
  final String emoji;
  final bool isTarget;
  bool caught;

  _MovingObject({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.emoji,
    required this.isTarget,
    this.caught = false,
  });
}

class _TargetHuntGameState extends State<TargetHuntGame>
    with TickerProviderStateMixin {
  // 테마별 목표물과 방해물
  static const List<Map<String, dynamic>> _themes = [
    {
      'name': '나비 채집',
      'target': '🦋',
      'distractors': ['🐝', '🐞', '🐜', '🦟'],
      'background': Color(0xFFE8F5E9),
    },
    {
      'name': '별 따기',
      'target': '⭐',
      'distractors': ['🌙', '☁️', '💫', '✨'],
      'background': Color(0xFF1A237E),
    },
    {
      'name': '사과 수확',
      'target': '🍎',
      'distractors': ['🍐', '🍊', '🍋', '🍏'],
      'background': Color(0xFFFFF3E0),
    },
  ];

  int _currentLevel = 0;
  int _score = 0;
  int _caught = 0;
  int _missed = 0;
  int _wrongCatch = 0;
  int _targetsToCatch = 5;

  List<_MovingObject> _objects = [];
  Timer? _gameTimer;
  Timer? _spawnTimer;
  bool _gameActive = false;
  bool _levelComplete = false;

  late Map<String, dynamic> _currentTheme;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentTheme = _themes[_random.nextInt(_themes.length)];
    _startLevel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _startLevel() {
    _objects = [];
    _caught = 0;
    _missed = 0;
    _wrongCatch = 0;
    _levelComplete = false;
    _gameActive = true;

    // 난이도에 따른 설정
    final targetCount = 3 + _currentLevel;
    final distractorCount = 2 + _currentLevel * 2;
    final speed = 1.0 + (_currentLevel * 0.3);

    // 초기 객체 스폰
    _spawnObjects(targetCount, distractorCount, speed);

    // 게임 루프 시작
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updateObjects();
    });

    setState(() {});
  }

  void _spawnObjects(int targetCount, int distractorCount, double speed) {
    final distractors = (_currentTheme['distractors'] as List<String>)
        .take(1 + _currentLevel)
        .toList();

    // 목표물 스폰
    for (int i = 0; i < targetCount; i++) {
      _objects.add(_createObject(
        _currentTheme['target'] as String,
        true,
        speed,
      ));
    }

    // 방해물 스폰
    for (int i = 0; i < distractorCount; i++) {
      final distractor = distractors[_random.nextInt(distractors.length)];
      _objects.add(_createObject(distractor, false, speed));
    }
  }

  _MovingObject _createObject(String emoji, bool isTarget, double speed) {
    return _MovingObject(
      x: _random.nextDouble() * 0.8 + 0.1,
      y: _random.nextDouble() * 0.6 + 0.2,
      dx: (_random.nextDouble() - 0.5) * speed * 0.01,
      dy: (_random.nextDouble() - 0.5) * speed * 0.01,
      emoji: emoji,
      isTarget: isTarget,
    );
  }

  void _updateObjects() {
    if (!mounted || !_gameActive) return;

    setState(() {
      for (var obj in _objects) {
        if (obj.caught) continue;

        // 위치 업데이트
        obj.x += obj.dx;
        obj.y += obj.dy;

        // 벽 충돌
        if (obj.x < 0.05 || obj.x > 0.95) obj.dx = -obj.dx;
        if (obj.y < 0.1 || obj.y > 0.85) obj.dy = -obj.dy;
      }
    });
  }

  void _onObjectTap(_MovingObject obj) {
    if (!_gameActive || obj.caught) return;

    setState(() {
      obj.caught = true;

      if (obj.isTarget) {
        _caught++;
        _score += 10;
      } else {
        _wrongCatch++;
        _score = max(0, _score - 5);
      }
    });

    widget.onScoreUpdate?.call(_score, _currentLevel + 1);

    // 목표물 모두 잡았는지 확인
    final remainingTargets = _objects.where((o) => o.isTarget && !o.caught).length;
    if (remainingTargets == 0) {
      _handleLevelComplete();
    }
  }

  void _handleLevelComplete() {
    _gameTimer?.cancel();
    _gameActive = false;

    setState(() {
      _levelComplete = true;
    });
  }

  void _nextLevel() {
    if (_currentLevel < 3) {
      _currentLevel++;
      _startLevel();
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _currentTheme['background'] as Color;
    final isDark = bgColor.computeLuminance() < 0.5;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('🎯 ${_currentTheme['name']}'),
        backgroundColor: isDark ? Colors.black26 : Colors.white24,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '점수: $_score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상태 표시
            _buildStatusBar(isDark),

            // 게임 영역
            Expanded(
              child: _levelComplete ? _buildLevelComplete(isDark) : _buildGameArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isDark) {
    final targetEmoji = _currentTheme['target'] as String;
    final totalTargets = _objects.where((o) => o.isTarget).length;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '$targetEmoji만 잡기!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                targetEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              Text(
                '$_caught / $totalTargets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '레벨 ${_currentLevel + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _objects.map((obj) {
            if (obj.caught) return const SizedBox.shrink();

            return Positioned(
              left: obj.x * constraints.maxWidth - 25,
              top: obj.y * constraints.maxHeight - 25,
              child: GestureDetector(
                onTap: () => _onObjectTap(obj),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: obj.isTarget
                        ? Colors.greenAccent.withOpacity(0.3)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      obj.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLevelComplete(bool isDark) {
    final totalTargets = _objects.where((o) => o.isTarget).length;
    final accuracy = totalTargets > 0
        ? (_caught / totalTargets * 100).round()
        : 0;
    final isLastLevel = _currentLevel >= 3;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? []
              : [
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
              '🎉 레벨 ${_currentLevel + 1} 클리어!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('잡은 수', '$_caught', Colors.green, isDark),
                _buildStatItem('정확도', '$accuracy%', Colors.blue, isDark),
                _buildStatItem('오답', '$_wrongCatch', Colors.red, isDark),
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
                    backgroundColor: isDark ? Colors.white24 : Colors.grey[200],
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: isLastLevel
                      ? () => widget.onComplete?.call()
                      : _nextLevel,
                  icon: Icon(isLastLevel ? Icons.check : Icons.arrow_forward),
                  label: Text(isLastLevel ? '완료' : '다음 레벨'),
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
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
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
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

