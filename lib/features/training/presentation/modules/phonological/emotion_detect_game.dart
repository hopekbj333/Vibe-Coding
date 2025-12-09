import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 감정 찾기 게임 (S 2.3.6)
/// 
/// 음성의 감정(기쁨/슬픔/화남)을 구별합니다.
/// 해당 감정의 캐릭터 얼굴을 터치합니다.
class EmotionDetectGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const EmotionDetectGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<EmotionDetectGame> createState() => _EmotionDetectGameState();
}

class _EmotionDetectGameState extends State<EmotionDetectGame> {
  int _currentQuestionIndex = 0;
  late List<EmotionQuestion> _questions;
  EmotionType? _selectedEmotion;
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

  List<EmotionQuestion> _generateQuestions(int level) {
    return [
      EmotionQuestion(
        sentence: '와! 오늘 정말 기뻐!',
        emotion: EmotionType.happy,
        audioPath: 'happy_voice.mp3',
      ),
      EmotionQuestion(
        sentence: '슬퍼... 친구가 이사 갔어.',
        emotion: EmotionType.sad,
        audioPath: 'sad_voice.mp3',
      ),
      EmotionQuestion(
        sentence: '너무 화가 나!',
        emotion: EmotionType.angry,
        audioPath: 'angry_voice.mp3',
      ),
      EmotionQuestion(
        sentence: '선물 받아서 너무 좋아!',
        emotion: EmotionType.happy,
        audioPath: 'happy_gift.mp3',
      ),
      EmotionQuestion(
        sentence: '아이스크림 떨어뜨렸어...',
        emotion: EmotionType.sad,
        audioPath: 'sad_icecream.mp3',
      ),
      EmotionQuestion(
        sentence: '왜 내 거 가져갔어?!',
        emotion: EmotionType.angry,
        audioPath: 'angry_take.mp3',
      ),
    ];
  }

  void _playAudio() {
    setState(() => _isPlaying = true);
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
    
    debugPrint('Playing: ${_questions[_currentQuestionIndex].audioPath}');
  }

  void _onSelect(EmotionType emotion) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = emotion == currentQuestion.emotion;

    setState(() {
      _selectedEmotion = emotion;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedEmotion = null;
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
                child: Column(
                  children: [
                    const Text(
                      '🎭 어떤 기분일까요?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '목소리를 듣고 기분을 맞춰보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 듣기 영역
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
                    // 스피커 아이콘
                    GestureDetector(
                      onTap: _isPlaying ? null : _playAudio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isPlaying
                              ? DesignSystem.primaryBlue
                              : DesignSystem.primaryBlue.withOpacity(0.1),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.volume_up : Icons.play_arrow,
                          size: 50,
                          color: _isPlaying ? Colors.white : DesignSystem.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isPlaying ? '듣는 중...' : '터치해서 들어보세요',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 감정 선택지
              const Text(
                '이 사람의 기분은?',
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
                  _buildEmotionCard(
                    emotion: EmotionType.happy,
                    emoji: '😊',
                    label: '기뻐요',
                    color: DesignSystem.childFriendlyYellow,
                    isCorrect: currentQuestion.emotion == EmotionType.happy,
                  ),
                  _buildEmotionCard(
                    emotion: EmotionType.sad,
                    emoji: '😢',
                    label: '슬퍼요',
                    color: DesignSystem.primaryBlue,
                    isCorrect: currentQuestion.emotion == EmotionType.sad,
                  ),
                  _buildEmotionCard(
                    emotion: EmotionType.angry,
                    emoji: '😠',
                    label: '화났어요',
                    color: DesignSystem.primaryRed,
                    isCorrect: currentQuestion.emotion == EmotionType.angry,
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
                DesignSystem.childFriendlyYellow,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionCard({
    required EmotionType emotion,
    required String emoji,
    required String label,
    required Color color,
    required bool isCorrect,
  }) {
    final isSelected = _selectedEmotion == emotion;
    final showCorrect = _answered && isCorrect;
    final showWrong = _answered && isSelected && !isCorrect;

    return GestureDetector(
      onTap: _answered ? null : () => _onSelect(emotion),
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
                      ? color.withOpacity(0.2)
                      : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? color
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
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
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

enum EmotionType {
  happy,
  sad,
  angry,
}

class EmotionQuestion {
  final String sentence;
  final EmotionType emotion;
  final String audioPath;

  EmotionQuestion({
    required this.sentence,
    required this.emotion,
    required this.audioPath,
  });
}

