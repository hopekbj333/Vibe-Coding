import 'package:flutter/material.dart';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.11: 음소 대치/추가
/// "공에서 'ㄱ'을 'ㅂ'으로 바꾸면?" → 음성 녹음
class PhonemeSubstitutionWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String recordingPath) onRecordingCompleted;

  const PhonemeSubstitutionWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onRecordingCompleted,
  });

  @override
  State<PhonemeSubstitutionWidget> createState() =>
      _PhonemeSubstitutionWidgetState();
}

class _PhonemeSubstitutionWidgetState extends State<PhonemeSubstitutionWidget>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 원래 단어 추출 (예: "공")
  String get _originalWord {
    // soundLabels[0]에 "공,ㄱ,ㅂ" 형태로 저장
    final parts = widget.question.soundLabels.firstOrNull?.split(',') ?? [];
    return parts.isNotEmpty ? parts[0] : '';
  }

  // 대치할 음소 추출 (예: "ㄱ")
  String get _fromPhoneme {
    final parts = widget.question.soundLabels.firstOrNull?.split(',') ?? [];
    return parts.length > 1 ? parts[1] : '';
  }

  // 대치될 음소 추출 (예: "ㅂ")
  String get _toPhoneme {
    final parts = widget.question.soundLabels.firstOrNull?.split(',') ?? [];
    return parts.length > 2 ? parts[2] : '';
  }

  Future<void> _startRecording() async {
    if (widget.isInputBlocked || _isRecording) return;

    setState(() => _isRecording = true);

    // 3초 녹음 시뮬레이션
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isRecording = false);
      // 녹음 완료 → 답안 제출 (임시 경로)
      widget.onRecordingCompleted('recording_phoneme_substitution_${DateTime.now().millisecondsSinceEpoch}.m4a');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSystem.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 안내 텍스트
          Text(
            widget.question.promptText,
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.neutralGray700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSystem.spacingXL),

          // 음소 대치 시각화
          _buildSubstitutionVisual(),
          SizedBox(height: DesignSystem.spacingXL),

          // 마이크 버튼
          GestureDetector(
            onTap: _startRecording,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = _isRecording
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? DesignSystem.semanticError
                          : DesignSystem.primaryBlue,
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                color: DesignSystem.semanticError
                                    .withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ]
                          : DesignSystem.shadowLarge,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: DesignSystem.spacingMD),

          // 상태 텍스트
          Text(
            _isRecording ? '녹음 중...' : '마이크를 눌러 답해줘',
            style: DesignSystem.textStyleRegular.copyWith(
              color: _isRecording
                  ? DesignSystem.semanticError
                  : DesignSystem.neutralGray600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 음소 대치 시각화: "공" - "ㄱ" → "ㅂ"
  Widget _buildSubstitutionVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 원래 단어
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingLG,
            vertical: DesignSystem.spacingMD,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMD),
            border: Border.all(
              color: DesignSystem.primaryBlue,
              width: 2,
            ),
          ),
          child: Text(
            _originalWord,
            style: DesignSystem.textStyleLarge.copyWith(
              color: DesignSystem.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: DesignSystem.spacingMD),

        // 빼기 아이콘
        Icon(
          Icons.remove_circle_outline_rounded,
          size: 32,
          color: DesignSystem.semanticError,
        ),
        SizedBox(width: DesignSystem.spacingSM),

        // 대치할 음소 (원래)
        Container(
          padding: EdgeInsets.all(DesignSystem.spacingMD),
          decoration: BoxDecoration(
            color: DesignSystem.semanticError.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSM),
            border: Border.all(
              color: DesignSystem.semanticError,
              width: 2,
            ),
          ),
          child: Text(
            _fromPhoneme,
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.semanticError,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: DesignSystem.spacingMD),

        // 더하기 아이콘
        Icon(
          Icons.add_circle_outline_rounded,
          size: 32,
          color: DesignSystem.semanticSuccess,
        ),
        SizedBox(width: DesignSystem.spacingSM),

        // 대치될 음소 (새로운)
        Container(
          padding: EdgeInsets.all(DesignSystem.spacingMD),
          decoration: BoxDecoration(
            color: DesignSystem.semanticSuccess.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSM),
            border: Border.all(
              color: DesignSystem.semanticSuccess,
              width: 2,
            ),
          ),
          child: Text(
            _toPhoneme,
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.semanticSuccess,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

