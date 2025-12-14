import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/character_widget.dart';
import '../../../../../core/widgets/child_friendly_button.dart';
import '../../providers/story_assessment_provider.dart';
import '../../../data/models/story_assessment_model.dart';
import 'story_question_page.dart';

/// 스토리 챕터 시작 페이지
/// 각 챕터(섬)의 인트로를 보여주고 문항으로 이동
class StoryChapterPage extends ConsumerWidget {
  final String childId;
  final String childName;

  const StoryChapterPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(currentStorySessionProvider);
    final session = sessionState.session;

    if (session == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('스토리를 준비하고 있어요...'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final currentChapter = session.currentChapter;
    if (currentChapter == null) {
      // 모든 챕터 완료
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('모든 여행을 완료했어요!'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.push('/story/result', extra: {
                    'childId': childId,
                    'childName': childName,
                  });
                },
                child: const Text('결과 보기'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getChapterBackgroundColor(currentChapter.type),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 챕터 제목
                Text(
                  currentChapter.title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 캐릭터
                const CharacterWidget(
                  emotion: CharacterEmotion.happy,
                  size: 180,
                ),
                const SizedBox(height: 32),

                // 챕터 설명 (대사)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    currentChapter.introDialogue,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF424242),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // 시작 버튼
                ChildFriendlyButton(
                  onPressed: () {
                    context.push(
                      '/story/question',
                      extra: {
                        'childId': childId,
                        'childName': childName,
                      },
                    );
                  },
                  label: '${currentChapter.title} 탐험하기! 🗺️',
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getChapterBackgroundColor(StoryChapterType type) {
    switch (type) {
      case StoryChapterType.phonologicalAwareness:
        return const Color(0xFF4CAF50); // 초록색 (소리 섬)
      case StoryChapterType.phonologicalProcessing:
        return const Color(0xFF2196F3); // 파란색 (기억 바다)
    }
  }

  Color _getChapterColor(StoryChapterType type) {
    switch (type) {
      case StoryChapterType.phonologicalAwareness:
        return const Color(0xFF4CAF50);
      case StoryChapterType.phonologicalProcessing:
        return const Color(0xFF2196F3);
    }
  }
}

