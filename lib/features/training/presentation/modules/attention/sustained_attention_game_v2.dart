import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

class SustainedAttentionGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;
  const SustainedAttentionGameV2({super.key, required this.childId, required this.onAnswer, this.onComplete, this.difficultyLevel = 1});
  @override
  State<SustainedAttentionGameV2> createState() => _SustainedAttentionGameV2State();
}

class _SustainedAttentionGameV2State extends State<SustainedAttentionGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
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
      final content = await _loaderService.loadFromLocalJson('sustained_attention.json');
      setState(() { _content = content; _isLoading = false; _questionStartTime = DateTime.now(); });
      Timer(const Duration(seconds: 5), () { if (mounted && !_answered) _onComplete(); });
    } catch (e) {
      setState(() { _errorMessage = '문항을 불러올 수 없습니다: $e'; _isLoading = false; });
    }
  }

  void _onComplete() {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    setState(() { _answered = true; _isCorrect = true; });
    widget.onAnswer(true, responseTime);
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() { _currentQuestionIndex++; _answered = false; _isCorrect = null; _questionStartTime = DateTime.now(); });
        Timer(const Duration(seconds: 5), () { if (mounted && !_answered) _onComplete(); });
      } else { widget.onComplete?.call(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError), const SizedBox(height: 16), Text(_errorMessage!, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도'))]));

    final currentItem = _content!.items[_currentQuestionIndex];
    return Stack(children: [Column(mainAxisAlignment: MainAxisAlignment.center, children: [Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()), const Spacer(), Container(padding: const EdgeInsets.all(24), margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)), child: Text(currentItem.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center)), const SizedBox(height: 40), const Text('🔴', style: TextStyle(fontSize: 100)), const SizedBox(height: 40), const Text('집중하세요!\n(5초 후 자동 완료)', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center), const Spacer()]), if (_answered && _isCorrect != null) FeedbackWidget(type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect, message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : FeedbackMessages.getRandomIncorrectMessage())]);
  }

  Widget _buildProgressIndicator() {
    final totalItems = _content!.items.length;
    return Row(children: [Text('${_currentQuestionIndex + 1} / $totalItems', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(width: 16), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / totalItems, minHeight: 8, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(Colors.red))))]);
  }
}
