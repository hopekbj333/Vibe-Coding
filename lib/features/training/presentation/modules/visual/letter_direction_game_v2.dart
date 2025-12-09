import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 글자 방향 구별 게임 (V-02) - JSON 기반 버전
/// 
/// b/d, p/q, ㄱ/ㄴ 등 혼동 글자 구별
class LetterDirectionGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const LetterDirectionGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<LetterDirectionGameV2> createState() => _LetterDirectionGameV2State();
}

class _LetterDirectionGameV2State extends State<LetterDirectionGameV2> {
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
      final content = await _loaderService.loadFromLocalJson('letter_direction.json');
      
      // 난이도 필터링
      final filteredItems = content.items.where((item) {
        final level = item.itemData?['level'] as int? ?? 1;
        return level <= widget.difficultyLevel;
      }).toList();
      
      setState(() {
        _content = TrainingContentModel(
          contentId: content.contentId,
          moduleId: content.moduleId,
          type: content.type,
          pattern: content.pattern,
          title: content.title,
          instruction: content.instruction,
          instructionAudioPath: content.instructionAudioPath,
          items: filteredItems.isNotEmpty ? filteredItems : content.items,
          difficulty: content.difficulty,
          metadata: content.metadata,
        );
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
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(currentItem.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
    Color backgroundColor = Colors.white;
    
    if (isSelected && _answered) {
      borderColor = _isCorrect! ? DesignSystem.semanticSuccess : DesignSystem.semanticError;
      backgroundColor = _isCorrect! ? Colors.green.shade50 : Colors.red.shade50;
    } else if (isSelected) {
      backgroundColor = Colors.pink.shade50;
      borderColor = Colors.pink;
    }

    return GestureDetector(
      onTap: () => _onOptionSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 4 : 2),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(option.label, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ),
        ),
      ],
    );
  }
}
