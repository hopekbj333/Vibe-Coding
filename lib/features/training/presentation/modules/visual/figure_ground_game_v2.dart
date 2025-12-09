import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

class FigureGroundGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;
  const FigureGroundGameV2({super.key, required this.childId, required this.onAnswer, this.onComplete, this.difficultyLevel = 1});
  @override
  State<FigureGroundGameV2> createState() => _FigureGroundGameV2State();
}

class _FigureGroundGameV2State extends State<FigureGroundGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;
  Set<int> _foundStars = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('figure_ground.json');
      setState(() { _content = content; _isLoading = false; _questionStartTime = DateTime.now(); });
    } catch (e) {
      setState(() { _errorMessage = '문항을 불러올 수 없습니다: $e'; _isLoading = false; });
    }
  }

  void _onStarClick(int index) {
    if (_answered) return;
    setState(() {
      _foundStars.add(index);
    });
    if (_foundStars.length >= 3) {
      _onComplete();
    }
  }

  void _onComplete() {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    setState(() { _answered = true; _isCorrect = true; });
    widget.onAnswer(true, responseTime);
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() { _currentQuestionIndex++; _answered = false; _isCorrect = null; _foundStars = {}; _questionStartTime = DateTime.now(); });
      } else { widget.onComplete?.call(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError), const SizedBox(height: 16), Text(_errorMessage!, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도'))]));

    final currentItem = _content!.items[_currentQuestionIndex];
    
    // 별이 있는 위치 (0-based index)
    final starPositions = [0, 4, 9, 13, 16, 21, 25, 30, 34, 40];
    
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(currentItem.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text('⭐를 ${_foundStars.length}/3개 찾았어요!', style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.brown, width: 3),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final isStar = starPositions.contains(index);
                    final isFound = _foundStars.contains(index);
                    String emoji;
                    
                    if (isStar) {
                      // 별은 회색으로 위장 (찾으면 노란색으로)
                      emoji = isFound ? '⭐' : '⚫';
                    } else {
                      // 배경 도형들
                      final shapes = ['●', '■', '▲'];
                      emoji = shapes[index % 3];
                    }
                    
                    return GestureDetector(
                      onTap: () {
                        if (isStar && !isFound) {
                          _onStarClick(index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFound ? Colors.yellow.shade100 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFound ? Colors.yellow : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: TextStyle(
                              fontSize: 20,
                              color: isFound ? Colors.orange : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('💡 숨어있는 별을 클릭하세요!', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),
            ],
          ),
        ),
        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect! ? currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage() : FeedbackMessages.getRandomIncorrectMessage(),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.brown),
            ),
          ),
        ),
      ],
    );
  }
}
