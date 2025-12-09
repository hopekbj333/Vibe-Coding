import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/stt_result_model.dart';
import '../../data/services/stt_service.dart';

/// 실시간 음성 인식 위젯
/// 
/// 녹음과 동시에 STT 변환을 시도하고 결과를 표시
class RealtimeSttWidget extends StatefulWidget {
  final void Function(SttResult result)? onResult;
  final void Function(String transcript)? onTranscriptChanged;
  final bool showWaveform;
  final bool autoStart;

  const RealtimeSttWidget({
    super.key,
    this.onResult,
    this.onTranscriptChanged,
    this.showWaveform = true,
    this.autoStart = false,
  });

  @override
  State<RealtimeSttWidget> createState() => _RealtimeSttWidgetState();
}

class _RealtimeSttWidgetState extends State<RealtimeSttWidget>
    with SingleTickerProviderStateMixin {
  final SimulatedSttService _sttService = SimulatedSttService();
  StreamSubscription<SttResult>? _sttSubscription;

  bool _isListening = false;
  String _currentTranscript = '';
  double _currentConfidence = 0.0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.autoStart) {
      _startListening();
    }
  }

  @override
  void dispose() {
    _sttSubscription?.cancel();
    _sttSubscription = null;
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    if (!mounted) return;

    setState(() {
      _isListening = true;
      _currentTranscript = '';
    });

    _pulseController.repeat(reverse: true);

    _sttSubscription = _sttService.startRealtimeRecognition().listen(
      (result) {
        if (!mounted) return;
        setState(() {
          _currentTranscript = result.transcript;
          _currentConfidence = result.confidence;
        });
        widget.onTranscriptChanged?.call(result.transcript);
        widget.onResult?.call(result);
      },
      onError: (error) {
        debugPrint('STT 오류: $error');
        if (mounted) _stopListening();
      },
    );
  }

  Future<void> _stopListening() async {
    _sttSubscription?.cancel();
    _sttSubscription = null;
    await _sttService.stopRealtimeRecognition();
    
    // mounted 체크: dispose 후에는 stop/reset 하지 않음
    if (mounted) {
      _pulseController.stop();
      _pulseController.reset();
      setState(() {
        _isListening = false;
      });
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isListening
            ? DesignSystem.primaryBlue.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening
              ? DesignSystem.primaryBlue
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 마이크 버튼
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? DesignSystem.semanticError
                          : DesignSystem.primaryBlue,
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: DesignSystem.semanticError.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 상태 텍스트
          Text(
            _isListening ? '듣는 중...' : '터치하여 말하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isListening
                  ? DesignSystem.semanticError
                  : Colors.grey.shade600,
            ),
          ),

          // 인식된 텍스트
          if (_currentTranscript.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _currentTranscript,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  _buildConfidenceIndicator(),
                ],
              ),
            ),
          ],

          // 웨이브폼 (선택적)
          if (widget.showWaveform && _isListening) ...[
            const SizedBox(height: 16),
            _buildWaveform(),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidencePercent = (_currentConfidence * 100).round();
    Color indicatorColor;
    
    if (_currentConfidence >= 0.9) {
      indicatorColor = DesignSystem.semanticSuccess;
    } else if (_currentConfidence >= 0.7) {
      indicatorColor = DesignSystem.semanticWarning;
    } else {
      indicatorColor = DesignSystem.semanticError;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _currentConfidence >= 0.7 ? Icons.check_circle : Icons.help_outline,
          size: 16,
          color: indicatorColor,
        ),
        const SizedBox(width: 4),
        Text(
          '신뢰도: $confidencePercent%',
          style: TextStyle(
            fontSize: 12,
            color: indicatorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          return _WaveformBar(
            delay: index * 50,
            isActive: _isListening,
          );
        }),
      ),
    );
  }
}

class _WaveformBar extends StatefulWidget {
  final int delay;
  final bool isActive;

  const _WaveformBar({
    required this.delay,
    required this.isActive,
  });

  @override
  State<_WaveformBar> createState() => _WaveformBarState();
}

class _WaveformBarState extends State<_WaveformBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(_WaveformBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 4,
          height: 40 * _animation.value,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: DesignSystem.primaryBlue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

/// 음성 인식 결과 표시 위젯 (간소화)
class SttResultBadge extends StatelessWidget {
  final SttResult result;
  final bool showConfidence;

  const SttResultBadge({
    super.key,
    required this.result,
    this.showConfidence = true,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(result.confidenceLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: confidenceColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            result.isHighConfidence ? Icons.check_circle : Icons.help_outline,
            size: 18,
            color: confidenceColor,
          ),
          const SizedBox(width: 8),
          Text(
            result.transcript,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: confidenceColor,
            ),
          ),
          if (showConfidence) ...[
            const SizedBox(width: 8),
            Text(
              '${result.confidencePercent}%',
              style: TextStyle(
                fontSize: 12,
                color: confidenceColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.high:
        return DesignSystem.semanticSuccess;
      case ConfidenceLevel.medium:
        return DesignSystem.semanticWarning;
      case ConfidenceLevel.low:
        return DesignSystem.semanticError;
    }
  }
}

