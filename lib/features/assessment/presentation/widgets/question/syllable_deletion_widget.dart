import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.7: 음절 탈락 위젯
/// 
/// "사과에서 '과'를 빼면?" → 글자 선택 (사/과/사과)
class SyllableDeletionWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const SyllableDeletionWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<SyllableDeletionWidget> createState() => _SyllableDeletionWidgetState();
}

class _SyllableDeletionWidgetState extends State<SyllableDeletionWidget>
    with SingleTickerProviderStateMixin {
  String _word = '';
  String _syllableToRemove = '';
  bool _questionShown = false;
  int? _selectedAnswer;
  
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
    
    // 데이터 파싱
    _parseData();
    
    // 자동으로 질문 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQuestion();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SyllableDeletionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _questionShown = false;
        _selectedAnswer = null;
      });
      _parseData();
      _fadeController.reset();
      _showQuestion();
    }
  }

  void _parseData() {
    // soundLabels[0]: "사과-과" (단어-제거할음절)
    if (widget.question.soundLabels.isNotEmpty) {
      final parts = widget.question.soundLabels[0].split('-');
      _word = parts[0]; // 사과
      _syllableToRemove = parts.length > 1 ? parts[1] : ''; // 과
    } else {
      _word = '사과';
      _syllableToRemove = '과';
    }
    debugPrint('단어: $_word, 제거할 음절: $_syllableToRemove');
  }

  Future<void> _showQuestion() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() => _questionShown = true);
    _fadeController.forward();
    
    // 질문 읽기 시간 (3초)
    await Future.delayed(const Duration(seconds: 3));
  }

  void _selectAnswer(int answer) {
    if (widget.isInputBlocked || !_questionShown) return;
    
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
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 질문 표시 (음성으로 읽어주는 내용)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(DesignSystem.spacingLG),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticError.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                  border: Border.all(
                    color: DesignSystem.semanticError,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // 원래 단어
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _word,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: DesignSystem.neutralGray800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 빼기 표시
                    const Icon(
                      Icons.remove_circle_outline,
                      size: 40,
                      color: DesignSystem.semanticError,
                    ),
                    const SizedBox(height: 16),
                    // 제거할 음절
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.semanticError.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: DesignSystem.semanticError,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        _syllableToRemove,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.semanticError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 질문
            if (_questionShown)
              Text(
                '뭐가 남아?',
                style: DesignSystem.textStyleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 선택지 (글자만)
            if (_questionShown)
              _buildOptions(),
            
            const SizedBox(height: DesignSystem.spacingXL),
          ],
        ),
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
        width: 100,
        height: 100,
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
            style: TextStyle(
              fontSize: 36,
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

