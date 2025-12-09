import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.2: 리듬 따라하기 위젯
/// 
/// 짧은 리듬 패턴을 시각적으로 보여주고, 아동이 화면을 탭하여 리듬을 재현합니다.
/// 탭 타이밍을 기록하여 평가합니다.
class RhythmTapWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(List<int> tapTimings) onRhythmCompleted;

  const RhythmTapWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onRhythmCompleted,
  });

  @override
  State<RhythmTapWidget> createState() => _RhythmTapWidgetState();
}

class _RhythmTapWidgetState extends State<RhythmTapWidget>
    with TickerProviderStateMixin {
  // 리듬 패턴 (밀리초 단위 간격)
  List<int> _rhythmPattern = [];
  
  // 시연 상태
  bool _isShowingPattern = false;
  int _currentBeatIndex = -1;
  
  // 녹음 상태
  bool _isRecording = false;
  List<int> _userTaps = [];
  DateTime? _recordingStartTime;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    
    // 리듬 패턴 설정 (soundLabels에서 가져오거나 기본값)
    _parseRhythmPattern();
    
    // 자동으로 리듬 시연 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRhythmPattern();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RhythmTapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _isShowingPattern = false;
        _isRecording = false;
        _currentBeatIndex = -1;
        _userTaps.clear();
      });
      _parseRhythmPattern();
      _showRhythmPattern();
    }
  }

  void _parseRhythmPattern() {
    // soundLabels에서 리듬 패턴 파싱 (예: "500,500,500" -> [500, 500, 500])
    if (widget.question.soundLabels.isNotEmpty) {
      try {
        _rhythmPattern = widget.question.soundLabels[0]
            .split(',')
            .map((e) => int.parse(e.trim()))
            .toList();
      } catch (e) {
        // 파싱 실패 시 기본 패턴 (똑-똑-똑, 500ms 간격)
        _rhythmPattern = [500, 500, 500];
      }
    } else {
      _rhythmPattern = [500, 500, 500];
    }
    debugPrint('리듬 패턴: $_rhythmPattern');
  }

  Future<void> _showRhythmPattern() async {
    setState(() {
      _isShowingPattern = true;
      _currentBeatIndex = -1;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // 리듬 패턴 시연
    for (int i = 0; i < _rhythmPattern.length; i++) {
      setState(() => _currentBeatIndex = i);
      _pulseController.forward(from: 0.0);
      
      // 비트 표시 시간
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 다음 비트까지 대기
      await Future.delayed(Duration(milliseconds: _rhythmPattern[i]));
    }

    setState(() {
      _isShowingPattern = false;
      _currentBeatIndex = -1;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // 녹음 시작
    _startRecording();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _userTaps.clear();
      _recordingStartTime = DateTime.now();
    });
  }

  void _onTap() {
    if (!_isRecording || widget.isInputBlocked) return;

    final now = DateTime.now();
    final tapTime = _recordingStartTime != null
        ? now.difference(_recordingStartTime!).inMilliseconds
        : 0;

    setState(() {
      _userTaps.add(tapTime);
    });

    // 애니메이션 효과
    _pulseController.forward(from: 0.0);

    debugPrint('탭 ${_userTaps.length}: ${tapTime}ms');

    // 패턴 개수만큼 탭하면 완료
    if (_userTaps.length >= _rhythmPattern.length) {
      _completeRhythm();
    }
  }

  void _completeRhythm() {
    setState(() => _isRecording = false);
    
    // 탭 간격 계산
    List<int> tapIntervals = [];
    for (int i = 1; i < _userTaps.length; i++) {
      tapIntervals.add(_userTaps[i] - _userTaps[i - 1]);
    }
    
    debugPrint('사용자 탭 간격: $tapIntervals');
    debugPrint('원본 리듬: $_rhythmPattern');
    
    // 결과 전달 (전체 탭 타이밍)
    widget.onRhythmCompleted(_userTaps);
  }

  void _replayPattern() {
    setState(() {
      _isRecording = false;
      _userTaps.clear();
    });
    _showRhythmPattern();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                const Icon(Icons.music_note_rounded, color: DesignSystem.primaryBlue),
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
          
          // 상태 표시
          _buildStatusIndicator(),
          
          const SizedBox(height: DesignSystem.spacingXL),
          
          // 리듬 패턴 시각화
          _buildRhythmVisualization(),
          
          const SizedBox(height: DesignSystem.spacingXL),
          
          // 탭 영역 또는 다시보기 버튼
          if (_isRecording)
            _buildTapArea()
          else if (!_isShowingPattern)
            TextButton.icon(
              onPressed: _replayPattern,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('다시 보기'),
              style: TextButton.styleFrom(
                foregroundColor: DesignSystem.neutralGray600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_isShowingPattern) {
      statusText = '잘 봐! 이 리듬을 기억해!';
      statusColor = DesignSystem.semanticInfo;
      statusIcon = Icons.visibility_rounded;
    } else if (_isRecording) {
      statusText = '이제 똑같이 눌러봐! (${_userTaps.length}/${_rhythmPattern.length})';
      statusColor = DesignSystem.semanticSuccess;
      statusIcon = Icons.touch_app_rounded;
    } else {
      statusText = '준비 중...';
      statusColor = DesignSystem.neutralGray500;
      statusIcon = Icons.pending_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingMD,
        vertical: DesignSystem.spacingSM,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusRound),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: DesignSystem.textStyleMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRhythmVisualization() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_rhythmPattern.length, (index) {
        final isActive = _currentBeatIndex == index;
        final isTapped = _isRecording && _userTaps.length > index;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isActive ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTapped
                        ? DesignSystem.semanticSuccess
                        : isActive
                            ? DesignSystem.primaryBlue
                            : DesignSystem.neutralGray300,
                    boxShadow: isActive || isTapped
                        ? DesignSystem.shadowMedium
                        : DesignSystem.shadowSmall,
                  ),
                  child: Icon(
                    isTapped
                        ? Icons.check_rounded
                        : Icons.circle,
                    color: Colors.white,
                    size: isTapped ? 32 : 24,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildTapArea() {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.primaryBlue,
              DesignSystem.primaryBlue.withOpacity(0.7),
            ],
          ),
          boxShadow: DesignSystem.shadowLarge,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 8),
            Text(
              '여기를\n눌러봐!',
              style: DesignSystem.textStyleMedium.copyWith(
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

