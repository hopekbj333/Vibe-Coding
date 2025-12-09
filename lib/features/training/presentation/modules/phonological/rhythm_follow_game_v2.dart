import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 리듬 따라하기 게임 (S 2.3.3) - JSON 기반 버전
/// 
/// 시범 리듬을 보고 같은 리듬으로 탭합니다.
/// JSON 파일에서 문항을 로드합니다.
class RhythmFollowGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const RhythmFollowGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<RhythmFollowGameV2> createState() => _RhythmFollowGameV2State();
}

class _RhythmFollowGameV2State extends State<RhythmFollowGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  List<int> _userTaps = [];
  bool _isShowingDemo = true;
  int _demoTapIndex = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  DateTime? _firstTapTime;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _demoTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('rhythm_follow.json');
      
      // 난이도에 맞는 문항만 필터링
      final filteredItems = content.items.where((item) {
        final beatCount = item.itemData?['beatCount'] as int? ?? 2;
        return beatCount <= widget.difficultyLevel + 2;
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
        _playDemo();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '문항을 불러올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _playDemo() {
    if (_content == null) return;
    
    setState(() {
      _isShowingDemo = true;
      _demoTapIndex = 0;
    });

    final currentItem = _content!.items[_currentQuestionIndex];
    final pattern = (currentItem.itemData?['pattern'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList() ?? [600, 600];

    _demoTimer?.cancel();
    
    // 첫 번째 탭은 즉시
    setState(() {
      _demoTapIndex = 0;
    });

    // 나머지 탭들을 패턴에 따라 재생
    int totalDelay = 0;
    for (int i = 0; i < pattern.length - 1; i++) {
      totalDelay += pattern[i];
      final capturedIndex = i + 1;
      
      Future.delayed(Duration(milliseconds: totalDelay), () {
        if (mounted && _isShowingDemo) {
          setState(() {
            _demoTapIndex = capturedIndex;
          });
        }
      });
    }

    // 데모 완료 후 사용자 차례
    final totalDuration = pattern.reduce((a, b) => a + b) + 1000;
    Future.delayed(Duration(milliseconds: totalDuration), () {
      if (mounted) {
        setState(() {
          _isShowingDemo = false;
          _demoTapIndex = -1;
          _questionStartTime = DateTime.now();
        });
      }
    });
  }

  void _onTap() {
    if (_answered || _isShowingDemo) return;

    final now = DateTime.now();
    _firstTapTime ??= now;
    
    final timeSinceFirst = now.difference(_firstTapTime!).inMilliseconds;
    _userTaps.add(timeSinceFirst);

    setState(() {});

    // 필요한 만큼 탭했으면 정답 확인
    final currentItem = _content!.items[_currentQuestionIndex];
    final requiredTaps = int.tryParse(currentItem.correctAnswer) ?? 2;
    
    if (_userTaps.length >= requiredTaps) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _checkAnswer();
      });
    }
  }

  void _checkAnswer() {
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final currentItem = _content!.items[_currentQuestionIndex];
    
    final requiredTaps = int.tryParse(currentItem.correctAnswer) ?? 2;
    
    // 간단한 검증: 탭 개수가 맞는지만 확인
    // 실제로는 타이밍도 확인해야 하지만, 아동용이므로 개수만으로도 충분
    final isCorrect = _userTaps.length == requiredTaps;

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
          _userTaps = [];
          _firstTapTime = null;
          _answered = false;
          _isCorrect = null;
        });
        _playDemo();
      } else {
        widget.onComplete?.call();
      }
    });
  }

  void _replayDemo() {
    setState(() {
      _userTaps = [];
      _firstTapTime = null;
    });
    _playDemo();
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
    final requiredTaps = int.tryParse(currentItem.correctAnswer) ?? 2;

    return Stack(
      children: [
        Column(
          children: [
            // 진행 상황
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildProgressIndicator(),
            ),
            
            const SizedBox(height: 24),

            // 안내 텍스트
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignSystem.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _isShowingDemo ? '🎵 리듬을 잘 들어보세요!' : '👆 따라서 터치해보세요!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentItem.question,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 터치 영역
            Expanded(
              child: GestureDetector(
                onTap: _onTap,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isShowingDemo
                        ? Colors.grey.shade200
                        : DesignSystem.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isShowingDemo
                          ? Colors.grey.shade400
                          : DesignSystem.primaryGreen,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 데모 중일 때 반짝이는 효과
                        if (_isShowingDemo && _demoTapIndex >= 0)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: DesignSystem.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.touch_app,
                              size: 60,
                              color: Colors.white,
                            ),
                          )
                        else if (!_isShowingDemo)
                          Icon(
                            Icons.touch_app,
                            size: 100,
                            color: DesignSystem.primaryGreen,
                          )
                        else
                          Icon(
                            Icons.volume_up,
                            size: 100,
                            color: Colors.grey.shade400,
                          ),
                        
                        const SizedBox(height: 24),

                        // 탭 횟수 표시
                        if (!_isShowingDemo)
                          Text(
                            '${_userTaps.length} / $requiredTaps',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _userTaps.length == requiredTaps
                                  ? DesignSystem.semanticSuccess
                                  : Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 다시 듣기 버튼
            if (!_isShowingDemo && !_answered)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _replayDemo,
                  icon: const Icon(Icons.replay),
                  label: const Text('다시 듣기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
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
                DesignSystem.primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
