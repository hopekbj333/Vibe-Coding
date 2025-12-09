import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 박수로 음절 쪼개기 게임 (S 2.5.1)
/// 
/// 단어를 듣고 음절 수만큼 탭합니다.
/// 예: "코끼리" → 탭탭탭 (3회)
class SyllableClapGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableClapGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableClapGame> createState() => _SyllableClapGameState();
}

class _SyllableClapGameState extends State<SyllableClapGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  late List<SyllableQuestion> _questions;
  int _tapCount = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isPlaying = false;
  bool _canTap = false;
  
  late AnimationController _clapController;
  late Animation<double> _clapAnimation;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
    
    _clapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _clapAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _clapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _clapController.dispose();
    super.dispose();
  }

  List<SyllableQuestion> _generateQuestions(int level) {
    switch (level) {
      case 1: // 2음절
        return [
          SyllableQuestion(word: '나비', syllables: ['나', '비'], emoji: '🦋'),
          SyllableQuestion(word: '사과', syllables: ['사', '과'], emoji: '🍎'),
          SyllableQuestion(word: '토끼', syllables: ['토', '끼'], emoji: '🐰'),
        ];
      case 2: // 3음절
        return [
          SyllableQuestion(word: '코끼리', syllables: ['코', '끼', '리'], emoji: '🐘'),
          SyllableQuestion(word: '바나나', syllables: ['바', '나', '나'], emoji: '🍌'),
          SyllableQuestion(word: '강아지', syllables: ['강', '아', '지'], emoji: '🐕'),
        ];
      case 3: // 4음절
        return [
          SyllableQuestion(word: '무지개', syllables: ['무', '지', '개'], emoji: '🌈'),
          SyllableQuestion(word: '해바라기', syllables: ['해', '바', '라', '기'], emoji: '🌻'),
          SyllableQuestion(word: '자동차', syllables: ['자', '동', '차'], emoji: '🚗'),
        ];
      default:
        return _generateQuestions(1);
    }
  }

  void _playWord() {
    if (_isPlaying || _canTap) return;
    
    final question = _questions[_currentQuestionIndex];
    
    setState(() {
      _isPlaying = true;
      _tapCount = 0;
    });
    
    debugPrint('Playing: ${question.word}');
    
    // 시뮬레이션: 단어 재생 후 탭 가능
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _canTap = true;
        });
      }
    });
  }

  void _onTap() {
    if (!_canTap || _answered) return;
    
    _clapController.forward().then((_) {
      _clapController.reverse();
    });
    
    setState(() {
      _tapCount++;
    });
    
    final question = _questions[_currentQuestionIndex];
    
    // 탭 수가 음절 수와 같으면 자동으로 확인
    if (_tapCount == question.syllables.length) {
      _checkAnswer();
    } else if (_tapCount > question.syllables.length) {
      // 너무 많이 탭하면 오답
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    if (_answered) return;
    
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final question = _questions[_currentQuestionIndex];
    final isCorrect = _tapCount == question.syllables.length;

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _canTap = false;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _tapCount = 0;
          _answered = false;
          _isCorrect = null;
          _canTap = false;
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
        GestureDetector(
          onTap: _canTap ? _onTap : null,
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
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
                  child: const Column(
                    children: [
                      Text(
                        '👏 박수로 쪼개기!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '단어를 듣고 음절마다 화면을 탭하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 단어 표시
                _buildWordArea(currentQuestion),

                const SizedBox(height: 32),

                // 탭 영역
                _buildTapArea(currentQuestion),

                const SizedBox(height: 24),

                // 듣기 버튼
                if (!_canTap && !_answered)
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? null : _playWord,
                    icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
                    label: Text(_isPlaying ? '듣는 중...' : '단어 듣기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.childFriendlyPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),

                // 확인 버튼
                if (_canTap && _tapCount > 0 && !_answered)
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? '${currentQuestion.syllables.join("-")} (${currentQuestion.syllables.length}개)'
                : '정답: ${currentQuestion.syllables.length}개',
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

  Widget _buildWordArea(SyllableQuestion question) {
    return Container(
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
            question.emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          Text(
            question.word,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_answered) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: question.syllables.map((syllable) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DesignSystem.semanticSuccess.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DesignSystem.semanticSuccess),
                  ),
                  child: Text(
                    syllable,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.semanticSuccess,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTapArea(SyllableQuestion question) {
    return AnimatedBuilder(
      animation: _clapAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _clapAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _canTap
                  ? DesignSystem.childFriendlyPurple
                  : Colors.grey.shade300,
              boxShadow: _canTap
                  ? [
                      BoxShadow(
                        color: DesignSystem.childFriendlyPurple.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 60,
                  color: _canTap ? Colors.white : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  _canTap ? '탭! $_tapCount' : '먼저 들어보세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _canTap ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SyllableQuestion {
  final String word;
  final List<String> syllables;
  final String emoji;

  SyllableQuestion({
    required this.word,
    required this.syllables,
    required this.emoji,
  });
}

