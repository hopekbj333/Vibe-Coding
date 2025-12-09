import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.3: 억양/강세 식별 위젯
/// 
/// 같은 문장을 다른 억양(평서/의문)으로 보여주고,
/// 어떤 느낌인지 표정 아이콘으로 선택하게 합니다.
class IntonationWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const IntonationWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<IntonationWidget> createState() => _IntonationWidgetState();
}

class _IntonationWidgetState extends State<IntonationWidget>
    with SingleTickerProviderStateMixin {
  bool _sentenceShown = false;
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
  void didUpdateWidget(IntonationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _sentenceShown = false;
        _selectedAnswer = null;
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

  void _selectAnswer(int answer) {
    if (widget.isInputBlocked || !_sentenceShown) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
    
    widget.onAnswerSelected(answer);
  }

  @override
  Widget build(BuildContext context) {
    // soundLabels[0]: 문장 텍스트, soundLabels[1]: 억양 유형
    final sentence = widget.question.soundLabels.isNotEmpty
        ? widget.question.soundLabels[0]
        : '밥 먹었어';
    final intonationType = widget.question.soundLabels.length > 1
        ? widget.question.soundLabels[1]
        : 'statement';
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  const Icon(Icons.record_voice_over_rounded, color: DesignSystem.primaryBlue),
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
            
            // 문장 표시 영역
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(DesignSystem.spacingLG),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                  border: Border.all(
                    color: DesignSystem.primaryBlue,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      sentence,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.neutralGray800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 억양 표시 (시각적 힌트)
                    Text(
                      intonationType == 'question' ? '❓' : '😐',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 질문
            if (_sentenceShown)
              Text(
                '어떤 느낌이야?',
                style: DesignSystem.textStyleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 표정 선택 버튼
            if (_sentenceShown)
              _buildEmotionButtons(),
            
            const SizedBox(height: DesignSystem.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionButtons() {
    return Opacity(
      opacity: widget.isInputBlocked ? 0.5 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 평서문 느낌 (😐)
          _buildEmotionButton(
            answer: 0,
            emoji: '😐',
            label: '그냥 말하는 거',
            color: DesignSystem.neutralGray600,
          ),
          
          // 의문문 느낌 (❓)
          _buildEmotionButton(
            answer: 1,
            emoji: '❓',
            label: '물어보는 거',
            color: DesignSystem.semanticInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionButton({
    required int answer,
    required String emoji,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedAnswer == answer;
    
    return GestureDetector(
      onTap: () => _selectAnswer(answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        height: 160,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
          border: Border.all(
            color: isSelected ? color : DesignSystem.neutralGray300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? DesignSystem.shadowMedium : DesignSystem.shadowSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: DesignSystem.spacingSM),
            // 라벨
            Text(
              label,
              style: DesignSystem.textStyleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : DesignSystem.neutralGray700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

