import 'package:uuid/uuid.dart';
import '../models/story_assessment_model.dart';
import 'story_question_mapping_service.dart';

/// 스토리형 검사 세션 생성 및 관리 서비스
class StoryAssessmentService {
  final StoryQuestionMappingService _mappingService =
      StoryQuestionMappingService();
  final Uuid _uuid = const Uuid();

  /// 새로운 스토리 검사 세션 생성
  Future<StoryAssessmentSession> createStorySession({
    required String childId,
    StoryTheme theme = StoryTheme.hangeulLand,
  }) async {
    // 35개 능력에 대한 스토리 문항 생성
    final allQuestions = await _mappingService.generateStoryQuestions();

    // 챕터별로 분류
    final phonologicalAwarenessQuestions =
        allQuestions.where((q) {
          return q.abilityId.startsWith('0.') ||
              q.abilityId.startsWith('1.') ||
              q.abilityId.startsWith('2.') ||
              q.abilityId.startsWith('3.');
        }).toList();

    final phonologicalProcessingQuestions =
        allQuestions.where((q) {
          return q.abilityId.startsWith('PM') ||
              q.abilityId.startsWith('RAN') ||
              q.abilityId.startsWith('V') ||
              q.abilityId.startsWith('WM') ||
              q.abilityId.startsWith('AT') ||
              q.abilityId.startsWith('EF');
        }).toList();

    // Chapter 1: 소리 섬 (음운인식능력 - 15개)
    final chapter1 = StoryChapter(
      chapterId: 'chapter_1_sound_island',
      title: '소리 섬',
      description: '소리를 듣고 구별하는 실력을 테스트하는 섬',
      type: StoryChapterType.phonologicalAwareness,
      questions: phonologicalAwarenessQuestions,
      introDialogue:
          '첫 번째 섬은 소리 섬이야!\n여기서는 소리를 듣고 구별하는 실력을 테스트해볼게.\n소리를 잘 듣고 구별할 수 있으면 한글을 배우는 게 훨씬 쉬워져.\n준비됐어? 그럼 출발해볼까?',
      completeDialogue:
          '와! 소리 섬을 모두 탐험했어!\n소리를 듣고 구별하는 실력이 정말 훌륭해!\n이제 다음 섬으로 가볼까?',
      reward: StoryReward(
        stars: 15,
        message: '소리 섬 완료! 별 15개 획득! ⭐⭐⭐⭐⭐',
      ),
    );

    // Chapter 2: 기억 바다 (음운처리능력 - 20개)
    final chapter2 = StoryChapter(
      chapterId: 'chapter_2_memory_ocean',
      title: '기억 바다',
      description: '소리를 기억하고 빠르게 말하는 실력을 테스트하는 바다',
      type: StoryChapterType.phonologicalProcessing,
      questions: phonologicalProcessingQuestions,
      introDialogue:
          '두 번째 섬은 기억 바다야!\n여기서는 소리를 기억하고 빠르게 말하는 실력을 테스트해볼게.\n소리를 잘 기억하고 빠르게 말할 수 있으면 한글을 읽는 속도가 빨라져.\n준비됐어?',
      completeDialogue:
          '와! 기억 바다를 모두 탐험했어!\n기억하고 빠르게 말하는 실력이 정말 훌륭해!\n모든 여행을 완료했어!',
      reward: StoryReward(
        stars: 20,
        message: '기억 바다 완료! 별 20개 획득! ⭐⭐⭐⭐⭐',
      ),
    );

    final chapters = [chapter1, chapter2];

    // 진행 상황 초기화
    final progress = StoryProgress(
      completedQuestions: [],
      questionResults: {},
      questionResponseTimes: {},
      completedChapters: [],
      totalStars: 0,
    );

    return StoryAssessmentSession(
      sessionId: _uuid.v4(),
      childId: childId,
      theme: theme,
      startedAt: DateTime.now(),
      status: StoryProgressStatus.notStarted,
      chapters: chapters,
      currentChapterIndex: 0,
      currentQuestionIndex: 0,
      progress: progress,
    );
  }

