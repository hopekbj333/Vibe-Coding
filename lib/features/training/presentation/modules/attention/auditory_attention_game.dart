import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.5.3: 청각 선택 주의 게임
/// 여러 소리가 겹쳐 나올 때 특정 소리만 찾기
/// (실제 소리 대신 시각적 시뮬레이션 + 텍스트로 구현)
class AuditoryAttentionGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const AuditoryAttentionGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<AuditoryAttentionGame> createState() => _AuditoryAttentionGameState();
}

class _AuditoryAttentionGameState extends State<AuditoryAttentionGame>
    with TickerProviderStateMixin {
  // 소리 종류
  static const Map<String, String> _sounds = {
    '딩': '🔔',
    '뿅': '✨',
    '뚝': '💧',
    '쿵': '🥁',
    '띵동': '🚪',
  };

  String _targetSound = '딩';
  String _targetEmoji = '🔔';

  int _currentRound = 0;
  final int _totalRounds = 15;
  int _score = 0;
  int _hits = 0;
  int _misses = 0;
  int _falseAlarms = 0;

  String _currentSound = '';
  String _currentEmoji = '';
  bool _showSound = false;
  bool _canTap = false;
  bool _tapped = false;
  bool _showFeedback = false;
  bool _wasCorrect = false;

  List<String> _backgroundSounds = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _roundTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // 목표 소리 설정
    final soundKeys = _sounds.keys.toList();
    _targetSound = soundKeys[_random.nextInt(soundKeys.length)];
    _targetEmoji = _sounds[_targetSound]!;

    _startGame();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _playNextSound();
  }

  void _playNextSound() {
    if (_currentRound >= _totalRounds) {
      widget.onComplete?.call();
      return;
    }

    // 목표 소리인지 결정 (약 30% 확률)
    final isTarget = _random.nextDouble() < 0.3;

    if (isTarget) {
      _currentSound = _targetSound;
      _currentEmoji = _targetEmoji;
    } else {
      // 목표가 아닌 다른 소리 선택
      final otherSounds = _sounds.entries
          .where((e) => e.key != _targetSound)
          .toList();
      final selected = otherSounds[_random.nextInt(otherSounds.length)];
      _currentSound = selected.key;
      _currentEmoji = selected.value;
    }

    // 배경 소리 (난이도에 따라)
    _backgroundSounds = [];
    if (_currentRound >= 5) {
      _backgroundSounds.add('🎵');
    }
    if (_currentRound >= 10) {
      _backgroundSounds.addAll(['🎶', '🎼']);
    }

    _tapped = false;
    _showFeedback = false;

    setState(() {
      _showSound = true;
      _canTap = true;
    });

    _pulseController.forward(from: 0);

    // 반응 시간 제한
    _roundTimer = Timer(const Duration(milliseconds: 1500), () {
      _checkMissedTarget(isTarget);
    });
  }

  void _checkMissedTarget(bool isTarget) {
    if (!mounted) return;

    if (isTarget && !_tapped) {
      // 목표 소리였는데 안 눌렀음
      setState(() {
        _misses++;
        _showFeedback = true;
        _wasCorrect = false;
      });
    } else if (!isTarget && !_tapped) {
      // 목표 아닌 소리였고 안 눌렀음 - 정답
      _score += 5;
    }

    _nextRound();
  }

  void _onTap() {
    if (!_canTap || _tapped) return;

    _roundTimer?.cancel();
    _tapped = true;
    _canTap = false;

    final isTarget = _currentSound == _targetSound;

    setState(() {
      _showFeedback = true;

      if (isTarget) {
        // 맞게 탭!
        _hits++;
        _score += 10;
        _wasCorrect = true;
      } else {
        // 틀리게 탭
        _falseAlarms++;
        _wasCorrect = false;
      }
    });

    widget.onScoreUpdate?.call(_score, _currentRound + 1);

    Future.delayed(const Duration(milliseconds: 800), _nextRound);
  }

  void _nextRound() {
    if (!mounted) return;

    setState(() {
      _showSound = false;
      _currentRound++;
    });

    if (_currentRound >= _totalRounds) {
      widget.onComplete?.call();
    } else {
      Future.delayed(const Duration(milliseconds: 500), _playNextSound);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(
        title: const Text('👂 소리 찾기'),
        backgroundColor: Colors.blueGrey[800],
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

              // 목표 소리 안내
              _buildTargetInfo(),

              // 소리 표시 영역
              Expanded(child: _buildSoundDisplay()),

              // 피드백
              if (_showFeedback) _buildFeedback(),

              // 탭 안내
              _buildTapInstruction(),

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
              Text(
                '맞음: $_hits  놓침: $_misses  잘못 누름: $_falseAlarms',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${_currentRound + 1} / $_totalRounds',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentRound + 1) / _totalRounds,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _targetEmoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            '"$_targetSound" 소리가 나면 터치!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 배경 소리 표시
          if (_backgroundSounds.isNotEmpty && _showSound)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _backgroundSounds
                  .map((s) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 20),
          // 현재 소리
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _showSound ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _showSound
                        ? (_currentSound == _targetSound
                            ? Colors.cyan.withOpacity(0.3)
                            : Colors.white10)
                        : Colors.white10,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _showSound
                          ? Colors.white54
                          : Colors.white24,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: _showSound
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentEmoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentSound,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.volume_off,
                            size: 48,
                            color: Colors.white24,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _wasCorrect
            ? Colors.greenAccent.withOpacity(0.2)
            : Colors.redAccent.withOpacity(0.2),
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
            _wasCorrect
                ? '정답!'
                : (_currentSound == _targetSound ? '놓쳤어요!' : '목표 소리가 아니에요!'),
            style: TextStyle(
              color: _wasCorrect ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapInstruction() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _canTap ? Icons.touch_app : Icons.hourglass_empty,
            color: _canTap ? Colors.cyan : Colors.white38,
          ),
          const SizedBox(width: 8),
          Text(
            _canTap ? '화면을 터치하세요!' : '다음 소리를 기다리세요...',
            style: TextStyle(
              fontSize: 16,
              color: _canTap ? Colors.white : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

