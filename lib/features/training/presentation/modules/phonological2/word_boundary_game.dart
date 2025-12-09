import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 단어 경계 찾기 게임 (S 2.4.2)
/// 
/// 붙여서 말한 문장에서 단어 구분점을 터치합니다.
class WordBoundaryGame extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const WordBoundaryGame({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<WordBoundaryGame> createState() => _WordBoundaryGameState();
}

class _WordBoundaryGameState extends State<WordBoundaryGame> {
  int _currentQuestionIndex = 0;
  late List<BoundaryQuestion> _questions;
  Set<int> _selectedBoundaries = {};
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

  List<BoundaryQuestion> _generateQuestions(int level) {
    switch (level) {
      case 1: // 쉬움: 2단어
        return [
          BoundaryQuestion(
            combinedText: '사과바나나',
            words: ['사과', '바나나'],
            correctBoundaries: {2}, // '사과' 뒤에서 2
          ),
          BoundaryQuestion(
            combinedText: '강아지고양이',
            words: ['강아지', '고양이'],
            correctBoundaries: {3}, // '강아지' 뒤에서 3
          ),
          BoundaryQuestion(
            combinedText: '엄마아빠',
            words: ['엄마', '아빠'],
            correctBoundaries: {2},
          ),
        ];
      case 2: // 중간: 3단어
        return [
          BoundaryQuestion(
            combinedText: '사과바나나포도',
            words: ['사과', '바나나', '포도'],
            correctBoundaries: {2, 5}, // 사과|바나나|포도
          ),
          BoundaryQuestion(
            combinedText: '토끼거북이사자',
            words: ['토끼', '거북이', '사자'],
            correctBoundaries: {2, 5},
          ),
          BoundaryQuestion(
            combinedText: '빨강노랑파랑',
            words: ['빨강', '노랑', '파랑'],
            correctBoundaries: {2, 4},
          ),
        ];
      default:
        return _generateQuestions(1);
    }
  }

  void _playAudio() {
    setState(() => _isPlaying = true);
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
    
    debugPrint('Playing: ${_questions[_currentQuestionIndex].combinedText}');
  }

  void _onBoundaryTap(int index) {
    if (_answered) return;
    
    setState(() {
      if (_selectedBoundaries.contains(index)) {
        _selectedBoundaries.remove(index);
      } else {
        _selectedBoundaries.add(index);
      }
    });
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentQuestion = _questions[_currentQuestionIndex];
    
    // 선택한 경계와 정답 비교
    final isCorrect = _selectedBoundaries.length == currentQuestion.correctBoundaries.length &&
        _selectedBoundaries.containsAll(currentQuestion.correctBoundaries);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedBoundaries = {};
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
                  color: DesignSystem.semanticWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      '✂️ 단어를 나눠보세요!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '단어 사이를 터치해서 경계를 표시하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 듣기 버튼
              ElevatedButton.icon(
                onPressed: _isPlaying ? null : _playAudio,
                icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
                label: Text(_isPlaying ? '듣는 중...' : '빠르게 듣기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.semanticWarning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 단어 경계 선택 영역
              _buildBoundaryArea(currentQuestion),

              const SizedBox(height: 24),

              // 결과 미리보기
              _buildPreview(currentQuestion),

              const SizedBox(height: 24),

              // 확인 버튼
              if (!_answered && _selectedBoundaries.isNotEmpty)
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

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? FeedbackMessages.getRandomCorrectMessage()
                : '정답: ${currentQuestion.words.join(' | ')}',
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

  Widget _buildBoundaryArea(BoundaryQuestion question) {
    final chars = question.combinedText.split('');
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(chars.length * 2 - 1, (index) {
          if (index % 2 == 0) {
            // 글자
            final charIndex = index ~/ 2;
            return Container(
              width: 40,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                chars[charIndex],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            // 경계 버튼
            final boundaryIndex = index ~/ 2;
            final isSelected = _selectedBoundaries.contains(boundaryIndex);
            final isCorrect = question.correctBoundaries.contains(boundaryIndex);
            final showCorrect = _answered && isCorrect;
            final showWrong = _answered && isSelected && !isCorrect;
            
            return GestureDetector(
              onTap: () => _onBoundaryTap(boundaryIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: showCorrect
                      ? DesignSystem.semanticSuccess.withOpacity(0.3)
                      : showWrong
                          ? DesignSystem.semanticError.withOpacity(0.3)
                          : isSelected
                              ? DesignSystem.semanticWarning.withOpacity(0.3)
                              : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected || showCorrect || showWrong
                    ? Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: showCorrect
                              ? DesignSystem.semanticSuccess
                              : showWrong
                                  ? DesignSystem.semanticError
                                  : DesignSystem.semanticWarning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildPreview(BoundaryQuestion question) {
    if (_selectedBoundaries.isEmpty && !_answered) {
      return const Text(
        '단어 사이를 터치해서 나눠보세요',
        style: TextStyle(color: Colors.grey),
      );
    }
    
    final chars = question.combinedText.split('');
    final result = StringBuffer();
    
    for (int i = 0; i < chars.length; i++) {
      result.write(chars[i]);
      final boundariesToShow = _answered ? question.correctBoundaries : _selectedBoundaries;
      if (boundariesToShow.contains(i) && i < chars.length - 1) {
        result.write(' | ');
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _answered
            ? (_isCorrect! ? DesignSystem.semanticSuccess : DesignSystem.semanticError)
                .withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        result.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _answered
              ? (_isCorrect!
                  ? DesignSystem.semanticSuccess
                  : DesignSystem.semanticError)
              : Colors.black87,
        ),
      ),
    );
  }
}

class BoundaryQuestion {
  final String combinedText;
  final List<String> words;
  final Set<int> correctBoundaries;

  BoundaryQuestion({
    required this.combinedText,
    required this.words,
    required this.correctBoundaries,
  });
}

