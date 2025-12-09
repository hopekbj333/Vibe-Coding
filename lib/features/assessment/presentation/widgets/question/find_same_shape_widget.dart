import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.5: 같은 형태 찾기 위젯
/// 
/// 상단에 목표 도형을 제시하고, 하단 보기 중에서 동일한 형태를 찾습니다.
class FindSameShapeWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const FindSameShapeWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<FindSameShapeWidget> createState() => _FindSameShapeWidgetState();
}

class _FindSameShapeWidgetState extends State<FindSameShapeWidget>
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
  void didUpdateWidget(FindSameShapeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _selectedAnswer = null;
      });
    }
  }

  void _onOptionTap(int index) {
    if (widget.isInputBlocked || _selectedAnswer != null) return;
    
    debugPrint('🔷 도형 선택: $index');
    
    setState(() {
      _selectedAnswer = index;
    });
    
    _scaleController.forward();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAnswerSelected(index);
    });
  }

  String _getTargetShape() {
    // soundLabels[0]에서 목표 도형 가져오기
    if (widget.question.soundLabels.isEmpty) return 'star';
    return widget.question.soundLabels[0];
  }

  Widget _buildShapeIcon(String shapeName, {double size = 80}) {
    IconData iconData;
    switch (shapeName.toLowerCase()) {
      case 'star':
        iconData = Icons.star;
        break;
      case 'circle':
        iconData = Icons.circle;
        break;
      case 'square':
        iconData = Icons.square;
        break;
      case 'triangle':
        iconData = Icons.change_history;
        break;
      default:
        iconData = Icons.shape_line;
    }
    
    return Icon(
      iconData,
      size: size,
      color: DesignSystem.primaryBlue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetShape = _getTargetShape();
    
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
        
        // 목표 도형 영역
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: DesignSystem.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DesignSystem.primaryBlue,
              width: 3,
            ),
          ),
          child: Column(
            children: [
              Text(
                '이 모양을 찾아봐!',
                style: DesignSystem.textStyleMedium.copyWith(
                  color: DesignSystem.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildShapeIcon(targetShape, size: 100),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 보기 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.question.optionsText.length,
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
                            // 도형 또는 이미지
                            Center(
                              child: widget.question.optionsImageUrl.isNotEmpty &&
                                      index < widget.question.optionsImageUrl.length
                                  ? Image.asset(
                                      widget.question.optionsImageUrl[index],
                                      width: 80,
                                      height: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildShapeIcon(
                                          widget.question.optionsText[index],
                                        );
                                      },
                                    )
                                  : _buildShapeIcon(
                                      widget.question.optionsText[index],
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

