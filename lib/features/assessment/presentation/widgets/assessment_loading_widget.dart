import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';

/// 검사 로딩 화면 (S 1.3.1)
/// 
/// 검사 데이터를 불러오는 동안 지루하지 않게
/// 캐릭터가 준비 운동을 하는 등의 애니메이션을 보여줍니다.
class AssessmentLoadingWidget extends StatefulWidget {
  final String message;

  const AssessmentLoadingWidget({
    super.key, 
    this.message = '친구들을 불러오고 있어...',
  });

  @override
  State<AssessmentLoadingWidget> createState() => _AssessmentLoadingWidgetState();
}

class _AssessmentLoadingWidgetState extends State<AssessmentLoadingWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 쿵짝쿵짝 뛰는 애니메이션
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignSystem.neutralGray50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 캐릭터 애니메이션 (Placeholder)
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: DesignSystem.shadowMedium,
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded, // 준비운동 하는 느낌의 아이콘
                  size: 80,
                  color: DesignSystem.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 로딩 메시지
            Text(
              widget.message,
              style: DesignSystem.textStyleLarge.copyWith(
                color: DesignSystem.neutralGray700,
              ),
            ),
            const SizedBox(height: DesignSystem.spacingSM),
            
            // 프로그레스 바 (가짜 진행률이 아닌 실제 로딩 상태를 보여주기 위해 무한루프 사용)
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: DesignSystem.neutralGray200,
                valueColor: const AlwaysStoppedAnimation<Color>(DesignSystem.primaryBlue),
                borderRadius: BorderRadius.circular(10),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

