import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.4: 단어 경계 인식 위젯
/// 
/// 문장을 보여주고 몇 개의 단어로 이루어졌는지 숫자를 선택하게 합니다.
class WordBoundaryWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const WordBoundaryWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<WordBoundaryWidget> createState() => _WordBoundaryWidgetState();
}

class _WordBoundaryWidgetState extends State<WordBoundaryWidget>
    with SingleTickerProviderStateMixin {
  bool _sentenceShown = false;
  int? _selectedNumber;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    // 자동으로 문장 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSentence();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WordBoundaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _sentenceShown = false;
        _selectedNumber = null;
      });
      _fadeController.reset();
      _showSentence();
    }
  }

  Future<void> _showSentence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() => _sentenceShown = true);
    _fadeController.forward();
    
    // 문장 표시 후 3초 대기 (읽을 시간 제공)
    await Future.delayed(const Duration(seconds: 3));
  }

  void _selectNumber(int number) {
    if (widget.isInputBlocked || !_sentenceShown) return;
    
    setState(() {
      _selectedNumber = number;
    });
    
    // 숫자를 답변으로 전달 (1~5 중 선택한 숫자)
    widget.onAnswerSelected(number);
  }

  @override
  Widget build(BuildContext context) {
    // soundLabels[0]: 문장 텍스트
    final sentence = widget.question.soundLabels.isNotEmpty
        ? widget.question.soundLabels[0]
        : '나는 학교에 갔어';
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingLG),
        child: Column(
          children: [
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 안내 텍스트
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingMD),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                border: Border.all(color: DesignSystem.neutralGray200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.article_rounded, color: DesignSystem.primaryBlue),
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
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 문장 표시 영역 (단어별로 분리 표시)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(DesignSystem.spacingLG),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticInfo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                  border: Border.all(
                    color: DesignSystem.semanticInfo,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.headphones_rounded,
                      size: 40,
                      color: DesignSystem.semanticInfo,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sentence,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.neutralGray800,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 질문
            if (_sentenceShown)
              Text(
                '몇 단어야?',
                style: DesignSystem.textStyleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 숫자 선택 버튼 (1~5)
            if (_sentenceShown)
              _buildNumberButtons(),
            
            const SizedBox(height: DesignSystem.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButtons() {
    return Opacity(
      opacity: widget.isInputBlocked ? 0.5 : 1.0,
      child: Wrap(
        spacing: DesignSystem.spacingMD,
        runSpacing: DesignSystem.spacingMD,
        alignment: WrapAlignment.center,
        children: List.generate(5, (index) {
          final number = index + 1; // 1~5
          return _buildNumberButton(number);
        }),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    final isSelected = _selectedNumber == number;
    
    return GestureDetector(
      onTap: () => _selectNumber(number),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected 
              ? DesignSystem.primaryBlue.withOpacity(0.2) 
              : Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
          border: Border.all(
            color: isSelected 
                ? DesignSystem.primaryBlue 
                : DesignSystem.neutralGray300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected 
              ? DesignSystem.shadowMedium 
              : DesignSystem.shadowSmall,
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isSelected 
                  ? DesignSystem.primaryBlue 
                  : DesignSystem.neutralGray700,
            ),
          ),
        ),
      ),
    );
  }
}

