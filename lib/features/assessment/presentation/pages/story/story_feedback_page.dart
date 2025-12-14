import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/character_widget.dart';
import '../../../../../core/widgets/child_friendly_button.dart';
import '../../../data/models/story_assessment_model.dart';
import 'story_question_page.dart';
import 'story_chapter_complete_page.dart';

/// 스토리 피드백 페이지
/// 정답/오답 피드백을 스토리 맥락으로 제공
class StoryFeedbackPage extends StatelessWidget {
  final String childId;
  final String childName;
  final bool isCorrect;
  final StoryFeedback feedback;

  const StoryFeedbackPage({
    super.key,
    required this.childId,
    required this.childName,
    required this.isCorrect,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 캐릭터
                CharacterWidget(
                  emotion: isCorrect
                      ? CharacterEmotion.happy
                      : CharacterEmotion.sad,
                  size: 200,
                ),
                const SizedBox(height: 32),

                // 피드백 메시지
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
                        isCorrect
                            ? feedback.correctMessage
                            : feedback.incorrectMessage,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isCorrect
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF9800),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isCorrect && feedback.correctEmoji != null)
                        Text(
                          feedback.correctEmoji!,
                          style: const TextStyle(fontSize: 48),
                        )
                      else if (!isCorrect && feedback.incorrectEmoji != null)
                        Text(
                          feedback.incorrectEmoji!,
                          style: const TextStyle(fontSize: 48),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 다음 버튼
                ChildFriendlyButton(
                  onPressed: () => _goToNext(context),
                  label: '다음 문항으로! ➡️',
                  color: isCorrect
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToNext(BuildContext context) {
    // 다음 문항으로 이동하거나 챕터 완료 페이지로 이동
    // 실제로는 세션 상태를 확인해야 함
    context.pushReplacement(
      '/story/question',
      extra: {
        'childId': childId,
        'childName': childName,
      },
    );
  }
}

