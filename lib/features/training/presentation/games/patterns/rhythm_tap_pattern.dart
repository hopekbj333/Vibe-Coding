import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// 리듬 탭 게임 패턴
/// 
/// 제시된 리듬에 맞춰 화면을 탭하는 게임입니다.
/// 타이밍 오차 허용 범위를 설정할 수 있습니다.
/// 
/// WP 2.2 - S 2.2.6
class RhythmTapPattern extends StatefulWidget {
  /// 문제 항목
  final ContentItem item;
  
  /// 완료 콜백 (정확도, 평균 타이밍 오차)
  final void Function(double accuracy, int avgTimingErrorMs) onComplete;
  
  /// 다음으로 이동 콜백
  final VoidCallback? onNext;
  
  /// 피드백 표시 여부
  final bool showFeedback;
  
  /// 타이밍 오차 허용 범위 (ms)
  final int toleranceMs;
  
  /// 문제 인덱스
  final int? questionIndex;
  
  /// 총 문제 수
  final int? totalQuestions;

  const RhythmTapPattern({
    super.key,
    required this.item,
    required this.onComplete,
    this.onNext,
    this.showFeedback = true,
    this.toleranceMs = 300, // 기본 오차 허용 300ms
    this.questionIndex,
    this.totalQuestions,
  });

  @override
  State<RhythmTapPattern> createState() => _RhythmTapPatternState();
}

