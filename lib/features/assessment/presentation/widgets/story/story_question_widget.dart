import 'package:flutter/material.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/audio_playback_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/audio_constants.dart';
import '../../../data/models/story_assessment_model.dart';
import '../../../../training/data/models/training_content_model.dart';

/// 스토리 문항 위젯
/// 
/// 문항을 표시하고 사용자 입력을 받는 위젯
/// 1-2번 문항의 특수 로직이 포함되어 있음 (수정 금지)
class StoryQuestionWidget extends StatefulWidget {
  final StoryQuestion storyQuestion;
  final bool isPlayingAudio;
  final String? selectedAnswer;
  final TtsService ttsService;
  final AudioPlaybackService audioPlaybackService;
  final Future<void> Function(String?) playQuestionAudio;
  final void Function(StoryQuestion, String) submitAnswer;

  const StoryQuestionWidget({
    super.key,
    required this.storyQuestion,
    required this.isPlayingAudio,
    required this.selectedAnswer,
    required this.ttsService,
    required this.audioPlayer,
    required this.playQuestionAudio,
    required this.submitAnswer,
  });

  @override
  State<StoryQuestionWidget> createState() => _StoryQuestionWidgetState();
}

class _StoryQuestionWidgetState extends State<StoryQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    final question = widget.storyQuestion.question;

    // 보기가 있는 경우
    if (question.options.isNotEmpty) {
      return _buildOptionsQuestion(question);
    }

    // 보기가 없는 경우 (rhythmTap, recording 등)
    if (question.pattern == GamePattern.rhythmTap && 
        question.correctAnswer.isNotEmpty) {
      return _buildRhythmTapQuestion(question);
    }
    
    // 보기가 없고 패턴 변환도 안 된 경우 자동 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 약간의 딜레이 후 자동 제출 (사용자가 스토리 맥락을 읽을 시간 제공)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.submitAnswer(widget.storyQuestion, question.correctAnswer);
        }
      });
    });

    return _buildDefaultQuestion(question);
  }

  /// 보기가 있는 문항 (객관식)
  Widget _buildOptionsQuestion(QuestionModel question) {
    // 오디오 재생 버튼 (다시 들을 수 있도록)
    // 2번 문항은 options의 audioPath 사용, 나머지는 questionAudioPath 사용
    final hasAudio = widget.storyQuestion.abilityId == '0.2'
        ? widget.storyQuestion.question.options.any((opt) => opt.audioPath != null && opt.audioPath!.isNotEmpty)
        : (widget.storyQuestion.questionAudioPath != null && widget.storyQuestion.questionAudioPath!.isNotEmpty);
    
    return Column(
      children: [
        // 오디오 재생 버튼
        if (hasAudio)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: IconButton(
              iconSize: 64,
              icon: Icon(
                widget.isPlayingAudio ? Icons.volume_up : Icons.volume_down,
                color: widget.isPlayingAudio ? Colors.green : Colors.grey,
              ),
              onPressed: widget.isPlayingAudio ? null : () async {
                // ⚠️ 2번 문항 특수 로직 (수정 금지)
                if (widget.storyQuestion.abilityId == '0.2') {
                  AppLogger.audio('2번 문항 오디오 시퀀스 재생 시작');
                  
                  // TTS 서비스 초기화 확인
                  await widget.ttsService.initialize();
                  
                  final audioOptions = widget.storyQuestion.question.options
                      .where((opt) => opt.audioPath != null && opt.audioPath!.isNotEmpty)
                      .toList();
                  
                  AppLogger.debug('재생할 오디오 개수', data: {
                    'count': audioOptions.length,
                  });
                  
                  for (int i = 0; i < audioOptions.length; i++) {
                    final audioPath = audioOptions[i].audioPath!;
                    
                    // 각 오디오 재생 전에 TTS 멘트 추가
                    final ttsText = i == 0 ? '첫 번째 소리입니다.' : '두 번째 소리입니다.';
                    AppLogger.tts('${i + 1}번째 오디오 전 TTS 시작', data: {
                      'ttsText': ttsText,
                    });
                    
                    try {
                      final ttsStartTime = DateTime.now();
                      await widget.ttsService.speak(ttsText);
                      final ttsDuration = DateTime.now().difference(ttsStartTime).inMilliseconds;
                      AppLogger.success('${i + 1}번째 오디오 전 TTS 완료', data: {
                        'durationMs': ttsDuration,
                      });
                    } catch (e, stackTrace) {
                      AppLogger.error(
                        'TTS 재생 실패',
                        error: e,
                        stackTrace: stackTrace,
                      );
                      // TTS 실패해도 오디오는 재생
                    }
                    
                    // 오디오 재생
                    AppLogger.audio('소리${i + 1} 재생 시작', data: {
                      'audioPath': audioPath,
                    });
                    try {
                      await widget.playQuestionAudio(audioPath);
                      AppLogger.success('소리${i + 1} 재생 완료');
                    } catch (e, stackTrace) {
                      AppLogger.error(
                        '오디오 재생 실패',
                        error: e,
                        stackTrace: stackTrace,
                        data: {'audioPath': audioPath},
                      );
                      // 계속 진행
                    }
                    
                    // 마지막이 아니면 딜레이
                    if (i < audioOptions.length - 1) {
                      AppLogger.delay('다음 소리 전 딜레이', data: {
                        'ms': AudioConstants.audioSequenceDelayMs,
                      });
                      await Future.delayed(AudioConstants.audioSequenceDelay);
                    }
                  }
                  
                  AppLogger.success('모든 오디오 재생 완료');
                } else {
                  // 기타 문항: 단일 오디오 재생
                  await widget.playQuestionAudio(widget.storyQuestion.questionAudioPath!);
                }
              },
            ),
          ),
        
        const SizedBox(height: 16),

        // 보기 버튼들
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final option = question.options[index];
              final isSelected = widget.selectedAnswer == option.optionId;

              return ElevatedButton(
                onPressed: () {
                  // 선택 상태는 부모 위젯에서 관리하므로 여기서는 바로 제출
                  widget.submitAnswer(widget.storyQuestion, option.optionId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade200,
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (option.imagePath != null)
                      Image.asset(
                        option.imagePath!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 120);
                        },
                      )
                    else
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 리듬 탭 문항 (음절 개수 선택)
  Widget _buildRhythmTapQuestion(QuestionModel question) {
    // 정답이 숫자인 경우 (음절 개수)
    try {
      int.parse(question.correctAnswer); // 정답 검증용 (사용 안 함)
      // 1~5개 음절 선택지 생성
      final syllableOptions = List.generate(5, (i) => i + 1);
      
      return Column(
        children: [
          // 스피커 버튼 (항상 표시 - 3번 문항은 항상 '나비' 소리 재생)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: IconButton(
              iconSize: 64,
              icon: Icon(
                widget.isPlayingAudio ? Icons.volume_up : Icons.volume_down,
                color: widget.isPlayingAudio ? Colors.green : Colors.grey,
              ),
              onPressed: widget.isPlayingAudio ? null : () async {
                // 스피커 버튼 클릭 시 '나비' 소리 재생 (3번 문항 전용)
                AppLogger.audio('스피커 버튼 클릭: 나비 소리 재생 시작', data: {
                  'question': question.question,
                  'questionAudioPath': widget.storyQuestion.questionAudioPath,
                });
                
                // 이전 오디오 정리
                await widget.audioPlaybackService.stop();
                
                final audioPath = widget.storyQuestion.questionAudioPath;
                bool audioPlayed = false;
                
                // 오디오 재생 시도
                if (audioPath != null && audioPath.isNotEmpty) {
                  try {
                    AppLogger.audio('오디오 재생 시도', data: {'audioPath': audioPath});
                    await widget.playQuestionAudio(audioPath);
                    AppLogger.success('오디오 재생 완료');
                    audioPlayed = true;
                  } catch (e, stackTrace) {
                    AppLogger.warning('오디오 재생 실패', data: {'error': e.toString()});
                    // 오디오 재생 실패 시 TTS로 대체
                  }
                }
                
                // 오디오 재생 실패하거나 경로가 없으면 TTS로 재생
                if (!audioPlayed) {
                  AppLogger.tts('TTS로 나비 읽기', data: {'question': question.question});
                  await widget.ttsService.speak(question.question);
                }
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 음절 개수 선택 버튼들
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: syllableOptions.length,
              itemBuilder: (context, index) {
                final count = syllableOptions[index];
                final isSelected = widget.selectedAnswer == count.toString();
                
                return ElevatedButton(
                  onPressed: () {
                    widget.submitAnswer(widget.storyQuestion, count.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade200,
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '개',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    } catch (e) {
      // 숫자 파싱 실패 시 자동 처리
      return _buildDefaultQuestion(question);
    }
  }

  /// 기본 문항 (보기 없음)
  Widget _buildDefaultQuestion(QuestionModel question) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 게임 패턴에 따른 안내
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  '이 문항은 자동으로 처리됩니다.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '패턴: ${question.pattern}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
