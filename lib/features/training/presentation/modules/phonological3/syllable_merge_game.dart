import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 블록 합치기 게임 (S 2.5.3)
/// 
/// 분리된 음절 블록을 합쳐서 단어를 만듭니다.
class SyllableMergeGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableMergeGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableMergeGame> createState() => _SyllableMergeGameState();
}

class _SyllableMergeGameState extends State<SyllableMergeGame> {
  int _currentQuestionIndex = 0;
  late List<MergeQuestion> _questions;
  List<String> _selectedSyllables = [];
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isMerged = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<MergeQuestion> _generateQuestions(int level) {
    return [
      MergeQuestion(
        syllables: ['나', '비'],
        correctWord: '나비',
        emoji: '🦋',
      ),
      MergeQuestion(
        syllables: ['사', '과'],
        correctWord: '사과',
        emoji: '🍎',
      ),
      MergeQuestion(
        syllables: ['바', '나', '나'],
        correctWord: '바나나',
        emoji: '🍌',
      ),
      MergeQuestion(
        syllables: ['코', '끼', '리'],
        correctWord: '코끼리',
        emoji: '🐘',
      ),
      MergeQuestion(
        syllables: ['강', '아', '지'],
        correctWord: '강아지',
        emoji: '🐕',
      ),
    ];
  }

  void _onSyllableTap(String syllable) {
    if (_answered || _isMerged) return;
    
    final question = _questions[_currentQuestionIndex];
    
    setState(() {
      if (_selectedSyllables.contains(syllable)) {
        _selectedSyllables.remove(syllable);
      } else if (_selectedSyllables.length < question.syllables.length) {
        _selectedSyllables.add(syllable);
      }
    });
  }

  void _onMerge() {
    if (_selectedSyllables.length != _questions[_currentQuestionIndex].syllables.length) {
      return;
    }
    
    setState(() {
      _isMerged = true;
    });
    
    Timer(const Duration(milliseconds: 800), () {
      _checkAnswer();
    });
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final question = _questions[_currentQuestionIndex];
    
    final mergedWord = _selectedSyllables.join('');
    final isCorrect = mergedWord == question.correctWord;

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedSyllables = [];
          _answered = false;
          _isCorrect = null;
          _isMerged = false;
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
                      '🧩 블록을 합쳐보세요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '음절 블록을 순서대로 눌러서 단어를 만드세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 타겟 그림
              Text(
                currentQuestion.emoji,
                style: const TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 24),

              // 합친 결과 영역
              _buildResultArea(currentQuestion),

              const SizedBox(height: 32),

              // 음절 블록들
              if (!_isMerged) _buildSyllableBlocks(currentQuestion),

              const SizedBox(height: 24),

              // 합치기 버튼
              if (!_answered && !_isMerged && _selectedSyllables.length == currentQuestion.syllables.length)
                ElevatedButton.icon(
                  onPressed: _onMerge,
                  icon: const Icon(Icons.merge_type),
                  label: const Text('합치기!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.childFriendlyGreen,
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
                DesignSystem.childFriendlyGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultArea(MergeQuestion question) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: _isMerged
            ? DesignSystem.childFriendlyGreen
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isMerged
            ? [
                BoxShadow(
                  color: DesignSystem.childFriendlyGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Text(
        _isMerged
            ? _selectedSyllables.join('')
            : _selectedSyllables.isEmpty
                ? '?'
                : _selectedSyllables.join(' + '),
        style: TextStyle(
          fontSize: _isMerged ? 40 : 32,
          fontWeight: FontWeight.bold,
          color: _isMerged ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSyllableBlocks(MergeQuestion question) {
    // 음절을 섞어서 표시
    final shuffledSyllables = List<String>.from(question.syllables)..shuffle();

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: shuffledSyllables.map((syllable) {
        final isSelected = _selectedSyllables.contains(syllable);
        final index = question.syllables.indexOf(syllable);

        return GestureDetector(
          onTap: () => _onSyllableTap(syllable),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getBlockColor(index)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _getBlockColor(index)
                    : Colors.grey.shade300,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _getBlockColor(index).withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              syllable,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
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

class MergeQuestion {
  final List<String> syllables;
  final String correctWord;
  final String emoji;

  MergeQuestion({
    required this.syllables,
    required this.correctWord,
    required this.emoji,
  });
}

