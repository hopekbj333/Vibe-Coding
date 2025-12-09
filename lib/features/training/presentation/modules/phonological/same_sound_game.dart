import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// 같은 소리 찾기 게임 (S 2.3.1)
/// 
/// 3개의 소리 중 같은 2개를 찾아 터치합니다.
/// 난이도: 악기 → 동물 → 환경음 (유사도 증가)
class SameSoundGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SameSoundGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SameSoundGame> createState() => _SameSoundGameState();
}

class _SameSoundGameState extends State<SameSoundGame> {
  int _currentQuestionIndex = 0;
  late List<SoundQuestion> _questions;
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

  List<SoundQuestion> _generateQuestions(int level) {
    // 난이도별 문제 생성
    switch (level) {
      case 1: // 쉬움: 악기 소리
        return [
          SoundQuestion(
            sounds: ['🥁 북', '🎹 피아노', '🥁 북'],
            correctIndices: {0, 2},
            soundPaths: ['drum.mp3', 'piano.mp3', 'drum.mp3'],
          ),
          SoundQuestion(
            sounds: ['🎸 기타', '🎸 기타', '🎺 트럼펫'],
            correctIndices: {0, 1},
            soundPaths: ['guitar.mp3', 'guitar.mp3', 'trumpet.mp3'],
          ),
          SoundQuestion(
            sounds: ['🔔 종', '🎻 바이올린', '🔔 종'],
            correctIndices: {0, 2},
            soundPaths: ['bell.mp3', 'violin.mp3', 'bell.mp3'],
          ),
        ];
      case 2: // 중간: 동물 소리
        return [
          SoundQuestion(
            sounds: ['🐕 멍멍', '🐱 야옹', '🐕 멍멍'],
            correctIndices: {0, 2},
            soundPaths: ['dog.mp3', 'cat.mp3', 'dog.mp3'],
          ),
          SoundQuestion(
            sounds: ['🐄 음메', '🐄 음메', '🐷 꿀꿀'],
            correctIndices: {0, 1},
            soundPaths: ['cow.mp3', 'cow.mp3', 'pig.mp3'],
          ),
          SoundQuestion(
            sounds: ['🐸 개굴', '🐤 삐약', '🐸 개굴'],
            correctIndices: {0, 2},
            soundPaths: ['frog.mp3', 'chick.mp3', 'frog.mp3'],
          ),
        ];
      case 3: // 어려움: 환경음
        return [
          SoundQuestion(
            sounds: ['🌧️ 비 소리', '💨 바람 소리', '🌧️ 비 소리'],
            correctIndices: {0, 2},
            soundPaths: ['rain.mp3', 'wind.mp3', 'rain.mp3'],
          ),
          SoundQuestion(
            sounds: ['🚗 자동차', '🚗 자동차', '🚂 기차'],
            correctIndices: {0, 1},
            soundPaths: ['car.mp3', 'car.mp3', 'train.mp3'],
          ),
          SoundQuestion(
            sounds: ['📞 전화', '🚪 노크', '📞 전화'],
            correctIndices: {0, 2},
            soundPaths: ['phone.mp3', 'knock.mp3', 'phone.mp3'],
          ),
        ];
      default:
        return _generateQuestions(1);
    }
  }

  void _onSoundTap(int index) {
    if (_answered) return;

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else if (_selectedIndices.length < 2) {
        _selectedIndices.add(index);
      }

      // 2개를 선택하면 정답 확인
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

    // 피드백 후 다음 문제로
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

  void _playSound(int index) {
    // TODO: 실제 오디오 재생 구현
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
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🔍 같은 소리를 찾아주세요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '3개 중에서 같은 소리 2개를 터치하세요',
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
                DesignSystem.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundCard(int index, SoundQuestion question) {
    final isSelected = _selectedIndices.contains(index);
    final isCorrectAnswer = question.correctIndices.contains(index);
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
                      ? DesignSystem.primaryBlue.withOpacity(0.2)
                      : Colors.white,
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
            // 스피커 아이콘
            Icon(
              Icons.volume_up,
              size: 40,
              color: isSelected
                  ? DesignSystem.primaryBlue
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            // 소리 라벨
            Text(
              question.sounds[index],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? DesignSystem.primaryBlue
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 선택 표시
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 소리 문제 데이터
class SoundQuestion {
  final List<String> sounds;
  final Set<int> correctIndices;
  final List<String> soundPaths;

  SoundQuestion({
    required this.sounds,
    required this.correctIndices,
    required this.soundPaths,
  });
}