class _RhythmTapPatternState extends State<RhythmTapPattern>
    with TickerProviderStateMixin {
  late AnimationController _drumController;
  late Animation<double> _drumAnimation;
  
  // 게임 상태
  GamePhase _phase = GamePhase.ready;
  
  // 리듬 패턴 (밀리초 단위 간격)
  List<int> _rhythmPattern = [];
  
  // 시연 중 현재 비트
  int _currentBeat = 0;
  
  // 사용자 탭 기록
  List<int> _userTaps = [];
  DateTime? _tapStartTime;
  
  // 결과
  bool _completed = false;
  double? _accuracy;
  
  Timer? _rhythmTimer;
  
  @override
  void initState() {
    super.initState();
    
    _drumController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _drumAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _drumController, curve: Curves.easeInOut),
    );
    
    _initializeRhythm();
  }
  
  @override
  void didUpdateWidget(RhythmTapPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      _resetGame();
      _initializeRhythm();
    }
  }
  
  @override
  void dispose() {
    _drumController.dispose();
    _rhythmTimer?.cancel();
    super.dispose();
  }
  
  void _initializeRhythm() {
    // itemData에서 리듬 패턴 가져오기 또는 기본 패턴 생성
    final patternData = widget.item.itemData?['rhythm'] as List<dynamic>?;
    
    if (patternData != null) {
      _rhythmPattern = patternData.map((e) => e as int).toList();
    } else {
      // 기본 리듬 패턴 생성 (500ms 간격의 4비트)
      _rhythmPattern = [500, 500, 500, 500];
    }
    
    setState(() {
      _phase = GamePhase.ready;
    });
  }
  
  void _resetGame() {
    _rhythmTimer?.cancel();
    
    setState(() {
      _phase = GamePhase.ready;
      _currentBeat = 0;
      _userTaps = [];
      _tapStartTime = null;
      _completed = false;
      _accuracy = null;
    });
  }
  
  void _startDemonstration() {
    setState(() {
      _phase = GamePhase.demonstration;
      _currentBeat = 0;
    });
    
    // 첫 번째 비트 즉시 재생
    _playBeat();
    
    // 나머지 비트 예약
    int totalDelay = 0;
    for (int i = 0; i < _rhythmPattern.length; i++) {
      totalDelay += _rhythmPattern[i];
      
      if (i < _rhythmPattern.length - 1) {
        final nextBeat = i + 1;
        Timer(Duration(milliseconds: totalDelay), () {
          if (mounted && _phase == GamePhase.demonstration) {
            setState(() {
              _currentBeat = nextBeat;
            });
            _playBeat();
          }
        });
      }
    }
    
    // 시연 완료 후 대기
    Timer(Duration(milliseconds: totalDelay + 500), () {
      if (mounted) {
        _startPlayerTurn();
      }
    });
  }
  
  void _playBeat() {
    _drumController.forward().then((_) {
      _drumController.reverse();
    });
  }
  
  void _startPlayerTurn() {
    setState(() {
      _phase = GamePhase.playerTurn;
      _currentBeat = 0;
      _userTaps = [];
      _tapStartTime = null;
    });
  }
  
  void _onTap() {
    if (_phase != GamePhase.playerTurn) return;
    
    // 첫 탭이면 시작 시간 기록
    if (_tapStartTime == null) {
      _tapStartTime = DateTime.now();
      _userTaps.add(0);
    } else {
      final elapsed = DateTime.now().difference(_tapStartTime!).inMilliseconds;
      _userTaps.add(elapsed);
    }
    
    _playBeat();
    
    setState(() {
      _currentBeat = _userTaps.length;
    });
    
    // 모든 탭 완료 확인
    if (_userTaps.length >= _rhythmPattern.length) {
      _evaluatePerformance();
    }
  }
  
  void _evaluatePerformance() {
    // 사용자 탭 간격 계산
    List<int> userIntervals = [];
    for (int i = 1; i < _userTaps.length; i++) {
      userIntervals.add(_userTaps[i] - _userTaps[i - 1]);
    }
    
    // 정확도 계산
    int correctTaps = 0;
    int totalError = 0;
    
    for (int i = 0; i < userIntervals.length && i < _rhythmPattern.length - 1; i++) {
      final expectedInterval = _rhythmPattern[i];
      final userInterval = userIntervals[i];
      final error = (userInterval - expectedInterval).abs();
      
      totalError += error;
      
      if (error <= widget.toleranceMs) {
        correctTaps++;
      }
    }
    
    final accuracy = _rhythmPattern.length > 1
        ? correctTaps / (_rhythmPattern.length - 1)
        : 1.0;
    
    final avgError = userIntervals.isNotEmpty
        ? totalError ~/ userIntervals.length
        : 0;
    
    setState(() {
      _phase = GamePhase.result;
      _completed = true;
      _accuracy = accuracy;
    });
    
    widget.onComplete(accuracy, avgError);
    
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
          onTap: _phase == GamePhase.playerTurn ? _onTap : null,
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
                
                // 드럼 영역
                _buildDrumArea(),
                
                const Spacer(),
                
                // 비트 인디케이터
                _buildBeatIndicator(),
                
                const SizedBox(height: 24),
                
                // 액션 버튼
                _buildActionButton(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        
        // 완료 피드백
        if (_completed && widget.showFeedback && _accuracy != null)
          FeedbackWidget(
            type: _accuracy! >= 0.7 ? FeedbackType.correct : FeedbackType.encouragement,
            message: '${(_accuracy! * 100).toInt()}% 정확도!',
          ),
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
    String instruction;
    String subtext = '';
    
    switch (_phase) {
      case GamePhase.ready:
        instruction = widget.item.question;
        subtext = '시작 버튼을 눌러주세요';
        break;
      case GamePhase.demonstration:
        instruction = '잘 들어보세요! 👀';
        subtext = '리듬을 기억하세요';
        break;
      case GamePhase.playerTurn:
        instruction = '이제 따라해보세요! 👆';
        subtext = '화면을 탭하세요';
        break;
      case GamePhase.result:
        instruction = '완료!';
        subtext = '';
        break;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _phase == GamePhase.playerTurn
            ? DesignSystem.semanticSuccess.withOpacity(0.1)
            : DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            instruction,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildDrumArea() {
    return AnimatedBuilder(
      animation: _drumAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _drumAnimation.value,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _phase == GamePhase.playerTurn
                      ? DesignSystem.semanticSuccess
                      : DesignSystem.primaryBlue,
                  _phase == GamePhase.playerTurn
                      ? DesignSystem.semanticSuccess.withOpacity(0.7)
                      : DesignSystem.primaryBlue.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_phase == GamePhase.playerTurn
                          ? DesignSystem.semanticSuccess
                          : DesignSystem.primaryBlue)
                      .withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: Center(
                  child: _phase == GamePhase.playerTurn
                      ? const Icon(
                          Icons.touch_app,
                          size: 80,
                          color: Colors.white,
                        )
                      : Icon(
                          _phase == GamePhase.demonstration
                              ? Icons.music_note
                              : Icons.play_arrow,
                          size: 80,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBeatIndicator() {
    final totalBeats = _rhythmPattern.length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalBeats, (index) {
        bool isActive = false;
        bool isCompleted = false;
        
        if (_phase == GamePhase.demonstration) {
          isActive = index == _currentBeat;
          isCompleted = index < _currentBeat;
        } else if (_phase == GamePhase.playerTurn) {
          isCompleted = index < _userTaps.length;
          isActive = index == _userTaps.length;
        } else if (_phase == GamePhase.result) {
          isCompleted = true;
        }
        
        return Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? DesignSystem.semanticSuccess
                : (isActive
                    ? DesignSystem.primaryBlue
                    : Colors.grey.shade300),
            border: isActive
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: DesignSystem.primaryBlue.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }
  
  Widget _buildActionButton() {
    if (_phase == GamePhase.ready) {
      return SizedBox(
        width: 200,
        height: 56,
        child: ElevatedButton(
          onPressed: _startDemonstration,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 8),
              Text(
                '시작',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_phase == GamePhase.playerTurn) {
      return Text(
        '탭! ${_userTaps.length} / ${_rhythmPattern.length}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: DesignSystem.primaryBlue,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// 게임 진행 단계
enum GamePhase {
  ready,         // 준비
  demonstration, // 시연
  playerTurn,    // 플레이어 차례
  result,        // 결과
}

