import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// 짝 맞추기 게임 패턴
/// 
/// 두 그룹의 아이템을 드래그하여 연결하거나,
/// 카드 뒤집기 형태의 메모리 게임입니다.
/// 
/// WP 2.2 - S 2.2.3
class MatchingPattern extends StatefulWidget {
  /// 문제 항목 (options를 왼쪽/오른쪽으로 분리해서 사용)
  final ContentItem item;
  
  /// 완료 콜백 (모든 짝을 맞추면 호출)
  final void Function(bool allCorrect, int totalTimeMs) onComplete;
  
  /// 다음으로 이동 콜백
  final VoidCallback? onNext;
  
  /// 피드백 표시 여부
  final bool showFeedback;
  
  /// 게임 모드
  final MatchingMode mode;
  
  /// 문제 인덱스
  final int? questionIndex;
  
  /// 총 문제 수
  final int? totalQuestions;

  const MatchingPattern({
    super.key,
    required this.item,
    required this.onComplete,
    this.onNext,
    this.showFeedback = true,
    this.mode = MatchingMode.dragLine,
    this.questionIndex,
    this.totalQuestions,
  });

  @override
  State<MatchingPattern> createState() => _MatchingPatternState();
}

/// 매칭 게임 모드
enum MatchingMode {
  dragLine,   // 선 긋기
  cardFlip,   // 카드 뒤집기
}

