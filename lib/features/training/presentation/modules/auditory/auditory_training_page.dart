import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';
import 'instrument_sequence_game.dart';
import 'animal_sound_story_game.dart';
import 'simon_says_game.dart';
import 'rhythm_pattern_game.dart';
import 'sound_rule_game.dart';

/// 청각/순차 처리 훈련 메인 페이지 (WP 3.2)
class AuditoryTrainingPage extends StatefulWidget {
  final String childId;

  const AuditoryTrainingPage({
    super.key,
    required this.childId,
  });

  @override
  State<AuditoryTrainingPage> createState() => _AuditoryTrainingPageState();
}

class _AuditoryTrainingPageState extends State<AuditoryTrainingPage> {
  // 게임 목록
  static const List<Map<String, dynamic>> _games = [
    {
      'id': 'instrument_sequence',
      'title': '악기 순서',
      'subtitle': '지휘자가 되어 악기 순서를 기억해요',
      'emoji': '🎼',
      'color': Color(0xFF6B4EFF),
      'scenario': 'S 3.2.1',
    },
    {
      'id': 'animal_story',
      'title': '동물 소리 이야기',
      'subtitle': '동물 친구들의 소리 순서를 맞춰요',
      'emoji': '🐾',
      'color': Colors.green,
      'scenario': 'S 3.2.2',
    },
    {
      'id': 'simon_says',
      'title': '사이먼 세즈',
      'subtitle': '빛과 소리의 순서를 따라해요',
      'emoji': '🎮',
      'color': Color(0xFF1A1A2E),
      'scenario': 'S 3.2.3',
    },
    {
      'id': 'rhythm_pattern',
      'title': '리듬 맞추기',
      'subtitle': '빠진 리듬을 찾아요',
      'emoji': '🎵',
      'color': Colors.orange,
      'scenario': 'S 3.2.4',
    },
    {
      'id': 'sound_rule',
      'title': '규칙 찾기',
      'subtitle': '소리의 규칙을 발견해요',
      'emoji': '🔍',
      'color': Colors.purple,
      'scenario': 'S 3.2.5',
    },
  ];

  String? _currentGame;
  int _lastScore = 0;
  int _lastTotal = 0;

  void _startGame(String gameId) {
    setState(() {
      _currentGame = gameId;
      _lastScore = 0;
      _lastTotal = 0;
    });
  }

  void _onGameComplete() {
    setState(() {
      _currentGame = null;
    });
    
    // 결과 다이얼로그 표시
    _showResultDialog();
  }

  void _onScoreUpdate(int score, int total) {
    setState(() {
      _lastScore = score;
      _lastTotal = total;
    });
  }

  void _showResultDialog() {
    final percentage = _lastTotal > 0 ? (_lastScore / _lastTotal * 100).round() : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(
              percentage >= 70 ? '🎉' : '💪',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Text(
              percentage >= 70 ? '잘했어요!' : '수고했어요!',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: percentage >= 70 ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '$_lastScore / $_lastTotal',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 70 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '정답률 $percentage%',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 70
                  ? '청각 순차 처리 능력이 좋아지고 있어요!'
                  : '조금 더 연습하면 더 잘할 수 있어요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGame != null) {
      return _buildGameScreen();
    }
    
    return _buildGameList();
  }

  Widget _buildGameScreen() {
    switch (_currentGame) {
      case 'instrument_sequence':
        return InstrumentSequenceGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'animal_story':
        return AnimalSoundStoryGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'simon_says':
        return SimonSaysGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'rhythm_pattern':
        return RhythmPatternGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'sound_rule':
        return SoundRuleGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      default:
        return _buildGameList();
    }
  }

  Widget _buildGameList() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('🎧 청각/순차 처리 훈련'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명 카드
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.purple[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('👂', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Text(
                        '소리 순서 기억하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '소리를 순서대로 듣고 기억하는 능력을 키워요.\n'
                    '이 능력은 말을 듣고 이해하는 데 중요해요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // 게임 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _buildGameCard(game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final color = game['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGame(game['id'] as String),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 이모지 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      game['emoji'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            game['title'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              game['scenario'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 화살표
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

