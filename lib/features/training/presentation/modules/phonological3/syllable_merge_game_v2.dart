import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 합성 게임 (S 3.1.2) - JSON 기반 버전
/// 
/// 쪼개진 음절을 순서대로 눌러서 단어를 만듭니다.
/// JSON 파일에서 문항을 로드합니다.
class SyllableMergeGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableMergeGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableMergeGameV2> createState() => _SyllableMergeGameV2State();
}

class _SyllableMergeGameV2State extends State<SyllableMergeGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  List<String> _selectedSequence = [];
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
      final content = await _loaderService.loadFromLocalJson('syllable_merge.json');
      
      // 난이도에 맞는 문항만 필터링
      final filteredItems = content.items.where((item) {
        final itemLevel = item.itemData?['syllableCount'] as int? ?? 2;
        return itemLevel <= widget.difficultyLevel + 1;
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

  void _onSyllableTap(String optionId) {
    if (_answered) return;

    setState(() {
      _selectedSequence.add(optionId);

      // 모든 음절을 선택하면 정답 확인
      final currentItem = _content!.items[_currentQuestionIndex];
      if (_selectedSequence.length == currentItem.options.length) {
        _checkAnswer();
      }
    });
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    
    // correctAnswer는 "syl1,syl2,syl3" 형식
    final correctSequence = currentItem.correctAnswer.split(',');
    
    final isCorrect = _selectedSequence.length == correctSequence.length &&
        List.generate(_selectedSequence.length, (i) => i)
            .every((i) => _selectedSequence[i] == correctSequence[i]);

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onAnswer(isCorrect, responseTime);

    // 피드백 후 다음 문제로
    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedSequence = [];
          _answered = false;
          _isCorrect = null;
          _questionStartTime = DateTime.now();
        });
      } else {
        widget.onComplete?.call();
      }
    });
  }

  void _playSound(ContentOption option) {
    // TODO: 실제 오디오 재생 구현
    debugPrint('Playing sound: ${option.audioPath}');
  }

  void _resetSelection() {
    if (_answered) return;
    setState(() {
      _selectedSequence = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignSystem.semanticError,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final currentItem = _content!.items[_currentQuestionIndex];
    final emoji = currentItem.itemData?['emoji'] as String? ?? '📝';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 진행 상황
              _buildProgressIndicator(),
              
              const SizedBox(height: 24),

              // 안내 텍스트
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$emoji 음절을 합쳐보세요!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentItem.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 선택된 음절 표시
              if (_selectedSequence.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignSystem.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ..._selectedSequence.asMap().entries.map((entry) {
                        final option = currentItem.options.firstWhere(
                          (opt) => opt.optionId == entry.value,
                        );
                        return Row(
                          children: [
                            if (entry.key > 0)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Text(
                              option.label,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // 음절 블록들
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: currentItem.options.map((option) {
                  return _buildSyllableBlock(option);
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 다시하기 버튼
              if (_selectedSequence.isNotEmpty && !_answered)
                ElevatedButton.icon(
                  onPressed: _resetSelection,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                  ),
                ),
            ],
          ),
        ),

        // 피드백 오버레이
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
    final totalItems = _content!.items.length;
    
    return Row(
      children: [
        Text(
          '${_currentQuestionIndex + 1} / $totalItems',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / totalItems,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                DesignSystem.primaryOrange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyllableBlock(ContentOption option) {
    final isSelected = _selectedSequence.contains(option.optionId);
    final selectionOrder = _selectedSequence.indexOf(option.optionId) + 1;

    return GestureDetector(
      onTap: isSelected || _answered ? null : () {
        _playSound(option);
        _onSyllableTap(option.optionId);
      },
      child: Opacity(
        opacity: isSelected ? 0.3 : 1.0,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.grey.shade300
                : DesignSystem.primaryOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.grey.shade400
                  : DesignSystem.primaryOrange,
              width: 3,
            ),
            boxShadow: [
              if (!isSelected && !_answered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$selectionOrder',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
