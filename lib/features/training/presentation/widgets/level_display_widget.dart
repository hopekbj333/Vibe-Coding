import 'package:flutter/material.dart';
import '../../data/models/tracking_models.dart';

/// S 3.6.5: 레벨 표시 위젯
class LevelDisplayWidget extends StatelessWidget {
  final LevelInfo levelInfo;
  final bool compact;

  const LevelDisplayWidget({
    super.key,
    required this.levelInfo,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView();
    }
    return _buildFullView();
  }

  Widget _buildCompactView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            levelInfo.characterEmoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            'Lv.${levelInfo.currentLevel}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.indigo[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 캐릭터 진화 표시
          _buildEvolutionPath(),
          const SizedBox(height: 20),
          
          // 현재 상태
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 캐릭터
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    levelInfo.characterEmoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 레벨 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelInfo.characterName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lv.${levelInfo.currentLevel}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // XP 바
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '경험치',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${levelInfo.currentXP} / ${levelInfo.xpToNextLevel} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: levelInfo.progressPercent,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              Text(
                '다음 레벨까지 ${levelInfo.xpToNextLevel - levelInfo.currentXP} XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionPath() {
    final stages = [
      {'level': 1, 'emoji': '🐣'},
      {'level': 5, 'emoji': '🐥'},
      {'level': 10, 'emoji': '🐔'},
      {'level': 20, 'emoji': '🦅'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isReached = levelInfo.currentLevel >= (stage['level'] as int);
        final isCurrent = levelInfo.characterEmoji == stage['emoji'];

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: isCurrent ? 40 : 32,
                  height: isCurrent ? 40 : 32,
                  decoration: BoxDecoration(
                    color: isReached ? Colors.white24 : Colors.white10,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      stage['emoji'] as String,
                      style: TextStyle(
                        fontSize: isCurrent ? 24 : 18,
                        color: isReached ? null : Colors.white30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lv.${stage['level']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isReached ? Colors.white : Colors.white38,
                  ),
                ),
              ],
            ),
            if (index < stages.length - 1)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: isReached ? Colors.white38 : Colors.white10,
              ),
          ],
        );
      }).toList(),
    );
  }
}

