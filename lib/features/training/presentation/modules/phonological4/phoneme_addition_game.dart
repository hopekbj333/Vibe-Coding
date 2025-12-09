import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 음소 추가 게임 (S 3.1.5)
/// 
/// "아에 ㄱ을 붙이면?" → 가
/// 빈 블록에 음소 드래그하여 완성
class PhonemeAdditionGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const PhonemeAdditionGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<PhonemeAdditionGame> createState() => _PhonemeAdditionGameState();
}

class _PhonemeAdditionGameState extends State<PhonemeAdditionGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late AnimationController _addController;
  late Animation<double> _addAnimation;

  final List<_AdditionQuestion> _questions = [
    // 초성 추가
    _AdditionQuestion(
      baseSound: '아',
      addPart: 'ㄱ',
      addType: AdditionType.onset,
      result: '가',
      options: ['ㄱ', 'ㄴ', 'ㄷ'],
      emoji: '🍎',
    ),
    _AdditionQuestion(
      baseSound: '아',
      addPart: 'ㄴ',
      addType: AdditionType.onset,
      result: '나',
      options: ['ㄴ', 'ㅁ', 'ㄹ'],
      emoji: '🌳',
    ),
    _AdditionQuestion(
      baseSound: '아',
      addPart: 'ㅁ',
      addType: AdditionType.onset,
      result: '마',
      options: ['ㅁ', 'ㅂ', 'ㅍ'],
      emoji: '🐴',
    ),
    _AdditionQuestion(
      baseSound: '오',
      addPart: 'ㅅ',
      addType: AdditionType.onset,
      result: '소',
      options: ['ㅅ', 'ㅈ', 'ㅊ'],
      emoji: '🐄',
    ),
    // 종성 추가
    _AdditionQuestion(
      baseSound: '가',
      addPart: 'ㅁ',
      addType: AdditionType.coda,
      result: '감',
      options: ['ㅁ', 'ㄴ', 'ㅇ'],
      emoji: '🍊',
    ),
    _AdditionQuestion(
      baseSound: '다',
      addPart: 'ㄹ',
      addType: AdditionType.coda,
      result: '달',
      options: ['ㄹ', 'ㄴ', 'ㅁ'],
      emoji: '🌙',
    ),
    _AdditionQuestion(
      baseSound: '바',
      addPart: 'ㅂ',
      addType: AdditionType.coda,
      result: '밥',
      options: ['ㅂ', 'ㄱ', 'ㅍ'],
      emoji: '🍚',
    ),
    _AdditionQuestion(
      baseSound: '사',
      addPart: 'ㄴ',
      addType: AdditionType.coda,
      result: '산',
      options: ['ㄴ', 'ㅁ', 'ㅇ'],
      emoji: '⛰️',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _questions.shuffle(Random());

    _addController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _addAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _addController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _selectAnswer(String selected) {
    if (_showFeedback) return;

    final question = _questions[_currentQuestionIndex];
    final correct = selected == question.addPart;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) _correctCount++;
    });

    if (correct) {
      _addController.forward();
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      _addController.reset();

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
        title: const Text('음소 추가 게임'),
        backgroundColor: Colors.green.shade400,
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
            colors: [Colors.green.shade50, Colors.white],
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
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
      ),
    );
  }

  Widget _buildWordDisplay(_AdditionQuestion question) {
    return AnimatedBuilder(
      animation: _addAnimation,
      builder: (context, child) {
        final addProgress = _showFeedback && _isCorrect ? _addAnimation.value : 0.0;

        return Column(
          children: [
            // 이모지
            Text(question.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),

            // 질문
            Text(
              question.addType == AdditionType.onset
                  ? '"${question.baseSound}"에 무엇을 붙이면 "${question.result}"?'
                  : '"${question.baseSound}" 뒤에 무엇을 붙이면 "${question.result}"?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignSystem.neutralGray800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 추가 과정
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (question.addType == AdditionType.onset) ...[
                  // 빈 블록 → 채워지는 음소
                  Transform.translate(
                    offset: Offset(20 * addProgress, 0),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: addProgress > 0
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: addProgress > 0 ? Colors.green : Colors.grey.shade400,
                          width: 2,
                          style: addProgress > 0 ? BorderStyle.solid : BorderStyle.none,
                        ),
                      ),
                      child: Center(
                        child: addProgress > 0.3
                            ? Text(
                                question.addPart,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              )
                            : Icon(
                                Icons.add,
                                size: 32,
                                color: Colors.grey.shade400,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // + 기호
                Opacity(
                  opacity: (1 - addProgress * 0.5).clamp(0.0, 1.0),
                  child: const Text('+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),

                // 기본 음
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Text(
                    question.baseSound,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),

                if (question.addType == AdditionType.coda) ...[
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: (1 - addProgress * 0.5).clamp(0.0, 1.0),
                    child: const Text('+', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  // 빈 블록 → 채워지는 음소
                  Transform.translate(
                    offset: Offset(-20 * addProgress, 0),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: addProgress > 0
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: addProgress > 0 ? Colors.green : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: addProgress > 0.3
                            ? Text(
                                question.addPart,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              )
                            : Icon(
                                Icons.add,
                                size: 32,
                                color: Colors.grey.shade400,
                              ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(width: 12),
                const Text('=', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),

                // 결과
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: addProgress > 0.5 ? Colors.amber.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: addProgress > 0.5 ? Colors.amber : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    addProgress > 0.5 ? question.result : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: addProgress > 0.5 ? Colors.amber.shade800 : Colors.grey,
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

  Widget _buildOptions(_AdditionQuestion question) {
    return Column(
      children: [
        const Text(
          '어떤 소리를 붙여야 할까요?',
          style: TextStyle(fontSize: 16, color: DesignSystem.neutralGray500),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: question.options.map((option) {
            final isCorrect = option == question.addPart;
            final showCorrect = _showFeedback && isCorrect;

            return GestureDetector(
              onTap: () => _selectAnswer(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: showCorrect ? Colors.green.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
        ),
      ],
    );
  }

  Widget _buildFeedback(_AdditionQuestion question) {
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
                ? '정답! ${question.addPart} + ${question.baseSound} = ${question.result}'
                : '다시 생각해봐요! 정답은 ${question.addPart}',
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

enum AdditionType {
  onset,  // 초성 추가
  coda,   // 종성 추가
}

class _AdditionQuestion {
  final String baseSound;
  final String addPart;
  final AdditionType addType;
  final String result;
  final List<String> options;
  final String emoji;

  _AdditionQuestion({
    required this.baseSound,
    required this.addPart,
    required this.addType,
    required this.result,
    required this.options,
    required this.emoji,
  });
}

