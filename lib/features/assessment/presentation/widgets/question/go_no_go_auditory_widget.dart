import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.6.6: Go/No-Go 청각 버전 위젯
/// 
/// 소리로 판단하여 선택적으로 반응합니다.
/// Go: '딩' 소리 → 터치
/// No-Go: '뿡' 소리 → 터치 금지
class GoNoGoAuditoryWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(Map<String, dynamic> result) onAnswerSelected;

  const GoNoGoAuditoryWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<GoNoGoAuditoryWidget> createState() => _GoNoGoAuditoryWidgetState();
}

class _GoNoGoAuditoryWidgetState extends State<GoNoGoAuditoryWidget>
    with SingleTickerProviderStateMixin {
  bool _isStarted = false;
  bool _isCompleted = false;
  String? _currentStimulus;
  int _currentTrial = 0;
  int _totalTrials = 10;
  
  int _correctResponses = 0;
  int _incorrectResponses = 0;
  int _missedResponses = 0;
  List<int> _reactionTimes = [];
  
  DateTime? _stimulusStartTime;
  final Random _random = Random();
  late AnimationController _soundWaveController;

  @override
  void initState() {
    super.initState();
    
    _soundWaveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    if (widget.question.soundLabels.isNotEmpty) {
      final config = widget.question.soundLabels[0].split(',');
      if (config.length >= 3) {
        _totalTrials = int.tryParse(config[2]) ?? 10;
      }
    }
  }

  @override
  void dispose() {
    _soundWaveController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GoNoGoAuditoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _resetState();
    }
  }

  void _resetState() {
    setState(() {
      _isStarted = false;
      _isCompleted = false;
      _currentStimulus = null;
      _currentTrial = 0;
      _correctResponses = 0;
      _incorrectResponses = 0;
      _missedResponses = 0;
      _reactionTimes.clear();
    });
  }

  void _startTest() {
    setState(() {
      _isStarted = true;
    });
    
    _nextTrial();
  }

  Future<void> _nextTrial() async {
    if (_currentTrial >= _totalTrials) {
      _completeTest();
      return;
    }
    
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1000)));
    
    if (!mounted) return;
    
    final isGo = _random.nextDouble() < 0.7;
    
    setState(() {
      _currentStimulus = isGo ? 'go' : 'nogo';
      _stimulusStartTime = DateTime.now();
      _currentTrial++;
    });
    
    // 소리 재생 애니메이션
    _soundWaveController.repeat(reverse: true);
    
    debugPrint('🔊 ${isGo ? "딩" : "뿡"} 소리 재생');
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _currentStimulus != null) {
        if (_currentStimulus == 'go') {
          setState(() {
            _missedResponses++;
          });
        } else {
          setState(() {
            _correctResponses++;
          });
        }
        
        _soundWaveController.stop();
        setState(() {
          _currentStimulus = null;
        });
        
        _nextTrial();
      }
    });
  }

  void _onScreenTap() {
    if (widget.isInputBlocked || !_isStarted || _currentStimulus == null) return;
    
    final reactionTime = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
    
    if (_currentStimulus == 'go') {
      setState(() {
        _correctResponses++;
        _reactionTimes.add(reactionTime);
      });
    } else {
      setState(() {
        _incorrectResponses++;
      });
    }
    
    _soundWaveController.stop();
    setState(() {
      _currentStimulus = null;
    });
    
    _nextTrial();
  }

  void _completeTest() {
    setState(() {
      _isCompleted = true;
    });
    
    final avgReactionTime = _reactionTimes.isNotEmpty
        ? _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length
        : 0.0;
    
    final result = {
      'correctResponses': _correctResponses,
      'incorrectResponses': _incorrectResponses,
      'missedResponses': _missedResponses,
      'avgReactionTime': avgReactionTime.toInt(),
      'accuracy': (_correctResponses / _totalTrials * 100).toStringAsFixed(1),
    };
    
    debugPrint('✅ Go/No-Go 청각 완료: $result');
    
    Future.delayed(const Duration(seconds: 1), () {
      widget.onAnswerSelected(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              widget.question.promptText,
              style: DesignSystem.textStyleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          if (!_isStarted)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: DesignSystem.primaryBlue,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '딩 = 터치!',
                        style: DesignSystem.textStyleLarge.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Icon(
                        Icons.volume_off,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '뿡 = 참기!',
                        style: DesignSystem.textStyleLarge.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _startTest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                    backgroundColor: DesignSystem.primaryBlue,
                  ),
                  child: Text(
                    '시작하기',
                    style: DesignSystem.textStyleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else if (_isCompleted)
            Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                Text(
                  '잘했어요!',
                  style: DesignSystem.textStyleLarge.copyWith(
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '정답: $_correctResponses / $_totalTrials',
                  style: DesignSystem.textStyleMedium,
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _onScreenTap,
              child: Container(
                width: double.infinity,
                height: 400,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: DesignSystem.neutralGray100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DesignSystem.neutralGray300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: _currentStimulus != null
                      ? AnimatedBuilder(
                          animation: _soundWaveController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_soundWaveController.value * 0.3),
                              child: Icon(
                                _currentStimulus == 'go'
                                    ? Icons.volume_up
                                    : Icons.volume_down,
                                size: 120,
                                color: _currentStimulus == 'go'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          },
                        )
                      : Text(
                          '귀 기울여봐...',
                          style: DesignSystem.textStyleLarge.copyWith(
                            color: DesignSystem.neutralGray500,
                          ),
                        ),
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          if (_isStarted && !_isCompleted)
            Text(
              '$_currentTrial / $_totalTrials',
              style: DesignSystem.textStyleMedium.copyWith(
                color: DesignSystem.neutralGray600,
              ),
            ),
        ],
      ),
    );
  }
}

