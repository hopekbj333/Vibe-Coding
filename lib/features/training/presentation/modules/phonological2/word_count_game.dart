import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 문장 속 단어 수 세기 게임 (S 2.4.1)
/// 
/// 문장을 듣고 몇 개의 단어인지 맞춥니다.
/// 캐릭터가 단어마다 점프하여 힌트를 줍니다.
class WordCountGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const WordCountGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<WordCountGame> createState() => _WordCountGameState();
}

class _WordCountGameState extends State<WordCountGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  late List<WordCountQuestion> _questions;
  int? _selectedCount;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  
  bool _isPlaying = false;
  int _currentJumpWord = -1;
  
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.difficultyLevel);
    _questionStartTime = DateTime.now();
    
    _jumpController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -30, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _jumpController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  List<WordCountQuestion> _generateQuestions(int level) {
    switch (level) {
      case 1: // 쉬움: 2단어
        return [
          WordCountQuestion(sentence: '엄마 왔어', words: ['엄마', '왔어'], wordCount: 2),
          WordCountQuestion(sentence: '밥 먹자', words: ['밥', '먹자'], wordCount: 2),
          WordCountQuestion(sentence: '안녕 친구', words: ['안녕', '친구'], wordCount: 2),
        ];
      case 2: // 중간: 3단어
        return [
          WordCountQuestion(sentence: '나는 사과 좋아', words: ['나는', '사과', '좋아'], wordCount: 3),
          WordCountQuestion(sentence: '강아지가 뛰어 간다', words: ['강아지가', '뛰어', '간다'], wordCount: 3),
          WordCountQuestion(sentence: '오늘 날씨 좋다', words: ['오늘', '날씨', '좋다'], wordCount: 3),
        ];
      case 3: // 어려움: 4단어
        return [
          WordCountQuestion(
            sentence: '나는 학교에 갔어요',
            words: ['나는', '학교에', '갔어요'],
            wordCount: 3,
          ),
          WordCountQuestion(
            sentence: '엄마가 맛있는 밥 줬어',
            words: ['엄마가', '맛있는', '밥', '줬어'],
            wordCount: 4,
          ),
          WordCountQuestion(
            sentence: '친구와 같이 놀이터 갔어',
            words: ['친구와', '같이', '놀이터', '갔어'],
            wordCount: 4,
          ),
        ];
      default:
        return _generateQuestions(1);
    }
  }

  Future<void> _playSentence() async {
    if (_isPlaying) return;
    
    final question = _questions[_currentQuestionIndex];
    
    setState(() {
      _isPlaying = true;
      _currentJumpWord = -1;
    });
    
    // 각 단어마다 캐릭터가 점프
    for (int i = 0; i < question.words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      
      setState(() => _currentJumpWord = i);
      _jumpController.forward(from: 0);
      
      debugPrint('Playing word: ${question.words[i]}');
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _currentJumpWord = -1;
      });
    }
  }

  void _onSelectCount(int count) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = count == currentQuestion.wordCount;

    setState(() {
      _selectedCount = count;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedCount = null;
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
                      '🔢 몇 개의 단어일까요?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '문장을 듣고 단어 개수를 세어보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 캐릭터와 단어 표시 영역
              _buildCharacterArea(currentQuestion),

              const SizedBox(height: 24),

              // 듣기 버튼
              ElevatedButton.icon(
                onPressed: _isPlaying ? null : _playSentence,
                icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
                label: Text(_isPlaying ? '듣는 중...' : '문장 듣기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 숫자 선택 버튼들
              const Text(
                '단어가 몇 개일까요?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildCountOptions(currentQuestion),
            ],
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? FeedbackMessages.getRandomCorrectMessage()
                : '정답: ${currentQuestion.wordCount}개',
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

  Widget _buildCharacterArea(WordCountQuestion question) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
          // 캐릭터 영역
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(question.words.length, (index) {
                final isJumping = _currentJumpWord == index;
                
                return AnimatedBuilder(
                  animation: _jumpAnimation,
                  builder: (context, child) {
                    final offset = isJumping ? _jumpAnimation.value : 0.0;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isJumping
                                  ? DesignSystem.childFriendlyYellow
                                  : DesignSystem.childFriendlyBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('😊', style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isPlaying && _currentJumpWord >= index)
                            Text(
                              question.words[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _currentJumpWord == index
                                    ? DesignSystem.primaryBlue
                                    : Colors.grey,
                              ),
                            )
                          else
                            const Text(
                              '?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          
          // 문장 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '"${question.sentence}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountOptions(WordCountQuestion question) {
    // 선택지: 정답 ± 1
    final options = <int>{
      question.wordCount - 1,
      question.wordCount,
      question.wordCount + 1,
    }.where((n) => n > 0).toList()..sort();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((count) {
        final isSelected = _selectedCount == count;
        final isCorrect = count == question.wordCount;
        final showCorrect = _answered && isCorrect;
        final showWrong = _answered && isSelected && !isCorrect;

        return GestureDetector(
          onTap: _answered ? null : () => _onSelectCount(count),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: showCorrect
                      ? DesignSystem.semanticSuccess
                      : showWrong
                          ? DesignSystem.semanticError
                          : isSelected
                              ? DesignSystem.primaryBlue
                              : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WordCountQuestion {
  final String sentence;
  final List<String> words;
  final int wordCount;

  WordCountQuestion({
    required this.sentence,
    required this.words,
    required this.wordCount,
  });
}

