import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 거꾸로 터치하기 게임 (WM-05) - JSON 기반 버전
/// 
/// 시범을 보고 역순으로 터치합니다.
class ReverseTouchGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const ReverseTouchGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<ReverseTouchGameV2> createState() => _ReverseTouchGameV2State();
}

class _ReverseTouchGameV2State extends State<ReverseTouchGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  List<int> _userSequence = [];
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showingDemo = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('reverse_touch.json');
      
      setState(() {
        _content = content;
        _isLoading = false;
        _questionStartTime = DateTime.now();
      });

      // 시범 보여주기
      _showDemo();
    } catch (e) {
      setState(() {
        _errorMessage = '문항을 불러올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showDemo() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _showingDemo = false;
    });
  }

  void _onOptionTap(int index) {
    if (_answered || _showingDemo) return;

    setState(() {
      _userSequence.add(index);
    });

    final currentItem = _content!.items[_currentQuestionIndex];
    final expectedLength = currentItem.options.length;

    // 모든 항목을 선택했으면 정답 확인
    if (_userSequence.length == expectedLength) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    
    // 역순이 맞는지 확인 (간단 버전: 항상 0,1,2 -> 2,1,0)
    final expectedSequence = List.generate(currentItem.options.length, (i) => i).reversed.toList();
    final isCorrect = _userSequence.toString() == expectedSequence.toString();

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _userSequence = [];
          _answered = false;
          _isCorrect = null;
          _showingDemo = true;
          _questionStartTime = DateTime.now();
        });
        _showDemo();
      } else {
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final currentItem = _content!.items[_currentQuestionIndex];

    return Stack(
      children: [
        Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
            const SizedBox(height: 24),
            
            // 지시문
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(_showingDemo ? '👀 잘 보세요!' : '🔄 거꾸로 터치하세요!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(currentItem.question, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // 옵션
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                currentItem.options.length,
                (index) => _buildOptionButton(index),
              ),
            ),

            const SizedBox(height: 40),

            // 사용자 선택 표시
            if (_userSequence.isNotEmpty && !_answered)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _userSequence.map((i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(currentItem.options[i].label, style: const TextStyle(fontSize: 32)),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : FeedbackMessages.getRandomIncorrectMessage(),
          ),
      ],
    );
  }

  Widget _buildOptionButton(int index) {
    final option = _content!.items[_currentQuestionIndex].options[index];
    final isHighlighted = _showingDemo;

    return GestureDetector(
      onTap: () => _onOptionTap(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.yellow.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.teal, width: 3),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(option.label, style: const TextStyle(fontSize: 48)),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalItems = _content!.items.length;
    
    return Row(
      children: [
        Text('${_currentQuestionIndex + 1} / $totalItems', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / totalItems,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
        ),
      ],
    );
  }
}
