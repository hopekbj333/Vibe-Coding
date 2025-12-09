import 'dart:math';
import 'package:flutter/material.dart';

/// S 3.3.4: 퍼즐 맞추기 게임
/// 조각난 그림을 원래 위치에 배치하는 공간 인식 훈련
class PuzzleGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const PuzzleGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzlePiece {
  final int correctIndex;
  int currentIndex;
  final String emoji;
  
  _PuzzlePiece({
    required this.correctIndex,
    required this.currentIndex,
    required this.emoji,
  });
  
  bool get isCorrect => correctIndex == currentIndex;
}

class _PuzzleQuestion {
  final String title;
  final String completeEmoji;
  final List<String> pieces;
  final int gridSize; // 2x2 = 4, 3x3 = 9

  const _PuzzleQuestion({
    required this.title,
    required this.completeEmoji,
    required this.pieces,
    required this.gridSize,
  });
}

class _PuzzleGameState extends State<PuzzleGame> with TickerProviderStateMixin {
  static final List<_PuzzleQuestion> _questions = [
    // 2x2 퍼즐 (4조각)
    _PuzzleQuestion(
      title: '🐱 고양이',
      completeEmoji: '🐱',
      pieces: ['😺', '🐱', '😸', '😻'],
      gridSize: 4,
    ),
    _PuzzleQuestion(
      title: '🌈 무지개',
      completeEmoji: '🌈',
      pieces: ['🔴', '🟠', '🟡', '🟢'],
      gridSize: 4,
    ),
    // 2x3 퍼즐 (6조각)
    _PuzzleQuestion(
      title: '🏠 우리 집',
      completeEmoji: '🏠',
      pieces: ['🏠', '🌳', '☀️', '🌷', '🚗', '🐕'],
      gridSize: 6,
    ),
    _PuzzleQuestion(
      title: '🎂 생일파티',
      completeEmoji: '🎂',
      pieces: ['🎂', '🎈', '🎁', '🎉', '🍰', '🕯️'],
      gridSize: 6,
    ),
    // 3x3 퍼즐 (9조각)
    _PuzzleQuestion(
      title: '🚀 우주여행',
      completeEmoji: '🚀',
      pieces: ['🚀', '🌙', '⭐', '🌍', '🛸', '👨‍🚀', '🌟', '☄️', '🪐'],
      gridSize: 9,
    ),
    _PuzzleQuestion(
      title: '🌊 바닷속',
      completeEmoji: '🐠',
      pieces: ['🐠', '🐙', '🦑', '🐚', '🦀', '🐬', '🐋', '🦈', '🌊'],
      gridSize: 9,
    ),
  ];

  int _currentQuestion = 0;
  int _score = 0;
  int _moves = 0;
  
  List<_PuzzlePiece> _pieces = [];
  int? _selectedIndex;
  bool _showFeedback = false;
  bool _isComplete = false;
  
  late AnimationController _completeController;
  late Animation<double> _completeAnimation;
  
