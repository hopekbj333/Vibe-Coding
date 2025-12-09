import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design/design_system.dart';
import 'word_count_game.dart';
import 'word_boundary_game.dart';
import 'alliteration_game.dart';
import 'rhyme_game.dart';
import 'word_chain_game.dart';

/// 음운 인식 2단계 훈련 페이지 (WP 2.4)
/// 
/// 단어와 문장의 구조를 인식하는 5가지 게임을 제공합니다.
class Phonological2TrainingPage extends StatefulWidget {
  final String childId;
  final String? childName;

  const Phonological2TrainingPage({
    super.key,
    required this.childId,
    this.childName,
  });

  @override
  State<Phonological2TrainingPage> createState() => _Phonological2TrainingPageState();
}

class _Phonological2TrainingPageState extends State<Phonological2TrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음운 인식 2단계'),
        backgroundColor: DesignSystem.childFriendlyGreen,
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
                  DesignSystem.childFriendlyGreen,
                  DesignSystem.childFriendlyGreen.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '📝 단어와 문장을 배워요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '문장 속 단어를 찾고, 소리의 규칙을 배워요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 시나리오 1: 단어 세기
          _buildSectionTitle('🔢 단어 세기'),
          const SizedBox(height: 12),
          _buildGameCard(
            title: '문장 속 단어 수 세기',
            description: '문장을 듣고 몇 개의 단어인지 맞춰요',
            icon: Icons.format_list_numbered,
            color: DesignSystem.childFriendlyBlue,
            gameType: Phonological2GameType.wordCount,
          ),
          _buildGameCard(
            title: '단어 경계 찾기',
            description: '붙어있는 단어를 나눠요',
            icon: Icons.content_cut,
            color: DesignSystem.semanticWarning,
            gameType: Phonological2GameType.wordBoundary,
          ),

          const SizedBox(height: 24),

          // 시나리오 2: 운율 찾기
          _buildSectionTitle('🎵 운율 찾기'),
          const SizedBox(height: 12),
          _buildGameCard(
            title: '두운(첫소리) 찾기',
            description: '같은 소리로 시작하는 단어를 찾아요',
            icon: Icons.first_page,
            color: DesignSystem.childFriendlyGreen,
            gameType: Phonological2GameType.alliteration,
          ),
          _buildGameCard(
            title: '각운(끝소리) 찾기',
            description: '같은 소리로 끝나는 단어를 찾아요',
            icon: Icons.last_page,
            color: DesignSystem.childFriendlyPurple,
            gameType: Phonological2GameType.rhyme,
          ),

          const SizedBox(height: 24),

          // 시나리오 3: 단어 이어가기
          _buildSectionTitle('🔗 단어 이어가기'),
          const SizedBox(height: 12),
          _buildGameCard(
            title: '끝말잇기 연습',
            description: '단어의 끝 글자로 시작하는 것을 찾아요',
            icon: Icons.link,
            color: DesignSystem.childFriendlyYellow,
            gameType: Phonological2GameType.wordChain,
          ),

          const SizedBox(height: 32),

          // 다음 단계로 이동
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  '✂️ 3단계로 넘어갈 준비가 됐나요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '음절을 쪼개고, 합치고, 조작해봐요!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/training/${widget.childId}/phonological3');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('3단계 시작하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
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
    required Phonological2GameType gameType,
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

  void _startGame(Phonological2GameType gameType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Phonological2GameScreen(
          childId: widget.childId,
          gameType: gameType,
        ),
      ),
    );
  }
}

/// 개별 게임 화면
class Phonological2GameScreen extends StatelessWidget {
  final String childId;
  final Phonological2GameType gameType;

  const Phonological2GameScreen({
    super.key,
    required this.childId,
    required this.gameType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getGameTitle()),
        backgroundColor: DesignSystem.childFriendlyGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _buildGame(context),
      ),
    );
  }

  String _getGameTitle() {
    switch (gameType) {
      case Phonological2GameType.wordCount:
        return '단어 수 세기';
      case Phonological2GameType.wordBoundary:
        return '단어 경계 찾기';
      case Phonological2GameType.alliteration:
        return '두운 찾기';
      case Phonological2GameType.rhyme:
        return '각운 찾기';
      case Phonological2GameType.wordChain:
        return '끝말잇기';
    }
  }

  Widget _buildGame(BuildContext context) {
    switch (gameType) {
      case Phonological2GameType.wordCount:
        return WordCountGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Word Count: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case Phonological2GameType.wordBoundary:
        return WordBoundaryGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Word Boundary: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case Phonological2GameType.alliteration:
        return AlliterationGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Alliteration: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case Phonological2GameType.rhyme:
        return RhymeGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Rhyme: $isCorrect, ${responseTime}ms');
          },
          onComplete: () => _showCompleteDialog(context),
        );
      case Phonological2GameType.wordChain:
        return WordChainGame(
          childId: childId,
          onAnswer: (isCorrect, responseTime) {
            debugPrint('Word Chain: $isCorrect, ${responseTime}ms');
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

enum Phonological2GameType {
  wordCount,
  wordBoundary,
  alliteration,
  rhyme,
  wordChain,
}

