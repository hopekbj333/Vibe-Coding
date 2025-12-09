import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.4.4: 거꾸로 터치 게임
/// 순서대로 불빛이 켜진 후, 거꾸로 터치
class ReverseTouchGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const ReverseTouchGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<ReverseTouchGame> createState() => _ReverseTouchGameState();
}

class _ReverseTouchGameState extends State<ReverseTouchGame>
    with TickerProviderStateMixin {
  static const List<Color> _buttonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.cyan,
  ];

  int _currentRound = 0;
  final int _totalRounds = 8;
  int _score = 0;
  int _sequenceLength = 2; // 시작: 2개

  List<int> _sequence = [];
  List<int> _userInput = [];
  int _highlightedButton = -1;
  int _currentPlayIndex = -1; // 현재 재생 중인 시퀀스 위치

  bool _isPlaying = false;
  bool _isUserTurn = false;
  bool _showFeedback = false;
  bool _isCorrect = false;

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
    _startRound();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startRound() {
    // 난이도 조절
    if (_currentRound < 2) {
      _sequenceLength = 2;
    } else if (_currentRound < 5) {
      _sequenceLength = 3;
    } else {
      _sequenceLength = 4;
    }

    // 시퀀스 생성
    _sequence = List.generate(
      _sequenceLength,
      (_) => _random.nextInt(_buttonColors.length),
    );
    _userInput = [];
    _isUserTurn = false;
    _showFeedback = false;

    setState(() {});

    // 시퀀스 재생 시작
    Future.delayed(const Duration(milliseconds: 500), _playSequence);
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlaying = true;
      _highlightedButton = -1;
      _currentPlayIndex = -1;
    });

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _currentPlayIndex = i;
        _highlightedButton = _sequence[i];
      });

      _glowController.forward();

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      _glowController.reverse();

      setState(() {
        _highlightedButton = -1;
      });
    }

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _isUserTurn = true;
      _currentPlayIndex = -1;
    });
  }

  void _onButtonTap(int index) {
    if (!_isUserTurn || _showFeedback) return;

    setState(() {
      _userInput.add(index);
      _highlightedButton = index;
    });

    _glowController.forward().then((_) {
      if (mounted) {
        _glowController.reverse();
        setState(() {
          _highlightedButton = -1;
        });
      }
    });

    // 역순 확인
    final reversedSequence = _sequence.reversed.toList();
    final currentIndex = _userInput.length - 1;

    if (_userInput[currentIndex] != reversedSequence[currentIndex]) {
      // 틀림
      _showResult(false);
    } else if (_userInput.length == _sequence.length) {
      // 완료 - 정답
      _showResult(true);
    }
  }

  void _showResult(bool correct) {
    setState(() {
      _showFeedback = true;
      _isCorrect = correct;
      _isUserTurn = false;

      if (correct) {
        _score++;
      }
    });

    widget.onScoreUpdate?.call(_score, _currentRound + 1);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      _currentRound++;

      if (_currentRound >= _totalRounds) {
        widget.onComplete?.call();
      } else {
        _startRound();
      }
    });
  }

  void _replaySequence() {
    if (_isPlaying || !_isUserTurn) return;

    setState(() {
      _userInput = [];
    });

    _playSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('🔄 거꾸로 터치'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '점수: $_score / ${_currentRound + 1}',
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

            // 상태 메시지
            _buildStatusMessage(),

            // 버튼 그리드
            Expanded(child: _buildButtonGrid()),

            // 순서 표시
            _buildSequenceIndicator(),

            // 피드백
            if (_showFeedback) _buildFeedback(),

            // 다시 듣기 버튼
            if (_isUserTurn && !_showFeedback) _buildReplayButton(),

            const SizedBox(height: 20),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4EFF), Color(0xFF9D4EDD)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_sequenceLength개 역순',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4EFF)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    String message;
    Color color;

    if (_isPlaying) {
      message = '👀 순서를 잘 보세요!';
      color = Colors.amber;
    } else if (_isUserTurn) {
      final remaining = _sequence.length - _userInput.length;
      message = '🔄 거꾸로 터치! ($remaining개 남음)';
      color = Colors.white;
    } else if (_showFeedback) {
      message = _isCorrect ? '🎉 완벽한 역순!' : '다시 도전!';
      color = _isCorrect ? Colors.greenAccent : Colors.redAccent;
    } else {
      message = '준비 중...';
      color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _buttonColors.length,
          itemBuilder: (context, index) {
            return _buildColorButton(index);
          },
        ),
      ),
    );
  }

  Widget _buildColorButton(int index) {
    final color = _buttonColors[index];
    final isHighlighted = _highlightedButton == index;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isHighlighted ? _glowAnimation.value : 0.0;

        return GestureDetector(
          onTap: () => _onButtonTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: Color.lerp(
                color.withOpacity(0.3),
                color,
                glowIntensity,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted ? Colors.white : color.withOpacity(0.5),
                width: isHighlighted ? 3 : 2,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSequenceIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _isPlaying ? '보여주는 순서' : '거꾸로 입력',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_sequence.length, (index) {
              final displayIndex = _isUserTurn
                  ? _sequence.length - 1 - index
                  : index;
              final color = _buttonColors[_sequence[displayIndex]];
              final isCompleted = _isUserTurn && index < _userInput.length;
              final isCurrent = _isPlaying && index <= _currentPlayIndex;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? color
                      : isCurrent
                          ? color.withOpacity(0.7)
                          : _isPlaying
                              ? color.withOpacity(0.3)
                              : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted || isCurrent ? color : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCompleted || isCurrent ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    final reversedSequence = _sequence.reversed.toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect
            ? Colors.greenAccent.withOpacity(0.2)
            : Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.info_outline,
                color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? '정답!' : '정답은...',
                style: TextStyle(
                  color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: reversedSequence.map((colorIndex) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _buttonColors[colorIndex],
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _replaySequence,
        icon: const Icon(Icons.replay),
        label: const Text('다시 보기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white24,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

