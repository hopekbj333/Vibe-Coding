import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 빠르기 순서 게임 (A-09) - JSON 기반 버전
class TempoSequenceGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const TempoSequenceGameV2({super.key, required this.childId, required this.onAnswer, this.onComplete, this.difficultyLevel = 1});

  @override
  State<TempoSequenceGameV2> createState() => _TempoSequenceGameV2State();
}

class _TempoSequenceGameV2State extends State<TempoSequenceGameV2> {
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
      final content = await _loaderService.loadFromLocalJson('tempo_sequence.json');
      setState(() { _content = content; _isLoading = false; _questionStartTime = DateTime.now(); });
    } catch (e) {
      setState(() { _errorMessage = '문항을 불러올 수 없습니다: $e'; _isLoading = false; });
    }
  }

  void _onTap(int index) {
    if (_answered) return;
    setState(() { _userSequence.add(index); });
    final currentItem = _content!.items[_currentQuestionIndex];
    if (_userSequence.length == currentItem.options.length) { _checkAnswer(); }
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    final correctSequence = currentItem.itemData?['sequence'] as List? ?? [0, 1, 2];
    final isCorrect = _userSequence.toString() == correctSequence.toString();
    setState(() { _answered = true; _isCorrect = isCorrect; });
    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() { _currentQuestionIndex++; _userSequence = []; _answered = false; _isCorrect = null; _questionStartTime = DateTime.now(); });
      } else { widget.onComplete?.call(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError), const SizedBox(height: 16), Text(_errorMessage!, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도'))]));

    final currentItem = _content!.items[_currentQuestionIndex];

    return Stack(
      children: [
        Column(children: [Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()), const SizedBox(height: 24), Container(margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(16)), child: Text(currentItem.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center)), const SizedBox(height: 40), Wrap(spacing: 16, runSpacing: 16, children: List.generate(currentItem.options.length, (index) => GestureDetector(onTap: () => _onTap(index), child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange, width: 3)), child: Center(child: Text(currentItem.options[index].label, style: const TextStyle(fontSize: 36)))))))]),
        if (_answered && _isCorrect != null) FeedbackWidget(type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect, message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : FeedbackMessages.getRandomIncorrectMessage()),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final totalItems = _content!.items.length;
    return Row(children: [Text('${_currentQuestionIndex + 1} / $totalItems', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(width: 16), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / totalItems, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange))))]);
  }
}
