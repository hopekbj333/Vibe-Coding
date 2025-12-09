import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.6.7: 지속적 주의력 (Continuous Performance) 위젯
/// 
/// 30초~1분간 빠르게 지나가는 도형 중 특정 도형만 터치합니다.
class ContinuousPerformanceWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(Map<String, dynamic> result) onAnswerSelected;

  const ContinuousPerformanceWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<ContinuousPerformanceWidget> createState() =>
      _ContinuousPerformanceWidgetState();
}

class _ContinuousPerformanceWidgetState
    extends State<ContinuousPerformanceWidget> {
  bool _isStarted = false;
  bool _isCompleted = false;
  String _currentStimulus = '';
  bool _isTargetStimulus = false;
  int _duration = 30;
  Timer? _timer;
  int _remainingSeconds = 0;
  
  int _totalTargets = 0;
  int _correctHits = 0;
  int _incorrectHits = 0;
  
  final Random _random = Random();
  final List<String> _stimuli = ['star', 'circle', 'square', 'triangle'];
  String _targetStimulus = 'star';

  @override
  void initState() {
    super.initState();
    
    if (widget.question.soundLabels.isNotEmpty) {
      final config = widget.question.soundLabels[0].split(',');
      if (config.isNotEmpty) {
        _targetStimulus = config[0]; // 'red_star' → 'star'로 단순화
        if (_targetStimulus.contains('_')) {
          _targetStimulus = _targetStimulus.split('_').last;
        }
      }
      if (config.length >= 2) {
        _duration = int.tryParse(config[1]) ?? 30;
      }
    }
    
    _remainingSeconds = _duration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ContinuousPerformanceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _resetState();
    }
  }

  void _resetState() {
    _timer?.cancel();
    setState(() {
      _isStarted = false;
      _isCompleted = false;
      _currentStimulus = '';
      _remainingSeconds = _duration;
      _totalTargets = 0;
      _correctHits = 0;
      _incorrectHits = 0;
    });
  }

  void _startTest() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = _duration;
    });
    
    // 1초마다 타이머 감소
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _completeTest();
      }
    });
    
    _showNextStimulus();
  }

  Future<void> _showNextStimulus() async {
    if (!_isStarted || _isCompleted) return;
    
    // 0.8~1.2초 간격으로 자극 표시
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(400)));
    
    if (!mounted || !_isStarted) return;
    
    // 30% 확률로 목표 자극
    final isTarget = _random.nextDouble() < 0.3;
    
    setState(() {
      _currentStimulus = isTarget ? _targetStimulus : _stimuli[_random.nextInt(_stimuli.length)];
      _isTargetStimulus = isTarget;
    });
    
    if (isTarget) {
      _totalTargets++;
    }
    
    // 0.5초 후 자극 숨기기
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentStimulus = '';
          _isTargetStimulus = false;
        });
        
        _showNextStimulus();
      }
    });
  }

  void _onTap() {
    if (widget.isInputBlocked || !_isStarted || _currentStimulus.isEmpty) return;
    
    if (_isTargetStimulus) {
      setState(() {
        _correctHits++;
      });
      debugPrint('✅ 정답 터치!');
    } else {
      setState(() {
        _incorrectHits++;
      });
      debugPrint('❌ 오답 터치!');
    }
  }

  void _completeTest() {
    setState(() {
      _isCompleted = true;
    });
    
    final result = {
      'totalTargets': _totalTargets,
      'correctHits': _correctHits,
      'incorrectHits': _incorrectHits,
      'missedTargets': _totalTargets - _correctHits,
      'accuracy': _totalTargets > 0
          ? (_correctHits / _totalTargets * 100).toStringAsFixed(1)
          : '0',
    };
    
    debugPrint('✅ 지속적 주의력 완료: $result');
    
    Future.delayed(const Duration(seconds: 1), () {
      widget.onAnswerSelected(result);
    });
  }

  IconData _getStimulusIcon(String stimulus) {
    switch (stimulus) {
      case 'star':
        return Icons.star;
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'triangle':
        return Icons.change_history;
      default:
        return Icons.star;
    }
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getStimulusIcon(_targetStimulus),
                        size: 100,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '이것만 터치!',
                        style: DesignSystem.textStyleLarge.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
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
                    '시작하기 ($_duration초)',
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
                  '정답: $_correctHits / $_totalTargets',
                  style: DesignSystem.textStyleMedium,
                ),
              ],
            )
          else
            Column(
              children: [
                // 남은 시간
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '$_remainingSeconds초',
                    style: DesignSystem.textStyleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 자극 표시 영역
                GestureDetector(
                  onTap: _onTap,
                  child: Container(
                    width: double.infinity,
                    height: 300,
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
                      child: _currentStimulus.isNotEmpty
                          ? Icon(
                              _getStimulusIcon(_currentStimulus),
                              size: 120,
                              color: _isTargetStimulus
                                  ? Colors.red
                                  : DesignSystem.primaryBlue,
                            )
                          : Container(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 점수
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '정답: $_correctHits  ',
                      style: DesignSystem.textStyleMedium.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '오답: $_incorrectHits',
                      style: DesignSystem.textStyleMedium.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

