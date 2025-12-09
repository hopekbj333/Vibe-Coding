import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.2: 동물 소리 순서 맞추기 위젯
/// 
/// 동물 울음소리를 순차적으로 재생하고, 사용자가 들은 순서대로 터치하게 합니다.
class AnimalSoundSequenceWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String answer) onAnswerSelected;

  const AnimalSoundSequenceWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<AnimalSoundSequenceWidget> createState() => _AnimalSoundSequenceWidgetState();
}

class _AnimalSoundSequenceWidgetState extends State<AnimalSoundSequenceWidget>
    with TickerProviderStateMixin {
  bool _sequencePlayed = false;
  final List<int> _userSequence = [];
  int? _currentPlayingIndex;
  late List<AnimationController> _pulseControllers;

  @override
  void initState() {
    super.initState();
    
    final optionsCount = widget.question.optionsText.length;
    _pulseControllers = List.generate(
      optionsCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    
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
  void didUpdateWidget(AnimalSoundSequenceWidget oldWidget) {
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
    
    debugPrint('🐶 동물 소리 시퀀스 재생: $sequence');
    
    await Future.delayed(const Duration(seconds: 2));
    
    for (int i = 0; i < sequence.length; i++) {
      final animalIndex = sequence[i];
      setState(() {
        _currentPlayingIndex = animalIndex;
      });
      
      _pulseControllers[animalIndex].forward().then((_) {
        _pulseControllers[animalIndex].reverse();
      });
      
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() {
        _currentPlayingIndex = null;
      });
      
      if (i < sequence.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    setState(() {
      _sequencePlayed = true;
    });
    
    debugPrint('✅ 시퀀스 재생 완료');
  }

  void _onAnimalTap(int index) {
    if (widget.isInputBlocked || !_sequencePlayed) return;
    
    debugPrint('🐶 동물 터치: $index');
    
    setState(() {
      _userSequence.add(index);
    });
    
    _pulseControllers[index].forward().then((_) {
      _pulseControllers[index].reverse();
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

  @override
  Widget build(BuildContext context) {
    final optionsCount = widget.question.optionsText.length;
    final crossAxisCount = optionsCount <= 4 ? 2 : 3;
    
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
                '동물 소리를 들어봐...',
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
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: optionsCount,
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
                          ? () => _onAnimalTap(index)
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
                            if (widget.question.optionsImageUrl.isNotEmpty &&
                                index < widget.question.optionsImageUrl.length)
                              Image.asset(
                                widget.question.optionsImageUrl[index],
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    _getAnimalIcon(widget.question.optionsText[index]),
                                    size: 60,
                                    color: DesignSystem.primaryBlue,
                                  );
                                },
                              )
                            else
                              Icon(
                                _getAnimalIcon(widget.question.optionsText[index]),
                                size: 60,
                                color: DesignSystem.primaryBlue,
                              ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              widget.question.optionsText[index],
                              style: DesignSystem.textStyleRegular,
                              textAlign: TextAlign.center,
                            ),
                            
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignSystem.semanticSuccess,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_userSequence.indexOf(index) + 1}',
                                    style: DesignSystem.textStyleSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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

  IconData _getAnimalIcon(String animalName) {
    switch (animalName) {
      case '강아지':
        return Icons.pets;
      case '고양이':
        return Icons.pets;
      case '돼지':
        return Icons.agriculture;
      case '소':
        return Icons.agriculture;
      case '오리':
        return Icons.flutter_dash;
      default:
        return Icons.pets;
    }
  }
}

