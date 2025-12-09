import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// Go/No-Go 반응형 게임 패턴
/// 
/// 연속으로 등장하는 자극에 선택적으로 반응하는 게임입니다.
/// 타이밍을 밀리초 단위로 측정합니다.
/// 
/// WP 2.2 - S 2.2.5
class GoNoGoPattern extends StatefulWidget {
  /// 문제 항목 (options에 go/no-go 타입이 지정됨)
  final ContentItem item;
  
  /// 완료 콜백 (정확도, 평균 반응시간)
  final void Function(double accuracy, int avgResponseTimeMs) onComplete;
  
  /// 다음으로 이동 콜백
  final VoidCallback? onNext;
  
  /// 피드백 표시 여부
  final bool showFeedback;
  
  /// 자극 제시 시간 (ms)
  final int stimulusDuration;
  
  /// 자극 간 간격 (ms)
  final int interStimulusInterval;
  
  /// 총 시행 횟수
  final int totalTrials;
  
  /// 문제 인덱스
  final int? questionIndex;
  
  /// 총 문제 수
  final int? totalQuestions;

  const GoNoGoPattern({
    super.key,
    required this.item,
    required this.onComplete,
    this.onNext,
    this.showFeedback = true,
    this.stimulusDuration = 1500,
    this.interStimulusInterval = 1000,
    this.totalTrials = 10,
    this.questionIndex,
    this.totalQuestions,
  });

  @override
  State<GoNoGoPattern> createState() => _GoNoGoPatternState();
}

