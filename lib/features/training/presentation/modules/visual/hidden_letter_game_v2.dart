import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 숨은 글자 찾기 게임 (V-01) - JSON 기반 버전
/// 
/// 그리드에서 타겟 글자 모두 찾기
class HiddenLetterGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const HiddenLetterGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<HiddenLetterGameV2> createState() => _HiddenLetterGameV2State();
}

class _HiddenLetterGameV2State extends State<HiddenLetterGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  Set<String> _selectedOptions = {};
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
      final content = await _loaderService.loadFromLocalJson('hidden_letter.json');
      
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

  void _onCellTapped(String optionId, bool isTarget) {
    if (_answered) return;

    setState(() {
      if (_selectedOptions.contains(optionId)) {
        _selectedOptions.remove(optionId);
      } else {
        _selectedOptions.add(optionId);
      }
    });
  }

  void _checkAnswer() {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    
    // correctAnswer는 "g1,g4,g8,g10" 형식
    final correctIds = currentItem.correctAnswer.split(',').toSet();
    final isCorrect = _selectedOptions.length == correctIds.length && _selectedOptions.containsAll(correctIds);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptions.clear();
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
    final target = currentItem.itemData?['target'] as String? ?? '?';

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
                color: DesignSystem.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("'$target'을(를) 모두 찾으세요", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${_selectedOptions.length}개 선택됨', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 그리드
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: currentItem.options.length,
                itemBuilder: (context, index) => _buildGridCell(index),
              ),
            ),

            // 확인 버튼
            if (!_answered)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _selectedOptions.isEmpty ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primaryOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  ),
                  child: const Text('확인', style: TextStyle(fontSize: 20)),
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

  Widget _buildGridCell(int index) {
    final option = _content!.items[_currentQuestionIndex].options[index];
    final isTarget = option.optionData?['isTarget'] == true;
    final isSelected = _selectedOptions.contains(option.optionId);

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (_answered) {
      if (isTarget) {
        backgroundColor = Colors.green.shade100;
        borderColor = DesignSystem.semanticSuccess;
      }
      if (isSelected && !isTarget) {
        backgroundColor = Colors.red.shade100;
        borderColor = DesignSystem.semanticError;
      }
    } else if (isSelected) {
      backgroundColor = Colors.orange.shade50;
      borderColor = DesignSystem.primaryOrange;
    }

    return GestureDetector(
      onTap: () => _onCellTapped(option.optionId, isTarget),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
        ),
        child: Center(
          child: Text(option.label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
              valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryOrange),
            ),
          ),
        ),
      ],
    );
  }
}
