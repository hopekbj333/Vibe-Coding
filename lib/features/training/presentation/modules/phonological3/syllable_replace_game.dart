import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 대치 게임 (S 2.5.7)
/// 
/// "'바나나'의 '바'를 '사'로 바꾸면?" → "사나나"
class SyllableReplaceGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableReplaceGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableReplaceGame> createState() => _SyllableReplaceGameState();
}

class _SyllableReplaceGameState extends State<SyllableReplaceGame>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  late List<ReplaceQuestion> _questions;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isReplaced = false;
  int? _selectedIndex;

  late AnimationController _replaceController;
  late Animation<double> _replaceAnimation;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();

    _replaceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _replaceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _replaceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _replaceController.dispose();
    super.dispose();
  }

  List<ReplaceQuestion> _generateQuestions(int level) {
    return [
      ReplaceQuestion(
        originalWord: '바나나',
        syllables: ['바', '나', '나'],
        replaceIndex: 0,
        originalSyllable: '바',
        newSyllable: '사',
        resultWord: '사나나',
        options: ['사나나', '바사나', '나사나'],
      ),
      ReplaceQuestion(
        originalWord: '나비',
        syllables: ['나', '비'],
        replaceIndex: 0,
        originalSyllable: '나',
        newSyllable: '아',
        resultWord: '아비',
        options: ['아비', '나아', '비아'],
      ),
      ReplaceQuestion(
        originalWord: '토끼',
        syllables: ['토', '끼'],
        replaceIndex: 1,
        originalSyllable: '끼',
        newSyllable: '마',
        resultWord: '토마',
        options: ['마끼', '토마', '끼토'],
      ),
      ReplaceQuestion(
        originalWord: '사과',
        syllables: ['사', '과'],
        replaceIndex: 1,
        originalSyllable: '과',
        newSyllable: '자',
        resultWord: '사자',
        options: ['사자', '자과', '과사'],
      ),
      ReplaceQuestion(
        originalWord: '코끼리',
        syllables: ['코', '끼', '리'],
        replaceIndex: 1,
        originalSyllable: '끼',
        newSyllable: '알',
        resultWord: '코알리',
        options: ['코알리', '알끼리', '코끼알'],
      ),
    ];
  }

  void _doReplace() {
    setState(() {
      _isReplaced = true;
    });
    _replaceController.forward();
  }

  void _selectOption(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final question = _questions[_currentQuestionIndex];
    final isCorrect = question.options[index] == question.resultWord;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _replaceController.reset();
        setState(() {
          _currentQuestionIndex++;
          _selectedIndex = null;
          _answered = false;
          _isCorrect = null;
          _isReplaced = false;
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
                ? '${currentQuestion.resultWord}!'
                : '정답: ${currentQuestion.resultWord}',
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            '🔁 소리 바꾸기!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '한 음절을 다른 음절로 바꾸면 뭐가 될까요?',
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionArea(ReplaceQuestion question) {
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
          // 음절 블록들
          AnimatedBuilder(
            animation: _replaceAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: question.syllables.asMap().entries.map((entry) {
                  final index = entry.key;
                  final syllable = entry.value;
                  final isTarget = index == question.replaceIndex;

                  String displaySyllable = syllable;
                  Color bgColor = _getBlockColor(index);

                  if (isTarget && _isReplaced) {
                    displaySyllable = question.newSyllable;
                    bgColor = Colors.purple;
                  }

                  return GestureDetector(
                    onTap: isTarget && !_isReplaced ? _doReplace : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isTarget && !_isReplaced
                            ? Border.all(color: Colors.purple, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: bgColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (isTarget && _isReplaced)
                            Transform.scale(
                              scale: _replaceAnimation.value,
                              child: Text(
                                displaySyllable,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Text(
                              displaySyllable,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: isTarget && !_isReplaced
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          if (isTarget && !_isReplaced)
                            const Text(
                              '↓',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // 바꿀 음절 표시
          if (!_isReplaced)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.originalSyllable,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward, color: Colors.purple, size: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Text(
                    question.newSyllable,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(
                  text: '"${question.originalWord}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '의 '),
                TextSpan(
                  text: '"${question.originalSyllable}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const TextSpan(text: '를 '),
                TextSpan(
                  text: '"${question.newSyllable}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const TextSpan(text: '로 바꾸면?'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (!_isReplaced)
            const Text(
              '위 블록을 터치해서 바꿔보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptions(ReplaceQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _selectedIndex == index;
        final isCorrect = option == question.resultWord;

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
                        ? Colors.purple.withOpacity(0.1)
                        : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ??
                      (isSelected ? Colors.purple : Colors.grey.shade300),
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
      DesignSystem.childFriendlyYellow,
      DesignSystem.childFriendlyPurple,
    ];
    return colors[index % colors.length];
  }
}

class ReplaceQuestion {
  final String originalWord;
  final List<String> syllables;
  final int replaceIndex;
  final String originalSyllable;
  final String newSyllable;
  final String resultWord;
  final List<String> options;

  ReplaceQuestion({
    required this.originalWord,
    required this.syllables,
    required this.replaceIndex,
    required this.originalSyllable,
    required this.newSyllable,
    required this.resultWord,
    required this.options,
  });
}

