import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/character_widget.dart';
import '../../../../../core/widgets/child_friendly_button.dart';
import '../../providers/story_assessment_provider.dart';
import '../../../data/models/story_assessment_model.dart';
import 'story_chapter_page.dart';

/// 스토리 검사 인트로 페이지
/// "한글 나라 모험" 시작 화면
class StoryIntroPage extends ConsumerStatefulWidget {
  final String childId;
  final String childName;

  const StoryIntroPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  ConsumerState<StoryIntroPage> createState() => _StoryIntroPageState();
}

class _StoryIntroPageState extends ConsumerState<StoryIntroPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // 연한 초록 배경
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 캐릭터 (한글)
                const CharacterWidget(
                  emotion: CharacterEmotion.excited,
                  size: 200,
                ),
                const SizedBox(height: 32),

                // 인사말
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
                        '안녕! 나는 한글이야! 👋',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.childName}야, 오늘 우리 함께\n신비한 한글 나라를 탐험해볼까?',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF424242),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '섬에는 재미있는 퀴즈들이 있어.\n하나씩 풀어보면서 우리의 실력을 알아볼게!',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 시작 버튼
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ChildFriendlyButton(
                    onPressed: () => _startStory(context),
                    label: '여행 시작하기! 🚀',
                    color: const Color(0xFF4CAF50),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startStory(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // 스토리 세션 생성 및 시작
      await ref
          .read(currentStorySessionProvider.notifier)
          .startNewStoryAssessment(
            childId: widget.childId,
            theme: StoryTheme.hangeulLand,
          );

      if (mounted) {
        // 첫 번째 챕터 페이지로 이동
        context.push(
          '/story/chapter',
          extra: {
            'childId': widget.childId,
            'childName': widget.childName,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

