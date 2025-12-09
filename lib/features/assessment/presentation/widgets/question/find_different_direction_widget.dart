import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.6: 방향이 다른 글자 찾기 위젯
/// 
/// b/d, p/q, ㄴ/ㄱ 등 좌우/상하 대칭 글자 중 방향이 다른 것을 찾습니다.
class FindDifferentDirectionWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const FindDifferentDirectionWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<FindDifferentDirectionWidget> createState() =>
      _FindDifferentDirectionWidgetState();
}

class _FindDifferentDirectionWidgetState
    extends State<FindDifferentDirectionWidget>
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
  void didUpdateWidget(FindDifferentDirectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _selectedAnswer = null;
      });
    }
  }

  void _onOptionTap(int index) {
    if (widget.isInputBlocked || _selectedAnswer != null) return;

    debugPrint('🔤 글자 선택: $index (${widget.question.optionsText[index]})');

    setState(() {
      _selectedAnswer = index;
    });

    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAnswerSelected(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            '방향이 다른 글자 하나를 찾아봐!',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // 글자 그리드 (2x2)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.question.optionsText.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedAnswer == index;
              final letter = widget.question.optionsText[index];

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
                            // 글자 (크게 표시)
                            Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: DesignSystem.primaryBlue,
                                  fontFamily: _getFontFamily(letter),
                                ),
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

  /// 글자에 따라 적절한 폰트 선택
  String? _getFontFamily(String letter) {
    // 영어 글자는 명확한 세리프 폰트 사용 (b/d, p/q 구별 용이)
    if (RegExp(r'[a-zA-Z]').hasMatch(letter)) {
      return 'Courier'; // 고정폭 폰트로 명확한 구별
    }
    // 한글은 기본 폰트
    return null;
  }
}

