import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';
import '../../widgets/feedback_widget.dart';

/// 흐름 추적 게임 - JSON 기반 버전
/// 
/// 움직이는 공을 손가락으로 터치하면서 따라가는 게임
class FlowTrackingGameV2 extends StatefulWidget {
  final String childId;
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  final VoidCallback? onComplete;
  final int difficultyLevel;

  const FlowTrackingGameV2({
    super.key,
    required this.childId,
    required this.onAnswer,
    this.onComplete,
    this.difficultyLevel = 1,
  });

  @override
  State<FlowTrackingGameV2> createState() => _FlowTrackingGameV2State();
}

class _FlowTrackingGameV2State extends State<FlowTrackingGameV2> {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentQuestionIndex = 0;
  bool _answered = false;
  bool? _isCorrect;
  DateTime? _questionStartTime;
  bool _isLoading = true;
  String? _errorMessage;
  
  // 게임 상태
  bool _gameStarted = false;
  int _timeRemaining = 10; // 10초 게임
  double _targetX = 0.5;
  double _targetY = 0.5;
  double _targetDx = 0.003;
  double _targetDy = 0.002;
  bool _isTracking = false;
  int _trackingTime = 0; // 밀리초
  
  Timer? _gameTimer;
  Timer? _moveTimer;
  Timer? _trackingTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('flow_tracking.json');
      
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '문항을 불러올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    _trackingTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _timeRemaining = 10;
      _trackingTime = 0;
      _targetX = 0.5;
      _targetY = 0.5;
      _questionStartTime = DateTime.now();
    });

    // 1초 타이머
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining <= 0) {
        _endGame();
      }
    });

    // 공 이동 (60fps)
    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      _updateTargetPosition();
    });

    // 추적 시간 카운터
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      
      if (_isTracking) {
        setState(() {
          _trackingTime += 100;
        });
      }
    });
  }

  void _updateTargetPosition() {
    if (!mounted) return;

    setState(() {
      _targetX += _targetDx;
      _targetY += _targetDy;

      // 벽 충돌
      if (_targetX < 0.1 || _targetX > 0.9) {
        _targetDx = -_targetDx;
        _targetDy += (_random.nextDouble() - 0.5) * 0.001;
      }
      if (_targetY < 0.2 || _targetY > 0.8) {
        _targetDy = -_targetDy;
        _targetDx += (_random.nextDouble() - 0.5) * 0.001;
      }

      // 속도 제한
      _targetDx = _targetDx.clamp(-0.005, 0.005);
      _targetDy = _targetDy.clamp(-0.004, 0.004);
    });
  }

  void _checkTracking(Offset touchPosition) {
    if (!_gameStarted || _answered) return;

    final size = MediaQuery.of(context).size;
    final targetPosition = Offset(
      _targetX * size.width,
      _targetY * size.height,
    );

    final distance = (touchPosition - targetPosition).distance;
    final isNear = distance < 60; // 60픽셀 이내

    if (isNear != _isTracking) {
      setState(() {
        _isTracking = isNear;
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    _trackingTimer?.cancel();

    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final trackingPercent = (_trackingTime / 10000 * 100).round();
    final isCorrect = trackingPercent >= 60; // 60% 이상이면 성공

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
      _gameStarted = false;
    });

    widget.onAnswer(isCorrect, responseTime);

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      if (_currentQuestionIndex < _content!.items.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _isCorrect = null;
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

    if (!_gameStarted && !_answered) {
      return _buildStartScreen(currentItem);
    }

    return Stack(
      children: [
        GestureDetector(
          onPanStart: (details) => _checkTracking(details.globalPosition),
          onPanUpdate: (details) => _checkTracking(details.globalPosition),
          onPanEnd: (details) {
            setState(() => _isTracking = false);
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.lightBlue.shade50,
            child: Stack(
              children: [
                // 상태 표시
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildStatusBar(),
                ),

                // 움직이는 공
                Positioned(
                  left: _targetX * MediaQuery.of(context).size.width - 40,
                  top: _targetY * MediaQuery.of(context).size.height - 40,
                  child: _buildTarget(),
                ),

                // 안내
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildTrackingIndicator(),
                ),
              ],
            ),
          ),
        ),

        if (_answered && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect! 
                ? '추적률 ${(_trackingTime / 100).toStringAsFixed(0)}%! ${currentItem.explanation ?? FeedbackMessages.getRandomCorrectMessage()}'
                : '더 오래 따라가보세요!',
          ),
      ],
    );
  }

  Widget _buildStartScreen(ContentItem item) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔴', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(item.question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text(
              '손가락으로 공을 계속\n터치하면서 따라가세요!\n\n손을 떼면 점수가 떨어져요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text('시작!', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final trackingPercent = (_trackingTime / 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Icon(Icons.timer, size: 20),
              const SizedBox(width: 4),
              Text('$_timeRemaining초', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Icon(_isTracking ? Icons.check_circle : Icons.radio_button_unchecked, color: _isTracking ? Colors.green : Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text('$trackingPercent%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isTracking ? Colors.green : Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTarget() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _isTracking ? Colors.greenAccent.withOpacity(0.3) : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: _isTracking ? Colors.green : Colors.grey, width: 4),
        boxShadow: _isTracking
            ? [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)]
            : [],
      ),
      child: const Center(
        child: Text('🔴', style: TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _buildTrackingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isTracking ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isTracking ? Colors.green : Colors.orange, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_isTracking ? Icons.touch_app : Icons.pan_tool, color: _isTracking ? Colors.green : Colors.orange),
          const SizedBox(width: 8),
          Text(
            _isTracking ? '✅ 잘하고 있어요!' : '👆 빨간 공을 터치하세요!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isTracking ? Colors.green[700] : Colors.orange[700]),
          ),
        ],
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlue),
            ),
          ),
        ),
      ],
    );
  }
}
