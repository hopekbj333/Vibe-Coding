import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 억양 구별하기 게임 (S 2.3.5)
/// 
/// 같은 문장의 평서문/의문문을 구별합니다.
/// "밥 먹었어." vs "밥 먹었어?" → 표정 아이콘 선택
class IntonationGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const IntonationGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<IntonationGame> createState() => _IntonationGameState();
}

class _IntonationGameState extends State<IntonationGame> {
  int _currentQuestionIndex = 0;
  late List<IntonationQuestion> _questions;
  int? _selectedIndex;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
  }

  List<IntonationQuestion> _generateQuestions(int level) {
    return [
      IntonationQuestion(
        sentence: '밥 먹었어?',
        intonationType: IntonationType.question,
        audioPath: 'ate_question.mp3',
      ),
      IntonationQuestion(
        sentence: '학교 갔어.',
        intonationType: IntonationType.statement,
        audioPath: 'school_statement.mp3',
      ),
      IntonationQuestion(
        sentence: '이거 뭐야?',
        intonationType: IntonationType.question,
        audioPath: 'what_question.mp3',
      ),
      IntonationQuestion(
        sentence: '재미있다.',
        intonationType: IntonationType.statement,
        audioPath: 'fun_statement.mp3',
      ),
      IntonationQuestion(
        sentence: '같이 갈래?',
        intonationType: IntonationType.question,
        audioPath: 'together_question.mp3',
      ),
    ];
  }

  void _playAudio() {
    setState(() => _isPlaying = true);
    
    // 시뮬레이션: 1.5초 후 재생 완료
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
    
    debugPrint('Playing: ${_questions[_currentQuestionIndex].audioPath}');
  }

  void _onSelect(IntonationType type) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = type == currentQuestion.intonationType;

    setState(() {
      _selectedIndex = type == IntonationType.statement ? 0 : 1;
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
                  color: DesignSystem.childFriendlyPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🗣️ 어떻게 말하고 있을까요?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '소리를 듣고 말하는 방식을 맞춰보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 문장 표시
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      '"${currentQuestion.sentence.replaceAll('?', '').replaceAll('.', '')}"',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 듣기 버튼
                    ElevatedButton.icon(
                      onPressed: _isPlaying ? null : _playAudio,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.volume_up),
                      label: Text(_isPlaying ? '재생 중...' : '들어보기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 선택지
              const Text(
                '이 말은...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildChoiceCard(
                    type: IntonationType.statement,
                    emoji: '😊',
                    label: '그냥 말하는 거',
                    isCorrect: currentQuestion.intonationType == IntonationType.statement,
                  ),
                  _buildChoiceCard(
                    type: IntonationType.question,
                    emoji: '🤔',
                    label: '물어보는 거',
                    isCorrect: currentQuestion.intonationType == IntonationType.question,
                  ),
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
                DesignSystem.childFriendlyPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required IntonationType type,
    required String emoji,
    required String label,
    required bool isCorrect,
  }) {
    final index = type == IntonationType.statement ? 0 : 1;
    final isSelected = _selectedIndex == index;
    final showCorrect = _answered && isCorrect;
    final showWrong = _answered && isSelected && !isCorrect;

    return GestureDetector(
      onTap: _answered ? null : () => _onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: showCorrect
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : showWrong
                  ? DesignSystem.semanticError.withOpacity(0.2)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? DesignSystem.childFriendlyPurple
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
              emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: showCorrect
                    ? DesignSystem.semanticSuccess
                    : showWrong
                        ? DesignSystem.semanticError
                        : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum IntonationType {
  statement, // 평서문
  question,  // 의문문
}

class IntonationQuestion {
  final String sentence;
  final IntonationType intonationType;
  final String audioPath;

  IntonationQuestion({
    required this.sentence,
    required this.intonationType,
    required this.audioPath,
  });
}

