import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 박수로 음절 쪼개기 게임 (S 2.5.1) - JSON 기반 버전
/// 
/// 단어를 듣고 음절 수만큼 탭합니다.
/// JSON 파일에서 문항을 로드합니다.
class SyllableClapGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const SyllableClapGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<SyllableClapGameV2> createState() => _SyllableClapGameV2State();
}

class _SyllableClapGameV2State extends State<SyllableClapGameV2>
    with TickerProviderStateMixin {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  int _tapCount = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isPlaying = false;
  bool _canTap = false;
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _clapController;
  late Animation<double> _clapAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    
    _clapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _clapAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _clapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _clapController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('syllable_clap.json');
      
      // 난이도에 맞는 문항만 필터링
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

  void _playWord() {
    if (_isPlaying || _canTap) return;
    
    final item = _content!.items[_currentQuestionIndex];
    
    setState(() {
      _isPlaying = true;
      _tapCount = 0;
    });
    
    debugPrint('Playing: ${item.question} (${item.questionAudioPath})');
    
    // 시뮬레이션: 단어 재생 후 탭 가능
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _canTap = true;
        });
      }
    });
  }

  void _onTap() {
    if (!_canTap || _answered) return;
    
    _clapController.forward().then((_) {
      _clapController.reverse();
    });
    
    setState(() {
      _tapCount++;
    });
    
    final item = _content!.items[_currentQuestionIndex];
    final correctCount = int.parse(item.correctAnswer);
    
    // 탭 수가 음절 수와 같으면 자동으로 확인
    if (_tapCount == correctCount) {
      _checkAnswer();
    } else if (_tapCount > correctCount) {
      // 너무 많이 탭하면 오답
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    if (_answered) return;
    
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final item = _content!.items[_currentQuestionIndex];
    final correctCount = int.parse(item.correctAnswer);
    final isCorrect = _tapCount == correctCount;

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _canTap = false;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 2), () {
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _tapCount = 0;
          _answered = false;
          _isCorrect = null;
          _canTap = false;
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

    return Stack(
      children: [
        GestureDetector(
          onTap: _canTap ? _onTap : null,
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressIndicator(),

                const SizedBox(height: 24),

                // 안내
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DesignSystem.childFriendlyPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '👏 박수로 쪼개기!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _content!.instruction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 단어 표시
                _buildWordArea(currentItem),

                const SizedBox(height: 32),

                // 탭 영역
                _buildTapArea(currentItem),

                const SizedBox(height: 24),

                // 듣기 버튼
                if (!_canTap && !_answered)
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? null : _playWord,
                    icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
                    label: Text(_isPlaying ? '듣는 중...' : '단어 듣기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.childFriendlyPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),

                // 확인 버튼
                if (_canTap && _tapCount > 0 && !_answered)
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect!
                ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage()
                : '정답: ${currentItem.correctAnswer}개',
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

  Widget _buildWordArea(ContentItem item) {
    final emoji = item.itemData?['emoji'] as String? ?? '📝';
    final syllables = item.itemData?['syllables'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          Text(
            item.question,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_answered && syllables.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: syllables.map((syllable) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: DesignSystem.semanticSuccess.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DesignSystem.semanticSuccess),
                  ),
                  child: Text(
                    syllable.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.semanticSuccess,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTapArea(ContentItem item) {
    return AnimatedBuilder(
      animation: _clapAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _clapAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _canTap
                  ? DesignSystem.childFriendlyPurple
                  : Colors.grey.shade300,
              boxShadow: _canTap
                  ? [
                      BoxShadow(
                        color: DesignSystem.childFriendlyPurple.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 60,
                  color: _canTap ? Colors.white : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  _canTap ? '탭! $_tapCount' : '먼저 들어보세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _canTap ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
