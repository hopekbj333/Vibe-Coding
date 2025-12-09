import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 음소 탈락 게임 (S 3.1.3)
/// 
/// "공에서 ㄱ을 빼면?" → 옹/공/강 중 선택
/// 초성/중성/종성 탈락 연습
class PhonemeDeletionGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const PhonemeDeletionGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<PhonemeDeletionGame> createState() => _PhonemeDeletionGameState();
}

class _PhonemeDeletionGameState extends State<PhonemeDeletionGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late AnimationController _deleteController;
  late Animation<double> _deleteAnimation;

  final List<_DeletionQuestion> _questions = [
    // 초성 탈락
    _DeletionQuestion(
      word: '공',
      deletePart: 'ㄱ',
      deleteType: DeletionType.onset,
      result: '옹',
      options: ['옹', '공', '강'],
      emoji: '⚽',
    ),
    _DeletionQuestion(
      word: '밤',
      deletePart: 'ㅂ',
      deleteType: DeletionType.onset,
      result: '암',
      options: ['밤', '암', '밤'],
      emoji: '🌰',
    ),
    _DeletionQuestion(
      word: '산',
      deletePart: 'ㅅ',
      deleteType: DeletionType.onset,
      result: '안',
      options: ['산', '안', '잔'],
      emoji: '⛰️',
    ),
    // 종성 탈락
    _DeletionQuestion(
      word: '감',
      deletePart: 'ㅁ',
      deleteType: DeletionType.coda,
      result: '가',
      options: ['가', '감', '강'],
      emoji: '🍊',
    ),
    _DeletionQuestion(
      word: '달',
      deletePart: 'ㄹ',
      deleteType: DeletionType.coda,
      result: '다',
      options: ['다', '달', '담'],
      emoji: '🌙',
    ),
    _DeletionQuestion(
      word: '강',
      deletePart: 'ㅇ',
      deleteType: DeletionType.coda,
      result: '가',
      options: ['강', '가', '간'],
      emoji: '🌊',
    ),
    _DeletionQuestion(
      word: '빵',
      deletePart: 'ㅇ',
      deleteType: DeletionType.coda,
      result: '빠',
      options: ['빠', '빵', '반'],
      emoji: '🍞',
    ),
    _DeletionQuestion(
      word: '문',
      deletePart: 'ㄴ',
      deleteType: DeletionType.coda,
      result: '무',
      options: ['문', '무', '물'],
      emoji: '🚪',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _questions.shuffle(Random());

    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _deleteAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _deleteController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _deleteController.dispose();
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
      _deleteController.forward();
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      _deleteController.reset();

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
        title: const Text('음소 탈락 게임'),
        backgroundColor: Colors.orange.shade400,
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
            colors: [Colors.orange.shade50, Colors.white],
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
                const SizedBox(height: 40),
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
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
      ),
    );
  }

  Widget _buildWordDisplay(_DeletionQuestion question) {
    return AnimatedBuilder(
      animation: _deleteAnimation,
      builder: (context, child) {
        final deleteProgress = _showFeedback && _isCorrect ? _deleteAnimation.value : 0.0;

        return Column(
          children: [
            // 이모지
            Text(question.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            // 단어와 탈락 부분
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 원래 단어
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
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 빼기 기호
                const Text('-', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),

                // 탈락 부분
                Transform.translate(
                  offset: Offset(0, -30 * deleteProgress),
                  child: Opacity(
                    opacity: (1 - deleteProgress).clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade400, width: 2),
                      ),
                      child: Text(
                        question.deletePart,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // = 기호
                const Text('=', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),

                // 결과
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: _showFeedback && _isCorrect
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _showFeedback && _isCorrect
                          ? Colors.green
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _showFeedback && _isCorrect ? question.result : '?',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _showFeedback && _isCorrect
                          ? Colors.green.shade700
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 질문
            Text(
              '"${question.word}"에서 ${question.deletePart}을 빼면?',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DesignSystem.neutralGray800,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptions(_DeletionQuestion question) {
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
                  fontSize: 40,
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

  Widget _buildFeedback(_DeletionQuestion question) {
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
                ? '정답! ${question.word} - ${question.deletePart} = ${question.result}'
                : '다시 생각해봐요! 정답은 ${question.result}',
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

enum DeletionType {
  onset,  // 초성 탈락
  coda,   // 종성 탈락
}

class _DeletionQuestion {
  final String word;
  final String deletePart;
  final DeletionType deleteType;
  final String result;
  final List<String> options;
  final String emoji;

  _DeletionQuestion({
    required this.word,
    required this.deletePart,
    required this.deleteType,
    required this.result,
    required this.options,
    required this.emoji,
  });
}