class _GoNoGoPatternState extends State<GoNoGoPattern>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  bool _isRunning = false;
  bool _showStimulus = false;
  bool _showFeedback = false;
  bool _completed = false;
  
  int _currentTrial = 0;
  ContentOption? _currentStimulus;
  DateTime? _stimulusStartTime;
  
  // 결과 기록
  List<TrialResult> _results = [];
  
  // 현재 시행 결과
  bool? _currentTrialCorrect;
  
  Timer? _stimulusTimer;
  Timer? _intervalTimer;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 시작 안내 후 게임 시작
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _startGame();
      }
    });
  }
  
  @override
  void didUpdateWidget(GoNoGoPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      _resetGame();
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _startGame();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _stimulusTimer?.cancel();
    _intervalTimer?.cancel();
    super.dispose();
  }
  
  void _resetGame() {
    _stimulusTimer?.cancel();
    _intervalTimer?.cancel();
    
    setState(() {
      _isRunning = false;
      _showStimulus = false;
      _showFeedback = false;
      _completed = false;
      _currentTrial = 0;
      _currentStimulus = null;
      _results = [];
      _currentTrialCorrect = null;
    });
  }
  
  void _startGame() {
    if (!mounted) return;
    
    setState(() {
      _isRunning = true;
      _currentTrial = 0;
      _results = [];
    });
    
    _showNextStimulus();
  }
  
  void _showNextStimulus() {
    if (_currentTrial >= widget.totalTrials || !mounted) {
      _onGameComplete();
      return;
    }
    
    // 랜덤하게 Go 또는 No-Go 자극 선택
    final goOptions = widget.item.options.where(
      (o) => o.optionData?['type'] == 'go'
    ).toList();
    final noGoOptions = widget.item.options.where(
      (o) => o.optionData?['type'] == 'nogo'
    ).toList();
    
    // 70% Go, 30% No-Go 비율
    final isGo = math.Random().nextDouble() < 0.7;
    
    List<ContentOption> options;
    if (isGo && goOptions.isNotEmpty) {
      options = goOptions;
    } else if (!isGo && noGoOptions.isNotEmpty) {
      options = noGoOptions;
    } else {
      options = widget.item.options;
    }
    
    final stimulus = options[math.Random().nextInt(options.length)];
    
    setState(() {
      _showStimulus = true;
      _showFeedback = false;
      _currentStimulus = stimulus;
      _stimulusStartTime = DateTime.now();
      _currentTrialCorrect = null;
    });
    
    _pulseController.repeat(reverse: true);
    
    // 자극 제시 시간 후 다음으로
    _stimulusTimer = Timer(Duration(milliseconds: widget.stimulusDuration), () {
      if (mounted) {
        _onStimulusTimeout();
      }
    });
  }
  
  void _onScreenTap() {
    if (!_isRunning || !_showStimulus || _currentStimulus == null) return;
    
    _stimulusTimer?.cancel();
    _pulseController.stop();
    
    final responseTime = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
    final isGoStimulus = _currentStimulus!.optionData?['type'] == 'go';
    
    // Go에 반응 = 정답, No-Go에 반응 = 오답
    final isCorrect = isGoStimulus;
    
    _results.add(TrialResult(
      stimulusType: isGoStimulus ? 'go' : 'nogo',
      responded: true,
      responseTime: responseTime,
      isCorrect: isCorrect,
    ));
    
    setState(() {
      _currentTrialCorrect = isCorrect;
      _showFeedback = true;
    });
    
    _moveToNextTrial();
  }
  
  void _onStimulusTimeout() {
    if (!mounted) return;
    
    _pulseController.stop();
    
    final isGoStimulus = _currentStimulus?.optionData?['type'] == 'go';
    
    // Go에 미반응 = 오답, No-Go에 미반응 = 정답
    final isCorrect = !isGoStimulus!;
    
    _results.add(TrialResult(
      stimulusType: isGoStimulus ? 'go' : 'nogo',
      responded: false,
      responseTime: null,
      isCorrect: isCorrect,
    ));
    
    setState(() {
      _currentTrialCorrect = isCorrect;
      _showFeedback = true;
    });
    
    _moveToNextTrial();
  }
  
  void _moveToNextTrial() {
    _intervalTimer = Timer(Duration(milliseconds: widget.interStimulusInterval), () {
      if (mounted) {
        setState(() {
          _showStimulus = false;
          _showFeedback = false;
          _currentTrial++;
        });
        
        _showNextStimulus();
      }
    });
  }
  
  void _onGameComplete() {
    if (!mounted) return;
    
    // 정확도 계산
    final correctCount = _results.where((r) => r.isCorrect).length;
    final accuracy = correctCount / _results.length;
    
    // Go 자극에 대한 평균 반응시간 계산
    final goResponses = _results.where(
      (r) => r.stimulusType == 'go' && r.responded && r.responseTime != null
    ).toList();
    
    final avgResponseTime = goResponses.isEmpty
        ? 0
        : (goResponses.map((r) => r.responseTime!).reduce((a, b) => a + b) ~/ goResponses.length);
    
    setState(() {
      _isRunning = false;
      _showStimulus = false;
      _completed = true;
    });
    
    widget.onComplete(accuracy, avgResponseTime);
    
    if (widget.showFeedback) {
      Timer(const Duration(seconds: 2), () {
        widget.onNext?.call();
      });
    } else {
      widget.onNext?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _onScreenTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                // 진행 상황 표시
                if (widget.questionIndex != null && widget.totalQuestions != null)
                  _buildProgressIndicator(),
                
                const SizedBox(height: 20),
                
                // 안내 텍스트
                _buildInstructionArea(),
                
                const Spacer(),
                
                // 자극 표시 영역
                _buildStimulusArea(),
                
                const Spacer(),
                
                // 시행 카운터
                _buildTrialCounter(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        
        // 완료 피드백
        if (_completed && widget.showFeedback)
          _buildCompletionFeedback(),
      ],
    );
  }
  
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            '${widget.questionIndex! + 1} / ${widget.totalQuestions}',
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
                value: (widget.questionIndex! + 1) / widget.totalQuestions!,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignSystem.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructionArea() {
    // Go 자극과 No-Go 자극 정보 찾기
    final goOption = widget.item.options.firstWhere(
      (o) => o.optionData?['type'] == 'go',
      orElse: () => widget.item.options.first,
    );
    final noGoOption = widget.item.options.firstWhere(
      (o) => o.optionData?['type'] == 'nogo',
      orElse: () => widget.item.options.last,
    );
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            widget.item.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Go 설명
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: DesignSystem.semanticSuccess.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignSystem.semanticSuccess,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        goOption.label.isNotEmpty ? goOption.label[0] : '👆',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('터치!', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              
              // No-Go 설명
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: DesignSystem.semanticError.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignSystem.semanticError,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        noGoOption.label.isNotEmpty ? noGoOption.label[0] : '✋',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('참기!', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStimulusArea() {
    if (!_isRunning && !_completed) {
      // 시작 대기 중
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              '준비...',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    if (!_showStimulus || _currentStimulus == null) {
      // 자극 간 간격
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.radio_button_unchecked,
            size: 100,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // 자극 표시
    final isGo = _currentStimulus!.optionData?['type'] == 'go';
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.1);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: _showFeedback
                  ? (_currentTrialCorrect == true
                      ? DesignSystem.semanticSuccess
                      : DesignSystem.semanticError)
                  : (isGo
                      ? DesignSystem.semanticSuccess.withOpacity(0.8)
                      : DesignSystem.semanticError.withOpacity(0.8)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isGo
                          ? DesignSystem.semanticSuccess
                          : DesignSystem.semanticError)
                      .withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: _currentStimulus!.imagePath != null
                  ? ClipOval(
                      child: Image.asset(
                        _currentStimulus!.imagePath!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildStimulusText(),
                      ),
                    )
                  : _buildStimulusText(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStimulusText() {
    return Text(
      _currentStimulus?.label ?? '',
      style: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
  
  Widget _buildTrialCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.totalTrials; i++)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i < _results.length
                  ? (_results[i].isCorrect
                      ? DesignSystem.semanticSuccess
                      : DesignSystem.semanticError)
                  : (i == _currentTrial && _isRunning
                      ? DesignSystem.primaryBlue
                      : Colors.grey.shade300),
              shape: BoxShape.circle,
              border: i == _currentTrial && _isRunning
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
          ),
      ],
    );
  }
  
  Widget _buildCompletionFeedback() {
    final correctCount = _results.where((r) => r.isCorrect).length;
    final accuracy = (correctCount / _results.length * 100).toInt();
    
    return FeedbackWidget(
      type: accuracy >= 70 ? FeedbackType.correct : FeedbackType.encouragement,
      message: '$accuracy% 정확도!\n잘했어요!',
    );
  }
}

/// 시행 결과
class TrialResult {
  final String stimulusType; // 'go' or 'nogo'
  final bool responded; // 반응했는지
  final int? responseTime; // 반응시간 (ms)
  final bool isCorrect; // 정답 여부

  TrialResult({
    required this.stimulusType,
    required this.responded,
    this.responseTime,
    required this.isCorrect,
  });
}

