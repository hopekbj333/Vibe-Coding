import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, unawaited;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../core/services/tts_service.dart';
import '../../../../../core/services/audio_playback_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/constants/audio_constants.dart';
import '../../../../../core/constants/asset_paths.dart';
import '../../providers/story_assessment_provider.dart';
import '../../../data/models/story_assessment_model.dart';
import '../../../../training/data/models/training_content_model.dart';
import '../../../data/services/instruction_sequence_loader_service.dart';
import '../../../domain/services/instruction_sequence_executor.dart';
import '../../widgets/story/story_question_widget.dart';

// #region agent log
Future<void> _debugLog(String location, String message, Map<String, dynamic> data, {String? hypothesisId}) async {
  try {
    final logEntry = {
      'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      'data': data,
      'sessionId': 'debug-session',
      'runId': 'run1',
      if (hypothesisId != null) 'hypothesisId': hypothesisId,
    };
    final logJson = jsonEncode(logEntry);
    
    // 웹에서는 파일 시스템 접근 불가 - print만 사용
    if (kIsWeb) {
      print('DEBUG: $logJson');
      return;
    }
    
    // 네이티브 플랫폼에서만 파일 로그
    try {
      final logPath = r'c:\dev\literacy-assessment\.cursor\debug.log';
      final file = File(logPath);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      await file.writeAsString('$logJson\n', mode: FileMode.append);
    } catch (e) {
      // 파일 로그 실패 시 print로 fallback
      print('DEBUG: $logJson');
    }
  } catch (e) {
    // 로그 실패해도 프로그램은 계속 진행 (print로 fallback)
    print('⚠️ Debug log failed: $e');
  }
}

// #endregion

/// 스토리 문항 페이지
/// 스토리 맥락과 함께 문항을 제시
class StoryQuestionPage extends ConsumerStatefulWidget {
  final String childId;
  final String childName;

  const StoryQuestionPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  ConsumerState<StoryQuestionPage> createState() => _StoryQuestionPageState();
}

