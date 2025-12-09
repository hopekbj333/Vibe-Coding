import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 퍼즐 게임 - JSON 기반 버전
class PuzzleGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const PuzzleGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<PuzzleGameV2> createState() => _PuzzleGameV2State();
}

class _PuzzleGameV2State extends State<PuzzleGameV2> {
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
      final content = await _loaderService.loadFromLocalJson('puzzle.json');
      
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

  void _onComplete() {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;

    setState(() {
      _answered = true;
      _isCorrect = true;
    });

    widget.onAnswer(true, responseTime);

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
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🧩 퍼즐을 맞추세요!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(currentItem.question, style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 간단한 퍼즐 시뮬레이션
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple, width: 3),
                      ),
                      child: Center(
                        child: Text('${index + 1}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _answered ? null : _onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                ),
                child: const Text('완성!', style: TextStyle(fontSize: 24, color: Colors.white)),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
        ),
      ],
    );
  }
}
