import 'package:flutter/material.dart';
import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.13: 숫자/단어 폭 기억
/// 숫자 시퀀스(예: 3-7-2) 재생 후 → 음성 녹음으로 따라 말하기
class MemorySpanWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String recordingPath) onRecordingCompleted;

  const MemorySpanWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onRecordingCompleted,
  });

  @override
  State<MemorySpanWidget> createState() => _MemorySpanWidgetState();
}

class _MemorySpanWidgetState extends State<MemorySpanWidget>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPlayingSequence = false;
  int _currentSequenceIndex = -1;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // 자동으로 시퀀스 재생
    _playSequence();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 시퀀스 추출 (예: ["3", "7", "2"])
  List<String> get _sequence {
    final seq = widget.question.soundLabels.firstOrNull ?? '';
    return seq.split('-').map((e) => e.trim()).toList();
  }

  Future<void> _playSequence() async {
    if (_isPlayingSequence) return;

    setState(() => _isPlayingSequence = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // 각 항목을 순차적으로 표시
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) break;
      setState(() => _currentSequenceIndex = i);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (mounted) {
      setState(() {
        _isPlayingSequence = false;
        _currentSequenceIndex = -1;
      });
    }
  }

  Future<void> _startRecording() async {
    if (widget.isInputBlocked || _isRecording || _isPlayingSequence) return;

    setState(() => _isRecording = true);

    // 3초 녹음 시뮬레이션
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isRecording = false);
      // 녹음 완료 → 답안 제출 (임시 경로)
      widget.onRecordingCompleted('recording_memory_span_${DateTime.now().millisecondsSinceEpoch}.m4a');
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

          // 시퀀스 표시
          if (_isPlayingSequence || _currentSequenceIndex >= 0)
            _buildSequenceDisplay(),
          SizedBox(height: DesignSystem.spacingXL),

          // 마이크 버튼
          if (!_isPlayingSequence)
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
          if (!_isPlayingSequence)
            Text(
              _isRecording ? '녹음 중...' : '순서대로 따라 말해줘',
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

  /// 시퀀스 순차 표시
  Widget _buildSequenceDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_sequence.length, (index) {
        final isActive = index == _currentSequenceIndex;
        final isPast = index < _currentSequenceIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TweenAnimationBuilder<double>(
            key: ValueKey('seq_$index'),
            tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.4),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isActive
                        ? DesignSystem.primaryBlue
                        : isPast
                            ? DesignSystem.neutralGray300
                            : DesignSystem.neutralGray100,
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMD),
                    border: Border.all(
                      color: isActive
                          ? DesignSystem.primaryBlue
                          : DesignSystem.neutralGray400,
                      width: 3,
                    ),
                    boxShadow:
                        isActive ? DesignSystem.shadowLarge : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _sequence[index],
                    style: DesignSystem.textStyleLarge.copyWith(
                      color: isActive
                          ? Colors.white
                          : isPast
                              ? DesignSystem.neutralGray500
                              : DesignSystem.neutralGray400,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

