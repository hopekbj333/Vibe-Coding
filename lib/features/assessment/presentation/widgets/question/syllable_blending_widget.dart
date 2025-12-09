import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.6: 음절 분해/합성 위젯
/// 
/// 음절을 분리해서 보여주고("나-비"), 합친 단어를 그림에서 선택하게 합니다.
class SyllableBlendingWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const SyllableBlendingWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<SyllableBlendingWidget> createState() => _SyllableBlendingWidgetState();
}

class _SyllableBlendingWidgetState extends State<SyllableBlendingWidget>
    with TickerProviderStateMixin {
  List<String> _syllables = [];
  int _currentSyllableIndex = -1;
  bool _syllablesShown = false;
  int? _selectedAnswer;
  
  late AnimationController _syllableController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _syllableController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _syllableController, curve: Curves.easeOut),
    );
    
    // 음절 파싱
    _parseSyllables();
    
    // 자동으로 음절 시연 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSyllables();
    });
  }

  @override
  void dispose() {
    _syllableController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SyllableBlendingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _currentSyllableIndex = -1;
        _syllablesShown = false;
        _selectedAnswer = null;
      });
      _parseSyllables();
      _showSyllables();
    }
  }

  void _parseSyllables() {
    // soundLabels[0]에서 음절 파싱 (예: "나-비" -> ["나", "비"])
    if (widget.question.soundLabels.isNotEmpty) {
      _syllables = widget.question.soundLabels[0].split('-');
    } else {
      _syllables = ['나', '비'];
    }
    debugPrint('음절: $_syllables');
  }

  Future<void> _showSyllables() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 각 음절을 순차적으로 강조
    for (int i = 0; i < _syllables.length; i++) {
      setState(() => _currentSyllableIndex = i);
      _syllableController.forward(from: 0.0);
      
      // 각 음절 표시 시간 (1초)
      await Future.delayed(const Duration(seconds: 1));
      
      // 음절 간 간격
      if (i < _syllables.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    setState(() {
      _currentSyllableIndex = -1;
      _syllablesShown = true;
    });
  }

  void _selectAnswer(int answer) {
    if (widget.isInputBlocked || !_syllablesShown) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
    
    widget.onAnswerSelected(answer);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingLG),
        child: Column(
          children: [
            const SizedBox(height: DesignSystem.spacingLG),
            
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
                  const Icon(Icons.auto_fix_high_rounded, color: DesignSystem.primaryBlue),
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
            
            // 음절 표시 영역
            _buildSyllablesDisplay(),
            
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 질문
            if (_syllablesShown)
              Text(
                '합치면 뭐야?',
                style: DesignSystem.textStyleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 선택지 (그림)
            if (_syllablesShown)
              _buildOptions(),
            
            const SizedBox(height: DesignSystem.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllablesDisplay() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLG),
      decoration: BoxDecoration(
        color: DesignSystem.semanticWarning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
        border: Border.all(
          color: DesignSystem.semanticWarning,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_syllables.length, (index) {
          final isActive = _currentSyllableIndex == index;
          
          return Row(
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isActive ? _scaleAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? DesignSystem.semanticWarning
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive
                            ? DesignSystem.shadowMedium
                            : DesignSystem.shadowSmall,
                      ),
                      child: Text(
                        _syllables[index],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.white
                              : DesignSystem.neutralGray800,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 음절 사이에 하이픈 표시
              if (index < _syllables.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.neutralGray400,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOptions() {
    return Opacity(
      opacity: widget.isInputBlocked ? 0.5 : 1.0,
      child: Wrap(
        spacing: DesignSystem.spacingMD,
        runSpacing: DesignSystem.spacingMD,
        alignment: WrapAlignment.center,
        children: List.generate(
          widget.question.optionsText.length,
          (index) => _buildOptionButton(index),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    final isSelected = _selectedAnswer == index;
    
    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 80,
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
            widget.question.optionsText[index],
            style: DesignSystem.textStyleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? DesignSystem.primaryBlue
                  : DesignSystem.neutralGray700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

