import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';
import 'spot_difference_game.dart';
import 'letter_direction_game.dart';
import 'hidden_letter_game.dart';
import 'puzzle_game.dart';
import 'shape_rotation_game.dart';
import 'mirror_symmetry_game.dart';

/// 시각 처리 훈련 메인 페이지 (WP 3.3)
class VisualTrainingPage extends StatefulWidget {
  final String childId;

  const VisualTrainingPage({
    super.key,
    required this.childId,
  });

  @override
  State<VisualTrainingPage> createState() => _VisualTrainingPageState();
}

class _VisualTrainingPageState extends State<VisualTrainingPage> {
  // 게임 목록
  static const List<Map<String, dynamic>> _games = [
    {
      'id': 'spot_difference',
      'title': '틀린 그림 찾기',
      'subtitle': '두 그림에서 다른 점을 찾아요',
      'emoji': '🔍',
      'color': Colors.amber,
      'scenario': 'S 3.3.1',
      'category': '시각 변별',
    },
    {
      'id': 'letter_direction',
      'title': '글자 방향 찾기',
      'subtitle': '비슷한 글자 중 목표 글자를 찾아요',
      'emoji': '👁️',
      'color': Colors.blue,
      'scenario': 'S 3.3.2',
      'category': '시각 변별',
    },
    {
      'id': 'hidden_letter',
      'title': '숨은 글자 찾기',
      'subtitle': '복잡한 배경에서 글자를 찾아요',
      'emoji': '🔎',
      'color': Colors.purple,
      'scenario': 'S 3.3.3',
      'category': '시각 변별',
    },
    {
      'id': 'puzzle',
      'title': '퍼즐 맞추기',
      'subtitle': '조각을 맞춰 그림을 완성해요',
      'emoji': '🧩',
      'color': Colors.green,
      'scenario': 'S 3.3.4',
      'category': '공간 인식',
    },
    {
      'id': 'shape_rotation',
      'title': '도형 회전',
      'subtitle': '도형을 돌리면 어떤 모양이 될까요?',
      'emoji': '🔄',
      'color': Colors.cyan,
      'scenario': 'S 3.3.5',
      'category': '공간 인식',
    },
    {
      'id': 'mirror_symmetry',
      'title': '거울 대칭',
      'subtitle': '거울에 비친 모습을 찾아요',
      'emoji': '🪞',
      'color': Colors.pink,
      'scenario': 'S 3.3.6',
      'category': '공간 인식',
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
                  ? '시각 처리 능력이 좋아지고 있어요!'
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
      case 'spot_difference':
        return SpotDifferenceGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'letter_direction':
        return LetterDirectionGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'hidden_letter':
        return HiddenLetterGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'puzzle':
        return PuzzleGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'shape_rotation':
        return ShapeRotationGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'mirror_symmetry':
        return MirrorSymmetryGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      default:
        return _buildGameList();
    }
  }

  Widget _buildGameList() {
    // 카테고리별 그룹화
    final visualGames = _games.where((g) => g['category'] == '시각 변별').toList();
    final spatialGames = _games.where((g) => g['category'] == '공간 인식').toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('👁️ 시각 처리 훈련'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명 카드
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[100]!, Colors.orange[100]!],
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
                        Text('👀', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Text(
                          '눈으로 잘 보기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '비슷한 글자를 구별하고, 공간을 이해하는 능력을 키워요.\n'
                      '이 능력은 글자를 읽는 데 중요해요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 시각 변별 섹션
              _buildSectionHeader('🔍 시각 변별', '비슷한 것들의 차이를 찾아요'),
              ...visualGames.map((game) => _buildGameCard(game)),
              
              const SizedBox(height: 16),
              
              // 공간 인식 섹션
              _buildSectionHeader('🧩 공간 인식', '공간과 모양을 이해해요'),
              ...spatialGames.map((game) => _buildGameCard(game)),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final color = game['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      game['emoji'] as String,
                      style: const TextStyle(fontSize: 28),
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

