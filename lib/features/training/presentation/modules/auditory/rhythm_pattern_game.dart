import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';

/// S 3.2.4: 리듬 패턴 완성 게임
/// 반복되는 리듬 패턴 중 빠진 부분 채우기
class RhythmPatternGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const RhythmPatternGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<RhythmPatternGame> createState() => _RhythmPatternGameState();
}

class _RhythmPatternQuestion {
  final String pattern; // 예: "ABAB" 
  final List<String> sounds; // ['쿵', '짝']
  final List<String> emojis; // ['🥁', '👏']
  final int missingIndex; // 빠진 위치
  final String answer; // 정답
  final List<String> options; // 선택지

  const _RhythmPatternQuestion({
    required this.pattern,
    required this.sounds,
    required this.emojis,
    required this.missingIndex,
    required this.answer,
    required this.options,
  });
}

class _RhythmPatternGameState extends State<RhythmPatternGame>
    with TickerProviderStateMixin {
  static final List<_RhythmPatternQuestion> _questions = [
    // 쉬움: ABAB 패턴
    _RhythmPatternQuestion(
      pattern: 'ABAB',
      sounds: ['쿵!', '짝!'],
      emojis: ['🥁', '👏'],
      missingIndex: 3,
      answer: '짝!',
      options: ['쿵!', '짝!'],
    ),
    _RhythmPatternQuestion(
      pattern: 'ABAB',
      sounds: ['쿵!', '짝!'],
      emojis: ['🥁', '👏'],
      missingIndex: 2,
      answer: '쿵!',
      options: ['쿵!', '짝!'],
    ),
    // 보통: AAB 패턴
    _RhythmPatternQuestion(
      pattern: 'AABAABAAB',
      sounds: ['쿵!', '짝!'],
      emojis: ['🥁', '👏'],
      missingIndex: 5,
      answer: '쿵!',
      options: ['쿵!', '짝!'],
    ),
    _RhythmPatternQuestion(
      pattern: 'AABAABAAB',
      sounds: ['쿵!', '짝!'],
      emojis: ['🥁', '👏'],
      missingIndex: 8,
      answer: '짝!',
      options: ['쿵!', '짝!'],
    ),
    // 어려움: ABB 패턴
    _RhythmPatternQuestion(
      pattern: 'ABBABB',
      sounds: ['딩!', '똥!'],
      emojis: ['🔔', '🎵'],
      missingIndex: 3,
      answer: '딩!',
      options: ['딩!', '똥!'],
    ),
    _RhythmPatternQuestion(
      pattern: 'ABBABB',
      sounds: ['딩!', '똥!'],
      emojis: ['🔔', '🎵'],
      missingIndex: 5,
      answer: '똥!',
      options: ['딩!', '똥!'],
    ),
    // 복합
    _RhythmPatternQuestion(
      pattern: 'ABCABC',
      sounds: ['쿵!', '짝!', '탁!'],
      emojis: ['🥁', '👏', '🪘'],
      missingIndex: 4,
      answer: '짝!',
      options: ['쿵!', '짝!', '탁!'],
    ),
    _RhythmPatternQuestion(
      pattern: 'ABCABC',
      sounds: ['쿵!', '짝!', '탁!'],
      emojis: ['🥁', '👏', '🪘'],
      missingIndex: 5,
      answer: '탁!',
      options: ['쿵!', '짝!', '탁!'],
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  
  bool _isPlaying = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _currentPlayingIndex = -1;
  String? _selectedAnswer;
  
  late AnimationController _beatController;
  late Animation<double> _beatAnimation;
  
  final Random _random = Random();
  late List<_RhythmPatternQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _beatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _beatAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _beatController, curve: Curves.easeOut),
    );
    
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _beatController.dispose();
    super.dispose();
  }

  _RhythmPatternQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _selectedAnswer = null;
    _showFeedback = false;
    _currentPlayingIndex = -1;
    
    setState(() {});
    
    Future.delayed(const Duration(milliseconds: 500), _playPattern);
  }

  Future<void> _playPattern() async {
    setState(() {
      _isPlaying = true;
    });
    
    final pattern = _question.pattern;
    
    for (int i = 0; i < pattern.length; i++) {
      if (!mounted) return;
      
      if (i == _question.missingIndex) {
        // 빠진 부분 - 물음표 표시
        setState(() {
          _currentPlayingIndex = i;
        });
        await Future.delayed(const Duration(milliseconds: 400));
      } else {
        setState(() {
          _currentPlayingIndex = i;
        });
        
        _beatController.forward().then((_) {
          if (mounted) _beatController.reverse();
        });
        
        await Future.delayed(const Duration(milliseconds: 400));
      }
      
      if (!mounted) return;
      
      setState(() {
        _currentPlayingIndex = -1;
      });
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (!mounted) return;
    
    setState(() {
      _isPlaying = false;
    });
  }

  void _selectAnswer(String answer) {
    if (_isPlaying || _showFeedback || _selectedAnswer != null) return;
    
    final correct = answer == _question.answer;
    
    setState(() {
      _selectedAnswer = answer;
      _showFeedback = true;
      _isCorrect = correct;
      
      if (correct) {
        _score++;
      }
    });
    
    widget.onScoreUpdate?.call(_score, _currentQuestion + 1);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      _currentQuestion++;
      
      if (_currentQuestion >= _shuffledQuestions.length) {
        widget.onComplete?.call();
      } else {
        _startQuestion();
      }
    });
  }

  void _replayPattern() {
    if (_isPlaying || _showFeedback) return;
    _playPattern();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('🎵 리듬 맞추기'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '점수: $_score / ${_currentQuestion + 1}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행 표시
            _buildProgressBar(),
            
            // 상태 메시지
            _buildStatusMessage(),
            
            // 패턴 표시
            Expanded(child: _buildPatternDisplay()),
            
            // 선택지
            if (!_isPlaying) _buildOptions(),
            
            // 피드백
            if (_showFeedback) _buildFeedback(),
            
            // 다시 듣기 버튼
            if (!_isPlaying && !_showFeedback) _buildReplayButton(),
            
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
                '문제 ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                '${_currentQuestion + 1} / ${_shuffledQuestions.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _shuffledQuestions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
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
    
    if (_isPlaying) {
      message = '🎵 리듬을 잘 들어보세요!';
      icon = Icons.hearing;
    } else if (_showFeedback) {
      message = _isCorrect ? '🎉 정답!' : '😅 다시 들어볼까요?';
      icon = _isCorrect ? Icons.celebration : Icons.refresh;
    } else {
      message = '❓ 빠진 리듬은 무엇일까요?';
      icon = Icons.help_outline;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternDisplay() {
    final pattern = _question.pattern;
    final sounds = _question.sounds;
    final emojis = _question.emojis;
    
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pattern.length, (index) {
            final char = pattern[index];
            final soundIndex = char.codeUnitAt(0) - 'A'.codeUnitAt(0);
            final isMissing = index == _question.missingIndex;
            final isPlaying = _currentPlayingIndex == index;
            
            return AnimatedBuilder(
              animation: _beatAnimation,
              builder: (context, child) {
                final scale = isPlaying && !isMissing ? _beatAnimation.value : 1.0;
                
                return Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isMissing
                          ? (isPlaying ? Colors.amber[100] : Colors.grey[200])
                          : (isPlaying ? Colors.orange[300] : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPlaying
                            ? Colors.orange
                            : isMissing
                                ? Colors.grey
                                : Colors.orange[200]!,
                        width: isPlaying ? 3 : 1,
                      ),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isMissing) ...[
                          const Text(
                            '❓',
                            style: TextStyle(fontSize: 28),
                          ),
                          Text(
                            '?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Text(
                            emojis[soundIndex],
                            style: const TextStyle(fontSize: 28),
                          ),
                          Text(
                            sounds[soundIndex],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            '다음에 올 소리를 선택하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _question.options.map((option) {
              final optionIndex = _question.sounds.indexOf(option);
              final emoji = _question.emojis[optionIndex];
              final isSelected = _selectedAnswer == option;
              final isCorrectAnswer = option == _question.answer;
              
              Color backgroundColor;
              Color borderColor;
              
              if (_showFeedback) {
                if (isCorrectAnswer) {
                  backgroundColor = Colors.green[100]!;
                  borderColor = Colors.green;
                } else if (isSelected && !_isCorrect) {
                  backgroundColor = Colors.red[100]!;
                  borderColor = Colors.red;
                } else {
                  backgroundColor = Colors.white;
                  borderColor = Colors.grey[300]!;
                }
              } else {
                backgroundColor = Colors.white;
                borderColor = Colors.orange[300]!;
              }
              
              return GestureDetector(
                onTap: () => _selectAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
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
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect
                ? '🎶 리듬이 완성됐어요!'
                : '정답: ${_question.answer}',
            style: TextStyle(
              fontSize: 16,
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
        onPressed: _replayPattern,
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

