import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

class ComplexSpanGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;
  const ComplexSpanGameV2({super.key, required this.childId, required this.onAnswer, this.onComplete, this.difficultyLevel = 1});
  @override
  State<ComplexSpanGameV2> createState() => _ComplexSpanGameV2State();
}

class _ComplexSpanGameV2State extends State<ComplexSpanGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('complex_span.json');
      setState(() { _content = content; _isLoading = false; _questionStartTime = DateTime.now(); });
    } catch (e) {
      setState(() { _errorMessage = '문항을 불러올 수 없습니다: $e'; _isLoading = false; });
    }
  }

  void _onConfirm(bool correct) {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    setState(() { _answered = true; _isCorrect = correct; });
    widget.onAnswer(correct, responseTime);
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() { _currentQuestionIndex++; _showAnswer = false; _answered = false; _isCorrect = null; _questionStartTime = DateTime.now(); });
      } else { widget.onComplete?.call(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError), const SizedBox(height: 16), Text(_errorMessage!, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도'))]));

    final currentItem = _content!.items[_currentQuestionIndex];
    return Stack(children: [Column(mainAxisAlignment: MainAxisAlignment.center, children: [Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()), const Spacer(), const Text('🧮 복합 기억!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 40), Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.deepOrange.shade100, borderRadius: BorderRadius.circular(24)), child: Text(currentItem.question, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 4))), const SizedBox(height: 40), if (!_showAnswer && !_answered) ElevatedButton(onPressed: () => setState(() => _showAnswer = true), style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: const Text('정답 보기', style: TextStyle(fontSize: 20, color: Colors.white))), if (_showAnswer) Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(16)), child: Text(currentItem.correctAnswer, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))), const SizedBox(height: 40), if (_showAnswer && !_answered) Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton(onPressed: () => _onConfirm(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: const Text('맞게 말했어요', style: TextStyle(color: Colors.white))), const SizedBox(width: 16), ElevatedButton(onPressed: () => _onConfirm(false), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: const Text('다시 해볼래요', style: TextStyle(color: Colors.white)))]), const Spacer()]), if (_answered && _isCorrect != null) FeedbackWidget(type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect, message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : '다시 한번 해봐요!')]);
  }

  Widget _buildProgressIndicator() {
    final totalItems = _content!.items.length;
    return Row(children: [Text('${_currentQuestionIndex + 1} / $totalItems', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(width: 16), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / totalItems, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange))))]);
  }
}
