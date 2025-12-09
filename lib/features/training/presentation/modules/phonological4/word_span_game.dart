import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 단어 폭 확장 게임 (S 3.1.8)
/// 
/// 단어 시퀀스 듣고 해당 그림 순서대로 터치
/// 스토리텔링: "마트에서 사야 할 것들"
class WordSpanGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const WordSpanGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<WordSpanGame> createState() => _WordSpanGameState();
}

class _WordSpanGameState extends State<WordSpanGame>
    with TickerProviderStateMixin {
  int _currentLevel = 2;
  int _maxLevelReached = 2;
  int _correctStreakAtLevel = 0;
  int _totalCorrect = 0;
  int _totalAttempts = 0;

  List<_WordItem> _currentSequence = [];
  List<_WordItem> _availableItems = [];
  List<_WordItem> _userInput = [];
  bool _isPlaying = false;
  bool _isInputPhase = false;
  bool _showResult = false;
  bool _isCorrect = false;
  int _playingIndex = -1;

  final List<_WordItem> _allItems = [
    _WordItem('사과', '🍎'),
    _WordItem('바나나', '🍌'),
    _WordItem('우유', '🥛'),
    _WordItem('빵', '🍞'),
    _WordItem('달걀', '🥚'),
    _WordItem('치즈', '🧀'),
    _WordItem('당근', '🥕'),
    _WordItem('토마토', '🍅'),
    _WordItem('포도', '🍇'),
    _WordItem('수박', '🍉'),
    _WordItem('아이스크림', '🍦'),
    _WordItem('주스', '🧃'),
  ];

  @override
  void initState() {
    super.initState();
    _generateSequence();
  }

  void _generateSequence() {
    final random = Random();
    final shuffled = List<_WordItem>.from(_allItems)..shuffle(random);

    // 현재 레벨에 맞는 개수만큼 시퀀스 생성
    _currentSequence = shuffled.take(_currentLevel).toList();

    // 선택지는 시퀀스 + 방해 아이템 (최대 8개)
    final extraCount = (8 - _currentLevel).clamp(2, 6);
    final extraItems = shuffled.skip(_currentLevel).take(extraCount).toList();
    _availableItems = [..._currentSequence, ...extraItems]..shuffle(random);

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

    for (int i = 0; i < _currentSequence.length; i++) {
      if (!mounted) return;

      setState(() {
        _playingIndex = i;
      });

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      setState(() {
        _playingIndex = -1;
      });

      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isInputPhase = true;
      });
    }
  }

  void _onItemTap(_WordItem item) {
    if (!_isInputPhase || _showResult) return;
    if (_userInput.contains(item)) return; // 이미 선택된 아이템

    setState(() {
      _userInput.add(item);
    });

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

      if (_correctStreakAtLevel >= 2 && _currentLevel < 6) {
        _currentLevel++;
        _correctStreakAtLevel = 0;
        if (_currentLevel > _maxLevelReached) {
          _maxLevelReached = _currentLevel;
        }
      }
    } else {
      _correctStreakAtLevel = 0;
      if (_currentLevel > 2) {
        _currentLevel--;
      }
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      if (_totalAttempts >= 8) {
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
        title: const Text('🛒 장보기 완료!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '최고 기록: $_maxLevelReached개',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('성공', '$_totalCorrect/$_totalAttempts'),
                _buildStatItem('정확도', '$accuracy%'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _maxLevelReached >= 5
                  ? '장보기 달인! 🌟'
                  : _maxLevelReached >= 4
                      ? '잘했어요! 👏'
                      : '연습하면 더 잘할 수 있어요! 💪',
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
              backgroundColor: Colors.orange,
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
            color: Colors.orange,
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
        title: const Text('장보기 게임'),
        backgroundColor: Colors.orange.shade400,
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
                  '최고: $_maxLevelReached개',
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
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 스토리 텍스트
                _buildStoryText(),
                const SizedBox(height: 16),

                // 시퀀스 표시
                _buildSequenceDisplay(),
                const SizedBox(height: 16),

                // 상태 메시지
                _buildStatusMessage(),
                const SizedBox(height: 16),

                // 아이템 그리드
                Expanded(child: _buildItemGrid()),

                // 컨트롤
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🛒', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '엄마의 심부름',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_totalAttempts + 1}/8 번째 심부름',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_currentLevel개',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceDisplay() {
    if (!_isPlaying && !_showResult && _userInput.isEmpty) {
      return const SizedBox(height: 80);
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_currentSequence.length, (index) {
          final isHighlighted = _playingIndex == index;
          final hasUserInput = index < _userInput.length;
          final item = _isPlaying && isHighlighted
              ? _currentSequence[index]
              : hasUserInput
                  ? _userInput[index]
                  : null;

          Color bgColor = Colors.grey.shade200;
          Color borderColor = Colors.grey.shade400;

          if (isHighlighted) {
            bgColor = Colors.orange.shade100;
            borderColor = Colors.orange;
          } else if (_showResult && hasUserInput) {
            final isCorrectItem = _userInput[index] == _currentSequence[index];
            bgColor = isCorrectItem ? Colors.green.shade100 : Colors.red.shade100;
            borderColor = isCorrectItem ? Colors.green : Colors.red;
          } else if (hasUserInput) {
            bgColor = Colors.orange.shade50;
            borderColor = Colors.orange.shade300;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 60,
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: item != null
                  ? Text(item.emoji, style: const TextStyle(fontSize: 32))
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
      message = _isCorrect ? '완벽해요! 🎉' : '순서가 달라요!';
      icon = _isCorrect ? Icons.check_circle : Icons.refresh;
      color = _isCorrect ? Colors.green : Colors.orange;
    } else if (_isPlaying) {
      message = '사야 할 것들을 기억하세요!';
      icon = Icons.hearing;
      color = Colors.orange;
    } else if (_isInputPhase) {
      message = '순서대로 터치하세요! (${_userInput.length}/${_currentSequence.length})';
      icon = Icons.touch_app;
      color = Colors.purple;
    } else {
      message = '듣기 버튼을 눌러 시작하세요';
      icon = Icons.play_circle;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _availableItems.length,
      itemBuilder: (context, index) {
        final item = _availableItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(_WordItem item) {
    final isSelected = _userInput.contains(item);
    final isDisabled = !_isInputPhase || _showResult || isSelected;
    final selectionOrder = _userInput.indexOf(item);

    return GestureDetector(
      onTap: isDisabled ? null : () => _onItemTap(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.shade100
              : isDisabled
                  ? Colors.grey.shade100
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.orange
                : isDisabled
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
            width: 2,
          ),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.emoji,
                  style: TextStyle(
                    fontSize: 32,
                    color: isDisabled && !isSelected
                        ? Colors.grey.withOpacity(0.5)
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.word,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.orange.shade700
                        : isDisabled
                            ? Colors.grey
                            : DesignSystem.neutralGray800,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  child: Center(
                    child: Text(
                      '${selectionOrder + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: (_isPlaying || _isInputPhase || _showResult) ? null : _playSequence,
        icon: const Icon(Icons.volume_up),
        label: const Text('듣기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class _WordItem {
  final String word;
  final String emoji;

  _WordItem(this.word, this.emoji);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WordItem && word == other.word;

  @override
  int get hashCode => word.hashCode;
}

