import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../data/models/training_content_model.dart';
import '../../../data/services/question_loader_service.dart';

/// S 3.4.2: 카드 기억 게임 (메모리 매칭) - JSON 기반 버전
/// 카드 뒤집어서 짝 찾기
/// JSON 파일에서 문항을 로드합니다.
class CardMatchGameV2 extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(int score, int total)? onScoreUpdate;

  const CardMatchGameV2({
    super.key,
    this.onComplete,
    this.onScoreUpdate,
  });

  @override
  State<CardMatchGameV2> createState() => _CardMatchGameV2State();
}

class _Card {
  final String emoji;
  final int pairId;
  bool isFlipped;
  bool isMatched;

  _Card({
    required this.emoji,
    required this.pairId,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _CardMatchGameV2State extends State<CardMatchGameV2>
    with TickerProviderStateMixin {
  final QuestionLoaderService _loaderService = QuestionLoaderService();
  
  TrainingContentModel? _content;
  int _currentLevel = 0;
  int _score = 0;
  int _moves = 0;
  int _matchedPairs = 0;
  bool _isLoading = true;
  String? _errorMessage;

  List<_Card> _cards = [];
  int? _firstCardIndex;
  int? _secondCardIndex;
  bool _isProcessing = false;
  bool _showFeedback = false;
  bool _levelComplete = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final content = await _loaderService.loadFromLocalJson('card_match.json');
      
      setState(() {
        _content = content;
        _isLoading = false;
      });
      
      _startLevel();
    } catch (e) {
      setState(() {
        _errorMessage = '문항을 불러올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _startLevel() {
    if (_content == null || _currentLevel >= _content!.items.length) {
      widget.onComplete?.call();
      return;
    }
    
    final levelItem = _content!.items[_currentLevel];
    final pairCount = levelItem.itemData?['pairCount'] as int? ?? 4;
    
    // 카드 생성
    _cards = [];
    
    for (int i = 0; i < pairCount; i++) {
      if (i * 2 + 1 < levelItem.options.length) {
        final option = levelItem.options[i * 2];
        final pairId = option.optionData?['pairId'] as int? ?? i;
        
        _cards.add(_Card(emoji: option.label, pairId: pairId));
        _cards.add(_Card(emoji: option.label, pairId: pairId));
      }
    }
    
    _cards.shuffle(_random);

    setState(() {
      _moves = 0;
      _matchedPairs = 0;
      _firstCardIndex = null;
      _secondCardIndex = null;
      _isProcessing = false;
      _showFeedback = false;
      _levelComplete = false;
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _levelComplete) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstCardIndex == null) {
      // 첫 번째 카드 선택
      _firstCardIndex = index;
    } else {
      // 두 번째 카드 선택
      _secondCardIndex = index;
      _moves++;
      _isProcessing = true;

      // 매칭 확인
      _checkMatch();
    }
  }

  void _checkMatch() {
    final first = _cards[_firstCardIndex!];
    final second = _cards[_secondCardIndex!];

    if (first.pairId == second.pairId) {
      // 매칭 성공!
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _matchedPairs++;
          _score += 10;
        });

        widget.onScoreUpdate?.call(_score, _currentLevel + 1);

        // 레벨 완료 확인
        final levelItem = _content!.items[_currentLevel];
        final pairCount = levelItem.itemData?['pairCount'] as int? ?? 4;
        
        if (_matchedPairs == pairCount) {
          _handleLevelComplete();
        } else {
          _resetSelection();
        }
      });
    } else {
      // 매칭 실패
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;

        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
        });

        _resetSelection();
      });
    }
  }

  void _resetSelection() {
    setState(() {
      _firstCardIndex = null;
      _secondCardIndex = null;
      _isProcessing = false;
    });
  }

  void _handleLevelComplete() {
    setState(() {
      _levelComplete = true;
      _showFeedback = true;
    });
  }

  void _nextLevel() {
    if (_currentLevel < _content!.items.length - 1) {
      _currentLevel++;
      _startLevel();
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final levelItem = _content!.items[_currentLevel];
    final gridColumns = levelItem.itemData?['gridColumns'] as int? ?? 4;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(_content!.title),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_moves',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            // 카드 그리드
            Expanded(child: _buildCardGrid(gridColumns)),

            // 레벨 완료 피드백
            if (_levelComplete) _buildLevelCompleteDialog(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final levelItem = _content!.items[_currentLevel];
    final totalPairs = levelItem.itemData?['pairCount'] as int? ?? 4;

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
                  color: Colors.orange,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_matchedPairs / $totalPairs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _matchedPairs / totalPairs,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid(int columns) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _buildCard(index);
        },
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isMatched
              ? Colors.green[100]
              : card.isFlipped
                  ? Colors.white
                  : Colors.orange[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? Colors.green
                : card.isFlipped
                    ? Colors.orange
                    : Colors.orange[400]!,
            width: 2,
          ),
          boxShadow: card.isFlipped || card.isMatched
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Text(
                  card.emoji,
                  style: TextStyle(
                    fontSize: _cards.length <= 12 ? 36 : 28,
                  ),
                )
              : Icon(
                  Icons.question_mark,
                  size: _cards.length <= 12 ? 32 : 24,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  Widget _buildLevelCompleteDialog() {
    final isLastLevel = _currentLevel >= _content!.items.length - 1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎉 레벨 클리어!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_moves번 만에 성공!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _startLevel,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: isLastLevel
                    ? () => widget.onComplete?.call()
                    : _nextLevel,
                icon: Icon(isLastLevel ? Icons.check : Icons.arrow_forward),
                label: Text(isLastLevel ? '완료' : '다음 레벨'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
