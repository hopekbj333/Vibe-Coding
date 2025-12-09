import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';

/// S 3.2.5: 소리 규칙 찾기 게임
/// 소리 시퀀스의 규칙 파악 후 다음 소리 예측
class SoundRuleGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const SoundRuleGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<SoundRuleGame> createState() => _SoundRuleGameState();
}

class _SoundRuleQuestion {
  final String title;
  final String hint;
  final List<Map<String, dynamic>> sequence; // 시퀀스
  final Map<String, dynamic> answer; // 정답
  final List<Map<String, dynamic>> options; // 선택지

  const _SoundRuleQuestion({
    required this.title,
    required this.hint,
    required this.sequence,
    required this.answer,
    required this.options,
  });
}

class _SoundRuleGameState extends State<SoundRuleGame>
    with TickerProviderStateMixin {
  static final List<_SoundRuleQuestion> _questions = [
    // 높낮이 패턴
    _SoundRuleQuestion(
      title: '높낮이 패턴',
      hint: '높은 소리와 낮은 소리가 번갈아 나와요',
      sequence: [
        {'label': '높음', 'emoji': '⬆️', 'color': Colors.red},
        {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
        {'label': '높음', 'emoji': '⬆️', 'color': Colors.red},
      ],
      answer: {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
      options: [
        {'label': '높음', 'emoji': '⬆️', 'color': Colors.red},
        {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
      ],
    ),
    _SoundRuleQuestion(
      title: '높낮이 패턴',
      hint: '높은 소리와 낮은 소리가 번갈아 나와요',
      sequence: [
        {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
        {'label': '높음', 'emoji': '⬆️', 'color': Colors.red},
        {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
        {'label': '높음', 'emoji': '⬆️', 'color': Colors.red},
      ],
      answer: {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
      options: [
        {'label': '높음', 'emoji': '⬆️', 'color': Colors.red},
        {'label': '낮음', 'emoji': '⬇️', 'color': Colors.blue},
      ],
    ),
    // 길이 패턴
    _SoundRuleQuestion(
      title: '길이 패턴',
      hint: '긴 소리와 짧은 소리가 번갈아 나와요',
      sequence: [
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
        {'label': '짧게', 'emoji': '•', 'color': Colors.orange},
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
      ],
      answer: {'label': '짧게', 'emoji': '•', 'color': Colors.orange},
      options: [
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
        {'label': '짧게', 'emoji': '•', 'color': Colors.orange},
      ],
    ),
    _SoundRuleQuestion(
      title: '길이 패턴',
      hint: '긴 소리가 두 번, 짧은 소리가 한 번 나와요',
      sequence: [
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
        {'label': '짧게', 'emoji': '•', 'color': Colors.orange},
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
      ],
      answer: {'label': '짧게', 'emoji': '•', 'color': Colors.orange},
      options: [
        {'label': '길게', 'emoji': '➖', 'color': Colors.purple},
        {'label': '짧게', 'emoji': '•', 'color': Colors.orange},
      ],
    ),
    // 크기 패턴
    _SoundRuleQuestion(
      title: '크기 패턴',
      hint: '큰 소리와 작은 소리가 번갈아 나와요',
      sequence: [
        {'label': '크게', 'emoji': '🔊', 'color': Colors.green},
        {'label': '작게', 'emoji': '🔈', 'color': Colors.teal},
        {'label': '크게', 'emoji': '🔊', 'color': Colors.green},
        {'label': '작게', 'emoji': '🔈', 'color': Colors.teal},
      ],
      answer: {'label': '크게', 'emoji': '🔊', 'color': Colors.green},
      options: [
        {'label': '크게', 'emoji': '🔊', 'color': Colors.green},
        {'label': '작게', 'emoji': '🔈', 'color': Colors.teal},
      ],
    ),
    // 세 가지 패턴
    _SoundRuleQuestion(
      title: '세 소리 패턴',
      hint: '세 가지 소리가 순서대로 반복돼요',
      sequence: [
        {'label': '도', 'emoji': '🔴', 'color': Colors.red},
        {'label': '레', 'emoji': '🟠', 'color': Colors.orange},
        {'label': '미', 'emoji': '🟡', 'color': Colors.yellow},
        {'label': '도', 'emoji': '🔴', 'color': Colors.red},
        {'label': '레', 'emoji': '🟠', 'color': Colors.orange},
      ],
      answer: {'label': '미', 'emoji': '🟡', 'color': Colors.yellow},
      options: [
        {'label': '도', 'emoji': '🔴', 'color': Colors.red},
        {'label': '레', 'emoji': '🟠', 'color': Colors.orange},
        {'label': '미', 'emoji': '🟡', 'color': Colors.yellow},
      ],
    ),
    // 복합 패턴
    _SoundRuleQuestion(
      title: '복합 패턴',
      hint: '높고 긴 소리, 낮고 짧은 소리가 번갈아요',
      sequence: [
        {'label': '높고긴', 'emoji': '⬆️➖', 'color': Colors.pink},
        {'label': '낮고짧', 'emoji': '⬇️•', 'color': Colors.indigo},
        {'label': '높고긴', 'emoji': '⬆️➖', 'color': Colors.pink},
      ],
      answer: {'label': '낮고짧', 'emoji': '⬇️•', 'color': Colors.indigo},
      options: [
        {'label': '높고긴', 'emoji': '⬆️➖', 'color': Colors.pink},
        {'label': '낮고짧', 'emoji': '⬇️•', 'color': Colors.indigo},
      ],
    ),
    // 점점 변화 패턴
    _SoundRuleQuestion(
      title: '점점 변화',
      hint: '소리가 점점 커져요',
      sequence: [
        {'label': '아주작게', 'emoji': '🔇', 'color': Colors.grey},
        {'label': '작게', 'emoji': '🔈', 'color': Colors.lightBlue},
        {'label': '보통', 'emoji': '🔉', 'color': Colors.blue},
      ],
      answer: {'label': '크게', 'emoji': '🔊', 'color': Colors.indigo},
      options: [
        {'label': '아주작게', 'emoji': '🔇', 'color': Colors.grey},
        {'label': '크게', 'emoji': '🔊', 'color': Colors.indigo},
      ],
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  
  bool _isPlaying = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _currentPlayingIndex = -1;
  Map<String, dynamic>? _selectedAnswer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final Random _random = Random();
  late List<_SoundRuleQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  _SoundRuleQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _selectedAnswer = null;
    _showFeedback = false;
    _currentPlayingIndex = -1;
    
    setState(() {});
    
    Future.delayed(const Duration(milliseconds: 500), _playSequence);
  }

  Future<void> _playSequence() async {
    setState(() {
      _isPlaying = true;
    });
    
    for (int i = 0; i < _question.sequence.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _currentPlayingIndex = i;
      });
      
      _pulseController.forward().then((_) {
        if (mounted) _pulseController.reverse();
      });
      
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (!mounted) return;
      
      setState(() {
        _currentPlayingIndex = -1;
      });
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    if (!mounted) return;
    
    setState(() {
      _isPlaying = false;
    });
  }

  void _selectAnswer(Map<String, dynamic> answer) {
    if (_isPlaying || _showFeedback || _selectedAnswer != null) return;
    
    final correct = answer['label'] == _question.answer['label'];
    
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

  void _replaySequence() {
    if (_isPlaying || _showFeedback) return;
    _playSequence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('🔍 규칙 찾기'),
        backgroundColor: Colors.purple,
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
            
            // 패턴 유형 & 힌트
            _buildPatternInfo(),
            
            // 시퀀스 표시
            Expanded(child: _buildSequenceDisplay()),
            
            // 질문
            _buildQuestion(),
            
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
                  color: Colors.purple,
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        children: [
          Text(
            _question.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 ${_question.hint}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.purple[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceDisplay() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(_question.sequence.length, (index) {
              return Row(
                children: [
                  _buildSoundItem(_question.sequence[index], index),
                  if (index < _question.sequence.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                ],
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
            // 물음표
            Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '❓',
                    style: TextStyle(fontSize: 32),
                  ),
                  Text(
                    '다음은?',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundItem(Map<String, dynamic> item, int index) {
    final isPlaying = _currentPlayingIndex == index;
    final color = item['color'] as Color;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isPlaying ? _pulseAnimation.value : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70,
            height: 90,
            decoration: BoxDecoration(
              color: isPlaying ? color.withOpacity(0.3) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlaying ? color : Colors.grey[300]!,
                width: isPlaying ? 3 : 1,
              ),
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['emoji'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '🎯 다음에 올 소리는 무엇일까요?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.purple[700],
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _question.options.map((option) {
          final isSelected = _selectedAnswer?['label'] == option['label'];
          final isCorrectAnswer = option['label'] == _question.answer['label'];
          final color = option['color'] as Color;
          
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
            borderColor = color;
          }
          
          return GestureDetector(
            onTap: () => _selectAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  Text(
                    option['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option['label'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
                ? '🎉 규칙을 찾았어요!'
                : '정답: ${_question.answer['emoji']} ${_question.answer['label']}',
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