class _StoryQuestionPageState extends ConsumerState<StoryQuestionPage> {
  DateTime? _questionStartTime;
  String? _selectedAnswer;
  String? _lastQuestionId;
  final AudioPlaybackService _audioPlaybackService = AudioPlaybackService();
  final TtsService _ttsService = TtsService();
  final InstructionSequenceLoaderService _sequenceLoader = InstructionSequenceLoaderService();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _audioPlaybackService.dispose();
    super.dispose();
  }

  /// 문항 오디오 재생 (오디오 파일만)
  /// 
  /// AudioPlaybackService를 사용하여 재생하며,
  /// 상태 관리를 위해 콜백을 통해 _isPlayingAudio를 업데이트합니다.
  Future<void> _playQuestionAudio(String? audioPath) async {
    // #region agent log
    await _debugLog('story_question_page.dart:50', '오디오 재생 함수 진입', {'audioPath': audioPath}, hypothesisId: 'H1');
    // #endregion
    
    if (audioPath == null || audioPath.isEmpty) {
      // #region agent log
      await _debugLog('story_question_page.dart:53', '오디오 경로가 비어있음', {}, hypothesisId: 'H1');
      // #endregion
      AppLogger.warning('오디오 경로가 비어있습니다');
      throw Exception('오디오 경로가 비어있습니다');
    }

    // #region agent log
    await _debugLog('story_question_page.dart:63', '오디오 재생 시작', {'audioPath': audioPath, 'isPlayingAudioBefore': _isPlayingAudio}, hypothesisId: 'H4');
    // #endregion

    try {
      // AudioPlaybackService를 사용하여 재생
      // 상태 변경은 콜백으로 처리
      await _audioPlaybackService.playAsset(
        audioPath,
        onStateChanged: (isPlaying) {
          if (mounted) {
            setState(() => _isPlayingAudio = isPlaying);
          }
        },
      );
      
      // #region agent log
      await _debugLog('story_question_page.dart:101', '오디오 재생 완료', {'audioPath': audioPath}, hypothesisId: 'H4');
      // #endregion
    } catch (e, stackTrace) {
      // #region agent log
      await _debugLog('story_question_page.dart:106', '오디오 재생 실패', {'audioPath': audioPath, 'error': e.toString(), 'errorType': e.runtimeType.toString(), 'stackTrace': stackTrace.toString()}, hypothesisId: 'H1');
      // #endregion
      
      // 오디오 파일이 없어도 계속 진행 (TTS만으로도 충분)
      // 에러를 다시 throw하여 호출자가 인지할 수 있도록 함
      rethrow;
    }
  }

  /// 전체 안내 시퀀스: JSON 기반 실행
  Future<void> _playFullInstructionSequence(StoryQuestion storyQuestion) async {
    AppLogger.sequence('_playFullInstructionSequence 호출됨', data: {
      'questionId': storyQuestion.questionId,
      'isPlayingAudio': _isPlayingAudio,
    });
    
    // 중복 재생 방지: 이미 오디오 재생 중이면 무시 (TTS는 별도 관리)
    if (_isPlayingAudio) {
      AppLogger.warning('이미 오디오 재생 중이므로 안내 시퀀스 건너뜀');
      return;
    }
    
    // #region agent log
    await _debugLog('story_question_page.dart:88', '안내 시퀀스 시작 (JSON 기반)', {'questionId': storyQuestion.questionId, 'audioPath': storyQuestion.questionAudioPath}, hypothesisId: 'H1');
    // #endregion
    
    try {
      AppLogger.sequence('JSON 기반 안내 시퀀스 시작');
      
      // 문항 번호 가져오기 (session에서)
      final sessionState = ref.read(currentStorySessionProvider);
      final session = sessionState.session;
      if (session == null) {
        AppLogger.error('세션이 없습니다');
        return;
      }
      
      final questionNumber = session.progress.completedQuestions.length + 1;
      AppLogger.sequence('문항 번호 계산', data: {
        'questionNumber': questionNumber,
        'completedQuestionsLength': session.progress.completedQuestions.length,
      });
      
      // JSON에서 시퀀스 로드
      AppLogger.sequence('JSON 파일에서 시퀀스 로드 시작', data: {
        'questionNumber': questionNumber,
      });
      final sequence = await _sequenceLoader.getSequenceForQuestion(questionNumber);
      if (sequence == null) {
        AppLogger.error('문항에 대한 시퀀스를 찾을 수 없습니다', data: {
          'questionNumber': questionNumber,
          'jsonPath': AssetPaths.instructionSequences,
        });
        return;
      }
      
      AppLogger.success('시퀀스 로드 완료', data: {
        'stepCount': sequence.steps.length,
      });
      for (int i = 0; i < sequence.steps.length; i++) {
        final step = sequence.steps[i];
        AppLogger.debug('Step 정보', data: {
          'stepNumber': i + 1,
          'action': step.action,
          'params': step.params,
        });
      }
      
      // 실행 엔진 생성 및 실행
      AppLogger.debug('실행 엔진 생성');
      final executor = InstructionSequenceExecutor(
        ttsService: _ttsService,
        audioPlayer: _audioPlayer,
        playQuestionAudio: _playQuestionAudio,
      );
      
      AppLogger.sequence('시퀀스 실행 시작');
      await executor.executeSequence(sequence, storyQuestion);
      AppLogger.success('시퀀스 실행 완료');
      
      // #region agent log
      await _debugLog('story_question_page.dart:122', '안내 시퀀스 완료 (JSON 기반)', {}, hypothesisId: 'H1');
      // #endregion
    } catch (e, stackTrace) {
      // #region agent log
      await _debugLog('story_question_page.dart:125', '안내 시퀀스 실패', {'error': e.toString(), 'stackTrace': stackTrace.toString()}, hypothesisId: 'H4');
      // #endregion
      
      AppLogger.error(
        '오디오 시퀀스 재생 실패',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow; // 에러를 다시 던져서 호출자가 인지할 수 있도록
    }
  }


  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(currentStorySessionProvider);
    final session = sessionState.session;

    if (session == null || sessionState.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('문항을 준비하고 있어요...'),
            ],
          ),
        ),
      );
    }

    final currentQuestion = session.currentQuestion;
    
    // 문항이 바뀌었는지 확인하고 초기화
    AppLogger.debug('문항 체크', data: {
      'currentQuestionId': currentQuestion?.questionId,
      'lastQuestionId': _lastQuestionId,
    });
    if (currentQuestion != null && 
        _lastQuestionId != currentQuestion.questionId) {
      AppLogger.success('문항 변경 감지', data: {
        'newQuestionId': currentQuestion.questionId,
      });
      
      // #region agent log
      // build() 메서드는 동기 메서드이므로 await 사용 불가
      // unawaited()를 사용하여 fire-and-forget 패턴으로 명시적으로 처리
      unawaited(_debugLog('story_question_page.dart:145', '새 문항 로드', {'questionId': currentQuestion.questionId, 'lastQuestionId': _lastQuestionId, 'audioPath': currentQuestion.questionAudioPath}, hypothesisId: 'H1'));
      // #endregion
      
      // 이전 안내 시퀀스가 재생 중이면 중지 (중복 재생 방지)
      AppLogger.debug('이전 오디오/TTS 중지');
      _ttsService.stop();
      _audioPlaybackService.stop();
      
      _lastQuestionId = currentQuestion.questionId;
      _questionStartTime = DateTime.now();
      _selectedAnswer = null;
      _isPlayingAudio = false;
      
      AppLogger.debug('_lastQuestionId 업데이트', data: {
        'lastQuestionId': _lastQuestionId,
        'isPlayingAudio': _isPlayingAudio,
      });
      
      // 전체 안내 시퀀스 자동 재생 (TTS 안내 → 오디오 → 다시 듣기 안내)
      // 약간의 딜레이를 주어 화면이 완전히 로드된 후 재생
      // 단, 이미 재생 중이면 재생하지 않음 (중복 방지)
      AppLogger.debug('addPostFrameCallback 등록');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLogger.debug('postFrameCallback 실행, 딜레이 시작');
        Future.delayed(AudioConstants.shortDelay, () {
          AppLogger.debug('300ms 딜레이 완료, 조건 체크 시작', data: {
            'mounted': mounted,
            'lastQuestionId': _lastQuestionId,
            'currentQuestionId': currentQuestion.questionId,
            'isPlayingAudio': _isPlayingAudio,
          });
          
          // 마운트 상태와 문항 ID를 다시 확인 (상태 변경 방지)
          if (mounted && 
              _lastQuestionId == currentQuestion.questionId &&
              !_isPlayingAudio) {
            AppLogger.success('조건 통과: _playFullInstructionSequence 호출 시작');
            _playFullInstructionSequence(currentQuestion);
          } else {
            AppLogger.warning('조건 실패: _playFullInstructionSequence 호출 안 함', data: {
              'mounted': mounted,
              'lastQuestionIdMatch': _lastQuestionId == currentQuestion.questionId,
              'isPlayingAudio': _isPlayingAudio,
            });
          }
        });
      });
    } else {
      if (currentQuestion == null) {
        AppLogger.warning('currentQuestion이 null입니다');
      } else if (_lastQuestionId == currentQuestion.questionId) {
        AppLogger.debug('문항이 변경되지 않음 (동일한 문항)');
      }
    }
    
    if (currentQuestion == null) {
      // 모든 문항 완료 또는 챕터 완료
      // 디버깅: 현재 상태 확인
      AppLogger.warning('currentQuestion is null', data: {
        'status': session.status.toString(),
        'chapterIndex': session.currentChapterIndex,
        'questionIndex': session.currentQuestionIndex,
        'currentChapterQuestions': session.currentChapter?.questions.length ?? 0,
        'totalChapters': session.chapters.length,
      });
      
      if (session.status == StoryProgressStatus.chapterComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacement(
              '/story/chapter-complete',
              extra: {
                'childId': widget.childId,
                'childName': widget.childName,
              },
            );
          }
        });
      } else if (session.status == StoryProgressStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacement(
              '/story/result',
              extra: {
                'childId': widget.childId,
                'childName': widget.childName,
              },
            );
          }
        });
      } else {
        // 예상치 못한 상태: 다음 문항으로 강제 이동 시도
        print('⚠️ Unexpected state: trying to move to next question');
        final currentChapter = session.currentChapter;
        if (currentChapter != null && 
            session.currentQuestionIndex < currentChapter.questions.length - 1) {
          // 다음 문항이 있는 경우 - 이는 버그이므로 로그만 남김
          print('   Next question should be available but currentQuestion is null');
        }
      }

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentChapter = session.currentChapter;
    final questionNumber = session.progress.completedQuestions.length + 1;
    final totalQuestions = session.totalQuestions;

    // 이전/다음 버튼 활성화 여부 확인
    final canGoPrevious = session.currentChapterIndex > 0 || 
                         session.currentQuestionIndex > 0;
    final canGoNext = (session.currentChapterIndex < session.chapters.length - 1) ||
                     (session.currentChapterIndex == session.chapters.length - 1 &&
                      session.currentQuestionIndex < (currentChapter?.questions.length ?? 0) - 1);

    return Scaffold(
      backgroundColor: _getChapterBackgroundColor(
        currentChapter?.type ?? StoryChapterType.phonologicalAwareness,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행률 바
            LinearProgressIndicator(
              value: session.progressRatio,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            // 문항 번호
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '문항 $questionNumber / $totalQuestions',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // 안내 문구 제거 (아동은 한글을 읽을 수 없으므로)
            // 음성만으로 안내 제공

            const SizedBox(height: 16),

            // 문항 위젯
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: StoryQuestionWidget(
                  storyQuestion: currentQuestion,
                  isPlayingAudio: _isPlayingAudio,
                  selectedAnswer: _selectedAnswer,
                  ttsService: _ttsService,
                  audioPlaybackService: _audioPlaybackService,
                  playQuestionAudio: _playQuestionAudio,
                  submitAnswer: (storyQuestion, answer) {
                    // 선택 상태 업데이트
                    setState(() {
                      _selectedAnswer = answer;
                    });
                    // 답변 제출
                    _submitAnswer(storyQuestion, answer);
                  },
                ),
              ),
            ),

            // 이전/다음 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 이전 버튼
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: canGoPrevious ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                    onPressed: canGoPrevious ? () {
                      // 오디오/TTS 중지
                      _ttsService.stop();
                      _audioPlaybackService.stop();
                      setState(() {
                        _isPlayingAudio = false;
                        _selectedAnswer = null;
                        _lastQuestionId = null; // 다음 문항 로드 시 안내 시퀀스 재생을 위해
                      });
                      ref.read(currentStorySessionProvider.notifier).moveToPreviousQuestion();
                    } : null,
                    tooltip: '이전 문항',
                  ),

                  // 다음 버튼
                  IconButton(
                    iconSize: 48,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: canGoNext ? Colors.white : Colors.white.withOpacity(0.3),
                    ),
                    onPressed: canGoNext ? () {
                      // 오디오/TTS 중지
                      _ttsService.stop();
                      _audioPlaybackService.stop();
                      setState(() {
                        _isPlayingAudio = false;
                        _selectedAnswer = null;
                        _lastQuestionId = null; // 다음 문항 로드 시 안내 시퀀스 재생을 위해
                      });
                      ref.read(currentStorySessionProvider.notifier).moveToNextQuestion();
                    } : null,
                    tooltip: '다음 문항',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _submitAnswer(StoryQuestion storyQuestion, String userAnswer) {
    if (_questionStartTime == null) return;

    final responseTimeMs =
        DateTime.now().difference(_questionStartTime!).inMilliseconds;

    // 답변 제출
    ref.read(currentStorySessionProvider.notifier).submitAnswer(
          questionId: storyQuestion.questionId,
          userAnswer: userAnswer,
          responseTimeMs: responseTimeMs,
        );

    // 피드백 페이지 없이 바로 다음 문항으로 이동 (또는 챕터/결과 페이지로)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 세션이 업데이트되었으므로 잠시 대기 후 상태 확인
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          
          final session = ref.read(currentStorySessionProvider).session;
          
          // 챕터 완료 또는 전체 완료
          if (session?.status == StoryProgressStatus.chapterComplete) {
            context.pushReplacement(
              '/story/chapter-complete',
              extra: {
                'childId': widget.childId,
                'childName': widget.childName,
              },
            );
            return;
          } else if (session?.status == StoryProgressStatus.completed) {
            // 결과 페이지로 이동 (accuracy, totalStars, completedCount 제거)
            context.pushReplacement(
              '/story/result',
              extra: {
                'childId': widget.childId,
                'childName': widget.childName,
              },
            );
            return;
          }
          
          // 피드백 페이지는 사용하지 않음 - 바로 다음 문항으로 이동
          // 세션이 업데이트되면 자동으로 다시 빌드되어 다음 문항이 표시됨
          // 아무것도 하지 않음 (페이지가 자동으로 다시 빌드됨)
        });
      }
    });
  }

  Color _getChapterBackgroundColor(StoryChapterType type) {
    switch (type) {
      case StoryChapterType.phonologicalAwareness:
        return const Color(0xFF4CAF50); // 초록색 (소리 섬)
      case StoryChapterType.phonologicalProcessing:
        return const Color(0xFF2196F3); // 파란색 (기억 바다)
    }
  }
}

