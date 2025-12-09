import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 끝말잇기 연습 게임 (S 2.4.5)
/// 
/// 제시된 단어의 끝 음절로 시작하는 그림을 찾습니다.
class WordChainGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const WordChainGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<WordChainGame> createState() => _WordChainGameState();
}

class _WordChainGameState extends State<WordChainGame> {
  int _currentQuestionIndex = 0;
  late List<ChainQuestion> _questions;
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

  List<ChainQuestion> _generateQuestions(int level) {
    return [
      ChainQuestion(
        startWord: '사과',
        startEmoji: '🍎',
        endSyllable: '과',
        options: [
          ChainOption(word: '과자', emoji: '🍪', isCorrect: true),
          ChainOption(word: '바나나', emoji: '🍌', isCorrect: false),
          ChainOption(word: '딸기', emoji: '🍓', isCorrect: false),
        ],
      ),
      ChainQuestion(
        startWord: '토끼',
        startEmoji: '🐰',
        endSyllable: '끼',
        options: [
          ChainOption(word: '호랑이', emoji: '🐯', isCorrect: false),
          ChainOption(word: '끼리', emoji: '🐘', isCorrect: true), // 코끼리의 끼리
          ChainOption(word: '강아지', emoji: '🐕', isCorrect: false),
        ],
      ),
      ChainQuestion(
        startWord: '나비',
        startEmoji: '🦋',
        endSyllable: '비',
        options: [
          ChainOption(word: '비행기', emoji: '✈️', isCorrect: true),
          ChainOption(word: '자동차', emoji: '🚗', isCorrect: false),
          ChainOption(word: '기차', emoji: '🚂', isCorrect: false),
        ],
      ),
      ChainQuestion(
        startWord: '기차',
        startEmoji: '🚂',
        endSyllable: '차',
        options: [
          ChainOption(word: '비행기', emoji: '✈️', isCorrect: false),
          ChainOption(word: '차표', emoji: '🎫', isCorrect: true),
          ChainOption(word: '버스', emoji: '🚌', isCorrect: false),
        ],
      ),
      ChainQuestion(
        startWord: '포도',
        startEmoji: '🍇',
        endSyllable: '도',
        options: [
          ChainOption(word: '사과', emoji: '🍎', isCorrect: false),
          ChainOption(word: '도넛', emoji: '🍩', isCorrect: true),
          ChainOption(word: '바나나', emoji: '🍌', isCorrect: false),
        ],
      ),
    ];
  }

  void _onOptionTap(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = currentQuestion.options[index].isCorrect;

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

              // 안내
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignSystem.childFriendlyYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🔗 끝말잇기!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '단어의 마지막 글자로 시작하는 것을 찾아보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 시작 단어
              Container(
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
                    Text(
                      currentQuestion.startEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentQuestion.startWord,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DesignSystem.semanticWarning,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '"${currentQuestion.endSyllable}"',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${currentQuestion.endSyllable}"로 시작하는 것은?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 연결 화살표
              const Icon(
                Icons.arrow_downward,
                size: 40,
                color: Colors.grey,
              ),

              const SizedBox(height: 16),

              // 선택지
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return _buildOptionCard(index, currentQuestion);
                }),
              ),
            ],
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? '${currentQuestion.startWord} → ${currentQuestion.options.firstWhere((o) => o.isCorrect).word}!'
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
                DesignSystem.childFriendlyYellow,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(int index, ChainQuestion question) {
    final option = question.options[index];
    final isSelected = _selectedIndex == index;
    final showCorrect = _answered && option.isCorrect;
    final showWrong = _answered && isSelected && !option.isCorrect;

    return GestureDetector(
      onTap: () => _onOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 130,
        decoration: BoxDecoration(
          color: showCorrect
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : showWrong
                  ? DesignSystem.semanticError.withOpacity(0.2)
                  : isSelected
                      ? DesignSystem.childFriendlyYellow.withOpacity(0.3)
                      : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? DesignSystem.childFriendlyYellow
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
              option.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              option.word,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: showCorrect
                    ? DesignSystem.semanticSuccess
                    : showWrong
                        ? DesignSystem.semanticError
                        : Colors.black87,
              ),
            ),
            if (showCorrect || showWrong) ...[
              const SizedBox(height: 4),
              Icon(
                showCorrect ? Icons.check_circle : Icons.cancel,
                color: showCorrect
                    ? DesignSystem.semanticSuccess
                    : DesignSystem.semanticError,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChainQuestion {
  final String startWord;
  final String startEmoji;
  final String endSyllable;
  final List<ChainOption> options;

  ChainQuestion({
    required this.startWord,
    required this.startEmoji,
    required this.endSyllable,
    required this.options,
  });
}

class ChainOption {
  final String word;
  final String emoji;
  final bool isCorrect;

  ChainOption({
    required this.word,
    required this.emoji,
    required this.isCorrect,
  });
}

