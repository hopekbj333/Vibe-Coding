import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

class DividedAttentionGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;
  const DividedAttentionGameV2({super.key, required this.childId, required this.onAnswer, this.onComplete, this.difficultyLevel = 1});
  @override
  State<DividedAttentionGameV2> createState() => _DividedAttentionGameV2State();
}

class _DividedAttentionGameV2State extends State<DividedAttentionGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
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
      final content = await _loaderService.loadFromLocalJson('divided_attention.json');
      setState(() { _content = content; _isLoading = false; _questionStartTime = DateTime.now(); });
    } catch (e) {
      setState(() { _errorMessage = '문항을 불러올 수 없습니다: $e'; _isLoading = false; });
    }
  }

  void _onOptionSelected(int index) {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    final selectedOption = currentItem.options[index];
    final isCorrect = currentItem.correctAnswer == selectedOption.optionId;
    setState(() { _selectedOptionIndex = index; _answered = true; _isCorrect = isCorrect; });
    widget.onAnswer(isCorrect, responseTime);
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() { _currentQuestionIndex++; _selectedOptionIndex = null; _answered = false; _isCorrect = null; _questionStartTime = DateTime.now(); });
      } else { widget.onComplete?.call(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError), const SizedBox(height: 16), Text(_errorMessage!, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도'))]));

    final currentItem = _content!.items[_currentQuestionIndex];
    return Stack(children: [Column(children: [Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()), const SizedBox(height: 24), Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.pink.shade100, borderRadius: BorderRadius.circular(16)), child: Text(currentItem.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center)), const SizedBox(height: 60), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [const Text('👈\n⭐', style: TextStyle(fontSize: 48), textAlign: TextAlign.center), const Text('👉\n●', style: TextStyle(fontSize: 48), textAlign: TextAlign.center)]), const SizedBox(height: 60), Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: currentItem.options.length, itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildOptionCard(index))))]), if (_answered && _isCorrect != null) FeedbackWidget(type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect, message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : FeedbackMessages.getRandomIncorrectMessage())]);
  }

  Widget _buildOptionCard(int index) {
    final option = _content!.items[_currentQuestionIndex].options[index];
    final isSelected = _selectedOptionIndex == index;
    Color borderColor = Colors.grey.shade300;
    Color backgroundColor = Colors.white;
    if (isSelected && _answered) { borderColor = _isCorrect! ? DesignSystem.semanticSuccess : DesignSystem.semanticError; backgroundColor = _isCorrect! ? Colors.green.shade50 : Colors.red.shade50; } else if (isSelected) { backgroundColor = Colors.pink.shade50; borderColor = Colors.pink; }
    return GestureDetector(onTap: () => _onOptionSelected(index), child: Container(padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: isSelected ? 3 : 2)), child: Center(child: Text(option.label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)))));
  }

  Widget _buildProgressIndicator() {
    final totalItems = _content!.items.length;
    return Row(children: [Text('${_currentQuestionIndex + 1} / $totalItems', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(width: 16), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / totalItems, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink))))]);
  }
}
