import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.3: 위치 순서 기억하기 위젯 (Simon Says)
/// 
/// 화면의 여러 위치에서 순서대로 불빛이 깜빡이고,
/// 사용자가 깜빡인 순서대로 터치하게 합니다.
class PositionSequenceWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String answer) onAnswerSelected;

  const PositionSequenceWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<PositionSequenceWidget> createState() => _PositionSequenceWidgetState();
}

class _PositionSequenceWidgetState extends State<PositionSequenceWidget>
    with TickerProviderStateMixin {
  bool _sequencePlayed = false;
  final List<int> _userSequence = [];
  int? _currentPlayingIndex;
  late List<AnimationController> _glowControllers;
  
  // 3x3 그리드 사용
  static const int _gridSize = 9; // 3x3

  @override
  void initState() {
    super.initState();
    
    _glowControllers = List.generate(
      _gridSize,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSequence();
    });
  }

  @override
  void dispose() {
    for (var controller in _glowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(PositionSequenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _sequencePlayed = false;
        _userSequence.clear();
        _currentPlayingIndex = null;
      });
      _playSequence();
    }
  }

  Future<void> _playSequence() async {
    if (widget.question.soundLabels.isEmpty) return;
    
    final sequenceStr = widget.question.soundLabels[0];
    final sequence = sequenceStr.split(',').map((e) => int.parse(e.trim())).toList();
    
    debugPrint('💡 위치 시퀀스 재생: $sequence');
    
    await Future.delayed(const Duration(seconds: 2));
    
    for (int i = 0; i < sequence.length; i++) {
      final positionIndex = sequence[i];
      
      setState(() {
        _currentPlayingIndex = positionIndex;
      });
      
      // 발광 애니메이션
      _glowControllers[positionIndex].forward();
      
      // 깜빡임 지속 시간
      await Future.delayed(const Duration(milliseconds: 600));
      
      _glowControllers[positionIndex].reverse();
      
      setState(() {
        _currentPlayingIndex = null;
      });
      
      // 다음 깜빡임 전 간격
      if (i < sequence.length - 1) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    
    setState(() {
      _sequencePlayed = true;
    });
    
    debugPrint('✅ 시퀀스 재생 완료');
  }

  void _onPositionTap(int index) {
    if (widget.isInputBlocked || !_sequencePlayed) return;
    
    debugPrint('💡 위치 터치: $index');
    
    setState(() {
      _userSequence.add(index);
    });
    
    // 시각적 피드백
    _glowControllers[index].forward().then((_) {
      _glowControllers[index].reverse();
    });
    
    final sequenceStr = widget.question.soundLabels[0];
    final correctSequence = sequenceStr.split(',').map((e) => int.parse(e.trim())).toList();
    
    if (_userSequence.length == correctSequence.length) {
      final userAnswer = _userSequence.join(',');
      debugPrint('✅ 사용자 답변: $userAnswer');
      
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnswerSelected(userAnswer);
      });
    }
  }

  void _onReplay() {
    if (widget.isInputBlocked) return;
    
    setState(() {
      _sequencePlayed = false;
      _userSequence.clear();
      _currentPlayingIndex = null;
    });
    
    _playSequence();
  }

  void _onReset() {
    if (widget.isInputBlocked || !_sequencePlayed) return;
    
    setState(() {
      _userSequence.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        
        if (!_sequencePlayed)
          Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '불빛을 잘 봐...',
                style: DesignSystem.textStyleMedium,
              ),
            ],
          )
        else
          Text(
            '깜빡인 순서대로 눌러봐! (${_userSequence.length}번 눌렀어)',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.primaryBlue,
            ),
          ),
        
        const SizedBox(height: 40),
        
        // 3x3 그리드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _gridSize,
              itemBuilder: (context, index) {
                final isPlaying = _currentPlayingIndex == index;
                final isSelected = _userSequence.contains(index);
                final selectionOrder = _userSequence.indexOf(index) + 1;
                
                return AnimatedBuilder(
                  animation: _glowControllers[index],
                  builder: (context, child) {
                    final glowIntensity = _glowControllers[index].value;
                    
                    return InkWell(
                      onTap: _sequencePlayed && !widget.isInputBlocked
                          ? () => _onPositionTap(index)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isPlaying || glowIntensity > 0
                              ? DesignSystem.primaryBlue.withOpacity(
                                  0.3 + (glowIntensity * 0.5),
                                )
                              : isSelected
                                  ? DesignSystem.semanticSuccess.withOpacity(0.3)
                                  : DesignSystem.neutralGray100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPlaying || glowIntensity > 0
                                ? DesignSystem.primaryBlue
                                : isSelected
                                    ? DesignSystem.semanticSuccess
                                    : DesignSystem.neutralGray300,
                            width: 2,
                          ),
                          boxShadow: isPlaying || glowIntensity > 0.3
                              ? [
                                  BoxShadow(
                                    color: DesignSystem.primaryBlue.withOpacity(
                                      glowIntensity * 0.6,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isSelected
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: DesignSystem.semanticSuccess,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$selectionOrder',
                                      style: DesignSystem.textStyleLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        // 버튼들
        if (_sequencePlayed && !widget.isInputBlocked)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _onReplay,
                icon: const Icon(Icons.replay),
                label: const Text('다시 보기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              
              const SizedBox(width: 16),
              
              if (_userSequence.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 누르기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

