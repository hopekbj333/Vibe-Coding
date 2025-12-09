import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.6.1 & S 1.6.2: 숫자 따라 말하기 (순방향/역방향) 위젯
/// 
/// 숫자 시퀀스를 재생하고 아동이 녹음하여 답변합니다.
/// 순방향: 그대로 따라 말하기
/// 역방향: 거꾸로 말하기
class DigitSpanWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String recordingPath) onRecordingCompleted;
  final bool isBackward; // true: 역방향, false: 순방향

  const DigitSpanWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onRecordingCompleted,
    this.isBackward = false,
  });

  @override
  State<DigitSpanWidget> createState() => _DigitSpanWidgetState();
}

class _DigitSpanWidgetState extends State<DigitSpanWidget>
    with SingleTickerProviderStateMixin {
  bool _sequencePlayed = false;
  bool _isRecording = false;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSequence();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DigitSpanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _sequencePlayed = false;
        _isRecording = false;
      });
      _playSequence();
    }
  }

  Future<void> _playSequence() async {
    if (widget.question.soundLabels.isEmpty) return;
    
    final sequence = widget.question.soundLabels[0]; // 예: "2-5-9"
    debugPrint('🔢 숫자 시퀀스: $sequence');
    
    // 2초 대기 후 재생 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));
    
    // 재생 완료
    setState(() {
      _sequencePlayed = true;
    });
    
    debugPrint('✅ 숫자 재생 완료. 녹음 준비');
  }

  void _onRecordTap() {
    if (widget.isInputBlocked || !_sequencePlayed || _isRecording) return;
    
    setState(() {
      _isRecording = true;
    });
    
    debugPrint('🎤 녹음 시작');
    
    // 3초 녹음 시뮬레이션
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        
        // 녹음 파일 경로 (시뮬레이션)
        final recordingPath = 'recording_${widget.question.id}_${DateTime.now().millisecondsSinceEpoch}.mp3';
        debugPrint('✅ 녹음 완료: $recordingPath');
        
        widget.onRecordingCompleted(recordingPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sequence = widget.question.soundLabels.isNotEmpty
        ? widget.question.soundLabels[0]
        : '';
    final digits = sequence.split('-');
    
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
          if (!_sequencePlayed)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  '숫자를 들어봐...',
                  style: DesignSystem.textStyleMedium,
                ),
              ],
            )
          else if (_isRecording)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  '녹음 중... 🎤',
                  style: DesignSystem.textStyleMedium.copyWith(
                    color: DesignSystem.semanticError,
                  ),
                ),
              ],
            )
          else
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
                widget.isBackward
                    ? '거꾸로 말해봐!'
                    : '그대로 따라 말해봐!',
                style: DesignSystem.textStyleMedium.copyWith(
                  color: DesignSystem.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          const SizedBox(height: 40),
          
          // 숫자 표시 (큰 글씨)
          if (_sequencePlayed && !_isRecording)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: digits.map((digit) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: DesignSystem.neutralGray100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: DesignSystem.neutralGray300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          digit,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          const SizedBox(height: 40),
          
          // 녹음 버튼
          if (_sequencePlayed && !_isRecording)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: InkWell(
                    onTap: _onRecordTap,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DesignSystem.semanticError,
                        boxShadow: [
                          BoxShadow(
                            color: DesignSystem.semanticError.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 16),
          
          if (_sequencePlayed && !_isRecording)
            Text(
              '마이크를 눌러서 말해봐',
              style: DesignSystem.textStyleRegular.copyWith(
                color: DesignSystem.neutralGray600,
              ),
            ),
        ],
      ),
    );
  }
}

