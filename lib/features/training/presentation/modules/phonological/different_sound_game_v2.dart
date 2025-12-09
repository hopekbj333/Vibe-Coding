import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 다른 소리 찾기 게임 (S 2.3.2) - JSON 기반 버전
/// 
/// 3개의 소리 중 1개만 다른 것을 찾아 터치합니다.
/// JSON 파일에서 문항을 로드합니다.
class DifferentSoundGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const DifferentSoundGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<DifferentSoundGameV2> createState() => _DifferentSoundGameV2State();
}

class _DifferentSoundGameV2State extends State<DifferentSoundGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  int? _selectedIndex;
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
      final content = await _loaderService.loadFromLocalJson('different_sound.json');
      
      final filteredItems = content.items.where((item) {
        final itemLevel = item.itemData?['level'] as int? ?? 1;
        return itemLevel <= widget.difficultyLevel;
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

  void _onSoundTap(int index) {
    if (_answered) return;

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    final correctIndex = int.parse(currentItem.correctAnswer.replaceAll('opt', '')) - 1;
    final isCorrect = index == correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedIndex = null;
          _answered = false;
          _isCorrect = null;
          _questionStartTime = DateTime.now();
        });
      } else {
        widget.onComplete?.call();
      }
    });
  }

  void _playSound(int index) {
    final currentItem = _content!.items[_currentQuestionIndex];
    final audioPath = currentItem.options[index].audioPath;
    debugPrint('Playing sound: $audioPath');
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
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final currentItem = _content!.items[_currentQuestionIndex];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('🎯 다른 소리를 찾아주세요!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_content!.instruction,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(currentItem.options.length, (index) {
                  return _buildSoundCard(index, currentItem);
                }),
              ),
            ],
          ),
        ),
        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage()
                : FeedbackMessages.getRandomIncorrectMessage(),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Text('${_currentQuestionIndex + 1} / ${_content!.items.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _content!.items.length,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.semanticWarning),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundCard(int index, ContentItem item) {
    final option = item.options[index];
    final isSelected = _selectedIndex == index;
    final correctIndex = int.parse(item.correctAnswer.replaceAll('opt', '')) - 1;
    final isCorrectAnswer = correctIndex == index;
    final showCorrect = _answered && isCorrectAnswer;
    final showWrong = _answered && isSelected && !isCorrectAnswer;

    return GestureDetector(
      onTap: () {
        _playSound(index);
        _onSoundTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: showCorrect
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : showWrong
                  ? DesignSystem.semanticError.withOpacity(0.2)
                  : isSelected
                      ? DesignSystem.semanticWarning.withOpacity(0.2)
                      : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showCorrect
                ? DesignSystem.semanticSuccess
                : showWrong
                    ? DesignSystem.semanticError
                    : isSelected
                        ? DesignSystem.semanticWarning
                        : Colors.grey.shade300,
            width: isSelected || showCorrect || showWrong ? 3 : 2,
          ),
          boxShadow: [
            if (!_answered)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, size: 40,
                color: isSelected ? DesignSystem.semanticWarning : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(option.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: isSelected ? DesignSystem.semanticWarning : Colors.black87),
                textAlign: TextAlign.center),
            if (showCorrect || showWrong) ...[
              const SizedBox(height: 8),
              Icon(showCorrect ? Icons.check_circle : Icons.cancel,
                  color: showCorrect ? DesignSystem.semanticSuccess : DesignSystem.semanticError,
                  size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
