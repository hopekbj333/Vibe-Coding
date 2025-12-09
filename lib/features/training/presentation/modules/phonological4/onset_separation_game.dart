import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 초성 분리 게임 (S 3.1.1)
/// 
/// "강아지의 첫 소리는?" → ㄱ/ㄴ/ㄷ 중 선택
/// 글자에서 초성이 분리되는 애니메이션
class OnsetSeparationGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const OnsetSeparationGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<OnsetSeparationGame> createState() => _OnsetSeparationGameState();
}

class _OnsetSeparationGameState extends State<OnsetSeparationGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _showSeparationAnimation = false;

  late AnimationController _separationController;
  late Animation<double> _separationAnimation;
  late AnimationController _feedbackController;

  final List<_OnsetQuestion> _questions = [
    _OnsetQuestion(
      word: '강아지',
      targetChar: '강',
      correctOnset: 'ㄱ',
      options: ['ㄱ', 'ㄴ', 'ㄷ'],
      emoji: '🐕',
    ),
    _OnsetQuestion(
      word: '나비',
      targetChar: '나',
      correctOnset: 'ㄴ',
      options: ['ㄴ', 'ㄹ', 'ㅁ'],
      emoji: '🦋',
    ),
    _OnsetQuestion(
      word: '바나나',
      targetChar: '바',
      correctOnset: 'ㅂ',
      options: ['ㅂ', 'ㅍ', 'ㅁ'],
      emoji: '🍌',
    ),
    _OnsetQuestion(
      word: '사과',
      targetChar: '사',
      correctOnset: 'ㅅ',
      options: ['ㅅ', 'ㅈ', 'ㅊ'],
      emoji: '🍎',
    ),
    _OnsetQuestion(
      word: '토끼',
      targetChar: '토',
      correctOnset: 'ㅌ',
      options: ['ㅌ', 'ㄷ', 'ㅋ'],
      emoji: '🐰',
    ),
    _OnsetQuestion(
      word: '하마',
      targetChar: '하',
      correctOnset: 'ㅎ',
      options: ['ㅎ', 'ㅋ', 'ㄱ'],
      emoji: '🦛',
    ),
    _OnsetQuestion(
      word: '코끼리',
      targetChar: '코',
      correctOnset: 'ㅋ',
      options: ['ㅋ', 'ㄱ', 'ㅌ'],
      emoji: '🐘',
    ),
    _OnsetQuestion(
      word: '기린',
      targetChar: '기',
      correctOnset: 'ㄱ',
      options: ['ㄱ', 'ㅋ', 'ㄲ'],
      emoji: '🦒',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _questions.shuffle(Random());

    _separationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _separationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _separationController, curve: Curves.easeOut),
    );

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _separationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectAnswer(String selected) {
    if (_showFeedback) return;

    final question = _questions[_currentQuestionIndex];
    final correct = selected == question.correctOnset;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) _correctCount++;
    });

    if (correct) {
      _separationController.forward();
    }
    _feedbackController.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      _separationController.reset();
      _feedbackController.reset();

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _showFeedback = false;
          _showSeparationAnimation = false;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showHint() {
    setState(() {
      _showSeparationAnimation = true;
    });
    _separationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _separationController.reverse();
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
            const SizedBox(height: 16),
            Text(
              accuracy >= 80
                  ? '초성 분리를 잘 했어요! 👏'
                  : '조금 더 연습해봐요! 💪',
              style: const TextStyle(fontSize: 16),
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
        title: const Text('초성 분리 게임'),
        backgroundColor: Colors.indigo.shade400,
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
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 진행 바
                _buildProgressBar(),
                const SizedBox(height: 40),

                // 이모지와 단어
                _buildWordDisplay(question),
                const SizedBox(height: 32),

                // 질문
                Text(
                  '"${question.targetChar}"의 첫 소리는?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.neutralGray800,
                  ),
                ),
                const SizedBox(height: 8),

                // 힌트 버튼
                TextButton.icon(
                  onPressed: _showHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('힌트 보기'),
                ),
                const SizedBox(height: 32),

                // 선택지
                _buildOptions(question),
                const SizedBox(height: 40),

                // 피드백
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
        valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400),
      ),
    );
  }

  Widget _buildWordDisplay(_OnsetQuestion question) {
    return AnimatedBuilder(
      animation: _separationAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // 이모지
            Text(
              question.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),

            // 단어와 초성 분리 애니메이션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showSeparationAnimation || (_showFeedback && _isCorrect))
                  Transform.translate(
                    offset: Offset(
                      -30 * _separationAnimation.value,
                      -20 * _separationAnimation.value,
                    ),
                    child: Opacity(
                      opacity: _separationAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade400, width: 2),
                        ),
                        child: Text(
                          question.correctOnset,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  child: Text(
                    question.word,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.neutralGray800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptions(_OnsetQuestion question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: question.options.map((option) {
        final isSelected = _showFeedback;
        final isCorrectOption = option == question.correctOnset;

        Color backgroundColor = Colors.white;
        Color borderColor = Colors.grey.shade300;

        if (isSelected) {
          if (isCorrectOption) {
            backgroundColor = Colors.green.shade100;
            borderColor = Colors.green;
          }
        }

        return GestureDetector(
          onTap: () => _selectAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 3),
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
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isSelected && isCorrectOption
                      ? Colors.green.shade700
                      : DesignSystem.neutralGray800,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(_OnsetQuestion question) {
    return AnimatedOpacity(
      opacity: _showFeedback ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
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
                  ? '정답! "${question.targetChar}"의 첫 소리는 ${question.correctOnset}!'
                  : '다시 생각해봐요! 정답은 ${question.correctOnset}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isCorrect ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnsetQuestion {
  final String word;
  final String targetChar;
  final String correctOnset;
  final List<String> options;
  final String emoji;

  _OnsetQuestion({
    required this.word,
    required this.targetChar,
    required this.correctOnset,
    required this.options,
    required this.emoji,
  });
}

