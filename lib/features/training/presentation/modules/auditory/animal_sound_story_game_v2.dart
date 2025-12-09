import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 동물 소리 이야기 게임 (A-01) - JSON 기반 버전
/// 
/// 동물들이 나오는 순서를 기억하고 재현
class AnimalSoundStoryGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const AnimalSoundStoryGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<AnimalSoundStoryGameV2> createState() => _AnimalSoundStoryGameV2State();
}

class _AnimalSoundStoryGameV2State extends State<AnimalSoundStoryGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  List<int> _userSequence = [];
  bool _isShowingDemo = true;
  int _demoIndex = -1;
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
      final content = await _loaderService.loadFromLocalJson('animal_sound_story.json');
      
      // 난이도에 따라 필터링
      final filteredItems = content.items.where((item) {
        final animalCount = item.itemData?['animalCount'] as int? ?? 3;
        return animalCount <= widget.difficultyLevel + 2;
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
      });
      
      _playDemo();
    } catch (e) {
      setState(() {
        _errorMessage = '문항을 불러올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _playDemo() {
    setState(() {
      _isShowingDemo = true;
      _demoIndex = -1;
      _userSequence = [];
    });

    final currentItem = _content!.items[_currentQuestionIndex];
    
    // 순차적으로 동물 표시
    for (int i = 0; i < currentItem.options.length; i++) {
      Future.delayed(Duration(milliseconds: i * 1500), () {
        if (mounted && _isShowingDemo) {
          setState(() => _demoIndex = i);
        }
      });
    }

    // 데모 완료
    Future.delayed(Duration(milliseconds: currentItem.options.length * 1500 + 1000), () {
      if (mounted) {
        setState(() {
          _isShowingDemo = false;
          _demoIndex = -1;
          _questionStartTime = DateTime.now();
        });
      }
    });
  }

  void _onAnimalTapped(int index) {
    if (_answered || _isShowingDemo) return;

    setState(() {
      _userSequence.add(index);
    });

    final currentItem = _content!.items[_currentQuestionIndex];
    
    // 모든 동물을 선택했으면 정답 확인
    if (_userSequence.length >= currentItem.options.length) {
      Future.delayed(const Duration(milliseconds: 500), _checkAnswer);
    }
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    
    // 순서가 맞는지 확인
    bool isCorrect = true;
    for (int i = 0; i < _userSequence.length; i++) {
      if (_userSequence[i] != i) {
        isCorrect = false;
        break;
      }
    }

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
        });
        _playDemo();
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
    final setting = currentItem.itemData?['setting'] as String? ?? '🎯';

    return Stack(
      children: [
        Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
            const SizedBox(height: 24),
            
            // 이야기 제목
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignSystem.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(setting, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 8),
                  Text(_isShowingDemo ? '👀 잘 보세요!' : '👆 순서대로 터치하세요!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(currentItem.question, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 동물 카드들
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: currentItem.options.length <= 3 ? 3 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: currentItem.options.length,
                itemBuilder: (context, index) => _buildAnimalCard(index),
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

  Widget _buildAnimalCard(int index) {
    final option = _content!.items[_currentQuestionIndex].options[index];
    final isHighlighted = _isShowingDemo && _demoIndex == index;
    final isTapped = _userSequence.contains(index);

    return GestureDetector(
      onTap: () => _onAnimalTapped(index),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted ? DesignSystem.primaryGreen.withOpacity(0.3) : (isTapped ? Colors.blue.shade50 : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? DesignSystem.primaryGreen : (isTapped ? Colors.blue : Colors.grey.shade300),
            width: isHighlighted ? 4 : 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.label.split(' ')[0], style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            if (isTapped) 
              Text('${_userSequence.indexOf(index) + 1}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
          ],
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
              valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}
