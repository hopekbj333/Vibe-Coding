import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../core/services/tts_service.dart';
import '../../providers/story_assessment_provider.dart';
import '../../../data/models/story_assessment_model.dart';
import '../../../../training/data/models/training_content_model.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TtsService _ttsService = TtsService();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// 오디오 파일 존재 여부 확인
  Future<bool> _checkAudioFileExists(String audioPath) async {
    try {
      // rootBundle.load는 'assets/' 접두사를 제외한 경로를 받습니다
      // audioPath가 'audio/pitch/long1.mp3' 형태이면 그대로 사용
      // audioPath가 'assets/audio/pitch/long1.mp3' 형태이면 'assets/'를 제거
      final bundlePath = audioPath.startsWith('assets/') 
          ? audioPath.substring(7) // 'assets/'.length = 7
          : audioPath;
      print('🔍 파일 존재 확인: bundlePath=$bundlePath (원본: $audioPath)');
      
      await rootBundle.load(bundlePath);
      print('✅ 파일 존재 확인 성공: $bundlePath');
      return true;
    } catch (e) {
      print('❌ 오디오 파일 존재 확인 실패: $audioPath -> $e');
      // Web에서는 파일 확인이 실패해도 재생은 시도해봄
      return false;
    }
  }

  /// 문항 오디오 재생 (오디오 파일만)
  Future<void> _playQuestionAudio(String? audioPath) async {
    // #region agent log
    await _debugLog('story_question_page.dart:50', '오디오 재생 함수 진입', {'audioPath': audioPath}, hypothesisId: 'H1');
    // #endregion
    
    if (audioPath == null || audioPath.isEmpty) {
      // #region agent log
      await _debugLog('story_question_page.dart:53', '오디오 경로가 비어있음', {}, hypothesisId: 'H1');
      // #endregion
      print('⚠️ 오디오 경로가 비어있습니다');
      throw Exception('오디오 경로가 비어있습니다');
    }

    // 파일 존재 여부 확인 (Web에서는 체크가 불완전할 수 있으므로 항상 재생 시도)
    final fileExists = await _checkAudioFileExists(audioPath);
    if (!fileExists) {
      print('⚠️ 오디오 파일 존재 확인 실패했지만 재생 시도: $audioPath');
      // Web에서는 파일 존재 확인이 불완전할 수 있으므로 재생을 시도해봅니다
    } else {
      print('✅ 오디오 파일 존재 확인 성공: $audioPath');
    }

    // #region agent log
    await _debugLog('story_question_page.dart:63', '오디오 재생 시작', {'audioPath': audioPath, 'isPlayingAudioBefore': _isPlayingAudio}, hypothesisId: 'H4');
    // #endregion
    
    // 이전 오디오 정리 (중복 재생 방지)
    await _audioPlayer.stop();
    
    // 볼륨 통일 설정 (0.0 ~ 1.0, 0.7로 설정하여 적당한 크기)
    await _audioPlayer.setVolume(0.7);
    
    setState(() => _isPlayingAudio = true);

    try {
      // audio_option_button 패턴 사용: AssetSource는 'assets/' 접두사를 제외하고 경로를 받습니다
      // 예: 'audio/environment/rain.mp3' (assets/ 제외)
      final assetSource = AssetSource(audioPath);
      
      // #region agent log
      await _debugLog('story_question_page.dart:73', 'AssetSource 생성 완료', {'audioPath': audioPath}, hypothesisId: 'H2');
      // #endregion
      
      print('🔊 AssetSource 생성: $audioPath');
      
      // #region agent log
      await _debugLog('story_question_page.dart:77', '오디오 재생 명령 전송 전', {'audioPath': audioPath}, hypothesisId: 'H3');
      // #endregion
      
      // play() 호출
      print('🔊 오디오 재생 시작: $audioPath (AssetSource: $assetSource)');
      await _audioPlayer.play(assetSource);
      
      // #region agent log
      await _debugLog('story_question_page.dart:83', '오디오 재생 명령 전송 완료, 완료 이벤트 대기 중', {'audioPath': audioPath}, hypothesisId: 'H3');
      // #endregion
      
      print('🔊 오디오 재생 중... (경로: $audioPath)');
      
      // audio_option_button 패턴: 재생 완료 이벤트 대기
      // 오디오 재생이 실제로 완료될 때까지 기다림
      try {
        // onPlayerComplete 이벤트가 발생할 때까지 기다림 (최대 15초)
        await _audioPlayer.onPlayerComplete.first.timeout(
          const Duration(seconds: 15),
        );
        print('✅ 오디오 재생 완료 이벤트 수신');
      } on TimeoutException {
        print('⚠️ 오디오 재생 완료 이벤트 타임아웃 (15초 경과) - 재생 상태 확인');
        // #region agent log
        await _debugLog('story_question_page.dart:92', '오디오 재생 완료 이벤트 타임아웃', {'audioPath': audioPath}, hypothesisId: 'H1');
        // #endregion
        
        // 타임아웃 발생 시 재생 상태 확인
        try {
          final state = _audioPlayer.state;
          print('🔍 현재 재생 상태: $state');
          // 재생 중이면 완료될 때까지 추가 대기
          if (state == PlayerState.playing) {
            print('⏳ 재생 중이므로 완료될 때까지 추가 대기...');
            await _audioPlayer.onPlayerComplete.first.timeout(
              const Duration(seconds: 10),
            );
            print('✅ 추가 대기 후 오디오 재생 완료');
          }
        } catch (e) {
          print('⚠️ 재생 상태 확인 중 오류: $e');
        }
      } catch (e) {
        print('⚠️ 오디오 재생 완료 대기 중 오류: $e');
        // #region agent log
        await _debugLog('story_question_page.dart:98', '오디오 재생 완료 대기 중 예외', {'audioPath': audioPath, 'error': e.toString()}, hypothesisId: 'H1');
        // #endregion
      }
      
      // #region agent log
      await _debugLog('story_question_page.dart:101', '오디오 재생 완료', {'audioPath': audioPath}, hypothesisId: 'H4');
      // #endregion
      
      print('🔊 오디오 재생 완료');
    } catch (e, stackTrace) {
      // #region agent log
      await _debugLog('story_question_page.dart:106', '오디오 재생 실패', {'audioPath': audioPath, 'error': e.toString(), 'errorType': e.runtimeType.toString(), 'stackTrace': stackTrace.toString()}, hypothesisId: 'H1');
      // #endregion
      
      print('❌ 오디오 재생 실패: $audioPath');
      print('에러 타입: ${e.runtimeType}');
      print('에러: $e');
      print('스택: $stackTrace');
      // 오디오 파일이 없어도 계속 진행 (TTS만으로도 충분)
      // 에러를 다시 throw하여 호출자가 인지할 수 있도록 함
      rethrow;
    } finally {
      if (mounted) {
        // #region agent log
        await _debugLog('story_question_page.dart:118', '오디오 재생 함수 종료', {'isPlayingAudioAfter': false}, hypothesisId: 'H4');
        // #endregion
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  /// 전체 안내 시퀀스: TTS 안내 → 오디오 재생 → 다시 듣기 안내
  Future<void> _playFullInstructionSequence(StoryQuestion storyQuestion) async {
    // 중복 재생 방지: 이미 재생 중이면 무시
    if (_isPlayingAudio) {
      print('⚠️ 이미 오디오 재생 중이므로 안내 시퀀스 건너뜀');
      return;
    }
    
    // #region agent log
    await _debugLog('story_question_page.dart:88', '안내 시퀀스 시작', {'questionId': storyQuestion.questionId, 'audioPath': storyQuestion.questionAudioPath}, hypothesisId: 'H1');
    // #endregion
    
    try {
      print('🎵 시작: 전체 안내 시퀀스');
      
      // TTS 초기화 확인
      await _ttsService.initialize();
      
      // #region agent log
      await _debugLog('story_question_page.dart:96', 'TTS 초기화 완료', {}, hypothesisId: 'H5');
      // #endregion
      
      // 2번 문항(abilityId '0.2': 소리 크기/높이 변별) 특별 처리
      if (storyQuestion.abilityId == '0.2') {
        print('🎵 2번 문항 (소리 크기/높이 변별) 처리');
        
        // 이전 오디오 정리 (이전 문항의 오디오가 남아있을 수 있음)
        await _audioPlayer.stop();
        _isPlayingAudio = false;
        
        // 1. 안내 멘트 (TTS) - 완료될 때까지 대기
        print('🎵 1단계: TTS 안내 시작');
        await _ttsService.speak('이제 두 가지의 소리를 들려 주겠습니다. 두 가지 중에서 어떤 소리가 더 긴지, 긴 소리를 화면에서 선택해 주세요.');
        print('🎵 1단계 완료 - TTS 완료 확인됨');
        
        // 안내 멘트가 완전히 끝나고 1초 대기
        await Future.delayed(const Duration(seconds: 1));
        
        // 2. options에서 audioPath가 있는 소리들을 순차적으로 재생
        final question = storyQuestion.question;
        print('🔍 2번 문항 options 확인: ${question.options.length}개');
        for (var opt in question.options) {
          print('  - optionId: ${opt.optionId}, audioPath: ${opt.audioPath}, audioPath==null: ${opt.audioPath == null}, isEmpty: ${opt.audioPath?.isEmpty ?? true}');
        }
        
        final audioOptions = question.options.where((opt) {
          final hasAudioPath = opt.audioPath != null && opt.audioPath!.isNotEmpty;
          print('🔍 필터링: optionId=${opt.optionId}, audioPath=${opt.audioPath}, hasAudioPath=$hasAudioPath');
          return hasAudioPath;
        }).toList();
        print('🔍 audioPath가 있는 options: ${audioOptions.length}개');
        
        if (audioOptions.isNotEmpty) {
          print('🎵 2단계: 순차 오디오 재생 시작 (${audioOptions.length}개)');
          
          // 각 오디오를 순차적으로 재생 (완전히 끝날 때까지 기다림)
          for (int i = 0; i < audioOptions.length; i++) {
            final option = audioOptions[i];
            final audioPath = option.audioPath!;
            
            print('🎵 소리${i + 1} 재생 시작: audioPath=$audioPath, optionId=${option.optionId}');
            
            try {
              // 오디오 재생 (완료될 때까지 대기)
              await _playQuestionAudio(audioPath);
              print('✅ 소리${i + 1} 재생 완료: $audioPath');
              
              // 소리가 끝나고 1초 대기 (마지막 소리가 아닌 경우)
              if (i < audioOptions.length - 1) {
                print('⏳ 다음 소리 재생 전 1초 대기...');
                await Future.delayed(const Duration(seconds: 1));
              }
            } catch (e, stackTrace) {
              print('❌ 소리${i + 1} 재생 실패: $audioPath');
              print('❌ 에러: $e');
              print('❌ 스택: $stackTrace');
              // 계속 진행 (다음 오디오 시도)
            }
          }
          
          print('🎵 2단계 완료 - 모든 오디오 재생 완료');
          
          // 모든 오디오 재생이 끝나고 1초 대기 후 스피커 멘트
          print('⏳ 스피커 멘트 전 1초 대기...');
          await Future.delayed(const Duration(seconds: 1));
        } else {
          print('⚠️ 재생할 오디오가 없습니다. options 개수: ${question.options.length}');
        }
        
        // 3. 다시 듣기 안내 (TTS) - 모든 소리가 끝난 후에만 재생
        print('🎵 3단계: 다시 듣기 안내 시작');
        await _ttsService.speak('소리를 다시 듣고 싶으면 스피커 모양을 누르세요');
        print('🎵 3단계 완료 - 전체 시퀀스 완료');
        
        // 2번 문항 처리 완료 - else 블록 실행 방지
        return;
      } else {
        // 1번 문항 및 기타 문항 처리 (기존 로직)
        // 1. 문항 안내 (TTS)
        print('🎵 1단계: TTS 안내 시작');
        await _ttsService.speak('무슨 소리인지 맞춰보세요');
        
        // #region agent log
        await _debugLog('story_question_page.dart:101', 'TTS 1단계 완료', {}, hypothesisId: 'H5');
        // #endregion
        
        print('🎵 1단계 완료');
        
        // 안내 멘트가 끝나고 1초 대기
        await Future.delayed(const Duration(seconds: 1));
        
        // 2. 오디오 재생 (비 소리 등)
        // #region agent log
        await _debugLog('story_question_page.dart:107', '오디오 경로 확인', {'questionAudioPath': storyQuestion.questionAudioPath, 'isNull': storyQuestion.questionAudioPath == null, 'isEmpty': storyQuestion.questionAudioPath?.isEmpty ?? true}, hypothesisId: 'H1');
        // #endregion
        
        if (storyQuestion.questionAudioPath != null && 
            storyQuestion.questionAudioPath!.isNotEmpty) {
          print('🎵 2단계: 오디오 재생 시작 - ${storyQuestion.questionAudioPath}');
          try {
            // 오디오 재생을 완료할 때까지 기다림 (_playQuestionAudio가 완료되면 오디오도 끝난 상태)
            await _playQuestionAudio(storyQuestion.questionAudioPath);
            print('🎵 2단계 완료 - 오디오 재생 완료');
            
            // 오디오 재생이 완전히 끝난 후 1초 대기
            await Future.delayed(const Duration(seconds: 1));
            print('🎵 오디오 완료 후 1초 대기 완료');
          } catch (e) {
            // #region agent log
            await _debugLog('story_question_page.dart:113', '오디오 재생 실패 (시퀀스 계속 진행)', {'audioPath': storyQuestion.questionAudioPath, 'error': e.toString()}, hypothesisId: 'H1');
            // #endregion
            print('⚠️ 오디오 재생 실패, TTS만으로 진행: ${storyQuestion.questionAudioPath}');
            print('에러: $e');
            // 오디오 재생 실패해도 시퀀스는 계속 진행 (TTS만으로도 충분)
          }
        } else {
          // #region agent log
          await _debugLog('story_question_page.dart:113', '오디오 경로 없음', {'questionAudioPath': storyQuestion.questionAudioPath}, hypothesisId: 'H1');
          // #endregion
          print('⚠️ 오디오 경로가 없습니다: ${storyQuestion.questionAudioPath}');
        }
        
        // 3. 다시 듣기 안내 (TTS)
        print('🎵 3단계: 다시 듣기 안내 시작');
        await _ttsService.speak('다시 듣고 싶으면 아래 스피커 버튼을 눌러주세요');
        print('🎵 3단계 완료 - 전체 시퀀스 완료');
      }
      
      // #region agent log
      await _debugLog('story_question_page.dart:122', '안내 시퀀스 완료', {}, hypothesisId: 'H1');
      // #endregion
    } catch (e, stackTrace) {
      // #region agent log
      await _debugLog('story_question_page.dart:125', '안내 시퀀스 실패', {'error': e.toString(), 'stackTrace': stackTrace.toString()}, hypothesisId: 'H4');
      // #endregion
      
      print('❌ 오디오 시퀀스 재생 실패: $e');
      print('스택: $stackTrace');
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
    if (currentQuestion != null && 
        _lastQuestionId != currentQuestion.questionId) {
      // #region agent log
      // build() 메서드는 동기 메서드이므로 await 사용 불가
      _debugLog('story_question_page.dart:145', '새 문항 로드', {'questionId': currentQuestion.questionId, 'lastQuestionId': _lastQuestionId, 'audioPath': currentQuestion.questionAudioPath}, hypothesisId: 'H1');
      // #endregion
      
      // 이전 안내 시퀀스가 재생 중이면 중지 (중복 재생 방지)
      _ttsService.stop();
      _audioPlayer.stop();
      
      _lastQuestionId = currentQuestion.questionId;
      _questionStartTime = DateTime.now();
      _selectedAnswer = null;
      _isPlayingAudio = false;
      
      // 전체 안내 시퀀스 자동 재생 (TTS 안내 → 오디오 → 다시 듣기 안내)
      // 약간의 딜레이를 주어 화면이 완전히 로드된 후 재생
      // 단, 이미 재생 중이면 재생하지 않음 (중복 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          // 마운트 상태와 문항 ID를 다시 확인 (상태 변경 방지)
          if (mounted && 
              _lastQuestionId == currentQuestion.questionId &&
              !_isPlayingAudio) {
            _playFullInstructionSequence(currentQuestion);
          }
        });
      });
    }
    
    if (currentQuestion == null) {
      // 모든 문항 완료 또는 챕터 완료
      // 디버깅: 현재 상태 확인
      print('⚠️ currentQuestion is null. Status: ${session.status}, ChapterIndex: ${session.currentChapterIndex}, QuestionIndex: ${session.currentQuestionIndex}');
      print('   Current chapter questions: ${session.currentChapter?.questions.length ?? 0}');
      print('   Total chapters: ${session.chapters.length}');
      
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
                child: _buildQuestionWidget(currentQuestion),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(StoryQuestion storyQuestion) {
    final question = storyQuestion.question;

    // 보기가 있는 경우
    if (question.options.isNotEmpty) {
      // 오디오 재생 버튼 (다시 들을 수 있도록)
      // 2번 문항은 options의 audioPath 사용, 나머지는 questionAudioPath 사용
      final hasAudio = storyQuestion.abilityId == '0.2'
          ? storyQuestion.question.options.any((opt) => opt.audioPath != null && opt.audioPath!.isNotEmpty)
          : (storyQuestion.questionAudioPath != null && storyQuestion.questionAudioPath!.isNotEmpty);
      
      return Column(
        children: [
          // 질문 텍스트 제거 (아동은 한글을 읽을 수 없으므로)
          // 오디오만 재생
          
          // 오디오 재생 버튼
          if (hasAudio)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: IconButton(
                iconSize: 64,
                icon: Icon(
                  _isPlayingAudio ? Icons.volume_up : Icons.volume_down,
                  color: _isPlayingAudio ? Colors.green : Colors.grey,
                ),
                onPressed: _isPlayingAudio ? null : () async {
                  // 2번 문항: options의 오디오들을 순차 재생
                  if (storyQuestion.abilityId == '0.2') {
                    final audioOptions = storyQuestion.question.options
                        .where((opt) => opt.audioPath != null && opt.audioPath!.isNotEmpty)
                        .toList();
                    
                    for (int i = 0; i < audioOptions.length; i++) {
                      final audioPath = audioOptions[i].audioPath!;
                      await _playQuestionAudio(audioPath);
                      if (i < audioOptions.length - 1) {
                        await Future.delayed(const Duration(seconds: 1));
                      }
                    }
                  } else {
                    // 기타 문항: 단일 오디오 재생
                    await _playQuestionAudio(storyQuestion.questionAudioPath!);
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
                childAspectRatio: 1.0, // 이미지 크기를 키웠으므로 비율 조정
              ),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _selectedAnswer == option.optionId;

                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedAnswer = option.optionId;
                    });
                    _submitAnswer(storyQuestion, option.optionId);
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

    // 보기가 없는 경우 (rhythmTap, recording 등)
    // 음절 개수 선택 객관식으로 변환
    if (question.pattern == GamePattern.rhythmTap && 
        question.correctAnswer.isNotEmpty) {
      // 정답이 숫자인 경우 (음절 개수)
      try {
        int.parse(question.correctAnswer); // 정답 검증용 (사용 안 함)
        // 1~5개 음절 선택지 생성
        final syllableOptions = List.generate(5, (i) => i + 1);
        
        return Column(
          children: [
            // 질문
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '몇 개의 음절인가요?',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
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
                  final isSelected = _selectedAnswer == count.toString();
                  
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedAnswer = count.toString();
                      });
                      _submitAnswer(storyQuestion, count.toString());
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
      }
    }
    
    // 보기가 없고 패턴 변환도 안 된 경우 자동 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 약간의 딜레이 후 자동 제출 (사용자가 스토리 맥락을 읽을 시간 제공)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _questionStartTime != null) {
          _submitAnswer(storyQuestion, question.correctAnswer);
        }
      });
    });

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
                const Icon(Icons.touch_app, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  question.gameTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  '이 문항은 자동으로 처리됩니다.\n잠시만 기다려주세요...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF757575),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
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

