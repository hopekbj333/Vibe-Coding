import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.1: 소리 순서 기억하기 위젯
/// 
/// 악기 소리를 순차적으로 재생하고, 사용자가 들은 순서대로 터치하게 합니다.
class SoundSequenceWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String answer) onAnswerSelected;

  const SoundSequenceWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<SoundSequenceWidget> createState() => _SoundSequenceWidgetState();
}

class _SoundSequenceWidgetState extends State<SoundSequenceWidget>
    with TickerProviderStateMixin {
  bool _sequencePlayed = false;
  final List<int> _userSequence = []; // 사용자가 터치한 순서
  int? _currentPlayingIndex; // 현재 재생 중인 악기 인덱스
  late List<AnimationController> _pulseControllers;

  @override
  void initState() {
    super.initState();
    
    // 각 악기마다 애니메이션 컨트롤러 생성
    final optionsCount = widget.question.optionsText.length;
    _pulseControllers = List.generate(
      optionsCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    
    // 시퀀스 재생 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSequence();
    });
  }

  @override
  void dispose() {
    for (var controller in _pulseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SoundSequenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 옵션 개수가 변경되면 controller 재생성
      final oldCount = oldWidget.question.optionsText.length;
      final newCount = widget.question.optionsText.length;
      
      if (oldCount != newCount) {
        // 기존 controller dispose
        for (var controller in _pulseControllers) {
          controller.dispose();
        }
        
        // 새 controller 생성
        _pulseControllers = List.generate(
          newCount,
          (index) => AnimationController(
            duration: const Duration(milliseconds: 500),
            vsync: this,
          ),
        );
      }
      
      // 새 문제로 전환 시 초기화
      setState(() {
        _sequencePlayed = false;
        _userSequence.clear();
        _currentPlayingIndex = null;
      });
      _playSequence();
    }
  }

  /// 소리 시퀀스 재생 (시각적 표시)
  Future<void> _playSequence() async {
    // soundLabels[0]에서 시퀀스 가져오기 (예: "0,1,2")
    if (widget.question.soundLabels.isEmpty) return;
    
    final sequenceStr = widget.question.soundLabels[0];
    final sequence = sequenceStr.split(',').map((e) => int.parse(e.trim())).toList();
    
    debugPrint('🎵 소리 시퀀스 재생: $sequence');
    
    // 2초 대기 후 시작
    await Future.delayed(const Duration(seconds: 2));
    
    // 각 악기 순서대로 재생 표시
    for (int i = 0; i < sequence.length; i++) {
      final instrumentIndex = sequence[i];
      setState(() {
        _currentPlayingIndex = instrumentIndex;
      });
      
      // 애니메이션 실행
      _pulseControllers[instrumentIndex].forward().then((_) {
        _pulseControllers[instrumentIndex].reverse();
      });
      
      // 소리 재생 시뮬레이션 (1초)
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() {
        _currentPlayingIndex = null;
      });
      
      // 다음 소리 전 간격
      if (i < sequence.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    setState(() {
      _sequencePlayed = true;
    });
    
    debugPrint('✅ 시퀀스 재생 완료. 사용자 입력 대기 중...');
  }

  /// 악기 터치 처리
  void _onInstrumentTap(int index) {
    if (widget.isInputBlocked || !_sequencePlayed) return;
    
    debugPrint('🎵 악기 터치: $index');
    
    setState(() {
      _userSequence.add(index);
    });
    
    // 시각적 피드백
    _pulseControllers[index].forward().then((_) {
      _pulseControllers[index].reverse();
    });
    
    // 정답 시퀀스 길이 가져오기
    final sequenceStr = widget.question.soundLabels[0];
    final correctSequence = sequenceStr.split(',').map((e) => int.parse(e.trim())).toList();
    
    // 시퀀스가 완성되면 제출
    if (_userSequence.length == correctSequence.length) {
      final userAnswer = _userSequence.join(',');
      debugPrint('✅ 사용자 답변: $userAnswer');
      
      // 0.5초 후 제출 (시각적 피드백 시간)
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnswerSelected(userAnswer);
      });
    }
  }

  /// 다시 듣기 버튼
  void _onReplay() {
    if (widget.isInputBlocked) return;
    
    setState(() {
      _sequencePlayed = false;
      _userSequence.clear();
      _currentPlayingIndex = null;
    });
    
    _playSequence();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // 상단 안내 텍스트
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            widget.question.promptText,
            style: DesignSystem.textStyleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 진행 상태 표시
        if (!_sequencePlayed)
          Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '악기 소리를 들어봐...',
                style: DesignSystem.textStyleMedium,
              ),
            ],
          )
        else
          Text(
            '들은 순서대로 눌러봐! (${_userSequence.length}번 눌렀어)',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.primaryBlue,
            ),
          ),
        
        const SizedBox(height: 40),
        
        // 악기 버튼들 (2x2 그리드)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.question.optionsText.length,
            itemBuilder: (context, index) {
              final isPlaying = _currentPlayingIndex == index;
              final isSelected = _userSequence.contains(index);
              
              return AnimatedBuilder(
                animation: _pulseControllers[index],
                builder: (context, child) {
                  final scale = isPlaying
                      ? 1.0 + (_pulseControllers[index].value * 0.2)
                      : 1.0;
                  
                  return Transform.scale(
                    scale: scale,
                    child: InkWell(
                      onTap: _sequencePlayed && !widget.isInputBlocked
                          ? () => _onInstrumentTap(index)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? DesignSystem.primaryBlue.withOpacity(0.3)
                              : isSelected
                                  ? DesignSystem.semanticSuccess.withOpacity(0.2)
                                  : DesignSystem.neutralGray100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPlaying
                                ? DesignSystem.primaryBlue
                                : isSelected
                                    ? DesignSystem.semanticSuccess
                                    : DesignSystem.neutralGray300,
                            width: isPlaying ? 3 : 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 악기 이미지
                            if (widget.question.optionsImageUrl.isNotEmpty &&
                                index < widget.question.optionsImageUrl.length)
                              Image.asset(
                                widget.question.optionsImageUrl[index],
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: DesignSystem.primaryBlue,
                                  );
                                },
                              )
                            else
                              Icon(
                                Icons.music_note,
                                size: 80,
                                color: DesignSystem.primaryBlue,
                              ),
                            
                            const SizedBox(height: 8),
                            
                            // 악기 이름
                            Text(
                              widget.question.optionsText[index],
                              style: DesignSystem.textStyleRegular,
                              textAlign: TextAlign.center,
                            ),
                            
                            // 선택 순서 표시
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignSystem.semanticSuccess,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_userSequence.indexOf(index) + 1}번째',
                                    style: DesignSystem.textStyleSmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 다시 듣기 버튼
        if (_sequencePlayed && !widget.isInputBlocked)
          ElevatedButton.icon(
            onPressed: _onReplay,
            icon: const Icon(Icons.replay),
            label: const Text('다시 듣기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

