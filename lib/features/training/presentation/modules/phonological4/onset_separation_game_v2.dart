import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 초성 분리 게임 (P-08) - JSON 기반 버전
/// 
/// "강아지의 첫소리는?" → ㄱ/ㄴ/ㄷ 중 선택
class OnsetSeparationGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const OnsetSeparationGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<OnsetSeparationGameV2> createState() => _OnsetSeparationGameV2State();
}

class _OnsetSeparationGameV2State extends State<OnsetSeparationGameV2> {
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
      final content = await _loaderService.loadFromLocalJson('onset_separation.json');
      
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

  void _onOptionSelected(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    final selectedOption = currentItem.options[index];
    
    final isCorrect = currentItem.correctAnswer == selectedOption.optionId;

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    // 피드백 후 다음 문제로
    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
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
    final emoji = currentItem.itemData?['emoji'] as String? ?? '📝';

    return Stack(
      children: [
        Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
            const SizedBox(height: 24),
            
            // 질문
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(currentItem.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 옵션
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: currentItem.options.length,
                itemBuilder: (context, index) => _buildOptionCard(index),
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

  Widget _buildOptionCard(int index) {
    final option = _content!.items[_currentQuestionIndex].options[index];
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = _answered && _content!.items[_currentQuestionIndex].correctAnswer == option.optionId;

    Color borderColor = Colors.grey.shade300;
    if (isSelected && _answered) {
      borderColor = _isCorrect! ? DesignSystem.semanticSuccess : DesignSystem.semanticError;
    }

    return GestureDetector(
      onTap: () => _onOptionSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 4 : 2),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(option.label, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
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
              valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}
