import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';

/// S 3.2.2: 동물 소리 이야기 게임
/// 동물 소리 시퀀스로 짧은 이야기 구성, 순서 재현
class AnimalSoundStoryGame extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const AnimalSoundStoryGame({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<AnimalSoundStoryGame> createState() => _AnimalSoundStoryGameState();
}

class _AnimalSoundStoryGameState extends State<AnimalSoundStoryGame>
    with TickerProviderStateMixin {
  // 이야기 데이터
  static const List<Map<String, dynamic>> _stories = [
    {
      'title': '농장의 아침',
      'setting': '🌅',
      'story': '농장에서 아침이 밝았어요!',
      'animals': [
        {'emoji': '🐓', 'name': '닭', 'sound': '꼬끼오~'},
        {'emoji': '🐕', 'name': '강아지', 'sound': '멍멍!'},
        {'emoji': '🐄', 'name': '소', 'sound': '음메~'},
      ],
    },
    {
      'title': '숲속 탐험',
      'setting': '🌲',
      'story': '숲속에서 동물 친구들을 만났어요!',
      'animals': [
        {'emoji': '🐦', 'name': '새', 'sound': '짹짹!'},
        {'emoji': '🦉', 'name': '부엉이', 'sound': '부엉부엉'},
        {'emoji': '🐿️', 'name': '다람쥐', 'sound': '찍찍!'},
      ],
    },
    {
      'title': '동물원 나들이',
      'setting': '🦁',
      'story': '동물원에 놀러 갔어요!',
      'animals': [
        {'emoji': '🦁', 'name': '사자', 'sound': '어흥!'},
        {'emoji': '🐘', 'name': '코끼리', 'sound': '뿌우~'},
        {'emoji': '🐒', 'name': '원숭이', 'sound': '끽끽!'},
      ],
    },
    {
      'title': '바닷가 여행',
      'setting': '🏖️',
      'story': '바닷가에서 친구들을 만났어요!',
      'animals': [
        {'emoji': '🦅', 'name': '갈매기', 'sound': '끼룩끼룩'},
        {'emoji': '🦀', 'name': '게', 'sound': '딱딱!'},
        {'emoji': '🐬', 'name': '돌고래', 'sound': '끼익!'},
        {'emoji': '🦭', 'name': '물개', 'sound': '아르르!'},
      ],
    },
    {
      'title': '밤의 숲',
      'setting': '🌙',
      'story': '밤이 되자 숲속이 시끌벅적해요!',
      'animals': [
        {'emoji': '🦉', 'name': '부엉이', 'sound': '부엉!'},
        {'emoji': '🐸', 'name': '개구리', 'sound': '개굴개굴'},
        {'emoji': '🦗', 'name': '귀뚜라미', 'sound': '귀뚤귀뚤'},
        {'emoji': '🦇', 'name': '박쥐', 'sound': '끼익!'},
      ],
    },
  ];

  int _currentStoryIndex = 0;
  int _currentRound = 0;
  int _score = 0;
  final int _totalQuestions = 5;
  
  List<int> _sequence = [];
  List<int> _userInput = [];
  
  bool _isPlayingStory = false;
  bool _isUserTurn = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  int _highlightedIndex = -1;
  int _currentPlayingIndex = -1;
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _startNewRound();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentStory => _stories[_currentStoryIndex];
  List<Map<String, dynamic>> get _currentAnimals => 
      List<Map<String, dynamic>>.from(_currentStory['animals']);

  void _startNewRound() {
    _currentStoryIndex = _currentRound % _stories.length;
    
    // 시퀀스 생성 (이야기 순서대로)
    _sequence = List.generate(_currentAnimals.length, (i) => i);
    _userInput = [];
    _isUserTurn = false;
    _showFeedback = false;
    
    setState(() {});
    
    // 이야기 재생 시작
    Future.delayed(const Duration(milliseconds: 500), _playStory);
  }

  Future<void> _playStory() async {
    setState(() {
      _isPlayingStory = true;
      _highlightedIndex = -1;
      _currentPlayingIndex = -1;
    });
    
    // 이야기 시작 대기
    await Future.delayed(const Duration(milliseconds: 1000));
    
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      
      final animalIndex = _sequence[i];
      
      setState(() {
        _currentPlayingIndex = i;
        _highlightedIndex = animalIndex;
      });
      
      _bounceController.forward().then((_) {
        if (mounted) _bounceController.reverse();
      });
      
      // 소리 재생 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 1200));
      
      if (!mounted) return;
      
      setState(() {
        _highlightedIndex = -1;
      });
      
      await Future.delayed(const Duration(milliseconds: 400));
    }
    
    if (!mounted) return;
    
    setState(() {
      _isPlayingStory = false;
      _isUserTurn = true;
      _currentPlayingIndex = -1;
    });
  }

  void _onAnimalTap(int index) {
    if (!_isUserTurn || _showFeedback) return;
    
    setState(() {
      _userInput.add(index);
      _highlightedIndex = index;
    });
    
    _bounceController.forward().then((_) {
      if (mounted) {
        _bounceController.reverse();
        setState(() {
          _highlightedIndex = -1;
        });
      }
    });
    
    // 입력 검증
    final currentIndex = _userInput.length - 1;
    if (_userInput[currentIndex] != _sequence[currentIndex]) {
      _showResult(false);
    } else if (_userInput.length == _sequence.length) {
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
      
      if (_currentRound >= _totalQuestions) {
        widget.onComplete?.call();
      } else {
        _startNewRound();
      }
    });
  }

  void _replayStory() {
    if (_isPlayingStory || !_isUserTurn) return;
    
    setState(() {
      _userInput = [];
    });
    
    _playStory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF0),
      appBar: AppBar(
        title: const Text('🐾 동물 소리 이야기'),
        backgroundColor: Colors.green,
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
            // 진행 표시
            _buildProgressBar(),
            
            // 이야기 카드
            _buildStoryCard(),
            
            // 동물 시퀀스 (재생 중)
            if (_isPlayingStory) _buildPlayingSequence(),
            
            // 동물 그리드 (입력용)
            Expanded(child: _buildAnimalGrid()),
            
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
                '이야기 ${_currentRound + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[100]!, Colors.green[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentStory['setting'] as String,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Text(
                _currentStory['title'] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentStory['story'] as String,
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingSequence() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: [
          const Text(
            '🎵 잘 들어보세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_sequence.length, (index) {
              final animal = _currentAnimals[_sequence[index]];
              final isPlaying = _currentPlayingIndex == index;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPlaying ? Colors.amber : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPlaying ? Colors.amber[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      animal['emoji'] as String,
                      style: TextStyle(fontSize: isPlaying ? 28 : 24),
                    ),
                    if (isPlaying)
                      Text(
                        animal['sound'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalGrid() {
    final animals = _currentAnimals;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isUserTurn && !_showFeedback) ...[
            Text(
              '🎯 순서대로 터치하세요! (${_userInput.length}/${_sequence.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: List.generate(animals.length, (index) {
              return _buildAnimalButton(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalButton(int index) {
    final animal = _currentAnimals[index];
    final isHighlighted = _highlightedIndex == index;
    final isSelected = _userInput.contains(index);
    final selectionOrder = _userInput.indexOf(index);
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        final scale = isHighlighted ? _bounceAnimation.value : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _onAnimalTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              height: 120,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.amber
                    : isSelected
                        ? Colors.green[100]
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        animal['emoji'] as String,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        animal['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        animal['sound'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${selectionOrder + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
                ? '🎉 ${_currentStory['title']} 완성!'
                : '다시 들어볼까요?',
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
        onPressed: _replayStory,
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

