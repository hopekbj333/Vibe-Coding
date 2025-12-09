import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 빠르기 구별하기 게임 (S 2.3.4)
/// 
/// 두 음악 중 더 빠른 것 또는 더 느린 것을 선택합니다.
class TempoCompareGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const TempoCompareGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<TempoCompareGame> createState() => _TempoCompareGameState();
}

class _TempoCompareGameState extends State<TempoCompareGame> {
  int _currentQuestionIndex = 0;
  late List<TempoQuestion> _questions;
  int? _selectedIndex;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  
  bool _playingFirst = false;
  bool _playingSecond = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<TempoQuestion> _generateQuestions(int level) {
    switch (level) {
      case 1: // 쉬움: 명확한 차이
        return [
          TempoQuestion(
            questionType: QuestionType.faster,
            firstLabel: '🎵 느린 음악',
            secondLabel: '🎶 빠른 음악',
            correctIndex: 1, // 두 번째가 더 빠름
            firstBpm: 60,
            secondBpm: 120,
          ),
          TempoQuestion(
            questionType: QuestionType.slower,
            firstLabel: '🎶 빠른 박수',
            secondLabel: '🎵 느린 박수',
            correctIndex: 1, // 두 번째가 더 느림
            firstBpm: 140,
            secondBpm: 70,
          ),
          TempoQuestion(
            questionType: QuestionType.faster,
            firstLabel: '🎵 천천히',
            secondLabel: '🎶 빠르게',
            correctIndex: 1,
            firstBpm: 80,
            secondBpm: 160,
          ),
        ];
      case 2: // 중간
        return [
          TempoQuestion(
            questionType: QuestionType.faster,
            firstLabel: '🎵 음악 A',
            secondLabel: '🎶 음악 B',
            correctIndex: 0,
            firstBpm: 110,
            secondBpm: 90,
          ),
          TempoQuestion(
            questionType: QuestionType.slower,
            firstLabel: '🎵 박자 A',
            secondLabel: '🎶 박자 B',
            correctIndex: 0,
            firstBpm: 85,
            secondBpm: 100,
          ),
          TempoQuestion(
            questionType: QuestionType.faster,
            firstLabel: '🎵 리듬 A',
            secondLabel: '🎶 리듬 B',
            correctIndex: 1,
            firstBpm: 95,
            secondBpm: 115,
          ),
        ];
      default:
        return _generateQuestions(1);
    }
  }

  void _playFirst() {
    setState(() {
      _playingFirst = true;
      _playingSecond = false;
    });
    
    // 시뮬레이션: 2초 후 재생 완료
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _playingFirst = false);
      }
    });
    
    debugPrint('Playing first: ${_questions[_currentQuestionIndex].firstBpm} BPM');
  }

  void _playSecond() {
    setState(() {
      _playingFirst = false;
      _playingSecond = true;
    });
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _playingSecond = false);
      }
    });
    
    debugPrint('Playing second: ${_questions[_currentQuestionIndex].secondBpm} BPM');
  }

  void _onSelect(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = index == currentQuestion.correctIndex;

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

              // 질문
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      currentQuestion.questionType == QuestionType.faster
                          ? '🏃 어느 것이 더 빠를까요?'
                          : '🐢 어느 것이 더 느릴까요?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '먼저 두 소리를 들어보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 듣기 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildListenButton(
                    label: currentQuestion.firstLabel,
                    isPlaying: _playingFirst,
                    onPlay: _playFirst,
                  ),
                  _buildListenButton(
                    label: currentQuestion.secondLabel,
                    isPlaying: _playingSecond,
                    onPlay: _playSecond,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 선택 버튼들
              const Text(
                '정답을 선택하세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChoiceButton(0, currentQuestion.firstLabel, currentQuestion),
                  _buildChoiceButton(1, currentQuestion.secondLabel, currentQuestion),
                ],
              ),
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
                DesignSystem.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListenButton({
    required String label,
    required bool isPlaying,
    required VoidCallback onPlay,
  }) {
    return GestureDetector(
      onTap: isPlaying ? null : onPlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isPlaying
              ? DesignSystem.primaryBlue.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaying ? DesignSystem.primaryBlue : Colors.grey.shade300,
            width: isPlaying ? 3 : 2,
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
            Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 50,
              color: isPlaying ? DesignSystem.primaryBlue : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPlaying ? DesignSystem.primaryBlue : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(int index, String label, TempoQuestion question) {
    final isSelected = _selectedIndex == index;
    final isCorrect = question.correctIndex == index;
    final showCorrect = _answered && isCorrect;
    final showWrong = _answered && isSelected && !isCorrect;

    return GestureDetector(
      onTap: _answered ? null : () => _onSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 80,
        decoration: BoxDecoration(
          color: showCorrect
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : showWrong
                  ? DesignSystem.semanticError.withOpacity(0.2)
                  : isSelected
                      ? DesignSystem.primaryBlue.withOpacity(0.2)
                      : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? DesignSystem.primaryBlue
                        : Colors.grey.shade300,
            width: isSelected || showCorrect || showWrong ? 3 : 2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showCorrect)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else if (showWrong)
                const Icon(Icons.cancel, color: Colors.red, size: 24),
              if (showCorrect || showWrong) const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: showCorrect
                        ? DesignSystem.semanticSuccess
                        : showWrong
                            ? DesignSystem.semanticError
                            : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum QuestionType {
  faster,
  slower,
}

class TempoQuestion {
  final QuestionType questionType;
  final String firstLabel;
  final String secondLabel;
  final int correctIndex;
  final int firstBpm;
  final int secondBpm;

  TempoQuestion({
    required this.questionType,
    required this.firstLabel,
    required this.secondLabel,
    required this.correctIndex,
    required this.firstBpm,
    required this.secondBpm,
  });
}

