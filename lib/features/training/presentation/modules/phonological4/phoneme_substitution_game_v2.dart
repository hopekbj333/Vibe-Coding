import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 음소 대치 게임 - JSON 기반 버전
class PhonemeSubstitutionGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const PhonemeSubstitutionGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<PhonemeSubstitutionGameV2> createState() => _PhonemeSubstitutionGameV2State();
}

class _PhonemeSubstitutionGameV2State extends State<PhonemeSubstitutionGameV2> {
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
      final content = await _loaderService.loadFromLocalJson('phoneme_substitution.json');
      
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

  void _onShowAnswer() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _onConfirm(bool userSaysCorrect) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    
    setState(() {
      _answered = true;
      _isCorrect = userSaysCorrect;
    });

    widget.onAnswer(userSaysCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _isCorrect = null;
          _showAnswer = false;
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
            
            const Text('🔤 소리를 바꿔보세요!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(currentItem.question, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),

            const SizedBox(height: 40),

            if (!_showAnswer && !_answered)
              ElevatedButton(
                onPressed: _onShowAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('정답 보기', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),

            if (_showAnswer)
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('정답:', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(currentItem.correctAnswer, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            if (_showAnswer && !_answered)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _onConfirm(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('맞게 말했어요', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _onConfirm(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('다시 해볼래요', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),

            const Spacer(),
          ],
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : '다시 한번 해봐요!',
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}
