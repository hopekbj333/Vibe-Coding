import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.4.1: 소리 식별 위젯
/// 
/// 두 가지 소리를 순차적으로 재생하고 "같아? 달라?" 버튼을 표시합니다.
class SoundIdentificationWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(int answer) onAnswerSelected;

  const SoundIdentificationWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<SoundIdentificationWidget> createState() => _SoundIdentificationWidgetState();
}

class _SoundIdentificationWidgetState extends State<SoundIdentificationWidget>
    with TickerProviderStateMixin {
  int _currentSoundIndex = -1; // -1: 대기, 0: 첫번째 소리, 1: 두번째 소리
  bool _soundsPlayed = false;
  int? _selectedAnswer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // 시각적 소리 시퀀스 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSoundsSequentially();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SoundIdentificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // 새 문제로 전환 시 초기화
      setState(() {
        _currentSoundIndex = -1;
        _soundsPlayed = false;
        _selectedAnswer = null;
      });
      // 시각적 표시 시작
      _playSoundsSequentially();
    }
  }

  Future<void> _playSoundsSequentially() async {
    // 소리 라벨 표시 (임시: TTS 대신 시각적 표시)
    final labels = widget.question.soundLabels;
    debugPrint('🔊 소리 라벨: $labels (개수: ${labels.length})');
    
    if (labels.length >= 2) {
      // 첫 번째 소리 표시
      debugPrint('🔊 첫 번째 소리: ${labels[0]}');
      setState(() => _currentSoundIndex = 0);
      await Future.delayed(const Duration(milliseconds: 800)); // 안내 시간
      await Future.delayed(const Duration(seconds: 2)); // 소리 재생 시간
      
      // 두 번째 소리 표시
      debugPrint('🔊 두 번째 소리: ${labels[1]}');
      setState(() => _currentSoundIndex = 1);
      await Future.delayed(const Duration(milliseconds: 800)); // 안내 시간
      await Future.delayed(const Duration(seconds: 2)); // 소리 재생 시간
      
      debugPrint('✓ 소리 시퀀스 완료');
    } else {
      debugPrint('⚠️ 소리 라벨이 2개 미만입니다: $labels');
    }
    
    setState(() {
      _currentSoundIndex = -1;
      _soundsPlayed = true;
    });
  }

  Future<void> _replaySounds() async {
    setState(() {
      _soundsPlayed = false;
      _selectedAnswer = null;
    });
    await _playSoundsSequentially();
  }

  void _selectAnswer(int answer) {
    if (widget.isInputBlocked || !_soundsPlayed) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
    
    widget.onAnswerSelected(answer);
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.question.soundLabels;
    
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 현재 재생 중인 소리 안내 (크게 표시)
          if (_currentSoundIndex >= 0 && _currentSoundIndex < 2)
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingMD),
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
                border: Border.all(
                  color: DesignSystem.primaryBlue,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _currentSoundIndex == 0 ? '첫 번째 소리' : '두 번째 소리',
                    style: DesignSystem.textStyleMedium.copyWith(
                      color: DesignSystem.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🔊 ${labels.length > _currentSoundIndex ? labels[_currentSoundIndex] : ""}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: DesignSystem.spacingXL),
          
          // 소리 재생 영역
          _buildSoundPlayArea(),
          
          const SizedBox(height: DesignSystem.spacingXL),
          
          // 다시 듣기 버튼
          if (_soundsPlayed)
            TextButton.icon(
              onPressed: widget.isInputBlocked ? null : _replaySounds,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('다시 보기'),
              style: TextButton.styleFrom(
                foregroundColor: DesignSystem.neutralGray600,
              ),
            ),
          
          const SizedBox(height: DesignSystem.spacingLG),
          
          // 질문 텍스트
          if (_soundsPlayed)
            Text(
              '두 소리가 같아? 달라?',
              style: DesignSystem.textStyleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          
          const SizedBox(height: DesignSystem.spacingXL),
          
          // 같아/달라 버튼
          if (_soundsPlayed)
            _buildAnswerButtons(),
        ],
      ),
    );
  }

  Widget _buildSoundPlayArea() {
    final labels = widget.question.soundLabels;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 첫 번째 소리
        _buildSoundCard(
          index: 0,
          label: labels.isNotEmpty ? labels[0] : '소리 1',
          icon: Icons.music_note_rounded,
          color: DesignSystem.primaryBlue,
        ),
        
        // VS 표시
        Container(
          padding: const EdgeInsets.all(DesignSystem.spacingSM),
          decoration: BoxDecoration(
            color: DesignSystem.neutralGray200,
            shape: BoxShape.circle,
          ),
          child: Text(
            'VS',
            style: DesignSystem.textStyleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignSystem.neutralGray600,
            ),
          ),
        ),
        
        // 두 번째 소리
        _buildSoundCard(
          index: 1,
          label: labels.length > 1 ? labels[1] : '소리 2',
          icon: Icons.music_note_rounded,
          color: DesignSystem.semanticWarning,
        ),
      ],
    );
  }

  Widget _buildSoundCard({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isPlaying = _currentSoundIndex == index;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isPlaying ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 120,
            height: 140,
            decoration: BoxDecoration(
              color: isPlaying ? color.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
              border: Border.all(
                color: isPlaying ? color : DesignSystem.neutralGray300,
                width: isPlaying ? 3 : 1,
              ),
              boxShadow: isPlaying ? DesignSystem.shadowMedium : DesignSystem.shadowSmall,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.volume_up_rounded : icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingSM),
                // 라벨
                Text(
                  label,
                  style: DesignSystem.textStyleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPlaying ? color : DesignSystem.neutralGray700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerButtons() {
    return Opacity(
      opacity: widget.isInputBlocked ? 0.5 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 같아요 버튼 (정답: 0)
          _buildAnswerButton(
            answer: 0,
            label: '같아요',
            icon: Icons.check_circle_rounded,
            color: DesignSystem.semanticSuccess,
            emoji: '👍',
          ),
          
          // 달라요 버튼 (정답: 1)
          _buildAnswerButton(
            answer: 1,
            label: '달라요',
            icon: Icons.cancel_rounded,
            color: DesignSystem.semanticError,
            emoji: '👎',
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton({
    required int answer,
    required String label,
    required IconData icon,
    required Color color,
    required String emoji,
  }) {
    final isSelected = _selectedAnswer == answer;
    
    return GestureDetector(
      onTap: () => _selectAnswer(answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
          border: Border.all(
            color: isSelected ? color : DesignSystem.neutralGray300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? DesignSystem.shadowMedium : DesignSystem.shadowSmall,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: DesignSystem.spacingSM),
            // 라벨
            Text(
              label,
              style: DesignSystem.textStyleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : DesignSystem.neutralGray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

