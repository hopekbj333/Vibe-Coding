import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../widgets/feedback_widget.dart';

/// 리듬 따라 치기 게임 (S 2.3.3)
/// 
/// 캐릭터가 북을 치는 패턴을 따라서 탭합니다.
/// 난이도: 2박 → 3박 → 4박 → 변박
class RhythmFollowGame extends StatefulWidget {
  final String childId;
  final void Function(double accuracy, int avgTimingErrorMs) onComplete;
  final VoidCallback? onGameEnd;
  final int difficultyLevel;

  const RhythmFollowGame({
    super.key,
    required this.childId,
    required this.onComplete,
    this.onGameEnd,
    this.difficultyLevel = 1,
  });

  @override
  State<RhythmFollowGame> createState() => _RhythmFollowGameState();
}

class _RhythmFollowGameState extends State<RhythmFollowGame>
    with TickerProviderStateMixin {
  late AnimationController _drumController;
  late Animation<double> _drumAnimation;

  int _currentRoundIndex = 0;
  late List<RhythmRound> _rounds;
  
  GamePhase _phase = GamePhase.ready;
  int _currentBeat = 0;
  List<int> _userTaps = [];
  DateTime? _tapStartTime;
  
  bool _completed = false;
  double? _accuracy;
  
  Timer? _rhythmTimer;

  @override
  void initState() {
    super.initState();
    
    _drumController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _drumAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _drumController, curve: Curves.easeInOut),
    );
    
    _rounds = _generateRounds(widget.difficultyLevel);
  }

  List<RhythmRound> _generateRounds(int level) {
    switch (level) {
      case 1: // 쉬움: 2박
        return [
          RhythmRound(pattern: [600, 600], label: '똑-똑'),
          RhythmRound(pattern: [600, 600], label: '똑-똑'),
          RhythmRound(pattern: [600, 600], label: '똑-똑'),
        ];
      case 2: // 중간: 3박
        return [
          RhythmRound(pattern: [500, 500, 500], label: '똑-똑-똑'),
          RhythmRound(pattern: [500, 500, 500], label: '똑-똑-똑'),
          RhythmRound(pattern: [500, 500, 500], label: '똑-똑-똑'),
        ];
      case 3: // 어려움: 4박
        return [
          RhythmRound(pattern: [400, 400, 400, 400], label: '똑-똑-똑-똑'),
          RhythmRound(pattern: [400, 400, 400, 400], label: '똑-똑-똑-똑'),
          RhythmRound(pattern: [400, 400, 400, 400], label: '똑-똑-똑-똑'),
        ];
      case 4: // 매우 어려움: 변박
        return [
          RhythmRound(pattern: [600, 300, 600], label: '똑--똑-똑'),
          RhythmRound(pattern: [300, 300, 600, 300], label: '똑-똑-똑--똑'),
          RhythmRound(pattern: [400, 400, 200, 200, 400], label: '변박 리듬'),
        ];
      default:
        return _generateRounds(1);
    }
  }

  @override
  void dispose() {
    _drumController.dispose();
    _rhythmTimer?.cancel();
    super.dispose();
  }

  void _startDemonstration() {
    final currentRound = _rounds[_currentRoundIndex];
    
    setState(() {
      _phase = GamePhase.demonstration;
      _currentBeat = 0;
    });
    
    _playBeat();
    
    int totalDelay = 0;
    for (int i = 0; i < currentRound.pattern.length; i++) {
      totalDelay += currentRound.pattern[i];
      
      if (i < currentRound.pattern.length - 1) {
        final nextBeat = i + 1;
        Timer(Duration(milliseconds: totalDelay), () {
          if (mounted && _phase == GamePhase.demonstration) {
            setState(() => _currentBeat = nextBeat);
            _playBeat();
          }
        });
      }
    }
    
    Timer(Duration(milliseconds: totalDelay + 500), () {
      if (mounted) _startPlayerTurn();
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
    
    final currentRound = _rounds[_currentRoundIndex];
    
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
    
    if (_userTaps.length >= currentRound.pattern.length) {
      _evaluateRound();
    }
  }

  void _evaluateRound() {
    final currentRound = _rounds[_currentRoundIndex];
    
    List<int> userIntervals = [];
    for (int i = 1; i < _userTaps.length; i++) {
      userIntervals.add(_userTaps[i] - _userTaps[i - 1]);
    }
    
    int correctTaps = 0;
    int totalError = 0;
    const tolerance = 200; // 200ms 오차 허용
    
    for (int i = 0; i < userIntervals.length && i < currentRound.pattern.length - 1; i++) {
      final expectedInterval = currentRound.pattern[i];
      final userInterval = userIntervals[i];
      final error = (userInterval - expectedInterval).abs();
      
      totalError += error;
      if (error <= tolerance) {
        correctTaps++;
      }
    }
    
    final roundAccuracy = currentRound.pattern.length > 1
        ? correctTaps / (currentRound.pattern.length - 1)
        : 1.0;
    
    setState(() {
      _phase = GamePhase.result;
    });
    
    Timer(const Duration(milliseconds: 1500), () {
      if (_currentRoundIndex < _rounds.length - 1) {
        setState(() {
          _currentRoundIndex++;
          _phase = GamePhase.ready;
          _currentBeat = 0;
        });
      } else {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    setState(() {
      _completed = true;
      _accuracy = 0.8; // 임시 값
    });
    
    widget.onComplete(0.8, 150);
    
    Timer(const Duration(seconds: 2), () {
      widget.onGameEnd?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRound = _rounds[_currentRoundIndex];
    
    return Stack(
      children: [
        GestureDetector(
          onTap: _phase == GamePhase.playerTurn ? _onTap : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProgressIndicator(),
                  
                  const SizedBox(height: 24),
                  
                  _buildInstructionArea(),
                  
                  const SizedBox(height: 40),
                  
                  _buildDrumArea(),
                  
                  const SizedBox(height: 32),
                  
                  _buildBeatIndicator(currentRound),
                  
                  const SizedBox(height: 24),
                  
                  if (_phase == GamePhase.ready)
                    _buildStartButton(),
                  
                  if (_phase == GamePhase.playerTurn)
                    Text(
                      '탭! ${_userTaps.length} / ${currentRound.pattern.length}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.primaryBlue,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        if (_completed && _accuracy != null)
          FeedbackWidget(
            type: _accuracy! >= 0.7 ? FeedbackType.correct : FeedbackType.encouragement,
            message: '${(_accuracy! * 100).toInt()}% 정확도!',
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Text(
          '라운드 ${_currentRoundIndex + 1} / ${_rounds.length}',
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
              value: (_currentRoundIndex + 1) / _rounds.length,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                DesignSystem.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionArea() {
    String instruction;
    String subtext = '';
    
    switch (_phase) {
      case GamePhase.ready:
        instruction = '🥁 리듬을 따라해보세요!';
        subtext = '시작 버튼을 누르면 시범을 보여줄게요';
        break;
      case GamePhase.demonstration:
        instruction = '👀 잘 들어보세요!';
        subtext = '리듬을 기억하세요';
        break;
      case GamePhase.playerTurn:
        instruction = '👆 이제 따라해보세요!';
        subtext = '화면을 탭하세요';
        break;
      case GamePhase.result:
        instruction = '✨ 잘했어요!';
        subtext = '';
        break;
    }
    
    return Container(
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
            width: 180,
            height: 180,
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
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🥁',
                style: TextStyle(fontSize: 80),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeatIndicator(RhythmRound round) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(round.pattern.length, (index) {
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
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? DesignSystem.semanticSuccess
                : (isActive ? DesignSystem.primaryBlue : Colors.grey.shade300),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: DesignSystem.primaryBlue.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
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

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: _startDemonstration,
      icon: const Icon(Icons.play_arrow, size: 28),
      label: const Text(
        '시작',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

enum GamePhase {
  ready,
  demonstration,
  playerTurn,
  result,
}

class RhythmRound {
  final List<int> pattern;
  final String label;

  RhythmRound({required this.pattern, required this.label});
}

