import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 사이먼 가라사대 게임 (A-04) - JSON 기반 버전
class SimonSaysGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SimonSaysGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SimonSaysGameV2> createState() => _SimonSaysGameV2State();
}

class _SimonSaysGameV2State extends State<SimonSaysGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  List<int> _userSequence = [];
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('simon_says.json');
      setState(() {
        _content = content;
        _isLoading = false;
        _questionStartTime = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '문항을 불러올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _onColorTap(int index) {
    if (_answered) return;

    setState(() {
      _userSequence.add(index);
    });

    final currentItem = _content!.items[_currentQuestionIndex];
    final sequence = currentItem.itemData?['sequence'] as List? ?? [0, 1, 2];
    
    if (_userSequence.length == sequence.length) {
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    final correctSequence = currentItem.itemData?['sequence'] as List? ?? [0, 1, 2];
    final isCorrect = _userSequence.toString() == correctSequence.toString();

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _userSequence = [];
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
            const Spacer(),
            
            const Text('💡 사이먼 가라사대!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(currentItem.question, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),

            const SizedBox(height: 60),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: List.generate(
                currentItem.options.length,
                (index) => _buildColorButton(index),
              ),
            ),

            const SizedBox(height: 40),

            if (_userSequence.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _userSequence.map((i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getColor(i),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const Spacer(),
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

  Color _getColor(int index) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
    return colors[index % colors.length];
  }

  Widget _buildColorButton(int index) {
    final option = _content!.items[_currentQuestionIndex].options[index];

    return GestureDetector(
      onTap: () => _onColorTap(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _getColor(index),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Text(option.label, style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
            ),
          ),
        ),
      ],
    );
  }
}
