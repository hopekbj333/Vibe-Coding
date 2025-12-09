import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// O/X 퀴즈 게임 패턴
/// 
/// 질문 제시 후 O/X 두 버튼 중 선택하는 게임입니다.
/// 큰 버튼, 명확한 색상 구분 (초록/빨강)
/// 
/// WP 2.2 - S 2.2.1
class OxQuizPattern extends StatefulWidget {
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
  
  /// 문제 인덱스 (진행 표시용)
  final int? questionIndex;
  
  /// 총 문제 수
  final int? totalQuestions;

  const OxQuizPattern({
    super.key,
    required this.item,
    required this.onAnswer,
    this.onNext,
    this.onPlayAudio,
    this.showFeedback = true,
    this.questionIndex,
    this.totalQuestions,
  });

  @override
  State<OxQuizPattern> createState() => _OxQuizPatternState();
}

class _OxQuizPatternState extends State<OxQuizPattern>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _answered = false;
  bool? _lastAnswerCorrect;
  DateTime? _questionStartTime;
  
  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(OxQuizPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      // 새 문제로 변경됨
      setState(() {
        _answered = false;
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

  void _handleAnswer(String answerId) {
    if (_answered) return;
    
    final responseTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    final isCorrect = answerId == widget.item.correctAnswer;
    
    setState(() {
      _answered = true;
      _lastAnswerCorrect = isCorrect;
    });
    
    widget.onAnswer(isCorrect, responseTime);
    
    // 피드백 후 다음 문제로
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
            
            const Spacer(),
            
            // 질문 영역
            _buildQuestionArea(),
            
            const Spacer(),
            
            // O/X 버튼 영역
            _buildButtonArea(),
            
            const SizedBox(height: 40),
          ],
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이미지가 있으면 표시
            if (widget.item.questionImagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.item.questionImagePath!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // 질문 텍스트
            Text(
              widget.item.question,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 오디오 재생 버튼
            if (widget.item.questionAudioPath != null || widget.onPlayAudio != null) ...[
              const SizedBox(height: 16),
              IconButton(
                onPressed: widget.onPlayAudio,
                icon: const Icon(Icons.volume_up),
                iconSize: 48,
                color: DesignSystem.primaryBlue,
                style: IconButton.styleFrom(
                  backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildButtonArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // O 버튼 (정답)
          _buildOXButton(
            label: 'O',
            color: DesignSystem.semanticSuccess,
            icon: Icons.check_circle_outline,
            optionId: 'O',
          ),
          
          const SizedBox(width: 32),
          
          // X 버튼 (오답)
          _buildOXButton(
            label: 'X',
            color: DesignSystem.semanticError,
            icon: Icons.cancel_outlined,
            optionId: 'X',
          ),
        ],
      ),
    );
  }
  
  Widget _buildOXButton({
    required String label,
    required Color color,
    required IconData icon,
    required String optionId,
  }) {
    final isSelected = _answered && widget.item.correctAnswer == optionId;
    final isWrong = _answered && widget.item.correctAnswer != optionId && _lastAnswerCorrect == false;
    
    return Expanded(
      child: GestureDetector(
        onTap: _answered ? null : () => _handleAnswer(optionId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 140,
          decoration: BoxDecoration(
            color: _answered
                ? (isSelected ? color : (isWrong ? color.withOpacity(0.3) : Colors.grey.shade300))
                : color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _answered
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

