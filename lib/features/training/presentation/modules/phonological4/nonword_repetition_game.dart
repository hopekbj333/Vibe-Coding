import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../../core/design/design_system.dart';

/// 비단어 따라하기 훈련 (S 3.1.6)
/// 
/// 존재하지 않는 단어(예: "두파리", "삐꾸롱") 듣고 따라 말하기
/// 게임화: 외계어 통역사 컨셉
class NonwordRepetitionGame extends StatefulWidget {
  final String childId;
  final VoidCallback? onComplete;

  const NonwordRepetitionGame({
    super.key,
    required this.childId,
    this.onComplete,
  });

  @override
  State<NonwordRepetitionGame> createState() => _NonwordRepetitionGameState();
}

class _NonwordRepetitionGameState extends State<NonwordRepetitionGame>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _showResult = false;
  bool _isCorrect = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _alienController;

  final List<_NonwordQuestion> _questions = [
    // 2음절 (쉬움)
    _NonwordQuestion(nonword: '두파', syllables: 2, level: 1),
    _NonwordQuestion(nonword: '비꾸', syllables: 2, level: 1),
    _NonwordQuestion(nonword: '토라', syllables: 2, level: 1),
    // 3음절 (보통)
    _NonwordQuestion(nonword: '두파리', syllables: 3, level: 2),
    _NonwordQuestion(nonword: '삐꾸롱', syllables: 3, level: 2),
    _NonwordQuestion(nonword: '토라붕', syllables: 3, level: 2),
    // 4음절 (어려움)
    _NonwordQuestion(nonword: '구릅타미', syllables: 4, level: 3),
    _NonwordQuestion(nonword: '삐뚜로기', syllables: 4, level: 3),
  ];

  @override
  void initState() {
    super.initState();
    _questions.shuffle(Random());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _alienController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _alienController.dispose();
    super.dispose();
  }

  void _playNonword() {
    if (_isPlaying || _isRecording) return;

    setState(() {
      _isPlaying = true;
    });

    _alienController.forward();

    // 시뮬레이션: 실제로는 TTS나 녹음된 음성 재생
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _alienController.reverse();
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _startRecording() {
    if (_isPlaying || _showResult) return;

    setState(() {
      _isRecording = true;
    });
    _pulseController.repeat(reverse: true);

    // 시뮬레이션: 3초 후 자동 종료
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isRecording) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    if (!_isRecording) return;

    _pulseController.stop();
    _pulseController.reset();

    // 시뮬레이션: 정답 판정 (실제로는 STT 결과와 비교)
    final random = Random();
    final correct = random.nextDouble() > 0.3; // 70% 정답률

    setState(() {
      _isRecording = false;
      _showResult = true;
      _isCorrect = correct;
      if (correct) _correctCount++;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _showResult = false;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    final accuracy = (_correctCount / _questions.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 외계어 통역 완료!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👽', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$_correctCount / ${_questions.length} 성공',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '정확도: $accuracy%',
              style: TextStyle(
                fontSize: 18,
                color: accuracy >= 70
                    ? DesignSystem.semanticSuccess
                    : DesignSystem.semanticWarning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              accuracy >= 70
                  ? '훌륭한 통역사예요! 🌟'
                  : '더 연습하면 잘할 수 있어요! 💪',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('나가기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _correctCount = 0;
                _showResult = false;
                _questions.shuffle(Random());
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('다시 하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('외계어 통역사'),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProgressBar(),
                const SizedBox(height: 24),
                _buildLevelIndicator(question),
                const Spacer(),
                _buildAlien(question),
                const Spacer(),
                _buildControls(),
                const SizedBox(height: 24),
                if (_showResult) _buildFeedback(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (_currentQuestionIndex + 1) / _questions.length,
        minHeight: 8,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
      ),
    );
  }

  Widget _buildLevelIndicator(_NonwordQuestion question) {
    final levelText = ['쉬움', '보통', '어려움'][question.level - 1];
    final levelColor = [Colors.green, Colors.orange, Colors.red][question.level - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: levelColor),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: levelColor, size: 18),
              const SizedBox(width: 8),
              Text(
                '$levelText (${question.syllables}음절)',
                style: TextStyle(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlien(_NonwordQuestion question) {
    return AnimatedBuilder(
      animation: _alienController,
      builder: (context, child) {
        return Column(
          children: [
            // 외계인 캐릭터
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade300,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 눈
                  Positioned(
                    top: 40,
                    child: Row(
                      children: [
                        _buildEye(_isPlaying),
                        const SizedBox(width: 30),
                        _buildEye(_isPlaying),
                      ],
                    ),
                  ),
                  // 입
                  Positioned(
                    bottom: 40,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isPlaying ? 40 : 20,
                      height: _isPlaying ? 30 : 10,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // 안테나
                  Positioned(
                    top: -20,
                    child: Row(
                      children: [
                        _buildAntenna(-0.3),
                        const SizedBox(width: 40),
                        _buildAntenna(0.3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 말풍선
            if (_isPlaying)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  '"${question.nonword}"',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '외계인의 말을 듣고\n똑같이 따라해보세요!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEye(bool isBlinking) {
    return Container(
      width: 24,
      height: isBlinking ? 4 : 24,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildAntenna(double angle) {
    return Transform.rotate(
      angle: angle,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow.shade300,
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: 20,
            color: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 듣기 버튼
        GestureDetector(
          onTap: _playNonword,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPlaying ? Colors.amber : Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: (_isPlaying ? Colors.amber : Colors.blue).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.volume_up : Icons.hearing,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),

        // 녹음 버튼
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRecording ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : Colors.pink,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : Colors.pink).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: _isRecording ? 10 : 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    return AnimatedOpacity(
      opacity: _showResult ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isCorrect ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.refresh,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _isCorrect ? '완벽해요! 🌟' : '다시 도전해봐요!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NonwordQuestion {
  final String nonword;
  final int syllables;
  final int level;

  _NonwordQuestion({
    required this.nonword,
    required this.syllables,
    required this.level,
  });
}

