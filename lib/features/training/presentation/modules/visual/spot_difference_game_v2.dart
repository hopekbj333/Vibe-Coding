import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

class SpotDifferenceGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;
  const SpotDifferenceGameV2({super.key, required this.childId, required this.onAnswer, this.onComplete, this.difficultyLevel = 1});
  @override
  State<SpotDifferenceGameV2> createState() => _SpotDifferenceGameV2State();
}

class _SpotDifferenceGameV2State extends State<SpotDifferenceGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('spot_difference.json');
      setState(() { _content = content; _isLoading = false; _questionStartTime = DateTime.now(); });
    } catch (e) {
      setState(() { _errorMessage = '문항을 불러올 수 없습니다: $e'; _isLoading = false; });
    }
  }

  void _onTreeClick() {
    if (_answered || _found) return;
    setState(() { _found = true; });
    _onComplete();
  }

  void _onComplete() {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    setState(() { _answered = true; _isCorrect = true; });
    widget.onAnswer(true, responseTime);
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() { _currentQuestionIndex++; _answered = false; _isCorrect = null; _found = false; _questionStartTime = DateTime.now(); });
      } else { widget.onComplete?.call(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: DesignSystem.semanticError), const SizedBox(height: 16), Text(_errorMessage!, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuestions, child: const Text('다시 시도'))]));

    final currentItem = _content!.items[_currentQuestionIndex];

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: _buildProgressIndicator()),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(currentItem.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              const Text('💡 차이점을 클릭하세요!', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 왼쪽 그림
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue, width: 3),
                    ),
                    child: const Column(
                      children: [
                        Text('왼쪽 그림', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text('🏠', style: TextStyle(fontSize: 50)),
                        SizedBox(height: 6),
                        Text('🌲 🌲 🌲', style: TextStyle(fontSize: 28)),
                        SizedBox(height: 6),
                        Text('🐕 🐱', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                  ),
                  const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  // 오른쪽 그림 (클릭 가능)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _found ? Colors.green : Colors.red, width: _found ? 4 : 3),
                    ),
                    child: Column(
                      children: [
                        const Text('오른쪽 그림', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('🏠', style: TextStyle(fontSize: 50)),
                        const SizedBox(height: 6),
                        // 나무 2개 - 클릭 가능!
                        GestureDetector(
                          onTap: _onTreeClick,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _found ? Colors.green.shade100 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _found ? Colors.green : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const Text('🌲 🌲', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('🐕 🐱', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                  ),
                ],
              ),
              if (_found) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Text('차이를 찾았어요!\n나무 1개가 적어요!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
