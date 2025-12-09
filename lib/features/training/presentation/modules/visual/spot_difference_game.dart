import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.3.1: 틀린 그림 찾기 게임
/// 두 그림에서 다른 부분을 찾는 시각 변별 훈련
class SpotDifferenceGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const SpotDifferenceGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<SpotDifferenceGame> createState() => _SpotDifferenceGameState();
}

class _SpotDifferenceQuestion {
  final String theme;
  final List<String> baseItems; // 기본 아이템들
  final List<int> differenceIndices; // 다른 부분 인덱스
  final List<String> changedItems; // 변경된 아이템들

  const _SpotDifferenceQuestion({
    required this.theme,
    required this.baseItems,
    required this.differenceIndices,
    required this.changedItems,
  });
}

class _SpotDifferenceGameState extends State<SpotDifferenceGame>
    with TickerProviderStateMixin {
  static final List<_SpotDifferenceQuestion> _questions = [
    // 레벨 1: 쉬움 (3개 차이)
    _SpotDifferenceQuestion(
      theme: '🏠 우리 집',
      baseItems: ['🏠', '🌳', '🌷', '☀️', '🐕', '🚗'],
      differenceIndices: [1, 4, 5],
      changedItems: ['🏠', '🌲', '🌷', '☀️', '🐈', '🚙'],
    ),
    _SpotDifferenceQuestion(
      theme: '🌊 바닷가',
      baseItems: ['🌊', '🏖️', '🦀', '⛱️', '🐚', '🌴'],
      differenceIndices: [2, 3, 5],
      changedItems: ['🌊', '🏖️', '🦐', '🏄', '🐚', '🌵'],
    ),
    // 레벨 2: 보통 (4개 차이)
    _SpotDifferenceQuestion(
      theme: '🎪 놀이공원',
      baseItems: ['🎡', '🎢', '🎠', '🍿', '🎈', '🎪', '🍦', '🎯'],
      differenceIndices: [0, 2, 4, 6],
      changedItems: ['🎰', '🎢', '🎪', '🍿', '🎀', '🎪', '🍨', '🎯'],
    ),
    _SpotDifferenceQuestion(
      theme: '🌲 숲속',
      baseItems: ['🌲', '🦊', '🍄', '🌸', '🦋', '🐿️', '🌻', '🍀'],
      differenceIndices: [1, 3, 5, 7],
      changedItems: ['🌲', '🦝', '🍄', '🌺', '🦋', '🐰', '🌻', '☘️'],
    ),
    // 레벨 3: 어려움 (5개 차이)
    _SpotDifferenceQuestion(
      theme: '🏫 학교',
      baseItems: ['🏫', '📚', '✏️', '🎒', '⏰', '🔔', '📐', '🖍️', '📓'],
      differenceIndices: [1, 3, 4, 6, 8],
      changedItems: ['🏫', '📖', '✏️', '🎿', '⌚', '🔔', '📏', '🖍️', '📔'],
    ),
    _SpotDifferenceQuestion(
      theme: '🍳 주방',
      baseItems: ['🍳', '🥘', '🍴', '🥄', '🍶', '🧂', '🥢', '🍽️', '🫖'],
      differenceIndices: [0, 2, 4, 6, 8],
      changedItems: ['🥚', '🥘', '🍽️', '🥄', '🍾', '🧂', '🥣', '🍽️', '☕'],
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  int _timeLeft = 60;
  Timer? _timer;
  
  Set<int> _foundDifferences = {};
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _lastTappedIndex = -1;
  bool _showHint = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final Random _random = Random();
  late List<_SpotDifferenceQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  _SpotDifferenceQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _foundDifferences = {};
    _showFeedback = false;
    _lastTappedIndex = -1;
    _showHint = false;
    
    // 난이도에 따른 시간 설정
    if (_currentQuestion < 2) {
      _timeLeft = 60;
    } else if (_currentQuestion < 4) {
      _timeLeft = 50;
    } else {
      _timeLeft = 45;
    }
    
    setState(() {});
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _timeLeft--;
      });
      
      if (_timeLeft <= 0) {
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _showResult(false);
  }

  void _onItemTap(int index, bool isRightSide) {
    if (_showFeedback) return;
    
    // 오른쪽 그림에서만 다른 부분 찾기
    if (!isRightSide) {
      // 왼쪽 클릭시 피드백
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오른쪽 그림에서 다른 부분을 찾아주세요!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _lastTappedIndex = index;
    });
    
    if (_question.differenceIndices.contains(index)) {
      // 정답!
      if (!_foundDifferences.contains(index)) {
        setState(() {
          _foundDifferences.add(index);
        });
        
        // 모두 찾았는지 확인
        if (_foundDifferences.length == _question.differenceIndices.length) {
          _timer?.cancel();
          _showResult(true);
        }
      }
    } else {
      // 오답 - 시간 패널티
      setState(() {
        _timeLeft = max(0, _timeLeft - 3);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('다시 찾아보세요! (-3초)'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResult(bool allFound) {
    setState(() {
      _showFeedback = true;
      _isCorrect = allFound;
      
      if (allFound) {
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

  void _useHint() {
    if (_showHint) return;
    
    setState(() {
      _showHint = true;
      _timeLeft = max(0, _timeLeft - 10); // 힌트 사용 시 시간 패널티
    });
    
    // 3초 후 힌트 숨김
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('🔍 틀린 그림 찾기'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: _timeLeft <= 10 ? Colors.red : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_timeLeft}초',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
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
            
            // 테마 & 찾은 개수
            _buildStatusBar(),
            
            // 두 그림
            Expanded(child: _buildPictureComparison()),
            
            // 피드백
            if (_showFeedback) _buildFeedback(),
            
            // 힌트 버튼
            if (!_showFeedback) _buildHintButton(),
            
            const SizedBox(height: 16),
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
                '스테이지 ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                '점수: $_score',
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final totalDifferences = _question.differenceIndices.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _question.theme,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              ...List.generate(totalDifferences, (index) {
                final found = index < _foundDifferences.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    found ? Icons.star : Icons.star_border,
                    color: found ? Colors.amber : Colors.grey,
                    size: 24,
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${_foundDifferences.length}/$totalDifferences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPictureComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 왼쪽 그림 (원본)
          Expanded(
            child: _buildPicture(
              items: _question.baseItems,
              isOriginal: true,
              label: '원본',
            ),
          ),
          const SizedBox(width: 12),
          // 오른쪽 그림 (차이 있음)
          Expanded(
            child: _buildPicture(
              items: _question.changedItems,
              isOriginal: false,
              label: '다른 그림',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicture({
    required List<String> items,
    required bool isOriginal,
    required String label,
  }) {
    final crossAxisCount = items.length <= 6 ? 2 : 3;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOriginal ? Colors.blue[200]! : Colors.orange[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 라벨
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isOriginal ? Colors.blue[50] : Colors.orange[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOriginal ? Colors.blue : Colors.orange,
                ),
              ),
            ),
          ),
          // 그림 그리드
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItem(
                  items[index],
                  index,
                  !isOriginal,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String emoji, int index, bool isRightSide) {
    final isDifferent = _question.differenceIndices.contains(index);
    final isFound = _foundDifferences.contains(index);
    final shouldHighlight = _showHint && isDifferent && isRightSide && !isFound;
    
    return GestureDetector(
      onTap: () => _onItemTap(index, isRightSide),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = shouldHighlight ? _pulseAnimation.value : 1.0;
          
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: isFound
                    ? Colors.green[100]
                    : shouldHighlight
                        ? Colors.amber[100]
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFound
                      ? Colors.green
                      : shouldHighlight
                          ? Colors.amber
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  if (isFound)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedback() {
    final found = _foundDifferences.length;
    final total = _question.differenceIndices.length;
    
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
            _isCorrect ? Icons.celebration : Icons.timer_off,
            color: _isCorrect ? Colors.green : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect
                ? '🎉 모두 찾았어요! ($total/$total)'
                : '⏰ 시간 초과! ($found/$total 발견)',
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

  Widget _buildHintButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _showHint ? null : _useHint,
        icon: const Icon(Icons.lightbulb_outline),
        label: Text(_showHint ? '힌트 사용 중...' : '힌트 보기 (-10초)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _showHint ? Colors.grey[300] : Colors.amber[100],
          foregroundColor: _showHint ? Colors.grey : Colors.amber[800],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

