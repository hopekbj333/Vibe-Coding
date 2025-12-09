import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import 'onset_separation_game.dart';
import 'phoneme_synthesis_game.dart';
import 'phoneme_deletion_game.dart';
import 'phoneme_substitution_game.dart';
import 'phoneme_addition_game.dart';
import 'nonword_repetition_game.dart';
import 'digit_span_game.dart';
import 'word_span_game.dart';

/// 음운 인식 4~5단계 훈련 페이지
/// 
/// 4단계: 음소 조작 (초성 분리, 합성, 탈락, 대치, 추가)
/// 5단계: 음운 기억 (비단어 따라하기, 숫자 폭, 단어 폭)
class Phonological4TrainingPage extends StatelessWidget {
  final String childId;

  const Phonological4TrainingPage({
    super.key,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음운 인식 4~5단계'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4단계: 음소 조작
                _buildSectionHeader(
                  '4단계: 음소 조작',
                  'ㄱ, ㄴ, ㄷ 같은 소리를 쪼개고 합치는 연습',
                  Icons.extension,
                  Colors.indigo,
                ),
                const SizedBox(height: 12),
                _buildGameGrid(context, _stage4Games),
                const SizedBox(height: 32),

                // 5단계: 음운 기억
                _buildSectionHeader(
                  '5단계: 음운 기억',
                  '소리를 듣고 기억하는 연습',
                  Icons.psychology,
                  Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildGameGrid(context, _stage5Games),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_GameInfo> get _stage4Games => [
    _GameInfo(
      title: '초성 분리',
      description: '첫 소리 찾기',
      emoji: '🔤',
      color: Colors.indigo,
      builder: (childId) => OnsetSeparationGame(childId: childId),
    ),
    _GameInfo(
      title: '음소 합성',
      description: '소리 합치기',
      emoji: '🧩',
      color: Colors.purple,
      builder: (childId) => PhonemeSynthesisGame(childId: childId),
    ),
    _GameInfo(
      title: '음소 탈락',
      description: '소리 빼기',
      emoji: '✂️',
      color: Colors.orange,
      builder: (childId) => PhonemeDeletionGame(childId: childId),
    ),
    _GameInfo(
      title: '음소 대치',
      description: '소리 바꾸기',
      emoji: '🔄',
      color: Colors.teal,
      builder: (childId) => PhonemeSubstitutionGame(childId: childId),
    ),
    _GameInfo(
      title: '음소 추가',
      description: '소리 붙이기',
      emoji: '➕',
      color: Colors.green,
      builder: (childId) => PhonemeAdditionGame(childId: childId),
    ),
  ];

  List<_GameInfo> get _stage5Games => [
    _GameInfo(
      title: '외계어 통역사',
      description: '비단어 따라하기',
      emoji: '👽',
      color: Colors.deepPurple,
      builder: (childId) => NonwordRepetitionGame(childId: childId),
    ),
    _GameInfo(
      title: '숫자 기억하기',
      description: '숫자 순서 맞추기',
      emoji: '🔢',
      color: Colors.blue,
      builder: (childId) => DigitSpanGame(childId: childId),
    ),
    _GameInfo(
      title: '장보기 게임',
      description: '단어 순서 기억하기',
      emoji: '🛒',
      color: Colors.orange,
      builder: (childId) => WordSpanGame(childId: childId),
    ),
  ];

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(BuildContext context, List<_GameInfo> games) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(context, game);
      },
    );
  }

  Widget _buildGameCard(BuildContext context, _GameInfo game) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => game.builder(childId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: game.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: game.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(game.emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              game.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: game.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              game.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameInfo {
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final Widget Function(String childId) builder;

  _GameInfo({
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.builder,
  });
}

