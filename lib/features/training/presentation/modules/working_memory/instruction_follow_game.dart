import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.4.3: 지시 따르기 게임
/// 여러 단계 지시를 듣고 순서대로 수행
class InstructionFollowGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const InstructionFollowGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<InstructionFollowGame> createState() => _InstructionFollowGameState();
}

class _GameItem {
  final String emoji;
  final String color;
  final String shape;
  final Color colorValue;

  const _GameItem({
    required this.emoji,
    required this.color,
    required this.shape,
    required this.colorValue,
  });
}

class _Instruction {
  final List<int> targetIndices; // 터치해야 할 아이템 인덱스들 (순서대로)
  final String description;

  const _Instruction({
    required this.targetIndices,
    required this.description,
  });
}

class _InstructionFollowGameState extends State<InstructionFollowGame> {
  static const List<_GameItem> _allItems = [
    _GameItem(emoji: '⭐', color: '빨간', shape: '별', colorValue: Colors.red),
    _GameItem(emoji: '⭐', color: '파란', shape: '별', colorValue: Colors.blue),
    _GameItem(emoji: '⭐', color: '초록', shape: '별', colorValue: Colors.green),
    _GameItem(emoji: '●', color: '빨간', shape: '원', colorValue: Colors.red),
    _GameItem(emoji: '●', color: '파란', shape: '원', colorValue: Colors.blue),
    _GameItem(emoji: '●', color: '초록', shape: '원', colorValue: Colors.green),
    _GameItem(emoji: '■', color: '빨간', shape: '네모', colorValue: Colors.red),
    _GameItem(emoji: '■', color: '파란', shape: '네모', colorValue: Colors.blue),
    _GameItem(emoji: '■', color: '초록', shape: '네모', colorValue: Colors.green),
  ];

  int _currentRound = 0;
  final int _totalRounds = 8;
  int _score = 0;
  int _currentStepIndex = 0;

  List<_GameItem> _displayItems = [];
  _Instruction? _currentInstruction;
  List<int> _userTaps = [];

  bool _showInstruction = true;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _difficulty = 1; // 1, 2, 3단계 지시

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    // 난이도 설정
    if (_currentRound < 3) {
      _difficulty = 1;
    } else if (_currentRound < 6) {
      _difficulty = 2;
    } else {
      _difficulty = 3;
    }

    // 표시할 아이템 선택 (6개)
    _displayItems = List.from(_allItems)..shuffle(_random);
    _displayItems = _displayItems.take(6).toList();

    // 지시 생성
    _currentInstruction = _generateInstruction();
    _userTaps = [];
    _currentStepIndex = 0;
    _showInstruction = true;
    _showFeedback = false;

    setState(() {});

    // 지시 읽기 시간
    Future.delayed(Duration(seconds: 2 + _difficulty), () {
      if (mounted) {
        setState(() {
          _showInstruction = false;
        });
      }
    });
  }

  _Instruction _generateInstruction() {
    final targets = <int>[];
    final descriptions = <String>[];

    for (int i = 0; i < _difficulty; i++) {
      int targetIndex;
      do {
        targetIndex = _random.nextInt(_displayItems.length);
      } while (targets.contains(targetIndex));

      targets.add(targetIndex);
      final item = _displayItems[targetIndex];
      descriptions.add('${item.color} ${item.shape}');
    }

    String fullDescription;
    if (_difficulty == 1) {
      fullDescription = '${descriptions[0]}을 터치하세요';
    } else if (_difficulty == 2) {
      fullDescription = '${descriptions[0]}을 터치하고,\n${descriptions[1]}을 터치하세요';
    } else {
      fullDescription = '${descriptions[0]},\n${descriptions[1]},\n${descriptions[2]}을\n순서대로 터치하세요';
    }

    return _Instruction(
      targetIndices: targets,
      description: fullDescription,
    );
  }

  void _onItemTap(int index) {
    if (_showInstruction || _showFeedback) return;
    if (_currentInstruction == null) return;

    final expectedIndex = _currentInstruction!.targetIndices[_currentStepIndex];

    if (index == expectedIndex) {
      // 정답!
      setState(() {
        _userTaps.add(index);
        _currentStepIndex++;
      });

      // 모든 단계 완료 확인
      if (_currentStepIndex >= _currentInstruction!.targetIndices.length) {
        _handleSuccess();
      }
    } else {
      // 오답!
      _handleFailure();
    }
  }

  void _handleSuccess() {
    setState(() {
      _showFeedback = true;
      _isCorrect = true;
      _score++;
    });

    widget.onScoreUpdate?.call(_score, _currentRound + 1);

    Future.delayed(const Duration(seconds: 2), _nextRound);
  }

  void _handleFailure() {
    setState(() {
      _showFeedback = true;
      _isCorrect = false;
    });

    widget.onScoreUpdate?.call(_score, _currentRound + 1);

    Future.delayed(const Duration(seconds: 2), _nextRound);
  }

  void _nextRound() {
    if (!mounted) return;

    _currentRound++;

    if (_currentRound >= _totalRounds) {
      widget.onComplete?.call();
    } else {
      _startRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text('📝 지시 따르기'),
        backgroundColor: Colors.indigo,
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

            // 지시 또는 상태 표시
            _buildInstructionOrStatus(),

            // 아이템 그리드
            Expanded(child: _buildItemGrid()),

            // 피드백
            if (_showFeedback) _buildFeedback(),

            const SizedBox(height: 16),
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
                  color: Colors.indigo[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_difficulty단계 지시',
                  style: TextStyle(
                    color: Colors.indigo[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${_currentRound + 1} / $_totalRounds',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentRound + 1) / _totalRounds,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionOrStatus() {
    if (_showInstruction) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[100]!, Colors.indigo[50]!],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo[200]!),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hearing, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  '잘 들어보세요!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentInstruction?.description ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    // 진행 상태 표시
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            '${_currentStepIndex + 1}번째 터치! (${_difficulty - _currentStepIndex}개 남음)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _displayItems.length,
        itemBuilder: (context, index) {
          return _buildItem(index);
        },
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _displayItems[index];
    final isTapped = _userTaps.contains(index);
    final isNextTarget = !_showInstruction && 
        !_showFeedback &&
        _currentInstruction != null &&
        _currentStepIndex < _currentInstruction!.targetIndices.length &&
        index == _currentInstruction!.targetIndices[_currentStepIndex];

    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isTapped ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTapped
                ? Colors.green
                : _showInstruction
                    ? Colors.grey[300]!
                    : item.colorValue,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              item.emoji,
              style: TextStyle(
                fontSize: 40,
                color: item.colorValue,
              ),
            ),
            if (isTapped)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_userTaps.indexOf(index) + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildFeedback() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect ? '🎉 지시를 잘 따랐어요!' : '다시 도전해요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}