  /// 답변 제출
  StoryAssessmentSession submitAnswer({
    required StoryAssessmentSession session,
    required String questionId,
    required String userAnswer,
    required int responseTimeMs,
  }) {
    final currentQuestion = session.currentQuestion;
    if (currentQuestion == null) {
      return session;
    }

    final isCorrect = userAnswer == currentQuestion.question.correctAnswer;

    // 중복 제출 방지: 이미 완료된 문항인지 확인
    if (session.progress.completedQuestions.contains(questionId)) {
      print('⚠️ Warning: Question $questionId already completed. Skipping duplicate submission.');
      return session; // 이미 완료된 문항이면 변경 없이 반환
    }

    // 진행 상황 업데이트
    final updatedProgress = session.progress.copyWith(
      completedQuestions: [
        ...session.progress.completedQuestions,
        questionId,
      ],
      questionResults: {
        ...session.progress.questionResults,
        questionId: isCorrect,
      },
      questionResponseTimes: {
        ...session.progress.questionResponseTimes,
        questionId: responseTimeMs,
      },
    );

    // 다음 문항으로 이동
    int nextQuestionIndex = session.currentQuestionIndex + 1;
    int nextChapterIndex = session.currentChapterIndex;
    StoryProgressStatus nextStatus = session.status;

    final currentChapter = session.currentChapter;
    if (currentChapter != null) {
      // 현재 챕터의 마지막 문항인지 확인
      // nextQuestionIndex가 questions.length와 같거나 크면 챕터 완료
      if (nextQuestionIndex >= currentChapter.questions.length) {
        // 챕터 완료
        nextQuestionIndex = 0;
        nextChapterIndex += 1;

        // 챕터 완료 보상 추가 (중복 방지)
        final List<String> updatedCompletedChapters;
        int updatedTotalStars;
        
        if (updatedProgress.completedChapters.contains(currentChapter.chapterId)) {
          // 이미 완료된 챕터면 별을 추가하지 않음
          print('⚠️ Warning: Chapter ${currentChapter.chapterId} already completed. Skipping duplicate reward.');
          updatedCompletedChapters = updatedProgress.completedChapters;
          updatedTotalStars = updatedProgress.totalStars;
        } else {
          // 새로 완료된 챕터면 별 추가
          updatedCompletedChapters = [
            ...updatedProgress.completedChapters,
            currentChapter.chapterId,
          ];
          updatedTotalStars = updatedProgress.totalStars + currentChapter.reward.stars;
        }

        final updatedProgressWithReward = updatedProgress.copyWith(
          completedChapters: updatedCompletedChapters,
          totalStars: updatedTotalStars,
        );

        // 모든 챕터 완료 확인
        if (nextChapterIndex >= session.chapters.length) {
          // 모든 챕터 완료
          nextStatus = StoryProgressStatus.completed;
          return session.copyWith(
            currentChapterIndex: nextChapterIndex - 1, // 마지막 챕터 인덱스 유지
            currentQuestionIndex: currentChapter.questions.length - 1, // 마지막 문항 인덱스 유지
            status: nextStatus,
            progress: updatedProgressWithReward,
            completedAt: DateTime.now(),
          );
        } else {
          // 다음 챕터로 이동
          nextStatus = StoryProgressStatus.chapterComplete;
          return session.copyWith(
            currentChapterIndex: nextChapterIndex,
            currentQuestionIndex: nextQuestionIndex,
            status: nextStatus,
            progress: updatedProgressWithReward,
          );
        }
      }
    }

    // 다음 문항으로 진행
    return session.copyWith(
      currentQuestionIndex: nextQuestionIndex,
      status: StoryProgressStatus.inChapter,
      progress: updatedProgress,
    );
  }

  /// 세션 시작
  StoryAssessmentSession startSession(StoryAssessmentSession session) {
    return session.copyWith(
      status: StoryProgressStatus.inChapter,
    );
  }

  /// 세션 일시 중지
  StoryAssessmentSession pauseSession(StoryAssessmentSession session) {
    return session.copyWith(
      status: StoryProgressStatus.paused,
    );
  }

  /// 세션 재개
  StoryAssessmentSession resumeSession(StoryAssessmentSession session) {
    return session.copyWith(
      status: StoryProgressStatus.inChapter,
    );
  }

  /// 세션 중도 포기
  StoryAssessmentSession abandonSession(StoryAssessmentSession session) {
    return session.copyWith(
      status: StoryProgressStatus.abandoned,
      completedAt: DateTime.now(),
    );
  }

  /// 세션 완료
  StoryAssessmentSession completeSession(StoryAssessmentSession session) {
    return session.copyWith(
      status: StoryProgressStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// 이전 문항으로 이동
  StoryAssessmentSession moveToPreviousQuestion(StoryAssessmentSession session) {
    final currentChapter = session.currentChapter;
    if (currentChapter == null) return session;

    int prevQuestionIndex = session.currentQuestionIndex - 1;
    int prevChapterIndex = session.currentChapterIndex;

    // 현재 챕터의 첫 번째 문항이면 이전 챕터로 이동
    if (prevQuestionIndex < 0) {
      if (prevChapterIndex > 0) {
        prevChapterIndex -= 1;
        final prevChapter = session.chapters[prevChapterIndex];
        prevQuestionIndex = prevChapter.questions.length - 1;
      } else {
        // 첫 번째 챕터의 첫 번째 문항이면 이동 불가
        return session;
      }
    }

    return session.copyWith(
      currentChapterIndex: prevChapterIndex,
      currentQuestionIndex: prevQuestionIndex,
      status: StoryProgressStatus.inChapter,
    );
  }

  /// 다음 문항으로 이동
  StoryAssessmentSession moveToNextQuestion(StoryAssessmentSession session) {
    final currentChapter = session.currentChapter;
    if (currentChapter == null) return session;

    int nextQuestionIndex = session.currentQuestionIndex + 1;
    int nextChapterIndex = session.currentChapterIndex;

    // 현재 챕터의 마지막 문항을 넘어가면 다음 챕터로 이동
    if (nextQuestionIndex >= currentChapter.questions.length) {
      if (nextChapterIndex < session.chapters.length - 1) {
        nextChapterIndex += 1;
        nextQuestionIndex = 0;
      } else {
        // 마지막 챕터의 마지막 문항이면 이동 불가
        return session;
      }
    }

    return session.copyWith(
      currentChapterIndex: nextChapterIndex,
      currentQuestionIndex: nextQuestionIndex,
      status: StoryProgressStatus.inChapter,
    );
  }
}

