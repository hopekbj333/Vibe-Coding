import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../training/data/models/training_content_model.dart';
import '../../../../core/services/tts_service.dart';

/// 오디오 재생 기능이 있는 선택지 버튼
class AudioOptionButton extends StatefulWidget {
  final ContentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const AudioOptionButton({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AudioOptionButton> createState() => _AudioOptionButtonState();
}

class _AudioOptionButtonState extends State<AudioOptionButton> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TtsService _ttsService = TtsService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    setState(() => _isPlaying = true);

    try {
      // 1. 오디오 파일이 있으면 파일 재생
      if (widget.option.audioPath != null && widget.option.audioPath!.isNotEmpty) {
        try {
          await _audioPlayer.play(AssetSource(widget.option.audioPath!));
          await _audioPlayer.onPlayerComplete.first;
        } catch (e) {
          print('⚠️ 오디오 파일 재생 실패, TTS 사용: ${widget.option.audioPath}');
          // 파일 재생 실패 시 TTS로 fallback
          await _playTts();
        }
      } else {
        // 2. 오디오 파일이 없으면 TTS 사용
        await _playTts();
      }
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _playTts() async {
    // 이모지 제거하고 텍스트만 추출
    final text = widget.option.label.replaceAll(RegExp(r'[^\w\sㄱ-ㅎㅏ-ㅣ가-힣]'), '').trim();
    
    if (text.isEmpty) {
      // 텍스트가 없으면 label 전체 읽기
      await _ttsService.speak(widget.option.label);
    } else {
      await _ttsService.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isSelected ? Colors.purple.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSelected ? Colors.purple : Colors.grey.shade300,
          width: widget.isSelected ? 3 : 2,
        ),
      ),
      child: Row(
        children: [
          // 🔊 오디오 재생 버튼 (왼쪽)
          GestureDetector(
            onTap: _playAudio,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(
                _isPlaying ? Icons.volume_up : Icons.volume_off,
                color: _isPlaying ? Colors.blue : Colors.grey.shade600,
                size: 32,
              ),
            ),
          ),
          
          // 세로 구분선
          Container(
            width: 2,
            height: 80,
            color: Colors.grey.shade300,
          ),
          
          // 레이블 + 선택 영역 (오른쪽)
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                height: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.option.label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
