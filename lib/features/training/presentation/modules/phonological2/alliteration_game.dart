import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 두운(첫소리) 찾기 게임 (S 2.4.3)
/// 
/// 3개 단어 중 같은 소리로 시작하는 2개를 찾습니다.
class AlliterationGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const AlliterationGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<AlliterationGame> createState() => _AlliterationGameState();
}

class _AlliterationGameState extends State<AlliterationGame> {
  int _currentQuestionIndex = 0;
  late List<AlliterationQuestion> _questions;
  Set<int> _selectedIndices = {};
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<AlliterationQuestion> _generateQuestions(int level) {
    return [
      AlliterationQuestion(
        words: ['사과', '사탕', '바나나'],
        emojis: ['🍎', '🍬', '🍌'],
        correctIndices: {0, 1}, // 사과, 사탕 (ㅅ으로 시작)
        startSound: 'ㅅ',
      ),
      AlliterationQuestion(
        words: ['고양이', '강아지', '토끼'],
        emojis: ['🐱', '🐕', '🐰'],
        correctIndices: {0, 1}, // 고양이, 강아지 (ㄱ으로 시작)
        startSound: 'ㄱ',
      ),
      AlliterationQuestion(
        words: ['비행기', '버스', '자동차'],
        emojis: ['✈️', '🚌', '🚗'],
        correctIndices: {0, 1}, // 비행기, 버스 (ㅂ으로 시작)
        startSound: 'ㅂ',
      ),
      AlliterationQuestion(
        words: ['나비', '노래', '사자'],
        emojis: ['🦋', '🎵', '🦁'],
        correctIndices: {0, 1}, // 나비, 노래 (ㄴ으로 시작)
        startSound: 'ㄴ',
      ),
      AlliterationQuestion(
        words: ['마이크', '책', '모자'],
        emojis: ['🎤', '📖', '🧢'],
        correctIndices: {0, 2}, // 마이크, 모자 (ㅁ으로 시작)
        startSound: 'ㅁ',
      ),
    ];
  }

  void _onWordTap(int index) {
    if (_answered) return;

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else if (_selectedIndices.length < 2) {
        _selectedIndices.add(index);
      }

      if (_selectedIndices.length == 2) {
        _checkAnswer();
      }
    });
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _selectedIndices.containsAll(currentQuestion.correctIndices) &&
        currentQuestion.correctIndices.containsAll(_selectedIndices);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedIndices = {};
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

              // 안내
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignSystem.childFriendlyGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🔤 같은 소리로 시작해요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '같은 소리로 시작하는 단어 2개를 찾아보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 단어 카드들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return _buildWordCard(index, currentQuestion);
                }),
              ),

              const SizedBox(height: 24),

              // 선택 상태 표시
              Text(
                '선택: ${_selectedIndices.length} / 2',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _selectedIndices.length == 2
                      ? DesignSystem.semanticSuccess
                      : Colors.grey,
                ),
              ),

              if (_answered && _isCorrect != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💡 "${currentQuestion.startSound}"으로 시작하는 단어들이에요!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? FeedbackMessages.getRandomCorrectMessage()
                : FeedbackMessages.getRandomIncorrectMessage(),
          ),
      ],
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
              valueColor: AlwaysStoppedAnimation<Color>(
                DesignSystem.childFriendlyGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(int index, AlliterationQuestion question) {
    final isSelected = _selectedIndices.contains(index);
    final isCorrectAnswer = question.correctIndices.contains(index);
    final showCorrect = _answered && isCorrectAnswer;
    final showWrong = _answered && isSelected && !isCorrectAnswer;

    return GestureDetector(
      onTap: () => _onWordTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: showCorrect
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : showWrong
                  ? DesignSystem.semanticError.withOpacity(0.2)
                  : isSelected
                      ? DesignSystem.childFriendlyGreen.withOpacity(0.2)
                      : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? DesignSystem.childFriendlyGreen
                        : Colors.grey.shade300,
            width: isSelected || showCorrect || showWrong ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question.emojis[index],
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              question.words[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: showCorrect
                    ? DesignSystem.semanticSuccess
                    : showWrong
                        ? DesignSystem.semanticError
                        : Colors.black87,
              ),
            ),
            if (isSelected && !_answered)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: DesignSystem.childFriendlyGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

class AlliterationQuestion {
  final List<String> words;
  final List<String> emojis;
  final Set<int> correctIndices;
  final String startSound;

  AlliterationQuestion({
    required this.words,
    required this.emojis,
    required this.correctIndices,
    required this.startSound,
  });
}

