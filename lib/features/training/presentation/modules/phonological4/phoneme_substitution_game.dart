import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 음소 대치 게임 (S 3.1.4)
/// 
/// "강의 ㄱ을 ㅂ으로 바꾸면?" → 방
/// 블록 교체 드래그 인터랙션
class PhonemeSubstitutionGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const PhonemeSubstitutionGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<PhonemeSubstitutionGame> createState() => _PhonemeSubstitutionGameState();
}

class _PhonemeSubstitutionGameState extends State<PhonemeSubstitutionGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _showSubstitution = false;

  late AnimationController _swapController;
  late Animation<double> _swapAnimation;

  final List<_SubstitutionQuestion> _questions = [
    _SubstitutionQuestion(
      word: '강',
      originalPart: 'ㄱ',
      newPart: 'ㅂ',
      result: '방',
      options: ['방', '망', '상'],
      originalEmoji: '🌊',
      resultEmoji: '🚪',
    ),
    _SubstitutionQuestion(
      word: '달',
      originalPart: 'ㄷ',
      newPart: 'ㅁ',
      result: '말',
      options: ['말', '발', '살'],
      originalEmoji: '🌙',
      resultEmoji: '🐴',
    ),
    _SubstitutionQuestion(
      word: '공',
      originalPart: 'ㄱ',
      newPart: 'ㅎ',
      result: '홍',
      options: ['홍', '통', '봉'],
      originalEmoji: '⚽',
      resultEmoji: '🔴',
    ),
    _SubstitutionQuestion(
      word: '밤',
      originalPart: 'ㅂ',
      newPart: 'ㄱ',
      result: '감',
      options: ['감', '남', '담'],
      originalEmoji: '🌰',
      resultEmoji: '🍊',
    ),
    _SubstitutionQuestion(
      word: '손',
      originalPart: 'ㅅ',
      newPart: 'ㅁ',
      result: '몬',
      options: ['몬', '돈', '본'],
      originalEmoji: '✋',
      resultEmoji: '👾',
    ),
    _SubstitutionQuestion(
      word: '바다',
      originalPart: 'ㅂ',
      newPart: 'ㅍ',
      result: '파다',
      options: ['파다', '마다', '사다'],
      originalEmoji: '🌊',
      resultEmoji: '🔵',
    ),
    _SubstitutionQuestion(
      word: '감',
      originalPart: 'ㅁ',
      newPart: 'ㅂ',
      result: '갑',
      options: ['갑', '간', '갈'],
      originalEmoji: '🍊',
      resultEmoji: '📦',
    ),
    _SubstitutionQuestion(
      word: '불',
      originalPart: 'ㅂ',
      newPart: 'ㄱ',
      result: '굴',
      options: ['굴', '물', '술'],
      originalEmoji: '🔥',
      resultEmoji: '🦪',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _questions.shuffle(Random());

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _swapAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  void _selectAnswer(String selected) {
    if (_showFeedback) return;

    final question = _questions[_currentQuestionIndex];
    final correct = selected == question.result;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) _correctCount++;
    });

    if (correct) {
      _swapController.forward();
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      _swapController.reset();

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _showFeedback = false;
          _showSubstitution = false;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showHint() {
    setState(() {
      _showSubstitution = true;
    });
    _swapController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_showFeedback) {
          _swapController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showSubstitution = false;
              });
            }
          });
        }
      });
    });
  }

  void _showResultDialog() {
    final accuracy = (_correctCount / _questions.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 게임 완료!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_correctCount / ${_questions.length} 정답',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '정확도: $accuracy%',
              style: TextStyle(
                fontSize: 18,
                color: accuracy >= 80
                    ? DesignSystem.semanticSuccess
                    : DesignSystem.semanticWarning,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('나가기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _correctCount = 0;
                _showFeedback = false;
                _questions.shuffle(Random());
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryBlue,
            ),
            child: const Text('다시 하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('음소 대치 게임'),
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProgressBar(),
                const SizedBox(height: 40),
                _buildWordDisplay(question),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _showHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('힌트 보기'),
                ),
                const SizedBox(height: 24),
                _buildOptions(question),
                const SizedBox(height: 40),
                if (_showFeedback) _buildFeedback(question),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (_currentQuestionIndex + 1) / _questions.length,
        minHeight: 8,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
      ),
    );
  }

  Widget _buildWordDisplay(_SubstitutionQuestion question) {
    return AnimatedBuilder(
      animation: _swapAnimation,
      builder: (context, child) {
        final swapProgress = (_showFeedback && _isCorrect) || _showSubstitution
            ? _swapAnimation.value
            : 0.0;

        return Column(
          children: [
            // 이모지 전환
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: (1 - swapProgress).clamp(0.0, 1.0),
                  child: Text(question.originalEmoji, style: const TextStyle(fontSize: 64)),
                ),
                const SizedBox(width: 16),
                const Text('→', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Opacity(
                  opacity: swapProgress.clamp(0.0, 1.0),
                  child: Text(question.resultEmoji, style: const TextStyle(fontSize: 64)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 대치 과정
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 원래 단어
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    question.word,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 교체 표시
                Column(
                  children: [
                  // 빠지는 음소
                  Transform.translate(
                    offset: Offset(0, -20 * swapProgress),
                    child: Opacity(
                      opacity: (1 - swapProgress).clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: Text(
                            question.originalPart,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.swap_vert, size: 32),
                  // 들어오는 음소
                  Transform.translate(
                    offset: Offset(0, 20 * (1 - swapProgress)),
                    child: Opacity(
                      opacity: swapProgress.clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Text(
                            question.newPart,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // 결과
                const Text('=', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: swapProgress > 0.5 ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: swapProgress > 0.5 ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    swapProgress > 0.5 ? question.result : '?',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: swapProgress > 0.5 ? Colors.green.shade700 : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 질문
            Text(
              '"${question.word}"의 ${question.originalPart}을 ${question.newPart}으로 바꾸면?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignSystem.neutralGray800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptions(_SubstitutionQuestion question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: question.options.map((option) {
        final isCorrect = option == question.result;
        final showCorrect = _showFeedback && isCorrect;

        return GestureDetector(
          onTap: () => _selectAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: showCorrect ? Colors.green.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: showCorrect ? Colors.green : Colors.grey.shade300,
                width: 3,
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
                option,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: showCorrect ? Colors.green.shade700 : DesignSystem.neutralGray800,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(_SubstitutionQuestion question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.info,
            color: _isCorrect ? Colors.green : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect
                ? '정답! ${question.word}의 ${question.originalPart}→${question.newPart} = ${question.result}'
                : '다시 생각해봐요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstitutionQuestion {
  final String word;
  final String originalPart;
  final String newPart;
  final String result;
  final List<String> options;
  final String originalEmoji;
  final String resultEmoji;

  _SubstitutionQuestion({
    required this.word,
    required this.originalPart,
    required this.newPart,
    required this.result,
    required this.options,
    required this.originalEmoji,
    required this.resultEmoji,
  });
}

