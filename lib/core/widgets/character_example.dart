/// 캐릭터 위젯 사용 예시
/// 
/// 실제 앱에서 캐릭터를 어떻게 사용하는지 보여주는 예시 화면입니다.

import 'package:flutter/material.dart';
import 'character_widget.dart';

class CharacterExampleScreen extends StatelessWidget {
  const CharacterExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 예시'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캐릭터 감정별 표시
            const Text(
              '1. 캐릭터 감정 5종',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildCharacterCard(
                  emotion: CharacterEmotion.happy,
                  label: '기쁨',
                  description: '정답 피드백',
                ),
                _buildCharacterCard(
                  emotion: CharacterEmotion.neutral,
                  label: '중립',
                  description: '기본 상태',
                ),
                _buildCharacterCard(
                  emotion: CharacterEmotion.thinking,
                  label: '생각',
                  description: '문제 제시',
                ),
                _buildCharacterCard(
                  emotion: CharacterEmotion.sad,
                  label: '슬픔',
                  description: '오답 (격려)',
                ),
                _buildCharacterCard(
                  emotion: CharacterEmotion.excited,
                  label: '신남',
                  description: '레벨업',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 크기별 표시
            const Text(
              '2. 캐릭터 크기 프리셋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CharacterWidget(
                      emotion: CharacterEmotion.happy,
                      size: CharacterWidget.sizeSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Small (100)'),
                  ],
                ),
                Column(
                  children: [
                    CharacterWidget(
                      emotion: CharacterEmotion.happy,
                      size: CharacterWidget.sizeMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Medium (150)'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 실제 사용 시나리오
            const Text(
              '3. 실제 사용 시나리오',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 시나리오 1: 문제 제시
            _buildScenario(
              title: '시나리오 1: 문제 제시',
              children: [
                CharacterWidget(
                  emotion: CharacterEmotion.thinking,
                  size: CharacterWidget.sizeMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  '어떤 동물이 "야옹" 소리를 낼까?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 시나리오 2: 정답
            _buildScenario(
              title: '시나리오 2: 정답!',
              backgroundColor: Colors.green[50],
              children: [
                CharacterWidget(
                  emotion: CharacterEmotion.happy,
                  size: CharacterWidget.sizeLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  '정답이에요! 잘했어요!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 시나리오 3: 오답
            _buildScenario(
              title: '시나리오 3: 아쉬워요 (격려)',
              backgroundColor: Colors.orange[50],
              children: [
                CharacterWidget(
                  emotion: CharacterEmotion.sad,
                  size: CharacterWidget.sizeLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  '괜찮아요. 다시 한번 해볼까요?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 시나리오 4: 레벨업
            _buildScenario(
              title: '시나리오 4: 레벨업!',
              backgroundColor: Colors.pink[50],
              children: [
                CharacterWidget(
                  emotion: CharacterEmotion.excited,
                  size: CharacterWidget.sizeXLarge,
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎉 레벨업! 정말 대단해요!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard({
    required CharacterEmotion emotion,
    required String label,
    required String description,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          CharacterWidget(
            emotion: emotion,
            size: 100,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScenario({
    required String title,
    required List<Widget> children,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
