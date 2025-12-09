import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 다른 소리 찾기 게임 (S 2.3.2)
/// 
/// 3개의 소리 중 1개만 다른 것을 찾아 터치합니다.
/// 난이도: 명확한 차이 → 미세한 차이
class DifferentSoundGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const DifferentSoundGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<DifferentSoundGame> createState() => _DifferentSoundGameState();
}

class _DifferentSoundGameState extends State<DifferentSoundGame> {
  int _currentQuestionIndex = 0;
  late List<OddSoundQuestion> _questions;
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

  List<OddSoundQuestion> _generateQuestions(int level) {
    switch (level) {
      case 1: // 쉬움: 명확한 차이
        return [
          OddSoundQuestion(
            sounds: ['🐕 멍멍', '🐕 멍멍', '🐱 야옹'],
            correctIndex: 2,
            soundPaths: ['dog.mp3', 'dog.mp3', 'cat.mp3'],
          ),
          OddSoundQuestion(
            sounds: ['🥁 북', '🎹 피아노', '🥁 북'],
            correctIndex: 1,
            soundPaths: ['drum.mp3', 'piano.mp3', 'drum.mp3'],
          ),
          OddSoundQuestion(
            sounds: ['🐸 개굴', '🐸 개굴', '🐤 삐약'],
            correctIndex: 2,
            soundPaths: ['frog.mp3', 'frog.mp3', 'chick.mp3'],
          ),
        ];
      case 2: // 중간
        return [
          OddSoundQuestion(
            sounds: ['🚗 빵빵', '🚂 칙칙', '🚗 빵빵'],
            correctIndex: 1,
            soundPaths: ['car.mp3', 'train.mp3', 'car.mp3'],
          ),
          OddSoundQuestion(
            sounds: ['🌧️ 비 소리', '🌧️ 비 소리', '💨 바람'],
            correctIndex: 2,
            soundPaths: ['rain.mp3', 'rain.mp3', 'wind.mp3'],
          ),
          OddSoundQuestion(
            sounds: ['🔔 딩동', '🔔 딩동', '📞 따르릉'],
            correctIndex: 2,
            soundPaths: ['bell.mp3', 'bell.mp3', 'phone.mp3'],
          ),
        ];
      case 3: // 어려움: 미세한 차이
        return [
          OddSoundQuestion(
            sounds: ['큰 북', '큰 북', '작은 북'],
            correctIndex: 2,
            soundPaths: ['big_drum.mp3', 'big_drum.mp3', 'small_drum.mp3'],
          ),
          OddSoundQuestion(
            sounds: ['높은 피아노', '낮은 피아노', '높은 피아노'],
            correctIndex: 1,
            soundPaths: ['high_piano.mp3', 'low_piano.mp3', 'high_piano.mp3'],
          ),
          OddSoundQuestion(
            sounds: ['빠른 발자국', '빠른 발자국', '느린 발자국'],
            correctIndex: 2,
            soundPaths: ['fast_step.mp3', 'fast_step.mp3', 'slow_step.mp3'],
          ),
        ];
      default:
        return _generateQuestions(1);
    }
  }

  void _onSoundTap(int index) {
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

  void _playSound(int index) {
    debugPrint('Playing sound: ${_questions[_currentQuestionIndex].soundPaths[index]}');
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
              // 진행 상황
              _buildProgressIndicator(),

              const SizedBox(height: 24),

              // 안내 텍스트
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎯 다른 소리를 찾아주세요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '3개 중에서 혼자 다른 소리 1개를 터치하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 소리 카드들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return _buildSoundCard(index, currentQuestion);
                }),
              ),
            ],
          ),
        ),

        // 피드백 오버레이
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
                DesignSystem.semanticWarning,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundCard(int index, OddSoundQuestion question) {
    final isSelected = _selectedIndex == index;
    final isCorrectAnswer = question.correctIndex == index;
    final showCorrect = _answered && isCorrectAnswer;
    final showWrong = _answered && isSelected && !isCorrectAnswer;

    return GestureDetector(
      onTap: () {
        _playSound(index);
        _onSoundTap(index);
      },
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
                      ? DesignSystem.semanticWarning.withOpacity(0.2)
                      : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? DesignSystem.semanticWarning
                        : Colors.grey.shade300,
            width: isSelected || showCorrect || showWrong ? 3 : 2,
          ),
          boxShadow: [
            if (!_answered)
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
              Icons.volume_up,
              size: 40,
              color: isSelected
                  ? DesignSystem.semanticWarning
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              question.sounds[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? DesignSystem.semanticWarning
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (showCorrect || showWrong) ...[
              const SizedBox(height: 8),
              Icon(
                showCorrect ? Icons.check_circle : Icons.cancel,
                color: showCorrect
                    ? DesignSystem.semanticSuccess
                    : DesignSystem.semanticError,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 다른 소리 문제 데이터
class OddSoundQuestion {
  final List<String> sounds;
  final int correctIndex;
  final List<String> soundPaths;

  OddSoundQuestion({
    required this.sounds,
    required this.correctIndex,
    required this.soundPaths,
  });
}

