import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.4.5: 거꾸로 말하기 게임
/// 단어/숫자 듣고 거꾸로 말하기 (간소화된 버전 - 객관식)
class ReverseSpeakGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const ReverseSpeakGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<ReverseSpeakGame> createState() => _ReverseSpeakGameState();
}

class _ReverseSpeakQuestion {
  final List<String> sequence;
  final List<String> reversed;
  final List<List<String>> options;
  final int correctIndex;

  const _ReverseSpeakQuestion({
    required this.sequence,
    required this.reversed,
    required this.options,
    required this.correctIndex,
  });
}

class _ReverseSpeakGameState extends State<ReverseSpeakGame>
    with TickerProviderStateMixin {
  static final List<_ReverseSpeakQuestion> _questions = [
    // 레벨 1: 2개
    _ReverseSpeakQuestion(
      sequence: ['일', '이'],
      reversed: ['이', '일'],
      options: [['일', '이'], ['이', '일'], ['이', '이']],
      correctIndex: 1,
    ),
    _ReverseSpeakQuestion(
      sequence: ['삼', '사'],
      reversed: ['사', '삼'],
      options: [['삼', '사'], ['사', '사'], ['사', '삼']],
      correctIndex: 2,
    ),
    _ReverseSpeakQuestion(
      sequence: ['빨강', '파랑'],
      reversed: ['파랑', '빨강'],
      options: [['빨강', '파랑'], ['파랑', '빨강'], ['파랑', '파랑']],
      correctIndex: 1,
    ),
    // 레벨 2: 3개
    _ReverseSpeakQuestion(
      sequence: ['일', '이', '삼'],
      reversed: ['삼', '이', '일'],
      options: [['일', '이', '삼'], ['삼', '이', '일'], ['이', '삼', '일']],
      correctIndex: 1,
    ),
    _ReverseSpeakQuestion(
      sequence: ['사', '오', '육'],
      reversed: ['육', '오', '사'],
      options: [['육', '사', '오'], ['육', '오', '사'], ['오', '육', '사']],
      correctIndex: 1,
    ),
    _ReverseSpeakQuestion(
      sequence: ['사과', '바나나', '포도'],
      reversed: ['포도', '바나나', '사과'],
      options: [['사과', '바나나', '포도'], ['포도', '사과', '바나나'], ['포도', '바나나', '사과']],
      correctIndex: 2,
    ),
    // 레벨 3: 4개
    _ReverseSpeakQuestion(
      sequence: ['일', '이', '삼', '사'],
      reversed: ['사', '삼', '이', '일'],
      options: [['사', '삼', '이', '일'], ['일', '이', '삼', '사'], ['사', '이', '삼', '일']],
      correctIndex: 0,
    ),
    _ReverseSpeakQuestion(
      sequence: ['칠', '팔', '구', '십'],
      reversed: ['십', '구', '팔', '칠'],
      options: [['십', '팔', '구', '칠'], ['십', '구', '팔', '칠'], ['칠', '팔', '구', '십']],
      correctIndex: 1,
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;

  bool _showSequence = true;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int? _selectedIndex;
  int _currentPlayIndex = -1;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Random _random = Random();
  late List<_ReverseSpeakQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  _ReverseSpeakQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _showSequence = true;
    _showFeedback = false;
    _selectedIndex = null;
    _currentPlayIndex = -1;

    setState(() {});

    _playSequence();
  }

  Future<void> _playSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i < _question.sequence.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentPlayIndex = i;
      });

      _pulseController.forward().then((_) {
        if (mounted) _pulseController.reverse();
      });

      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted) return;

    setState(() {
      _currentPlayIndex = -1;
      _showSequence = false;
    });
  }

  void _selectAnswer(int index) {
    if (_showSequence || _showFeedback || _selectedIndex != null) return;

    final correct = index == _question.correctIndex;

    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      _isCorrect = correct;

      if (correct) {
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

  void _replaySequence() {
    if (_showFeedback) return;

    setState(() {
      _showSequence = true;
    });

    _playSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: const Text('🔊 거꾸로 기억하기'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '점수: $_score / ${_currentQuestion + 1}',
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

            // 시퀀스 표시
            _buildSequenceDisplay(),

            const SizedBox(height: 24),

            // 선택지
            if (!_showSequence) _buildOptions(),

            // 피드백
            if (_showFeedback) _buildFeedback(),

            // 다시 듣기 버튼
            if (!_showSequence && !_showFeedback) _buildReplayButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final sequenceLength = _question.sequence.length;

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
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$sequenceLength개 역순',
                  style: TextStyle(
                    color: Colors.teal[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${_currentQuestion + 1} / ${_shuffledQuestions.length}',
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _showSequence ? Colors.teal[50] : Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _showSequence ? Colors.teal[200]! : Colors.amber[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _showSequence ? Icons.hearing : Icons.swap_horiz,
                color: _showSequence ? Colors.teal : Colors.amber[700],
              ),
              const SizedBox(width: 8),
              Text(
                _showSequence ? '잘 들어보세요!' : '거꾸로는 뭘까요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _showSequence ? Colors.teal : Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_question.sequence.length, (index) {
              final isPlaying = _currentPlayIndex == index;

              return AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = isPlaying ? _pulseAnimation.value : 1.0;

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPlaying ? Colors.teal : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: isPlaying
                            ? [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        _question.sequence[index],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPlaying ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '정답을 선택하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_question.options.length, (index) {
              return _buildOptionButton(index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    final option = _question.options[index];
    final isSelected = _selectedIndex == index;
    final isCorrectAnswer = index == _question.correctIndex;

    Color backgroundColor;
    Color borderColor;

    if (_showFeedback) {
      if (isCorrectAnswer) {
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green;
      } else if (isSelected && !_isCorrect) {
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red;
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.grey[300]!;
      }
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.teal[300]!;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...option.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              );
            }),
            if (_showFeedback && isCorrectAnswer)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.check_circle, color: Colors.green),
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
            _isCorrect ? Icons.check_circle : Icons.info_outline,
            color: _isCorrect ? Colors.green : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect
                ? '🎉 정답! 역순 완벽!'
                : '정답: ${_question.reversed.join(' → ')}',
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

  Widget _buildReplayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _replaySequence,
        icon: const Icon(Icons.replay),
        label: const Text('다시 듣기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

