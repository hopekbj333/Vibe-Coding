import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 소리 듣고 합치기 게임 (S 2.5.4)
/// 
/// "나...비" 천천히 재생 → 합친 단어 그림 선택
class SyllableListenMergeGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableListenMergeGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableListenMergeGame> createState() => _SyllableListenMergeGameState();
}

class _SyllableListenMergeGameState extends State<SyllableListenMergeGame> {
  int _currentQuestionIndex = 0;
  late List<ListenMergeQuestion> _questions;
  int? _selectedIndex;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isPlaying = false;
  bool _hasListened = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<ListenMergeQuestion> _generateQuestions(int level) {
    return [
      ListenMergeQuestion(
        syllables: ['나', '비'],
        correctWord: '나비',
        options: [
          WordOption(word: '나비', emoji: '🦋'),
          WordOption(word: '나무', emoji: '🌳'),
          WordOption(word: '바다', emoji: '🌊'),
        ],
      ),
      ListenMergeQuestion(
        syllables: ['사', '과'],
        correctWord: '사과',
        options: [
          WordOption(word: '사자', emoji: '🦁'),
          WordOption(word: '사과', emoji: '🍎'),
          WordOption(word: '포도', emoji: '🍇'),
        ],
      ),
      ListenMergeQuestion(
        syllables: ['바', '나', '나'],
        correctWord: '바나나',
        options: [
          WordOption(word: '바다', emoji: '🌊'),
          WordOption(word: '바나나', emoji: '🍌'),
          WordOption(word: '바람', emoji: '🌬️'),
        ],
      ),
      ListenMergeQuestion(
        syllables: ['코', '끼', '리'],
        correctWord: '코끼리',
        options: [
          WordOption(word: '코끼리', emoji: '🐘'),
          WordOption(word: '코알라', emoji: '🐨'),
          WordOption(word: '고릴라', emoji: '🦍'),
        ],
      ),
    ];
  }

  void _playSound() {
    if (_isPlaying) return;
    
    final question = _questions[_currentQuestionIndex];
    
    setState(() {
      _isPlaying = true;
    });
    
    // 시뮬레이션: 음절 천천히 재생
    debugPrint('Playing syllables: ${question.syllables.join("...")}');
    
    Timer(Duration(milliseconds: 500 * question.syllables.length + 1000), () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _hasListened = true;
        });
      }
    });
  }

  void _selectOption(int index) {
    if (_answered || !_hasListened) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final question = _questions[_currentQuestionIndex];
    final isCorrect = question.options[index].word == question.correctWord;

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
          _hasListened = false;
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
                      '👂 듣고 합쳐보세요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '천천히 들려주는 소리를 합치면 어떤 단어일까요?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 소리 재생 영역
              _buildSoundArea(currentQuestion),

              const SizedBox(height: 32),

              // 선택지
              if (_hasListened) _buildOptions(currentQuestion),
            ],
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? '${currentQuestion.correctWord}!'
                : '정답: ${currentQuestion.correctWord}',
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

  Widget _buildSoundArea(ListenMergeQuestion question) {
    return Column(
      children: [
        GestureDetector(
          onTap: _playSound,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPlaying
                  ? DesignSystem.childFriendlyYellow
                  : DesignSystem.childFriendlyYellow.withOpacity(0.3),
              boxShadow: _isPlaying
                  ? [
                      BoxShadow(
                        color: DesignSystem.childFriendlyYellow.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              _isPlaying ? Icons.volume_up : Icons.play_arrow,
              size: 80,
              color: _isPlaying ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isPlaying)
          Text(
            question.syllables.join(' ... '),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          )
        else if (_hasListened)
          const Text(
            '어떤 단어일까요?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          )
        else
          const Text(
            '터치해서 들어보세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildOptions(ListenMergeQuestion question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _selectedIndex == index;
        final isCorrect = option.word == question.correctWord;

        Color? borderColor;
        if (_answered) {
          if (isCorrect) {
            borderColor = DesignSystem.semanticSuccess;
          } else if (isSelected) {
            borderColor = DesignSystem.semanticError;
          }
        }

        return GestureDetector(
          onTap: () => _selectOption(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor ?? (isSelected ? DesignSystem.primaryBlue : Colors.grey.shade300),
                width: isSelected || (_answered && isCorrect) ? 4 : 2,
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
              children: [
                Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                if (_answered) ...[
                  const SizedBox(height: 8),
                  Text(
                    option.word,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCorrect
                          ? DesignSystem.semanticSuccess
                          : Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ListenMergeQuestion {
  final List<String> syllables;
  final String correctWord;
  final List<WordOption> options;

  ListenMergeQuestion({
    required this.syllables,
    required this.correctWord,
    required this.options,
  });
}

class WordOption {
  final String word;
  final String emoji;

  WordOption({
    required this.word,
    required this.emoji,
  });
}

