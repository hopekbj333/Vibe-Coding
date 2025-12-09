import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// 음성 녹음 위젯 (S 1.4.8 등)
/// 
/// 질문을 표시하고 음성 녹음 버튼을 제공합니다.
/// 녹음 완료 후 자동으로 제출됩니다.
class RecordingWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String recordingPath) onRecordingCompleted;

  const RecordingWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onRecordingCompleted,
  });

  @override
  State<RecordingWidget> createState() => _RecordingWidgetState();
}

class _RecordingWidgetState extends State<RecordingWidget>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecorded = false;
  int _recordingSeconds = 0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecordingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _isRecording = false;
        _hasRecorded = false;
        _recordingSeconds = 0;
      });
    }
  }

  void _startRecording() {
    if (widget.isInputBlocked) return;
    
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    
    // 녹음 시뮬레이션 (3초)
    _simulateRecording();
  }

  Future<void> _simulateRecording() async {
    for (int i = 1; i <= 3; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() => _recordingSeconds = i);
      }
    }
    
    // 녹음 완료
    if (mounted && _isRecording) {
      _stopRecording();
    }
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });
    
    // 녹음 경로 시뮬레이션
    final recordingPath = 'recording_${widget.question.id}_${DateTime.now().millisecondsSinceEpoch}.wav';
    debugPrint('녹음 완료: $recordingPath');
    
    // 자동 제출
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onRecordingCompleted(recordingPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    // soundLabels[0]: 단어 (예: "나비")
    final word = widget.question.soundLabels.isNotEmpty
        ? widget.question.soundLabels[0]
        : '';
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingLG),
        child: Column(
          children: [
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 안내 텍스트 (promptText는 음성용)
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
                  const Icon(Icons.mic_rounded, color: DesignSystem.primaryBlue),
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
            
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 단어 표시 (뒤집을 단어)
            if (word.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingLG),
                decoration: BoxDecoration(
                  color: DesignSystem.semanticWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                  border: Border.all(
                    color: DesignSystem.semanticWarning,
                    width: 2,
                  ),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.neutralGray800,
                  ),
                ),
              ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 뒤집기 아이콘
            const Icon(
              Icons.swap_vert_rounded,
              size: 40,
              color: DesignSystem.semanticWarning,
            ),
            
            const SizedBox(height: DesignSystem.spacingLG),
            
            // 질문
            Text(
              '거꾸로 하면?',
              style: DesignSystem.textStyleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: DesignSystem.spacingXL),
            
            // 녹음 버튼 또는 상태 표시
            if (!_hasRecorded)
              _buildRecordingButton()
            else
              _buildCompletedIndicator(),
            
            const SizedBox(height: DesignSystem.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingButton() {
    if (_isRecording) {
      // 녹음 중
      return Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignSystem.semanticError,
                    boxShadow: DesignSystem.shadowLarge,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: DesignSystem.spacingMD),
          Text(
            '녹음 중... $_recordingSeconds초',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.semanticError,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      // 녹음 대기
      return GestureDetector(
        onTap: _startRecording,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignSystem.primaryBlue,
            boxShadow: DesignSystem.shadowLarge,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mic_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                '눌러서\n말해봐!',
                style: DesignSystem.textStyleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCompletedIndicator() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLG),
      decoration: BoxDecoration(
        color: DesignSystem.semanticSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
        border: Border.all(
          color: DesignSystem.semanticSuccess,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: DesignSystem.semanticSuccess,
            size: 40,
          ),
          const SizedBox(width: 12),
          Text(
            '녹음 완료!',
            style: DesignSystem.textStyleLarge.copyWith(
              color: DesignSystem.semanticSuccess,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

