import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 블록 쪼개기 게임 (S 2.5.2)
/// 
/// 단어가 적힌 블록을 음절 단위로 드래그하여 분리합니다.
class SyllableSplitGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableSplitGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableSplitGame> createState() => _SyllableSplitGameState();
}

class _SyllableSplitGameState extends State<SyllableSplitGame> {
  int _currentQuestionIndex = 0;
  late List<SplitQuestion> _questions;
  bool _isSplit = false;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<SplitQuestion> _generateQuestions(int level) {
    return [
      SplitQuestion(word: '나비', syllables: ['나', '비'], emoji: '🦋'),
      SplitQuestion(word: '사과', syllables: ['사', '과'], emoji: '🍎'),
      SplitQuestion(word: '바나나', syllables: ['바', '나', '나'], emoji: '🍌'),
      SplitQuestion(word: '토끼', syllables: ['토', '끼'], emoji: '🐰'),
      SplitQuestion(word: '코끼리', syllables: ['코', '끼', '리'], emoji: '🐘'),
    ];
  }

  void _onSplit() {
    if (_isSplit || _answered) return;
    
    setState(() {
      _isSplit = true;
    });
    
    // 잠시 후 자동으로 정답 처리
    Timer(const Duration(milliseconds: 800), () {
      _checkAnswer();
    });
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;

    setState(() {
      _answered = true;
      _isCorrect = true; // 블록을 쪼개면 성공
    });

    widget.onAnswer(true, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isSplit = false;
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
                  color: DesignSystem.childFriendlyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      '✂️ 블록을 쪼개보세요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '단어 블록을 잡아당겨서 음절로 나눠요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 이모지
              Text(
                currentQuestion.emoji,
                style: const TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 24),

              // 블록 영역
              _buildBlockArea(currentQuestion),

              const SizedBox(height: 32),

              // 쪼개기 버튼
              if (!_isSplit && !_answered)
                ElevatedButton.icon(
                  onPressed: _onSplit,
                  icon: const Icon(Icons.content_cut),
                  label: const Text('쪼개기!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.childFriendlyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: FeedbackType.correct,
            message: '${currentQuestion.syllables.join(" + ")} = ${currentQuestion.word}',
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
                DesignSystem.childFriendlyBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockArea(SplitQuestion question) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _isSplit
          ? _buildSplitBlocks(question)
          : _buildCombinedBlock(question),
    );
  }

  Widget _buildCombinedBlock(SplitQuestion question) {
    return Container(
      key: const ValueKey('combined'),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: DesignSystem.childFriendlyBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.childFriendlyBlue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        question.word,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSplitBlocks(SplitQuestion question) {
    return Row(
      key: const ValueKey('split'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: question.syllables.asMap().entries.map((entry) {
        final index = entry.key;
        final syllable = entry.value;
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset((index - question.syllables.length / 2 + 0.5) * 20 * value, 0),
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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

class SplitQuestion {
  final String word;
  final List<String> syllables;
  final String emoji;

  SplitQuestion({
    required this.word,
    required this.syllables,
    required this.emoji,
  });
}

