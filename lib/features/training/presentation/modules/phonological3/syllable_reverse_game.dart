import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 뒤집기 게임 (S 2.5.6)
/// 
/// "나비를 거꾸로 하면?" → "비나" 선택
class SyllableReverseGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableReverseGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableReverseGame> createState() => _SyllableReverseGameState();
}

class _SyllableReverseGameState extends State<SyllableReverseGame>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  late List<ReverseQuestion> _questions;
  int? _selectedIndex;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _showAnimation = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  List<ReverseQuestion> _generateQuestions(int level) {
    return [
      ReverseQuestion(
        originalWord: '나비',
        syllables: ['나', '비'],
        reversedWord: '비나',
        options: ['비나', '나비', '바니'],
      ),
      ReverseQuestion(
        originalWord: '토끼',
        syllables: ['토', '끼'],
        reversedWord: '끼토',
        options: ['끼토', '토토', '토끼'],
      ),
      ReverseQuestion(
        originalWord: '사과',
        syllables: ['사', '과'],
        reversedWord: '과사',
        options: ['사과', '과사', '가사'],
      ),
      ReverseQuestion(
        originalWord: '바나나',
        syllables: ['바', '나', '나'],
        reversedWord: '나나바',
        options: ['나나바', '바바나', '나바나'],
      ),
      ReverseQuestion(
        originalWord: '코끼리',
        syllables: ['코', '끼', '리'],
        reversedWord: '리끼코',
        options: ['리끼코', '코리끼', '끼리코'],
      ),
    ];
  }

  void _showReverseAnimation() {
    setState(() {
      _showAnimation = true;
    });
    _flipController.forward();
  }

  void _selectOption(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final question = _questions[_currentQuestionIndex];
    final isCorrect = question.options[index] == question.reversedWord;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _flipController.reset();
        setState(() {
          _currentQuestionIndex++;
          _selectedIndex = null;
          _answered = false;
          _isCorrect = null;
          _showAnimation = false;
          _questionStartTime = DateTime.now();
        });
      } else {
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildQuestionArea(currentQuestion),
              const SizedBox(height: 32),
              _buildOptions(currentQuestion),
            ],
          ),
        ),
        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? '${currentQuestion.reversedWord}!'
                : '정답: ${currentQuestion.reversedWord}',
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            '🔄 거꾸로 말하기!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '단어를 거꾸로 하면 뭐가 될까요?',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Text(
          '${_currentQuestionIndex + 1} / ${_questions.length}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionArea(ReverseQuestion question) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 원래 단어 또는 뒤집기 애니메이션
          AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final displaySyllables = _showAnimation
                  ? _lerpSyllables(question.syllables, question.syllables.reversed.toList(), _flipAnimation.value)
                  : question.syllables;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value * 3.14159),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: displaySyllables.asMap().entries.map((entry) {
                    final index = entry.key;
                    final syllable = entry.value;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _getBlockColor(index),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getBlockColor(index).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        syllable,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // 뒤집기 버튼
          if (!_showAnimation)
            ElevatedButton.icon(
              onPressed: _showReverseAnimation,
              icon: const Icon(Icons.rotate_right),
              label: const Text('거꾸로!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

          const SizedBox(height: 16),

          Text(
            '"${question.originalWord}"를 거꾸로 하면?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _lerpSyllables(List<String> from, List<String> to, double t) {
    if (t < 0.5) return from;
    return to;
  }

  Widget _buildOptions(ReverseQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _selectedIndex == index;
        final isCorrect = option == question.reversedWord;

        Color? bgColor;
        Color? borderColor;
        if (_answered) {
          if (isCorrect) {
            bgColor = DesignSystem.semanticSuccess.withOpacity(0.2);
            borderColor = DesignSystem.semanticSuccess;
          } else if (isSelected) {
            bgColor = DesignSystem.semanticError.withOpacity(0.2);
            borderColor = DesignSystem.semanticError;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () => _selectOption(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: bgColor ??
                    (isSelected
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ??
                      (isSelected ? Colors.orange : Colors.grey.shade300),
                  width: isSelected || (_answered && isCorrect) ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _answered && isCorrect
                      ? DesignSystem.semanticSuccess
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getBlockColor(int index) {
    final colors = [
      DesignSystem.childFriendlyBlue,
      DesignSystem.childFriendlyGreen,
      DesignSystem.childFriendlyPurple,
      DesignSystem.childFriendlyYellow,
    ];
    return colors[index % colors.length];
  }
}

class ReverseQuestion {
  final String originalWord;
  final List<String> syllables;
  final String reversedWord;
  final List<String> options;

  ReverseQuestion({
    required this.originalWord,
    required this.syllables,
    required this.reversedWord,
    required this.options,
  });
}

