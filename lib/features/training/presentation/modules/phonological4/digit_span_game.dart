import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 숫자 폭 확장 게임 (S 3.1.7)
/// 
/// 숫자 시퀀스 듣고 순서대로 터치
/// 점점 길어지는 시퀀스로 기억 폭 훈련
class DigitSpanGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const DigitSpanGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<DigitSpanGame> createState() => _DigitSpanGameState();
}

class _DigitSpanGameState extends State<DigitSpanGame>
    with TickerProviderStateMixin {
  int _currentLevel = 2; // 시작 레벨 (2개 숫자)
  int _maxLevelReached = 2;
  int _correctStreakAtLevel = 0;
  int _totalCorrect = 0;
  int _totalAttempts = 0;

  List<int> _currentSequence = [];
  List<int> _userInput = [];
  bool _isPlaying = false;
  bool _isInputPhase = false;
  bool _showResult = false;
  bool _isCorrect = false;
  int _playingIndex = -1;

  late AnimationController _highlightController;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _generateSequence();
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  void _generateSequence() {
    final random = Random();
    _currentSequence = List.generate(
      _currentLevel,
      (_) => random.nextInt(9) + 1, // 1-9
    );
    _userInput = [];
    _isInputPhase = false;
    _showResult = false;
    _playingIndex = -1;
  }

  Future<void> _playSequence() async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _userInput = [];
    });

    // 각 숫자를 순서대로 재생
    for (int i = 0; i < _currentSequence.length; i++) {
      if (!mounted) return;

      setState(() {
        _playingIndex = i;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _playingIndex = -1;
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isInputPhase = true;
      });
    }
  }

  void _onNumberTap(int number) {
    if (!_isInputPhase || _showResult) return;

    setState(() {
      _userInput.add(number);
    });

    // 모든 숫자를 입력했으면 정답 확인
    if (_userInput.length == _currentSequence.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    bool correct = true;
    for (int i = 0; i < _currentSequence.length; i++) {
      if (_userInput[i] != _currentSequence[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      _showResult = true;
      _isCorrect = correct;
      _isInputPhase = false;
      _totalAttempts++;
    });

    if (correct) {
      _totalCorrect++;
      _correctStreakAtLevel++;

      // 2번 연속 성공하면 레벨 업
      if (_correctStreakAtLevel >= 2) {
        _currentLevel++;
        _correctStreakAtLevel = 0;
        if (_currentLevel > _maxLevelReached) {
          _maxLevelReached = _currentLevel;
        }
      }
    } else {
      _correctStreakAtLevel = 0;
      // 레벨 다운 (최소 2)
      if (_currentLevel > 2) {
        _currentLevel--;
      }
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      if (_totalAttempts >= 10) {
        _showResultDialog();
      } else {
        _generateSequence();
        setState(() {});
      }
    });
  }

  void _showResultDialog() {
    final accuracy = (_totalCorrect / _totalAttempts * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🏆 게임 완료!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '최고 기록: $_maxLevelReached자리',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('정답', '$_totalCorrect/$_totalAttempts'),
                _buildStatItem('정확도', '$accuracy%'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _maxLevelReached >= 5
                  ? '기억력 챔피언! 🌟'
                  : _maxLevelReached >= 4
                      ? '잘했어요! 👏'
                      : '더 연습하면 늘어요! 💪',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('나가기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentLevel = 2;
                _maxLevelReached = 2;
                _correctStreakAtLevel = 0;
                _totalCorrect = 0;
                _totalAttempts = 0;
                _generateSequence();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('다시 하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    widget.onComplete?.call();
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DesignSystem.primaryBlue,
          ),
        ),
        Text(label, style: const TextStyle(color: DesignSystem.neutralGray500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('숫자 기억하기'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '최고: $_maxLevelReached자리',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 레벨 표시
                _buildLevelIndicator(),
                const SizedBox(height: 24),

                // 시퀀스 표시 영역
                _buildSequenceDisplay(),
                const SizedBox(height: 24),

                // 상태 메시지
                _buildStatusMessage(),
                const SizedBox(height: 24),

                // 숫자 패드
                Expanded(child: _buildNumberPad()),

                // 컨트롤 버튼
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '현재: $_currentLevel자리',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${_totalAttempts + 1}/10',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSequenceDisplay() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_currentSequence.length, (index) {
          final isHighlighted = _playingIndex == index;
          final isUserInput = _isInputPhase && index < _userInput.length;
          final showNumber = _isPlaying && isHighlighted;
          final showUserNumber = isUserInput;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.blue
                  : showUserNumber
                      ? (_showResult
                          ? (_userInput[index] == _currentSequence[index]
                              ? Colors.green.shade100
                              : Colors.red.shade100)
                          : Colors.blue.shade100)
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted
                    ? Colors.blue.shade700
                    : showUserNumber
                        ? Colors.blue
                        : Colors.grey.shade400,
                width: 2,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                showNumber
                    ? '${_currentSequence[index]}'
                    : showUserNumber
                        ? '${_userInput[index]}'
                        : '',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? Colors.white : Colors.blue.shade700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusMessage() {
    String message;
    IconData icon;
    Color color;

    if (_showResult) {
      message = _isCorrect ? '정답! 👏' : '다시 도전해봐요!';
      icon = _isCorrect ? Icons.check_circle : Icons.refresh;
      color = _isCorrect ? Colors.green : Colors.orange;
    } else if (_isPlaying) {
      message = '숫자를 잘 기억하세요!';
      icon = Icons.hearing;
      color = Colors.blue;
    } else if (_isInputPhase) {
      message = '순서대로 터치하세요!';
      icon = Icons.touch_app;
      color = Colors.purple;
    } else {
      message = '듣기 버튼을 누르세요';
      icon = Icons.play_circle;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final number = index + 1;
        return _buildNumberButton(number);
      },
    );
  }

  Widget _buildNumberButton(int number) {
    final isDisabled = !_isInputPhase || _showResult;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onNumberTap(number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade300 : Colors.blue,
            width: 2,
          ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey : Colors.blue.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: (_isPlaying || _isInputPhase || _showResult) ? null : _playSequence,
          icon: const Icon(Icons.volume_up),
          label: const Text('듣기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}

