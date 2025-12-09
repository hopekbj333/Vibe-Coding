import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.4: 다른 그림 찾기 위젯
/// 
/// 여러 유사한 그림 중 하나만 다른 것을 찾습니다.
class FindDifferentWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const FindDifferentWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<FindDifferentWidget> createState() => _FindDifferentWidgetState();
}

class _FindDifferentWidgetState extends State<FindDifferentWidget>
    with SingleTickerProviderStateMixin {
  int? _selectedAnswer;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FindDifferentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _selectedAnswer = null;
      });
    }
  }

  void _onOptionTap(int index) {
    if (widget.isInputBlocked || _selectedAnswer != null) return;
    
    debugPrint('🖼️ 그림 선택: $index');
    
    setState(() {
      _selectedAnswer = index;
    });
    
    _scaleController.forward();
    
    // 0.5초 후 제출
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAnswerSelected(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final optionsCount = widget.question.optionsText.length;
    final crossAxisCount = optionsCount <= 4 ? 2 : 3;
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            widget.question.promptText,
            style: DesignSystem.textStyleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 안내 텍스트
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: DesignSystem.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DesignSystem.primaryBlue.withOpacity(0.3),
            ),
          ),
          child: Text(
            '다른 그림 하나를 찾아서 눌러봐!',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 그림 그리드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: optionsCount,
            itemBuilder: (context, index) {
              final isSelected = _selectedAnswer == index;
              
              return AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  final scale = isSelected
                      ? 1.0 + (_scaleController.value * 0.1)
                      : 1.0;
                  
                  return Transform.scale(
                    scale: scale,
                    child: InkWell(
                      onTap: () => _onOptionTap(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DesignSystem.semanticSuccess.withOpacity(0.2)
                              : DesignSystem.neutralGray100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? DesignSystem.semanticSuccess
                                : DesignSystem.neutralGray300,
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // 그림
                            Center(
                              child: widget.question.optionsImageUrl.isNotEmpty &&
                                      index < widget.question.optionsImageUrl.length
                                  ? Image.asset(
                                      widget.question.optionsImageUrl[index],
                                      width: 100,
                                      height: 100,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image,
                                          size: 100,
                                          color: DesignSystem.primaryBlue,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.image,
                                      size: 100,
                                      color: DesignSystem.primaryBlue,
                                    ),
                            ),
                            
                            // 선택 표시
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: DesignSystem.semanticSuccess,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
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
            },
          ),
        ),
        
        const SizedBox(height: 40),
        ],
      ),
    );
  }
}

