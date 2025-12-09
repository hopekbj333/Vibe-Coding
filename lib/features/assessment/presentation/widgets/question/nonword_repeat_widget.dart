import 'package:flutter/material.dart';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.12: 비단어 따라말하기
/// 존재하지 않는 단어(예: "두파리") 재생 후 → 음성 녹음
class NonwordRepeatWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String recordingPath) onRecordingCompleted;

  const NonwordRepeatWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onRecordingCompleted,
  });

  @override
  State<NonwordRepeatWidget> createState() => _NonwordRepeatWidgetState();
}

class _NonwordRepeatWidgetState extends State<NonwordRepeatWidget>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasPlayedNonword = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // 자동으로 비단어 재생
    _playNonword();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 비단어 추출
  String get _nonword {
    return widget.question.soundLabels.firstOrNull ?? '';
  }

  Future<void> _playNonword() async {
    if (_hasPlayedNonword) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _hasPlayedNonword = true);
      // 2초간 비단어 표시
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _startRecording() async {
    if (widget.isInputBlocked || _isRecording || !_hasPlayedNonword) return;

    setState(() => _isRecording = true);

    // 3초 녹음 시뮬레이션
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isRecording = false);
      // 녹음 완료 → 답안 제출 (임시 경로)
      widget.onRecordingCompleted('recording_nonword_${DateTime.now().millisecondsSinceEpoch}.m4a');
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

          // 비단어 표시 (말풍선 형태)
          if (_hasPlayedNonword)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingXL,
                      vertical: DesignSystem.spacingLG,
                    ),
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryBlue.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(DesignSystem.borderRadiusLG),
                      border: Border.all(
                        color: DesignSystem.primaryBlue,
                        width: 3,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.volume_up_rounded,
                          size: 40,
                          color: DesignSystem.primaryBlue,
                        ),
                        SizedBox(width: DesignSystem.spacingMD),
                        Text(
                          _nonword,
                          style: DesignSystem.textStyleLarge.copyWith(
                            color: DesignSystem.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: DesignSystem.spacingXL),

          // 마이크 버튼
          if (_hasPlayedNonword)
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
          if (_hasPlayedNonword)
            Text(
              _isRecording ? '녹음 중...' : '똑같이 따라 말해줘',
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
}

