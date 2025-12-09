import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// 선택형 문제 (O/X, N지선다) 위젯
/// 
/// 이미지나 텍스트로 된 보기를 보여주고 선택을 받습니다.
/// 아동 친화적인 UI (큰 버튼, 그림 위주)를 적용합니다.
class ChoiceQuestionWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int index) onOptionSelected;

  const ChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onOptionSelected,
  });

  @override
  State<ChoiceQuestionWidget> createState() => _ChoiceQuestionWidgetState();
}

class _ChoiceQuestionWidgetState extends State<ChoiceQuestionWidget> {
  // S 1.3.4: 선택된 옵션 인덱스 (시각적 피드백용)
  int? _selectedIndex;
  
  @override
  void didUpdateWidget(ChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 새 문제가 로드되면 선택 초기화
    if (oldWidget.question.id != widget.question.id) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTwoOptions = widget.question.optionsText.length == 2 || 
                         widget.question.optionsImageUrl.length == 2;

    return Column(
      children: [
        // 질문 텍스트 (성우가 읽어주지만, 개발자/부모 확인용으로 표시)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingLG,
            vertical: DesignSystem.spacingMD,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
            border: Border.all(color: DesignSystem.neutralGray200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded, color: DesignSystem.primaryBlue),
              const SizedBox(width: DesignSystem.spacingSM),
              Flexible(
                child: Text(
                  widget.question.promptText,
                  style: DesignSystem.textStyleMedium.copyWith(
                    color: DesignSystem.neutralGray800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),

        // 보기 영역
        Expanded(
          flex: 4,
          child: isTwoOptions
              ? _buildTwoOptions(context)
              : _buildGridOptions(context),
        ),
        
        const Spacer(),
      ],
    );
  }

  Widget _buildTwoOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildOptionButton(context, 0)),
        const SizedBox(width: DesignSystem.spacingLG),
        Expanded(child: _buildOptionButton(context, 1)),
      ],
    );
  }

  Widget _buildGridOptions(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(DesignSystem.spacingMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DesignSystem.spacingLG,
        mainAxisSpacing: DesignSystem.spacingLG,
        childAspectRatio: 1.0,
      ),
      itemCount: _getOptionCount(),
      itemBuilder: (context, index) {
        return _buildOptionButton(context, index);
      },
    );
  }

  int _getOptionCount() {
    return widget.question.optionsImageUrl.isNotEmpty 
        ? widget.question.optionsImageUrl.length 
        : widget.question.optionsText.length;
  }

  Widget _buildOptionButton(BuildContext context, int index) {
    final hasImage = widget.question.optionsImageUrl.length > index;
    final imageUrl = hasImage ? widget.question.optionsImageUrl[index] : '';
    final text = widget.question.optionsText.length > index 
        ? widget.question.optionsText[index] 
        : '';
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: widget.isInputBlocked ? null : () => _handleOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: isSelected 
            ? (Matrix4.identity()..scale(0.95)) // S 1.3.4: 버튼 눌림 효과
            : Matrix4.identity(),
        child: Opacity(
          opacity: widget.isInputBlocked ? 0.7 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? DesignSystem.primaryBlue.withOpacity(0.1) // 선택 시 배경색
                  : Colors.white,
              borderRadius: BorderRadius.circular(DesignSystem.borderRadiusXL),
              boxShadow: widget.isInputBlocked || isSelected 
                  ? [] 
                  : DesignSystem.shadowMedium,
              border: Border.all(
                color: isSelected 
                    ? DesignSystem.primaryBlue // S 1.3.4: 선택 시 테두리 강조
                    : DesignSystem.neutralGray200,
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasImage)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignSystem.spacingMD),
                      child: _buildImage(imageUrl),
                    ),
                  ),
                if (text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(DesignSystem.spacingSM),
                    child: Text(
                      text,
                      style: DesignSystem.textStyleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? DesignSystem.primaryBlue 
                            : DesignSystem.neutralGray800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 이미지 빌더 (SVG와 일반 이미지 모두 지원)
  Widget _buildImage(String imageUrl) {
    // SVG 파일인 경우
    if (imageUrl.endsWith('.svg')) {
      return SvgPicture.asset(
        imageUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 일반 이미지 파일인 경우
    return Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image_not_supported_rounded,
          size: 40,
          color: DesignSystem.neutralGray300,
        );
      },
    );
  }

  /// S 1.3.4: 옵션 터치 처리
  /// 
  /// 1. 시각적 피드백 (버튼 눌림 효과)
  /// 2. 부모에게 선택 전달
  void _handleOptionTap(int index) {
    // 시각적 피드백
    setState(() {
      _selectedIndex = index;
    });
    
    // 선택 전달 (약간의 딜레이 후 - 눌림 효과가 보이도록)
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onOptionSelected(index);
    });
  }
}
