import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/design/design_system.dart';
import 'syllable_clap_game.dart';
import 'syllable_split_game.dart';
import 'syllable_merge_game.dart';
import 'syllable_listen_merge_game.dart';
import 'syllable_drop_game.dart';
import 'syllable_reverse_game.dart';
import 'syllable_replace_game.dart';

/// 음운 인식 3단계 훈련 페이지 (음절 조작)
/// 
/// 음절을 쪼개고, 합치고, 조작하는 훈련입니다.
class Phonological3TrainingPage extends StatefulWidget {
  final String childId;

  const Phonological3TrainingPage({
    super.key,
    required this.childId,
  });

  @override
  State<Phonological3TrainingPage> createState() => _Phonological3TrainingPageState();
}

class _Phonological3TrainingPageState extends State<Phonological3TrainingPage> {
  int? _selectedGameIndex;

  final List<GameInfo> _games = [
    GameInfo(
      title: '박수로 쪼개기',
      description: '단어를 듣고 음절마다 탭!',
      icon: '👏',
      color: Color(0xFF9C27B0),
      category: '음절 분해',
    ),
    GameInfo(
      title: '블록 쪼개기',
      description: '단어 블록을 음절로 분리해요',
      icon: '✂️',
      color: Color(0xFF2196F3),
      category: '음절 분해',
    ),
    GameInfo(
      title: '블록 합치기',
      description: '음절을 합쳐서 단어 만들기',
      icon: '🧩',
      color: Color(0xFF4CAF50),
      category: '음절 합성',
    ),
    GameInfo(
      title: '듣고 합치기',
      description: '천천히 들리는 소리를 합쳐봐요',
      icon: '👂',
      color: Color(0xFFFFC107),
      category: '음절 합성',
    ),
    GameInfo(
      title: '음절 빼기',
      description: '단어에서 소리를 빼면?',
      icon: '🗑️',
      color: Color(0xFFF44336),
      category: '음절 조작',
    ),
    GameInfo(
      title: '거꾸로 말하기',
      description: '단어를 뒤집어 봐요!',
      icon: '🔄',
      color: Color(0xFFFF9800),
      category: '음절 조작',
    ),
    GameInfo(
      title: '소리 바꾸기',
      description: '한 음절을 다른 음절로!',
      icon: '🔁',
      color: Color(0xFF673AB7),
      category: '음절 조작',
    ),
  ];

  void _onGameComplete() {
    setState(() {
      _selectedGameIndex = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 잘했어요!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onAnswer(bool isCorrect, int responseTimeMs) {
    debugPrint('Answer: $isCorrect, Time: ${responseTimeMs}ms');
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedGameIndex != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_games[_selectedGameIndex!].title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedGameIndex = null;
              });
            },
          ),
        ),
        body: _buildSelectedGame(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('음운 인식 3단계'),
            Text(
              '음절 조작',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCategory('음절 분해', '단어를 음절로 쪼개요', 0, 2),
            const SizedBox(height: 24),
            _buildCategory('음절 합성', '음절을 합쳐서 단어를 만들어요', 2, 2),
            const SizedBox(height: 24),
            _buildCategory('음절 조작', '음절을 빼고, 뒤집고, 바꿔요', 4, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '✂️',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '음절 조작',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '단어를 쪼개고, 합치고, 바꿔봐요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, String description, int startIndex, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(title),
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            return _buildGameCard(_games[startIndex + index], startIndex + index);
          },
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '음절 분해':
        return Icons.call_split;
      case '음절 합성':
        return Icons.merge_type;
      case '음절 조작':
        return Icons.auto_fix_high;
      default:
        return Icons.games;
    }
  }

  Widget _buildGameCard(GameInfo game, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: game.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: game.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    game.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: game.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedGame() {
    switch (_selectedGameIndex) {
      case 0:
        return SyllableClapGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      case 1:
        return SyllableSplitGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      case 2:
        return SyllableMergeGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      case 3:
        return SyllableListenMergeGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      case 4:
        return SyllableDropGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      case 5:
        return SyllableReverseGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      case 6:
        return SyllableReplaceGame(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onGameComplete,
        );
      default:
        return const Center(child: Text('게임 준비 중'));
    }
  }
}

class GameInfo {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final String category;

  GameInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}

