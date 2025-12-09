/// Placeholder 위젯 사용 예시
/// 
/// 이 파일은 실제 앱에서 사용하지 않고, 참고용으로만 사용됩니다.

import 'package:flutter/material.dart';
import 'placeholder_image_widget.dart';

class PlaceholderExampleScreen extends StatelessWidget {
  const PlaceholderExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placeholder 예시'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캐릭터 섹션
            const Text(
              '1. 캐릭터 Placeholder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                CharacterPlaceholder(
                  emotion: CharacterEmotion.happy,
                  size: 150,
                ),
                CharacterPlaceholder(
                  emotion: CharacterEmotion.neutral,
                  size: 150,
                ),
                CharacterPlaceholder(
                  emotion: CharacterEmotion.thinking,
                  size: 150,
                ),
                CharacterPlaceholder(
                  emotion: CharacterEmotion.sad,
                  size: 150,
                ),
                CharacterPlaceholder(
                  emotion: CharacterEmotion.excited,
                  size: 150,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // UI 아이콘 섹션
            const Text(
              '2. UI 아이콘 Placeholder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                IconPlaceholder(label: '별', size: 80),
                IconPlaceholder(label: '체크', size: 80),
                IconPlaceholder(label: '재시도', size: 80),
                IconPlaceholder(label: '플레이', size: 80),
                IconPlaceholder(label: '정지', size: 80),
                IconPlaceholder(label: '홈', size: 80),
              ],
            ),

            const SizedBox(height: 32),

            // 배지 섹션
            const Text(
              '3. 배지 Placeholder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                BadgePlaceholder(label: '브론즈', size: 100),
                BadgePlaceholder(label: '실버', size: 100),
                BadgePlaceholder(label: '골드', size: 100),
              ],
            ),

            const SizedBox(height: 32),

            // 게임 에셋 섹션
            const Text(
              '4. 게임 에셋 Placeholder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                GameAssetPlaceholder(label: '고양이', size: 120),
                GameAssetPlaceholder(label: '강아지', size: 120),
                GameAssetPlaceholder(label: '사과', size: 120),
                GameAssetPlaceholder(label: '바나나', size: 120),
              ],
            ),

            const SizedBox(height: 32),

            // 실제 사용 예시
            const Text(
              '5. 실제 게임 화면 예시',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 캐릭터 (질문 제시)
                  CharacterPlaceholder(
                    emotion: CharacterEmotion.thinking,
                    size: 150,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '어떤 동물이 "야옹" 소리를 낼까?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // 선택지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GameAssetPlaceholder(label: '고양이', size: 100),
                      GameAssetPlaceholder(label: '강아지', size: 100),
                      GameAssetPlaceholder(label: '새', size: 100),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 코드 예시
            const Text(
              '6. 코드 예시',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''
// 캐릭터 표시
CharacterPlaceholder(
  emotion: CharacterEmotion.happy,
  size: 200,
)

// 게임 에셋 표시
GameAssetPlaceholder(
  label: '고양이',
  size: 150,
)

// UI 아이콘 표시
IconPlaceholder(
  label: '별',
  size: 80,
)

// 실제 에셋으로 교체 시
Image.asset(
  'assets/characters/character_happy.png',
  width: 200,
  height: 200,
)
''',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
