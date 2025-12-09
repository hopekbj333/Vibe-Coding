import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.3.3: 숨은 글자 찾기 게임
/// 복잡한 배경에서 특정 글자/도형 찾기
class HiddenLetterGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const HiddenLetterGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<HiddenLetterGame> createState() => _HiddenLetterGameState();
}

class _HiddenLetterQuestion {
  final String target; // 찾을 글자
  final List<String> grid; // 그리드 내 글자들
  final List<int> targetIndices; // 타겟 위치들

  const _HiddenLetterQuestion({
    required this.target,
    required this.grid,
    required this.targetIndices,
  });
}

class _HiddenLetterGameState extends State<HiddenLetterGame> {
  static final List<_HiddenLetterQuestion> _questions = [
    // 쉬움: 큰 그리드, 뚜렷한 차이
    _HiddenLetterQuestion(
      target: '가',
      grid: ['나', '가', '다', '라', '마', '바', '가', '사', '아', '가', '자', '가'],
      targetIndices: [1, 6, 9, 11],
    ),
    _HiddenLetterQuestion(
      target: '★',
      grid: ['☆', '★', '☆', '☆', '★', '☆', '☆', '☆', '★', '☆', '★', '☆'],
      targetIndices: [1, 4, 8, 10],
    ),
    // 보통: 비슷한 글자들
    _HiddenLetterQuestion(
      target: 'ㄱ',
      grid: ['ㄴ', 'ㄱ', 'ㄴ', 'ㄴ', 'ㄴ', 'ㄱ', 'ㄴ', 'ㄱ', 'ㄴ', 'ㄴ', 'ㄴ', 'ㄱ', 'ㄴ', 'ㄴ', 'ㄱ', 'ㄴ'],
      targetIndices: [1, 5, 7, 11, 14],
    ),
    _HiddenLetterQuestion(
      target: '6',
      grid: ['9', '6', '9', '9', '6', '9', '9', '9', '6', '9', '6', '9', '9', '9', '6', '9'],
      targetIndices: [1, 4, 8, 10, 14],
    ),
    // 어려움: 더 많은 글자
    _HiddenLetterQuestion(
      target: '강',
      grid: ['강', '장', '방', '강', '황', '장', '강', '방', '황', '강', '방', '장', '강', '황', '장', '방', '강', '황', '장', '강'],
      targetIndices: [0, 3, 6, 9, 12, 16, 19],
    ),
    _HiddenLetterQuestion(
      target: '●',
      grid: ['○', '●', '○', '◐', '○', '●', '◐', '○', '●', '○', '◐', '○', '●', '○', '◐', '●', '○', '●', '◐', '○'],
      targetIndices: [1, 5, 8, 12, 15, 17],
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  int _timeLeft = 30;
  Timer? _timer;
  
  Set<int> _foundTargets = {};
  Set<int> _wrongTaps = {};
  bool _showFeedback = false;
  bool _isCorrect = false;
  
  final Random _random = Random();
  late List<_HiddenLetterQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _HiddenLetterQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _foundTargets = {};
    _wrongTaps = {};
    _showFeedback = false;
    
    // 난이도에 따른 시간 설정
    if (_currentQuestion < 2) {
      _timeLeft = 30;
    } else if (_currentQuestion < 4) {
      _timeLeft = 25;
    } else {
      _timeLeft = 20;
    }
    
    setState(() {});
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _timeLeft--;
      });
      
      if (_timeLeft <= 0) {
        timer.cancel();
        _showResult(false);
      }
    });
  }

  void _onCellTap(int index) {
    if (_showFeedback) return;
    
    if (_foundTargets.contains(index) || _wrongTaps.contains(index)) {
      return; // 이미 터치한 셀
    }
    
    if (_question.targetIndices.contains(index)) {
      // 정답!
      setState(() {
        _foundTargets.add(index);
      });
      
      // 모두 찾았는지 확인
      if (_foundTargets.length == _question.targetIndices.length) {
        _timer?.cancel();
        _showResult(true);
      }
    } else {
      // 오답
      setState(() {
        _wrongTaps.add(index);
        _timeLeft = max(0, _timeLeft - 2); // 시간 패널티
      });
    }
  }

  void _showResult(bool allFound) {
    setState(() {
      _showFeedback = true;
      _isCorrect = allFound;
      
      if (allFound) {
        _score++;
      }
    });
    
    widget.onScoreUpdate?.call(_score, _currentQuestion + 1);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      _currentQuestion++;
      
      if (_currentQuestion >= _shuffledQuestions.length) {
        widget.onComplete?.call();
      } else {
        _startQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('🔎 숨은 글자 찾기'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: _timeLeft <= 5 ? Colors.red[200] : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_timeLeft}초',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 5 ? Colors.red[200] : Colors.white,
                    ),
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
            // 진행 표시
            _buildProgressBar(),
            
            // 타겟 표시
            _buildTargetDisplay(),
            
            // 찾은 개수 표시
            _buildFoundCount(),
            
            // 그리드
            Expanded(child: _buildGrid()),
            
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
              Text(
                '문제 ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                '점수: $_score',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _shuffledQuestions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[100]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '찾아야 할 글자: ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Text(
              _question.target,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundCount() {
    final total = _question.targetIndices.length;
    final found = _foundTargets.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(total, (index) {
            final isFound = index < found;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isFound ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isFound ? Colors.green : Colors.grey[400],
                size: 28,
              ),
            );
          }),
          const SizedBox(width: 12),
          Text(
            '$found / $total',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final grid = _question.grid;
    final crossAxisCount = grid.length <= 12 ? 4 : 5;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: grid.length,
        itemBuilder: (context, index) {
          return _buildCell(index);
        },
      ),
    );
  }

  Widget _buildCell(int index) {
    final letter = _question.grid[index];
    final isTarget = _question.targetIndices.contains(index);
    final isFound = _foundTargets.contains(index);
    final isWrong = _wrongTaps.contains(index);
    
    Color backgroundColor;
    Color borderColor;
    
    if (isFound) {
      backgroundColor = Colors.green[100]!;
      borderColor = Colors.green;
    } else if (isWrong) {
      backgroundColor = Colors.red[100]!;
      borderColor = Colors.red;
    } else if (_showFeedback && isTarget) {
      // 피드백 시 못 찾은 타겟 표시
      backgroundColor = Colors.amber[100]!;
      borderColor = Colors.amber;
    } else {
      backgroundColor = Colors.grey[100]!;
      borderColor = Colors.grey[300]!;
    }
    
    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isFound || isWrong || (_showFeedback && isTarget) ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: _question.grid.length <= 12 ? 28 : 22,
              fontWeight: FontWeight.bold,
              color: isFound
                  ? Colors.green[700]
                  : isWrong
                      ? Colors.red[700]
                      : Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final found = _foundTargets.length;
    final total = _question.targetIndices.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.celebration : Icons.timer_off,
            color: _isCorrect ? Colors.green : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect
                ? '🎉 모두 찾았어요!'
                : '⏰ 시간 초과! ($found/$total 발견)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }
}

