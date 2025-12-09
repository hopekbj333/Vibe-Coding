import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 음소 합성 게임 (S 3.1.2)
/// 
/// ㄱ + ㅏ = ? → 가/나/다 그림 중 선택
/// 블록이 합쳐지는 애니메이션
class PhonemeSynthesisGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const PhonemeSynthesisGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<PhonemeSynthesisGame> createState() => _PhonemeSynthesisGameState();
}

class _PhonemeSynthesisGameState extends State<PhonemeSynthesisGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late AnimationController _mergeController;
  late Animation<double> _mergeAnimation;

  final List<_SynthesisQuestion> _questions = [
    _SynthesisQuestion(
      onset: 'ㄱ',
      vowel: 'ㅏ',
      coda: null,
      result: '가',
      options: [
        _SynthesisOption('가', '🍎'),
        _SynthesisOption('나', '🌸'),
        _SynthesisOption('다', '⭐'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㄴ',
      vowel: 'ㅏ',
      coda: null,
      result: '나',
      options: [
        _SynthesisOption('나', '🌳'),
        _SynthesisOption('다', '🌙'),
        _SynthesisOption('라', '🎵'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㅁ',
      vowel: 'ㅏ',
      coda: null,
      result: '마',
      options: [
        _SynthesisOption('바', '🍌'),
        _SynthesisOption('마', '🐴'),
        _SynthesisOption('사', '🦁'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㅅ',
      vowel: 'ㅏ',
      coda: null,
      result: '사',
      options: [
        _SynthesisOption('사', '🦁'),
        _SynthesisOption('자', '🚗'),
        _SynthesisOption('차', '🚌'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㄱ',
      vowel: 'ㅏ',
      coda: 'ㅁ',
      result: '감',
      options: [
        _SynthesisOption('감', '🍊'),
        _SynthesisOption('강', '🌊'),
        _SynthesisOption('갈', '🍂'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㅂ',
      vowel: 'ㅏ',
      coda: 'ㅂ',
      result: '밥',
      options: [
        _SynthesisOption('반', '🏠'),
        _SynthesisOption('밥', '🍚'),
        _SynthesisOption('발', '🦶'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㅅ',
      vowel: 'ㅏ',
      coda: 'ㄴ',
      result: '산',
      options: [
        _SynthesisOption('산', '⛰️'),
        _SynthesisOption('삼', '3️⃣'),
        _SynthesisOption('살', '🏠'),
      ],
    ),
    _SynthesisQuestion(
      onset: 'ㅎ',
      vowel: 'ㅏ',
      coda: 'ㄴ',
      result: '한',
      options: [
        _SynthesisOption('할', '👴'),
        _SynthesisOption('한', '1️⃣'),
        _SynthesisOption('함', '📦'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _questions.shuffle(Random());

    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _mergeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mergeController.dispose();
    super.dispose();
  }

  void _selectAnswer(_SynthesisOption option) {
    if (_showFeedback) return;

    final question = _questions[_currentQuestionIndex];
    final correct = option.syllable == question.result;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) _correctCount++;
    });

    if (correct) {
      _mergeController.forward();
    }

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      _mergeController.reset();

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _showFeedback = false;
        });
      } else {
        _showResultDialog();
      }
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
                  ? '음소 합성을 잘 했어요! 👏'
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
        title: const Text('음소 합성 게임'),
        backgroundColor: Colors.purple.shade400,
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
            colors: [Colors.purple.shade50, Colors.white],
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

                // 음소 블록들
                _buildPhonemeBlocks(question),
                const SizedBox(height: 40),

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
        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
      ),
    );
  }

  Widget _buildPhonemeBlocks(_SynthesisQuestion question) {
    return AnimatedBuilder(
      animation: _mergeAnimation,
      builder: (context, child) {
        final mergeProgress = _showFeedback && _isCorrect ? _mergeAnimation.value : 0.0;

        return Column(
          children: [
            const Text(
              '소리를 합치면?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DesignSystem.neutralGray800,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 초성 블록
                Transform.translate(
                  offset: Offset(30 * mergeProgress, 0),
                  child: _buildPhonemeBlock(question.onset, Colors.red.shade100, Colors.red),
                ),
                
                // + 기호
                Opacity(
                  opacity: (1 - mergeProgress).clamp(0.0, 1.0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                ),

                // 중성 블록
                Transform.translate(
                  offset: Offset(-20 * mergeProgress, 0),
                  child: _buildPhonemeBlock(question.vowel, Colors.blue.shade100, Colors.blue),
                ),

                // 종성이 있는 경우
                if (question.coda != null) ...[
                  Opacity(
                    opacity: 1 - mergeProgress,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(-50 * mergeProgress, 0),
                    child: _buildPhonemeBlock(question.coda!, Colors.green.shade100, Colors.green),
                  ),
                ],

                // = 기호
                Opacity(
                  opacity: 1 - mergeProgress,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('=', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                ),

                // ? 또는 결과
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: mergeProgress > 0.5
                      ? Container(
                          key: const ValueKey('result'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber, width: 3),
                          ),
                          child: Text(
                            question.result,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('question'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade400, width: 3),
                          ),
                          child: const Text(
                            '?',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildPhonemeBlock(String phoneme, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        phoneme,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: borderColor.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildOptions(_SynthesisQuestion question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: question.options.map((option) {
        final isCorrect = option.syllable == question.result;
        final showCorrect = _showFeedback && isCorrect;

        return GestureDetector(
          onTap: () => _selectAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            padding: const EdgeInsets.all(12),
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
            child: Column(
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  option.syllable,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: showCorrect ? Colors.green.shade700 : DesignSystem.neutralGray800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedback(_SynthesisQuestion question) {
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
                ? '정답! ${question.onset}+${question.vowel}${question.coda != null ? '+${question.coda}' : ''}=${question.result}'
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

class _SynthesisQuestion {
  final String onset;      // 초성
  final String vowel;      // 중성
  final String? coda;      // 종성 (선택)
  final String result;     // 결과 음절
  final List<_SynthesisOption> options;

  _SynthesisQuestion({
    required this.onset,
    required this.vowel,
    this.coda,
    required this.result,
    required this.options,
  });
}

class _SynthesisOption {
  final String syllable;
  final String emoji;

  _SynthesisOption(this.syllable, this.emoji);
}

