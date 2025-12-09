import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 청각 주의력 게임 - JSON 기반 버전
class AuditoryAttentionGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const AuditoryAttentionGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<AuditoryAttentionGameV2> createState() => _AuditoryAttentionGameV2State();
}

class _AuditoryAttentionGameV2State extends State<AuditoryAttentionGameV2> {
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
      final content = await _loaderService.loadFromLocalJson('auditory_attention.json');
      
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

  void _onResponse(bool userPressed) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final isCorrect = userPressed; // 샘플이므로 간단히 처리

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
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
            
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('👂 들리면 터치하세요!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(currentItem.question, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 80),

            GestureDetector(
              onTap: () => _onResponse(true),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.cyan.shade300,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: const Center(
                  child: Icon(Icons.touch_app, size: 80, color: Colors.white),
                ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
            ),
          ),
        ),
      ],
    );
  }
}
