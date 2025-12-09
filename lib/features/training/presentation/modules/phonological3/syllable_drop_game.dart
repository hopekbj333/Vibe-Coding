import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 탈락 게임 (S 2.5.5)
/// 
/// "사과에서 '과'를 빼면?" → 정답 그림 선택
class SyllableDropGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableDropGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableDropGame> createState() => _SyllableDropGameState();
}

class _SyllableDropGameState extends State<SyllableDropGame> {
  int _currentQuestionIndex = 0;
  late List<DropQuestion> _questions;
  int? _selectedIndex;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<DropQuestion> _generateQuestions(int level) {
    return [
      DropQuestion(
        originalWord: '사과',
        syllables: ['사', '과'],
        dropSyllable: '과',
        dropPosition: 1,
        correctAnswer: '사',
        options: ['사', '과', '사과'],
      ),
      DropQuestion(
        originalWord: '나비',
        syllables: ['나', '비'],
        dropSyllable: '나',
        dropPosition: 0,
        correctAnswer: '비',
        options: ['나', '비', '나비'],
      ),
      DropQuestion(
        originalWord: '바나나',
        syllables: ['바', '나', '나'],
        dropSyllable: '바',
        dropPosition: 0,
        correctAnswer: '나나',
        options: ['바', '나나', '바나'],
      ),
      DropQuestion(
        originalWord: '코끼리',
        syllables: ['코', '끼', '리'],
        dropSyllable: '끼',
        dropPosition: 1,
        correctAnswer: '코리',
        options: ['코끼', '끼리', '코리'],
      ),
      DropQuestion(
        originalWord: '토마토',
        syllables: ['토', '마', '토'],
        dropSyllable: '토',
        dropPosition: 2,
        correctAnswer: '토마',
        options: ['토마', '마토', '토토'],
      ),
    ];
  }

  void _selectOption(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final question = _questions[_currentQuestionIndex];
    final isCorrect = question.options[index] == question.correctAnswer;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedIndex = null;
          _answered = false;
          _isCorrect = null;
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
                ? '${currentQuestion.correctAnswer}!'
                : '정답: ${currentQuestion.correctAnswer}',
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            '🗑️ 소리를 빼면?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '단어에서 소리를 빼면 뭐가 남을까요?',
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionArea(DropQuestion question) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: question.syllables.asMap().entries.map((entry) {
              final index = entry.key;
              final syllable = entry.value;
              final isDrop = index == question.dropPosition;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDrop
                      ? Colors.red.shade100
                      : DesignSystem.childFriendlyBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDrop ? Colors.red : DesignSystem.childFriendlyBlue,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      syllable,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDrop ? Colors.red : DesignSystem.childFriendlyBlue,
                        decoration: isDrop ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (isDrop) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.close, color: Colors.red, size: 24),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 20, color: Colors.black),
              children: [
                TextSpan(
                  text: '"${question.originalWord}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '에서 '),
                TextSpan(
                  text: '"${question.dropSyllable}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const TextSpan(text: '를 빼면?'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(DropQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _selectedIndex == index;
        final isCorrect = option == question.correctAnswer;

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
                        ? DesignSystem.primaryBlue.withOpacity(0.1)
                        : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ??
                      (isSelected
                          ? DesignSystem.primaryBlue
                          : Colors.grey.shade300),
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
}

class DropQuestion {
  final String originalWord;
  final List<String> syllables;
  final String dropSyllable;
  final int dropPosition;
  final String correctAnswer;
  final List<String> options;

  DropQuestion({
    required this.originalWord,
    required this.syllables,
    required this.dropSyllable,
    required this.dropPosition,
    required this.correctAnswer,
    required this.options,
  });
}

