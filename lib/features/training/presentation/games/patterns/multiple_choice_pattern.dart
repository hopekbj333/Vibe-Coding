import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// N지선다 게임 패턴
/// 
/// 2~4개 이미지/텍스트 보기 중 정답 선택하는 게임입니다.
/// 보기 배치: 2개(좌우), 3개(삼각형), 4개(2x2 그리드)
/// 
/// WP 2.2 - S 2.2.2
class MultipleChoicePattern extends StatefulWidget {
  /// 현재 문제 항목
  final ContentItem item;
  
  /// 정답/오답 콜백
  final void Function(bool isCorrect, int responseTimeMs) onAnswer;
  
  /// 다음 문제로 이동 콜백
  final VoidCallback? onNext;
  
  /// 질문 오디오 재생 콜백
  final VoidCallback? onPlayAudio;
  
  /// 피드백 표시 여부
  final bool showFeedback;
  
  /// 문제 인덱스
  final int? questionIndex;
  
  /// 총 문제 수
  final int? totalQuestions;
  
  /// 선택지 스타일 (이미지/텍스트)
  final ChoiceStyle choiceStyle;

  const MultipleChoicePattern({
    super.key,
    required this.item,
    required this.onAnswer,
    this.onNext,
    this.onPlayAudio,
    this.showFeedback = true,
    this.questionIndex,
    this.totalQuestions,
    this.choiceStyle = ChoiceStyle.imageWithLabel,
  });

  @override
  State<MultipleChoicePattern> createState() => _MultipleChoicePatternState();
}

/// 선택지 표시 스타일
enum ChoiceStyle {
  textOnly,
  imageOnly,
  imageWithLabel,
}

class _MultipleChoicePatternState extends State<MultipleChoicePattern>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  bool _answered = false;
  String? _selectedOptionId;
  bool? _lastAnswerCorrect;
  DateTime? _questionStartTime;
  
  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(MultipleChoicePattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      setState(() {
        _answered = false;
        _selectedOptionId = null;
        _lastAnswerCorrect = null;
        _questionStartTime = DateTime.now();
      });
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnswer(String optionId) {
    if (_answered) return;
    
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final isCorrect = optionId == widget.item.correctAnswer;
    
    setState(() {
      _answered = true;
      _selectedOptionId = optionId;
      _lastAnswerCorrect = isCorrect;
    });
    
    widget.onAnswer(isCorrect, responseTime);
    
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
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              // 진행 상황 표시
              if (widget.questionIndex != null && widget.totalQuestions != null)
                _buildProgressIndicator(),
              
              const SizedBox(height: 20),
              
              // 질문 영역
              _buildQuestionArea(),
              
              const SizedBox(height: 32),
              
              // 선택지 영역
              _buildChoicesArea(),
            ],
          ),
        ),
        
        // 피드백 오버레이
        if (_answered && widget.showFeedback && _lastAnswerCorrect != null)
          FeedbackWidget(
            type: _lastAnswerCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _lastAnswerCorrect! 
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // 질문 이미지
          if (widget.item.questionImagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.item.questionImagePath!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 질문 텍스트
          Text(
            widget.item.question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          // 오디오 버튼
          if (widget.onPlayAudio != null) ...[
            const SizedBox(height: 12),
            IconButton(
              onPressed: widget.onPlayAudio,
              icon: const Icon(Icons.volume_up),
              iconSize: 40,
              color: DesignSystem.primaryBlue,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChoicesArea() {
    final optionCount = widget.item.options.length;
    
    if (optionCount <= 2) {
      // 2개: 좌우로 나란히
      return _buildHorizontalChoices();
    } else if (optionCount == 3) {
      // 3개: 상단 1개, 하단 2개
      return _buildTriangleChoices();
    } else {
      // 4개 이상: 2x2 그리드
      return _buildGridChoices();
    }
  }
  
  Widget _buildHorizontalChoices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.item.options.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildChoiceCard(entry.value, entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTriangleChoices() {
    final options = widget.item.options;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 상단 1개
          SizedBox(
            width: 180,
            child: _buildChoiceCard(options[0], 0),
          ),
          const SizedBox(height: 16),
          // 하단 2개
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 160,
                child: _buildChoiceCard(options[1], 1),
              ),
              SizedBox(
                width: 160,
                child: _buildChoiceCard(options[2], 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridChoices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5, // 카드 높이를 줄임 (1.2 → 1.5)
        ),
        itemCount: widget.item.options.length,
        itemBuilder: (context, index) {
          return _buildChoiceCard(widget.item.options[index], index);
        },
      ),
    );
  }
  
  Widget _buildChoiceCard(ContentOption option, int index) {
    final isSelected = _selectedOptionId == option.optionId;
    final isCorrect = option.optionId == widget.item.correctAnswer;
    final showAsCorrect = _answered && isCorrect;
    final showAsWrong = _answered && isSelected && !isCorrect;
    
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    
    if (showAsCorrect) {
      backgroundColor = DesignSystem.semanticSuccess.withOpacity(0.2);
      borderColor = DesignSystem.semanticSuccess;
    } else if (showAsWrong) {
      backgroundColor = DesignSystem.semanticError.withOpacity(0.2);
      borderColor = DesignSystem.semanticError;
    } else if (!_answered) {
      borderColor = DesignSystem.primaryBlue.withOpacity(0.3);
    }
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _answered ? null : () => _handleAnswer(option.optionId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected || showAsCorrect ? 3 : 2,
            ),
            boxShadow: _answered
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이미지
              if (option.imagePath != null && 
                  widget.choiceStyle != ChoiceStyle.textOnly)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      option.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              
              // 레이블
              if (widget.choiceStyle != ChoiceStyle.imageOnly) ...[
                if (option.imagePath != null) const SizedBox(height: 8),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: showAsCorrect
                        ? DesignSystem.semanticSuccess
                        : showAsWrong
                            ? DesignSystem.semanticError
                            : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              // 정답/오답 아이콘
              if (_answered && (showAsCorrect || showAsWrong)) ...[
                const SizedBox(height: 8),
                Icon(
                  showAsCorrect ? Icons.check_circle : Icons.cancel,
                  color: showAsCorrect
                      ? DesignSystem.semanticSuccess
                      : DesignSystem.semanticError,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

