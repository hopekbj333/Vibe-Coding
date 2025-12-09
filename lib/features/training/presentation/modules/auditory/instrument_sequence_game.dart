import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';

/// S 3.2.1: 악기 순서 게임
/// 악기 소리를 순서대로 듣고, 같은 순서로 터치하여 재현
class InstrumentSequenceGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const InstrumentSequenceGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<InstrumentSequenceGame> createState() => _InstrumentSequenceGameState();
}

class _InstrumentSequenceGameState extends State<InstrumentSequenceGame>
    with TickerProviderStateMixin {
  // 악기 데이터
  static const List<Map<String, String>> _instruments = [
    {'id': 'piano', 'emoji': '🎹', 'name': '피아노'},
    {'id': 'drum', 'emoji': '🥁', 'name': '드럼'},
    {'id': 'guitar', 'emoji': '🎸', 'name': '기타'},
    {'id': 'violin', 'emoji': '🎻', 'name': '바이올린'},
    {'id': 'trumpet', 'emoji': '🎺', 'name': '트럼펫'},
    {'id': 'xylophone', 'emoji': '🎵', 'name': '실로폰'},
  ];

  // 레벨별 설정
  static const List<Map<String, dynamic>> _levels = [
    {'sequenceLength': 3, 'instrumentCount': 4, 'playDelay': 800},
    {'sequenceLength': 4, 'instrumentCount': 5, 'playDelay': 700},
    {'sequenceLength': 5, 'instrumentCount': 5, 'playDelay': 600},
    {'sequenceLength': 5, 'instrumentCount': 6, 'playDelay': 500},
  ];

  int _currentLevel = 0;
  int _currentRound = 0;
  int _score = 0;
  int _totalQuestions = 8;
  
  List<Map<String, String>> _availableInstruments = [];
  List<int> _sequence = [];
  List<int> _userInput = [];
  
  bool _isPlaying = false;
  bool _isUserTurn = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _highlightedIndex = -1;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startNewRound();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startNewRound() {
    final levelConfig = _levels[_currentLevel];
    final sequenceLength = levelConfig['sequenceLength'] as int;
    final instrumentCount = levelConfig['instrumentCount'] as int;
    
    // 사용할 악기 선택
    _availableInstruments = List.from(_instruments)..shuffle(_random);
    _availableInstruments = _availableInstruments.take(instrumentCount).toList();
    
    // 시퀀스 생성
    _sequence = List.generate(
      sequenceLength,
      (_) => _random.nextInt(instrumentCount),
    );
    _userInput = [];
    _isUserTurn = false;
    _showFeedback = false;
    
    setState(() {});
    
    // 시퀀스 재생 시작
    Future.delayed(const Duration(milliseconds: 500), _playSequence);
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlaying = true;
      _highlightedIndex = -1;
    });
    
    final playDelay = _levels[_currentLevel]['playDelay'] as int;
    
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _highlightedIndex = _sequence[i];
      });
      
      _pulseController.forward();
      
      // 소리 재생 시뮬레이션
      await Future.delayed(Duration(milliseconds: playDelay));
      
      if (!mounted) return;
      
      _pulseController.reverse();
      
      setState(() {
        _highlightedIndex = -1;
      });
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    if (!mounted) return;
    
    setState(() {
      _isPlaying = false;
      _isUserTurn = true;
    });
  }

  void _onInstrumentTap(int index) {
    if (!_isUserTurn || _showFeedback) return;
    
    setState(() {
      _userInput.add(index);
      _highlightedIndex = index;
    });
    
    _pulseController.forward().then((_) {
      if (mounted) {
        _pulseController.reverse();
        setState(() {
          _highlightedIndex = -1;
        });
      }
    });
    
    // 입력 검증
    final currentIndex = _userInput.length - 1;
    if (_userInput[currentIndex] != _sequence[currentIndex]) {
      // 틀림
      _showResult(false);
    } else if (_userInput.length == _sequence.length) {
      // 완료 - 정답
      _showResult(true);
    }
  }

  void _showResult(bool correct) {
    setState(() {
      _showFeedback = true;
      _isCorrect = correct;
      _isUserTurn = false;
      
      if (correct) {
        _score++;
      }
    });
    
    widget.onScoreUpdate?.call(_score, _currentRound + 1);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      _currentRound++;
      
      // 레벨 업 체크
      if (correct && _currentRound > 0 && _currentRound % 2 == 0 && _currentLevel < _levels.length - 1) {
        _currentLevel++;
      }
      
      if (_currentRound >= _totalQuestions) {
        widget.onComplete?.call();
      } else {
        _startNewRound();
      }
    });
  }

  void _replaySequence() {
    if (_isPlaying || !_isUserTurn) return;
    
    setState(() {
      _userInput = [];
    });
    
    _playSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('🎼 오케스트라 지휘자'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '점수: $_score / ${_currentRound + 1}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 레벨 & 진행 표시
            _buildProgressBar(),
            
            // 상태 메시지
            _buildStatusMessage(),
            
            // 악기 그리드
            Expanded(child: _buildInstrumentGrid()),
            
            // 피드백
            if (_showFeedback) _buildFeedback(),
            
            // 다시 듣기 버튼
            if (_isUserTurn && !_showFeedback) _buildReplayButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '레벨 ${_currentLevel + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B4EFF),
                ),
              ),
              Text(
                '${_currentRound + 1} / $_totalQuestions',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentRound + 1) / _totalQuestions,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4EFF)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    String message;
    IconData icon;
    Color color;
    
    if (_isPlaying) {
      message = '🎵 소리를 잘 들어보세요! (${_sequence.length}개)';
      icon = Icons.hearing;
      color = Colors.orange;
    } else if (_isUserTurn) {
      final remaining = _sequence.length - _userInput.length;
      message = '🎯 순서대로 터치하세요! (남은 개수: $remaining)';
      icon = Icons.touch_app;
      color = DesignSystem.primaryBlue;
    } else if (_showFeedback) {
      message = _isCorrect ? '🎉 완벽한 연주!' : '😅 다시 도전해요!';
      icon = _isCorrect ? Icons.celebration : Icons.refresh;
      color = _isCorrect ? Colors.green : Colors.orange;
    } else {
      message = '준비 중...';
      icon = Icons.hourglass_empty;
      color = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentGrid() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: List.generate(_availableInstruments.length, (index) {
          return _buildInstrumentButton(index);
        }),
      ),
    );
  }

  Widget _buildInstrumentButton(int index) {
    final instrument = _availableInstruments[index];
    final isHighlighted = _highlightedIndex == index;
    final isSelected = _userInput.contains(index);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isHighlighted ? _pulseAnimation.value : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _onInstrumentTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.amber
                    : isSelected
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHighlighted
                      ? Colors.amber[700]!
                      : isSelected
                          ? Colors.green
                          : Colors.grey[300]!,
                  width: isHighlighted || isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHighlighted
                        ? Colors.amber.withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: isHighlighted ? 12 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    instrument['emoji']!,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    instrument['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedback() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.info_outline,
            color: _isCorrect ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect
                ? '🎊 멋진 지휘자예요!'
                : '다음엔 더 잘할 수 있어요!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _replaySequence,
        icon: const Icon(Icons.replay),
        label: const Text('다시 듣기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

