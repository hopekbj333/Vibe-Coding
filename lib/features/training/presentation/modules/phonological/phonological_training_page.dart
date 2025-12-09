import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design/design_system.dart';
import 'same_sound_game.dart';
import 'different_sound_game.dart';
import 'rhythm_follow_game.dart';
import 'tempo_compare_game.dart';
import 'intonation_game.dart';
import 'emotion_detect_game.dart';

/// 음운 인식 훈련 페이지 (WP 2.3)
/// 
/// 청각적 주의와 운율 감각을 훈련하는 6가지 게임을 제공합니다.
class PhonologicalTrainingPage extends StatefulWidget {
  final String childId;
  final String? childName;

  const PhonologicalTrainingPage({
    super.key,
    required this.childId,
    this.childName,
  });

  @override
  State<PhonologicalTrainingPage> createState() => _PhonologicalTrainingPageState();
}

class _PhonologicalTrainingPageState extends State<PhonologicalTrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음운 인식 훈련'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignSystem.primaryBlue,
                  DesignSystem.primaryBlue.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '👂 소리를 잘 듣는 연습',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '글자를 배우기 전에 귀를 트이게 해요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2단계로 이동 버튼
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => context.push('/training/${widget.childId}/phonological2'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignSystem.childFriendlyGreen,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DesignSystem.childFriendlyGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: DesignSystem.childFriendlyGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📝 2단계로 이동',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '단어와 문장 구조 배우기',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 시나리오 1: 소리 탐정
          _buildSectionTitle('🔍 소리 탐정 게임'),
          const SizedBox(height: 12),
          _buildGameCard(
            title: '같은 소리 찾기',
            description: '3개 중에서 같은 소리 2개를 찾아요',
            icon: Icons.search,
            color: DesignSystem.childFriendlyBlue,
            gameType: PhonologicalGameType.sameSound,
          ),
          _buildGameCard(
            title: '다른 소리 찾기',
            description: '3개 중에서 혼자 다른 소리를 찾아요',
            icon: Icons.find_replace,
            color: DesignSystem.semanticWarning,
            gameType: PhonologicalGameType.differentSound,
          ),

          const SizedBox(height: 24),

          // 시나리오 2: 리듬 놀이
          _buildSectionTitle('🥁 리듬 놀이'),
          const SizedBox(height: 12),
          _buildGameCard(
            title: '리듬 따라 치기',
            description: '북 소리를 듣고 따라 쳐요',
            icon: Icons.music_note,
            color: DesignSystem.childFriendlyGreen,
            gameType: PhonologicalGameType.rhythmFollow,
          ),
          _buildGameCard(
            title: '빠르기 구별하기',
            description: '더 빠른 것과 느린 것을 구별해요',
            icon: Icons.speed,
            color: DesignSystem.childFriendlyPurple,
            gameType: PhonologicalGameType.tempoCompare,
          ),

          const SizedBox(height: 24),

          // 시나리오 3: 말의 느낌
          _buildSectionTitle('🎭 말의 느낌'),
          const SizedBox(height: 12),
          _buildGameCard(
            title: '억양 구별하기',
            description: '질문인지 아닌지 구별해요',
            icon: Icons.record_voice_over,
            color: DesignSystem.childFriendlyYellow,
            gameType: PhonologicalGameType.intonation,
          ),
          _buildGameCard(
            title: '감정 찾기',
            description: '목소리에서 기분을 찾아요',
            icon: Icons.emoji_emotions,
            color: DesignSystem.primaryRed,
            gameType: PhonologicalGameType.emotion,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required PhonologicalGameType gameType,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _startGame(gameType),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(PhonologicalGameType gameType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhonologicalGameScreen(
          childId: widget.childId,
          gameType: gameType,
        ),
      ),
    );
  }
}

/// 개별 게임 화면
class PhonologicalGameScreen extends StatelessWidget {
  final String childId;
  final PhonologicalGameType gameType;

  const PhonologicalGameScreen({
    super.key,
    required this.childId,
    required this.gameType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getGameTitle()),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _buildGame(context),
      ),
    );
  }

  String _getGameTitle() {
    switch (gameType) {
      case PhonologicalGameType.sameSound:
        return '같은 소리 찾기';
      case PhonologicalGameType.differentSound:
        return '다른 소리 찾기';
      case PhonologicalGameType.rhythmFollow:
        return '리듬 따라 치기';
      case PhonologicalGameType.tempoCompare:
        return '빠르기 구별하기';
      case PhonologicalGameType.intonation:
        return '억양 구별하기';
      case PhonologicalGameType.emotion:
        return '감정 찾기';
    }
  }

  Widget _buildGame(BuildContext context) {
    switch (gameType) {
      case PhonologicalGameType.sameSound:
        return SameSoundGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Same Sound: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case PhonologicalGameType.differentSound:
        return DifferentSoundGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Different Sound: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case PhonologicalGameType.rhythmFollow:
        return RhythmFollowGame(
          childId: childId,
          onComplete: (accuracy, avgError) {
            debugPrint('Rhythm: $accuracy, ${avgError}ms');
          },
          onGameEnd: () => _showCompleteDialog(context),
        );
      case PhonologicalGameType.tempoCompare:
        return TempoCompareGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Tempo: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case PhonologicalGameType.intonation:
        return IntonationGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Intonation: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case PhonologicalGameType.emotion:
        return EmotionDetectGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Emotion: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
    }
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 잘했어요!'),
        content: const Text('모든 문제를 완료했어요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('목록으로'),
          ),
        ],
      ),
    );
  }
}

enum PhonologicalGameType {
  sameSound,
  differentSound,
  rhythmFollow,
  tempoCompare,
  intonation,
  emotion,
}

