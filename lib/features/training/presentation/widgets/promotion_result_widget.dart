import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../domain/services/mini_test_service.dart';

/// 승급 판정 결과 위젯
/// 
/// 테스트 통과/미통과에 따른 결과와 안내
class PromotionResultWidget extends StatefulWidget {
  final PromotionResult result;
  final VoidCallback? onProceedToNextStage;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const PromotionResultWidget({
    super.key,
    required this.result,
    this.onProceedToNextStage,
    this.onRetry,
    this.onClose,
  });

  @override
  State<PromotionResultWidget> createState() => _PromotionResultWidgetState();
}

class _PromotionResultWidgetState extends State<PromotionResultWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          _buildIcon(),
          const SizedBox(height: 24),

          // 점수
          _buildScore(),
          const SizedBox(height: 16),

          // 메시지
          Text(
            widget.result.message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.neutralGray800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 진행 바
          _buildProgressBar(),
          const SizedBox(height: 24),

          // 재도전 권장
          if (!widget.result.isPassed && widget.result.retryRecommendation != null)
            _buildRetryRecommendation(),

          // 버튼들
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.result.isPromoted) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // 빛나는 효과
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade300,
                  Colors.amber.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.star,
              size: 60,
              color: Colors.white,
            ),
          ),
        ],
      );
    } else if (widget.result.isPassed) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade100,
        ),
        child: Icon(
          Icons.check_circle,
          size: 70,
          color: Colors.green.shade600,
        ),
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange.shade100,
        ),
        child: Icon(
          Icons.refresh,
          size: 70,
          color: Colors.orange.shade600,
        ),
      );
    }
  }

  Widget _buildScore() {
    final isPassed = widget.result.isPassed;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.result.testScore}',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: isPassed ? Colors.green.shade600 : Colors.orange.shade600,
          ),
        ),
        const Text(
          '점',
          style: TextStyle(
            fontSize: 24,
            color: DesignSystem.neutralGray500,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '/ ${widget.result.threshold}점',
          style: const TextStyle(
            fontSize: 18,
            color: DesignSystem.neutralGray500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = (widget.result.testScore / 100).clamp(0.0, 1.0);
    final thresholdProgress = widget.result.threshold / 100;
    final isPassed = widget.result.isPassed;

    return Column(
      children: [
        Stack(
          children: [
            // 배경 바
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 진행 바
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPassed
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // 기준선
            Positioned(
              left: thresholdProgress * 280, // 대략적인 위치
              child: Container(
                width: 3,
                height: 20,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0점', style: TextStyle(color: DesignSystem.neutralGray500)),
            Text(
              '통과 기준 ${widget.result.threshold}점',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text('100점', style: TextStyle(color: DesignSystem.neutralGray500)),
          ],
        ),
      ],
    );
  }

  Widget _buildRetryRecommendation() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.result.retryRecommendation!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (widget.result.isPromoted) {
      return Column(
        children: [
          // 다음 단계로 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onProceedToNextStage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 8),
                  Text(
                    '다음 단계로 가기!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 닫기 버튼
          TextButton(
            onPressed: widget.onClose,
            child: const Text('나중에 하기'),
          ),
        ],
      );
    } else if (widget.result.isPassed) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '완료!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          // 다시 도전 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text(
                    '더 연습하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 닫기 버튼
          TextButton(
            onPressed: widget.onClose,
            child: const Text('나중에 하기'),
          ),
        ],
      );
    }
  }
}

