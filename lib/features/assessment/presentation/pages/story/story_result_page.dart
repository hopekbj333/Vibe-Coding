import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/character_widget.dart';
import '../../providers/story_assessment_provider.dart';

/// 스토리 검사 결과 페이지
/// 전체 여행 완료 및 결과 표시
class StoryResultPage extends StatefulWidget {
  final String childId;
  final String childName;

  const StoryResultPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<StoryResultPage> createState() => _StoryResultPageState();
}

class _StoryResultPageState extends State<StoryResultPage> {

  @override
  Widget build(BuildContext context) {
    // 전체 페이지를 RepaintBoundary로 감싸서 불필요한 리페인트 방지
    return RepaintBoundary(
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 캐릭터 (결과 페이지에서는 애니메이션 비활성화 및 key 추가)
                  const CharacterWidget(
                    key: ValueKey('result_character'),
                    emotion: CharacterEmotion.excited,
                    size: 200,
                    animate: false, // 결과 페이지에서는 흔들림 방지
                  ),
                const SizedBox(height: 32),

                  // 완료 메시지
                  Container(
                    key: const ValueKey('result_card'),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '모든 여행 완료! 🎉',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${widget.childName}야, 정말 수고했어!\n모든 섬을 탐험하고 여행을 마쳤어! 🎊',
                          key: ValueKey('result_message_${widget.childName}'),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF424242),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                  // 홈으로 버튼 (결과 페이지에서는 일반 버튼 사용하여 애니메이션 리빌드 방지)
                  SizedBox(
                    key: const ValueKey('result_button'),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 세션 클리어 (ProviderScope에서 접근)
                        final container = ProviderScope.containerOf(context);
                        container.read(currentStorySessionProvider.notifier).clearSession();
                        // 홈으로 이동 (모든 스토리 페이지를 스택에서 제거)
                        if (mounted && context.mounted) {
                          // GoRouter의 go 메서드를 사용하여 홈으로 이동
                          GoRouter.of(context).go('/home');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '홈으로 돌아가기 🏠',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