  final Random _random = Random();
  late List<_PuzzleQuestion> _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _completeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _completeController, curve: Curves.elasticOut),
    );
    
    _shuffledQuestions = List.from(_questions)..shuffle(_random);
    _startQuestion();
  }

  @override
  void dispose() {
    _completeController.dispose();
    super.dispose();
  }

  _PuzzleQuestion get _question => _shuffledQuestions[_currentQuestion];

  void _startQuestion() {
    _moves = 0;
    _selectedIndex = null;
    _showFeedback = false;
    _isComplete = false;
    
    // 퍼즐 조각 생성 및 섞기
    final piecesList = <_PuzzlePiece>[];
    for (int i = 0; i < _question.pieces.length; i++) {
      piecesList.add(_PuzzlePiece(
        correctIndex: i,
        currentIndex: i,
        emoji: _question.pieces[i],
      ));
    }
    
    // 섞기 (하지만 풀 수 있도록)
    do {
      piecesList.shuffle(_random);
      for (int i = 0; i < piecesList.length; i++) {
        piecesList[i].currentIndex = i;
      }
    } while (_isPuzzleSolved(piecesList));
    
    _pieces = piecesList;
    setState(() {});
  }

  bool _isPuzzleSolved(List<_PuzzlePiece> pieces) {
    return pieces.every((p) => p.isCorrect);
  }

  void _onPieceTap(int index) {
    if (_showFeedback) return;
    
    if (_selectedIndex == null) {
      // 첫 번째 선택
      setState(() {
        _selectedIndex = index;
      });
    } else if (_selectedIndex == index) {
      // 같은 조각 다시 탭 - 선택 취소
      setState(() {
        _selectedIndex = null;
      });
    } else {
      // 두 번째 선택 - 교환
      _swapPieces(_selectedIndex!, index);
    }
  }

  void _swapPieces(int index1, int index2) {
    setState(() {
      // 조각 위치 교환
      final temp = _pieces[index1];
      _pieces[index1] = _pieces[index2];
      _pieces[index2] = temp;
      
      // currentIndex 업데이트
      _pieces[index1].currentIndex = index1;
      _pieces[index2].currentIndex = index2;
      
      _selectedIndex = null;
      _moves++;
    });
    
    // 완성 체크
    if (_isPuzzleSolved(_pieces)) {
      _handleComplete();
    }
  }

  void _handleComplete() {
    _isComplete = true;
    _score++;
    
    _completeController.forward();
    
    widget.onScoreUpdate?.call(_score, _currentQuestion + 1);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      setState(() {
        _showFeedback = true;
      });
      
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        
        _currentQuestion++;
        
        if (_currentQuestion >= _shuffledQuestions.length) {
          widget.onComplete?.call();
        } else {
          _completeController.reset();
          _startQuestion();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('🧩 퍼즐 맞추기'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '이동: $_moves',
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
            
            // 완성 힌트
            _buildHint(),
            
            // 퍼즐 그리드
            Expanded(child: _buildPuzzleGrid()),
            
            // 피드백
            if (_showFeedback) _buildFeedback(),
            
            // 안내 메시지
            if (!_showFeedback && !_isComplete) _buildInstruction(),
            
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
                '퍼즐 ${_currentQuestion + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _question.completeEmoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _question.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '순서대로 맞춰보세요!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleGrid() {
    final gridSize = _question.gridSize;
    final crossAxisCount = gridSize <= 4 ? 2 : 3;
    
    return Center(
      child: AnimatedBuilder(
        animation: _completeAnimation,
        builder: (context, child) {
          final scale = _isComplete ? _completeAnimation.value : 1.0;
          
          return Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isComplete ? Colors.green[100] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isComplete ? Colors.green : Colors.grey[300]!,
                  width: _isComplete ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isComplete
                        ? Colors.green.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: _isComplete ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: crossAxisCount / ((gridSize / crossAxisCount).ceil()),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: _pieces.length,
                  itemBuilder: (context, index) {
                    return _buildPiece(index);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPiece(int index) {
    final piece = _pieces[index];
    final isSelected = _selectedIndex == index;
    final isCorrect = piece.isCorrect;
    
    return GestureDetector(
      onTap: () => _onPieceTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber[100]
              : isCorrect && _isComplete
                  ? Colors.green[100]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.amber
                : isCorrect && _isComplete
                    ? Colors.green
                    : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            piece.emoji,
            style: TextStyle(
              fontSize: _question.gridSize <= 4 ? 48 : 36,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, color: Colors.amber[700], size: 20),
          const SizedBox(width: 8),
          Text(
            _selectedIndex == null
                ? '조각을 선택하세요'
                : '바꿀 조각을 선택하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[800],
            ),
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
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text(
            '🎉 완성! ($_moves번 이동)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}

