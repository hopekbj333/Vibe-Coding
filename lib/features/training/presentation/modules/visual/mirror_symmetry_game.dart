import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.3.6: 거울 대칭 찾기 게임
/// 제시된 도형의 거울 대칭 이미지 찾기
class MirrorSymmetryGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const MirrorSymmetryGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<MirrorSymmetryGame> createState() => _MirrorSymmetryGameState();
}

class _MirrorSymmetryQuestion {
  final String original; // 원본
  final String symmetryType; // 'horizontal' (좌우) or 'vertical' (상하)
  final String correctAnswer; // 정답
  final List<String> options; // 선택지
  final String hint; // 힌트

  const _MirrorSymmetryQuestion({
    required this.original,
    required this.symmetryType,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });
}

class _MirrorSymmetryGameState extends State<MirrorSymmetryGame>
    with TickerProviderStateMixin {
  static final List<_MirrorSymmetryQuestion> _questions = [
    // 좌우 대칭 (거울)
    _MirrorSymmetryQuestion(
      original: '👉',
      symmetryType: 'horizontal',
      correctAnswer: '👈',
      options: ['👉', '👈', '👆'],
      hint: '거울에 비친 모습',
    ),
    _MirrorSymmetryQuestion(
      original: '➡️',
      symmetryType: 'horizontal',
      correctAnswer: '⬅️',
      options: ['➡️', '⬅️', '⬆️'],
      hint: '거울에 비친 모습',
    ),
    _MirrorSymmetryQuestion(
      original: '🐕',
      symmetryType: 'horizontal',
      correctAnswer: '🐕‍🦺',
      options: ['🐕', '🐕‍🦺', '🐈'],
      hint: '거울에 비친 모습',
    ),
    _MirrorSymmetryQuestion(
      original: '◀️',
      symmetryType: 'horizontal',
      correctAnswer: '▶️',
      options: ['◀️', '▶️', '🔼'],
      hint: '거울에 비친 모습',
    ),
    // 상하 대칭 (물에 비친)
    _MirrorSymmetryQuestion(
      original: '🔼',
      symmetryType: 'vertical',
      correctAnswer: '🔽',
      options: ['🔼', '🔽', '▶️'],
      hint: '물에 비친 모습',
    ),
    _MirrorSymmetryQuestion(
      original: '⬆️',
      symmetryType: 'vertical',
      correctAnswer: '⬇️',
      options: ['⬆️', '⬇️', '➡️'],
      hint: '물에 비친 모습',
    ),
    _MirrorSymmetryQuestion(
      original: '☝️',
      symmetryType: 'vertical',
      correctAnswer: '👇',
      options: ['☝️', '👇', '👈'],
      hint: '물에 비친 모습',
    ),
    _MirrorSymmetryQuestion(
      original: '▲',
      symmetryType: 'vertical',
      correctAnswer: '▼',
      options: ['▲', '▼', '◀'],
      hint: '물에 비친 모습',
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  
  bool _showFeedback = false;
  bool _isCorrect = false;
  String? _selectedAnswer;
  
  late AnimationController _mirrorController;
  late Animation<double> _mirrorAnimation;
  
  final Random _random = Random();
  late List<_MirrorSymmetryQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _mirrorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _mirrorAnimation = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _mirrorController, curve: Curves.easeInOut),
    );
    
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _mirrorController.dispose();
    super.dispose();
  }

  _MirrorSymmetryQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _selectedAnswer = null;
    _showFeedback = false;
    _mirrorController.reset();
    
    setState(() {});
    
    // 애니메이션 재생
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _mirrorController.forward();
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_showFeedback || _selectedAnswer != null) return;
    
    final correct = answer == _question.correctAnswer;
    
    setState(() {
      _selectedAnswer = answer;
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

  void _replayAnimation() {
    if (_showFeedback) return;
    
    _mirrorController.reset();
    _mirrorController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text('🪞 거울 대칭'),
        backgroundColor: Colors.pink,
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
            
            // 문제 설명
            _buildQuestionText(),
            
            // 대칭 표시
            Expanded(child: _buildMirrorDisplay()),
            
            // 선택지
            _buildOptions(),
            
            // 피드백
            if (_showFeedback) _buildFeedback(),
            
            // 다시 보기 버튼
            if (!_showFeedback) _buildReplayButton(),
            
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
              Text(
                '문제 ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText() {
    final isHorizontal = _question.symmetryType == 'horizontal';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isHorizontal ? Icons.swap_horiz : Icons.swap_vert,
                color: Colors.pink,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isHorizontal ? '거울에 비친 모습은?' : '물에 비친 모습은?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHorizontal ? Colors.blue[50] : Colors.cyan[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isHorizontal ? '🪞 좌우 대칭' : '💧 상하 대칭',
              style: TextStyle(
                fontSize: 14,
                color: isHorizontal ? Colors.blue : Colors.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMirrorDisplay() {
    final isHorizontal = _question.symmetryType == 'horizontal';
    
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 원본
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '원본',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink[200]!, width: 2),
                ),
                child: Center(
                  child: Text(
                    _question.original,
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ],
          ),
          
          // 거울/물
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isHorizontal ? '🪞' : '💧',
                  style: const TextStyle(fontSize: 24),
                ),
                Container(
                  width: 4,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isHorizontal ? Colors.blue[200]! : Colors.cyan[200]!,
                        isHorizontal ? Colors.blue[400]! : Colors.cyan[400]!,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          
          // 대칭 (애니메이션)
          AnimatedBuilder(
            animation: _mirrorAnimation,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: isHorizontal
                            ? (Matrix4.identity()..scale(_mirrorAnimation.value, 1.0))
                            : (Matrix4.identity()..scale(1.0, _mirrorAnimation.value)),
                        child: Opacity(
                          opacity: (1 - _mirrorAnimation.value.abs()).clamp(0.0, 1.0),
                          child: Text(
                            _question.original,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            '대칭된 모습을 선택하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _question.options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isCorrectAnswer = option == _question.correctAnswer;
              
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
                borderColor = Colors.pink[300]!;
              }
              
              return GestureDetector(
                onTap: () => _selectAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
                ? '🎉 정답이에요!'
                : '정답: ${_question.correctAnswer}',
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
        onPressed: _replayAnimation,
        icon: const Icon(Icons.replay),
        label: const Text('다시 보기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

