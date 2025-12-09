import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 음절 분리 게임 (S 3.1.3) - JSON 기반 버전
/// 
/// 단어 블록을 터치하면 음절로 쪼개집니다.
/// JSON 파일에서 문항을 로드합니다.
class SyllableSplitGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableSplitGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableSplitGameV2> createState() => _SyllableSplitGameV2State();
}

class _SyllableSplitGameV2State extends State<SyllableSplitGameV2>
    with SingleTickerProviderStateMixin {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  bool _isSplit = false;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _splitAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _splitAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('syllable_split.json');
      
      // 난이도에 맞는 문항만 필터링
      final filteredItems = content.items.where((item) {
        final syllables = item.itemData?['syllables'] as List<dynamic>? ?? [];
        return syllables.length <= widget.difficultyLevel + 1;
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

  void _onWordTap() {
    if (_answered || _isSplit) return;

    setState(() {
      _isSplit = true;
    });

    _animationController.forward();

    // 애니메이션 후 정답 확인
    Timer(const Duration(milliseconds: 800), () {
      _checkAnswer();
    });
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    
    // 터치하면 항상 정답 (단어를 쪼개는 행위 자체가 목표)
    final isCorrect = true;

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
          _isSplit = false;
          _answered = false;
          _isCorrect = null;
          _questionStartTime = DateTime.now();
          _animationController.reset();
        });
      } else {
        widget.onComplete?.call();
      }
    });
  }

  void _playSound() {
    final currentItem = _content!.items[_currentQuestionIndex];
    // TODO: 실제 오디오 재생 구현
    debugPrint('Playing sound: ${currentItem.questionAudioPath}');
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
    final word = currentItem.itemData?['word'] as String? ?? '';
    final syllables = (currentItem.itemData?['syllables'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

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
                  color: DesignSystem.childFriendlyPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$emoji ${currentItem.question}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '단어를 터치해보세요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // 단어 / 음절 블록
              if (!_isSplit)
                _buildWordBlock(emoji, word)
              else
                _buildSyllableBlocks(syllables),

              const SizedBox(height: 60),

              // 힌트
              if (!_isSplit)
                Text(
                  '👆 위의 단어를 터치해보세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
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
                DesignSystem.childFriendlyPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordBlock(String emoji, String word) {
    return GestureDetector(
      onTap: () {
        _playSound();
        _onWordTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: DesignSystem.childFriendlyPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: DesignSystem.childFriendlyPurple,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              word,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllableBlocks(List<String> syllables) {
    return AnimatedBuilder(
      animation: _splitAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: syllables.asMap().entries.map((entry) {
            final index = entry.key;
            final syllable = entry.value;
            final offset = (index - (syllables.length - 1) / 2) * 120 * _splitAnimation.value;
            
            return Transform.translate(
              offset: Offset(offset, 0),
              child: Container(
                width: 80,
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.childFriendlyPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DesignSystem.childFriendlyPurple,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    syllable,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