class _MatchingPatternState extends State<MatchingPattern>
    with TickerProviderStateMixin {
  DateTime? _startTime;
  
  // 선 긋기 모드용
  List<MatchPair> _matchPairs = [];
  int? _selectedLeftIndex;
  Offset? _dragStart;
  Offset? _dragEnd;
  
  // 카드 뒤집기 모드용
  List<CardItem> _cards = [];
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  Set<int> _matchedIndices = {};
  bool _isChecking = false;
  
  bool _completed = false;
  bool? _allCorrect;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeGame();
  }
  
  @override
  void didUpdateWidget(MatchingPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      setState(() {
        _startTime = DateTime.now();
        _completed = false;
        _allCorrect = null;
      });
      _initializeGame();
    }
  }
  
  void _initializeGame() {
    if (widget.mode == MatchingMode.dragLine) {
      _initDragLineMode();
    } else {
      _initCardFlipMode();
    }
  }
  
  void _initDragLineMode() {
    // options를 왼쪽/오른쪽 그룹으로 나눔 (optionData의 'group' 필드 사용)
    final leftOptions = <ContentOption>[];
    final rightOptions = <ContentOption>[];
    
    for (var option in widget.item.options) {
      final group = option.optionData?['group'] as String? ?? 'left';
      if (group == 'left') {
        leftOptions.add(option);
      } else {
        rightOptions.add(option);
      }
    }
    
    // 짝 정보 생성
    _matchPairs = [];
    for (int i = 0; i < leftOptions.length; i++) {
      final left = leftOptions[i];
      final matchId = left.optionData?['matchId'] as String?;
      final rightIndex = rightOptions.indexWhere(
        (r) => r.optionData?['matchId'] == matchId,
      );
      
      _matchPairs.add(MatchPair(
        leftOption: left,
        rightOption: rightIndex >= 0 ? rightOptions[rightIndex] : null,
        leftIndex: i,
        rightIndex: rightIndex >= 0 ? rightIndex : -1,
        isMatched: false,
      ));
    }
    
    _selectedLeftIndex = null;
    _dragStart = null;
    _dragEnd = null;
    
    setState(() {});
  }
  
  void _initCardFlipMode() {
    // 카드 쌍 생성 및 섞기
    _cards = [];
    
    for (var option in widget.item.options) {
      // 같은 optionId를 가진 쌍으로 카드 2개 생성
      _cards.add(CardItem(
        option: option,
        isFlipped: false,
        isMatched: false,
      ));
    }
    
    // 카드 섞기
    _cards.shuffle(math.Random());
    
    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
    _matchedIndices = {};
    _isChecking = false;
    
    setState(() {});
  }
  
  void _onCardTap(int index) {
    if (_isChecking || _matchedIndices.contains(index)) return;
    if (_cards[index].isFlipped) return;
    
    setState(() {
      _cards[index].isFlipped = true;
      
      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else if (_secondFlippedIndex == null) {
        _secondFlippedIndex = index;
        _checkCardMatch();
      }
    });
  }
  
  void _checkCardMatch() {
    if (_firstFlippedIndex == null || _secondFlippedIndex == null) return;
    
    _isChecking = true;
    
    final first = _cards[_firstFlippedIndex!];
    final second = _cards[_secondFlippedIndex!];
    
    // matchId가 같으면 매칭
    final firstMatchId = first.option.optionData?['matchId'];
    final secondMatchId = second.option.optionData?['matchId'];
    final isMatch = firstMatchId == secondMatchId;
    
    Timer(const Duration(milliseconds: 800), () {
      setState(() {
        if (isMatch) {
          _matchedIndices.add(_firstFlippedIndex!);
          _matchedIndices.add(_secondFlippedIndex!);
          _cards[_firstFlippedIndex!].isMatched = true;
          _cards[_secondFlippedIndex!].isMatched = true;
        } else {
          _cards[_firstFlippedIndex!].isFlipped = false;
          _cards[_secondFlippedIndex!].isFlipped = false;
        }
        
        _firstFlippedIndex = null;
        _secondFlippedIndex = null;
        _isChecking = false;
        
        // 모든 카드가 매칭되었는지 확인
        if (_matchedIndices.length == _cards.length) {
          _onGameComplete();
        }
      });
    });
  }
  
  void _onGameComplete() {
    final totalTime = DateTime.now().difference(_startTime!).inMilliseconds;
    
    setState(() {
      _completed = true;
      _allCorrect = true; // 짝맞추기는 완료하면 성공
    });
    
    widget.onComplete(true, totalTime);
    
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
        Column(
          children: [
            // 진행 상황 표시
            if (widget.questionIndex != null && widget.totalQuestions != null)
              _buildProgressIndicator(),
            
            const SizedBox(height: 20),
            
            // 질문
            _buildQuestionArea(),
            
            const SizedBox(height: 24),
            
            // 게임 영역
            Expanded(
              child: widget.mode == MatchingMode.dragLine
                  ? _buildDragLineGame()
                  : _buildCardFlipGame(),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
        
        // 피드백 오버레이
        if (_completed && widget.showFeedback && _allCorrect != null)
          FeedbackWidget(
            type: _allCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _allCorrect! 
                ? FeedbackMessages.getRandomCorrectMessage()
                : FeedbackMessages.getRandomIncorrectMessage(),
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
  
  Widget _buildQuestionArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.item.question,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildDragLineGame() {
    // 드래그 선 긋기 모드 (간소화된 버전 - 탭으로 선택)
    final leftOptions = _matchPairs.map((p) => p.leftOption).toList();
    final rightOptions = _matchPairs
        .where((p) => p.rightOption != null)
        .map((p) => p.rightOption!)
        .toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 왼쪽 그룹
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: leftOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final pair = _matchPairs[index];
                
                return _buildMatchItem(
                  option: option,
                  isLeft: true,
                  isSelected: _selectedLeftIndex == index,
                  isMatched: pair.isMatched,
                  onTap: pair.isMatched
                      ? null
                      : () {
                          setState(() {
                            _selectedLeftIndex = index;
                          });
                        },
                );
              }).toList(),
            ),
          ),
          
          // 연결선 영역
          const SizedBox(width: 40),
          
          // 오른쪽 그룹
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rightOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                
                // 이미 매칭된 오른쪽 아이템인지 확인
                final isMatched = _matchPairs.any(
                  (p) => p.rightIndex == index && p.isMatched,
                );
                
                return _buildMatchItem(
                  option: option,
                  isLeft: false,
                  isSelected: false,
                  isMatched: isMatched,
                  onTap: (_selectedLeftIndex == null || isMatched)
                      ? null
                      : () {
                          _tryMatch(index);
                        },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  void _tryMatch(int rightIndex) {
    if (_selectedLeftIndex == null) return;
    
    final pair = _matchPairs[_selectedLeftIndex!];
    final isCorrectMatch = pair.rightIndex == rightIndex;
    
    setState(() {
      if (isCorrectMatch) {
        _matchPairs[_selectedLeftIndex!] = MatchPair(
          leftOption: pair.leftOption,
          rightOption: pair.rightOption,
          leftIndex: pair.leftIndex,
          rightIndex: pair.rightIndex,
          isMatched: true,
        );
        
        // 모든 매칭 완료 확인
        if (_matchPairs.every((p) => p.isMatched)) {
          _onGameComplete();
        }
      }
      _selectedLeftIndex = null;
    });
  }
  
  Widget _buildMatchItem({
    required ContentOption option,
    required bool isLeft,
    required bool isSelected,
    required bool isMatched,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMatched
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : isSelected
                  ? DesignSystem.primaryBlue.withOpacity(0.3)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMatched
                ? DesignSystem.semanticSuccess
                : isSelected
                    ? DesignSystem.primaryBlue
                    : Colors.grey.shade300,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  option.imagePath!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            if (option.label.isNotEmpty) ...[
              if (option.imagePath != null) const SizedBox(height: 8),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMatched
                      ? DesignSystem.semanticSuccess
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCardFlipGame() {
    // 카드 뒤집기 모드
    final crossAxisCount = _cards.length <= 4 ? 2 : (_cards.length <= 9 ? 3 : 4);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _buildFlipCard(index);
        },
      ),
    );
  }
  
  Widget _buildFlipCard(int index) {
    final card = _cards[index];
    
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isMatched
              ? DesignSystem.semanticSuccess.withOpacity(0.2)
              : card.isFlipped
                  ? Colors.white
                  : DesignSystem.primaryBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? DesignSystem.semanticSuccess
                : DesignSystem.primaryBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: card.isFlipped || card.isMatched
            ? _buildCardFront(card)
            : _buildCardBack(),
      ),
    );
  }
  
  Widget _buildCardFront(CardItem card) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (card.option.imagePath != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  card.option.imagePath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        if (card.option.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              card.option.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: card.isMatched
                    ? DesignSystem.semanticSuccess
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
  
  Widget _buildCardBack() {
    return Center(
      child: Icon(
        Icons.question_mark,
        size: 48,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}

/// 매칭 쌍 데이터
class MatchPair {
  final ContentOption leftOption;
  final ContentOption? rightOption;
  final int leftIndex;
  final int rightIndex;
  final bool isMatched;

  MatchPair({
    required this.leftOption,
    this.rightOption,
    required this.leftIndex,
    required this.rightIndex,
    required this.isMatched,
  });
}

/// 카드 아이템 데이터
class CardItem {
  final ContentOption option;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.option,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

