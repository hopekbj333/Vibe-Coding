import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/character_widget.dart';
import '../../../../../core/widgets/child_friendly_button.dart';
import '../../providers/story_assessment_provider.dart';
import '../../../data/models/story_assessment_model.dart';
import 'story_chapter_page.dart';
import 'story_result_page.dart';

/// 스토리 챕터 완료 페이지
/// 챕터 완료 시 보상과 함께 표시
class StoryChapterCompletePage extends ConsumerWidget {
  final String childId;
  final String childName;

  const StoryChapterCompletePage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(currentStorySessionProvider);
    final session = sessionState.session;

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completedChapter = session.chapters.firstWhere(
      (c) => session.progress.completedChapters.contains(c.chapterId),
      orElse: () => session.chapters[session.currentChapterIndex],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 캐릭터
                const CharacterWidget(
                  emotion: CharacterEmotion.excited,
                  size: 200,
                ),
                const SizedBox(height: 32),

                // 챕터 완료 메시지
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Column(
                    children: [
                      Text(
                        '${completedChapter.title} 완료! 🎉',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        completedChapter.completeDialogue,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF424242),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // 보상
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 8),
                            Text(
                              '${completedChapter.reward.stars}개 획득!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 다음 버튼
                ChildFriendlyButton(
                  onPressed: () {
                    // 다음 챕터로 이동하거나 결과 페이지로 이동
                    if (session.currentChapterIndex < session.chapters.length) {
                      context.pushReplacement(
                        '/story/chapter',
                        extra: {
                          'childId': childId,
                          'childName': childName,
                        },
                      );
                    } else {
                      // 결과 값들을 계산하여 전달
                      final progress = session.progress;
                      context.pushReplacement(
                        '/story/result',
                        extra: {
                          'childId': childId,
                          'childName': childName,
                          'accuracy': progress.accuracy,
                          'totalStars': progress.totalStars,
                          'completedCount': progress.completedQuestions.length,
                        },
                      );
                    }
                  },
                  label: '다음 섬으로! 🗺️',
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

