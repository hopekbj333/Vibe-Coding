import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.3.5: 도형 회전 예측 게임
/// 도형을 회전하면 어떤 모양이 되는지 예측하는 공간 지각 훈련
class ShapeRotationGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const ShapeRotationGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<ShapeRotationGame> createState() => _ShapeRotationGameState();
}

class _ShapeRotationQuestion {
  final String shape; // 원본 도형
  final int rotationDegrees; // 회전 각도 (90, 180, 270)
  final String correctAnswer; // 정답
  final List<String> options; // 선택지

  const _ShapeRotationQuestion({
    required this.shape,
    required this.rotationDegrees,
    required this.correctAnswer,
    required this.options,
  });
}

class _ShapeRotationGameState extends State<ShapeRotationGame>
    with TickerProviderStateMixin {
  static final List<_ShapeRotationQuestion> _questions = [
    // 90도 회전
    _ShapeRotationQuestion(
      shape: '▲',
      rotationDegrees: 90,
      correctAnswer: '▶',
      options: ['◀', '▶', '▼'],
    ),
    _ShapeRotationQuestion(
      shape: '▶',
      rotationDegrees: 90,
      correctAnswer: '▼',
      options: ['▲', '▼', '◀'],
    ),
    _ShapeRotationQuestion(
      shape: '➡️',
      rotationDegrees: 90,
      correctAnswer: '⬇️',
      options: ['⬆️', '⬇️', '⬅️'],
    ),
    // 180도 회전
    _ShapeRotationQuestion(
      shape: '▲',
      rotationDegrees: 180,
      correctAnswer: '▼',
      options: ['▲', '▼', '▶'],
    ),
    _ShapeRotationQuestion(
      shape: '⬆️',
      rotationDegrees: 180,
      correctAnswer: '⬇️',
      options: ['⬆️', '⬇️', '➡️'],
    ),
    _ShapeRotationQuestion(
      shape: '🔼',
      rotationDegrees: 180,
      correctAnswer: '🔽',
      options: ['🔼', '🔽', '▶️'],
    ),
    // 270도 회전
    _ShapeRotationQuestion(
      shape: '▲',
      rotationDegrees: 270,
      correctAnswer: '◀',
      options: ['▶', '◀', '▼'],
    ),
    _ShapeRotationQuestion(
      shape: '➡️',
      rotationDegrees: 270,
      correctAnswer: '⬆️',
      options: ['⬆️', '⬇️', '⬅️'],
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  
  bool _showRotation = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String? _selectedAnswer;
  
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  final Random _random = Random();
  late List<_ShapeRotationQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  _ShapeRotationQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _selectedAnswer = null;
    _showFeedback = false;
    _showRotation = false;
    _rotationController.reset();
    
    setState(() {});
    
    // 회전 애니메이션 재생
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showRotation = true;
        });
        _rotationController.forward();
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

  void _replayRotation() {
    if (_showFeedback) return;
    
    _rotationController.reset();
    _rotationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        title: const Text('🔄 도형 회전'),
        backgroundColor: Colors.cyan,
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
            
            // 도형 표시
            Expanded(child: _buildShapeDisplay()),
            
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
                  color: Colors.cyan,
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText() {
    final rotationText = _question.rotationDegrees == 90
        ? '오른쪽으로 한 번'
        : _question.rotationDegrees == 180
            ? '두 번 (180°)'
            : '왼쪽으로 한 번';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan[200]!),
      ),
      child: Column(
        children: [
          const Text(
            '이 도형을 돌리면?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rotate_right, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '$rotationText 돌리면?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeDisplay() {
    return Center(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          final rotationRadians = _showRotation
              ? _rotationAnimation.value * _question.rotationDegrees * pi / 180
              : 0.0;
          
          return Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan[200]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: rotationRadians,
              child: Center(
                child: Text(
                  _question.shape,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            '정답을 선택하세요',
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
                borderColor = Colors.cyan[300]!;
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
        onPressed: _replayRotation,
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

