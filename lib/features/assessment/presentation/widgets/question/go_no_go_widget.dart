import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.6.5: Go/No-Go 기본 위젯 (시각 자극)
/// 
/// 화면에 무작위로 등장하는 자극에 선택적으로 반응합니다.
/// Go 자극: 토끼 → 빠르게 터치
/// No-Go 자극: 늑대 → 터치하지 않기
class GoNoGoWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(Map<String, dynamic> result) onAnswerSelected;

  const GoNoGoWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<GoNoGoWidget> createState() => _GoNoGoWidgetState();
}

class _GoNoGoWidgetState extends State<GoNoGoWidget> {
  bool _isStarted = false;
  bool _isCompleted = false;
  String? _currentStimulus; // 'go' or 'nogo'
  int _currentTrial = 0;
  int _totalTrials = 10;
  
  // 결과 데이터
  int _correctResponses = 0; // 정반응 (Go에 터치)
  int _incorrectResponses = 0; // 오반응 (NoGo에 터치)
  int _missedResponses = 0; // 누락 (Go에 미터치)
  List<int> _reactionTimes = []; // 반응 시간들
  
  DateTime? _stimulusStartTime;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // soundLabels에서 설정 가져오기
    if (widget.question.soundLabels.isNotEmpty) {
      final config = widget.question.soundLabels[0].split(',');
      if (config.length >= 3) {
        _totalTrials = int.tryParse(config[2]) ?? 10;
      }
    }
  }

  @override
  void didUpdateWidget(GoNoGoWidget oldWidget) {
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
    
    // 1~2초 랜덤 대기
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(1000)));
    
    if (!mounted) return;
    
    // 자극 표시 (70% Go, 30% NoGo)
    final isGo = _random.nextDouble() < 0.7;
    
    setState(() {
      _currentStimulus = isGo ? 'go' : 'nogo';
      _stimulusStartTime = DateTime.now();
      _currentTrial++;
    });
    
    // 1.5초 후 자동 종료 (응답 없음)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _currentStimulus != null) {
        // 응답하지 않음
        if (_currentStimulus == 'go') {
          setState(() {
            _missedResponses++;
          });
        }
        // NoGo는 응답하지 않는 것이 정답이므로 정반응 카운트
        else {
          setState(() {
            _correctResponses++;
          });
        }
        
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
      // 정반응
      setState(() {
        _correctResponses++;
        _reactionTimes.add(reactionTime);
      });
    } else {
      // 오반응
      setState(() {
        _incorrectResponses++;
      });
    }
    
    setState(() {
      _currentStimulus = null;
    });
    
    _nextTrial();
  }

  void _completeTest() {
    setState(() {
      _isCompleted = true;
    });
    
    // 결과 계산
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
    
    debugPrint('✅ Go/No-Go 완료: $result');
    
    // 1초 후 결과 제출
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
                        Icons.pets,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '토끼 = 터치!',
                        style: DesignSystem.textStyleLarge.copyWith(
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Icon(
                        Icons.dangerous,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '늑대 = 참기!',
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
                      ? Icon(
                          _currentStimulus == 'go'
                              ? Icons.pets // 토끼 (Go)
                              : Icons.dangerous, // 늑대 (NoGo)
                          size: 150,
                          color: _currentStimulus == 'go'
                              ? Colors.green
                              : Colors.red,
                        )
                      : Text(
                          '준비...',
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

