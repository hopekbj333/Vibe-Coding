import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';
import 'n_back_game.dart';
import 'card_match_game.dart';
import 'instruction_follow_game.dart';
import 'reverse_touch_game.dart';
import 'reverse_speak_game.dart';

/// 작업 기억 훈련 메인 페이지 (WP 3.4)
class WorkingMemoryTrainingPage extends StatefulWidget {
  final String childId;

  const WorkingMemoryTrainingPage({
    super.key,
    required this.childId,
  });

  @override
  State<WorkingMemoryTrainingPage> createState() =>
      _WorkingMemoryTrainingPageState();
}

class _WorkingMemoryTrainingPageState extends State<WorkingMemoryTrainingPage> {
  // 게임 목록
  static const List<Map<String, dynamic>> _games = [
    {
      'id': 'n_back',
      'title': 'N-Back 게임',
      'subtitle': 'N개 전과 같으면 터치해요',
      'emoji': '🧠',
      'color': Color(0xFF6B4EFF),
      'scenario': 'S 3.4.1',
      'category': '기억 폭 확장',
    },
    {
      'id': 'card_match',
      'title': '카드 짝 맞추기',
      'subtitle': '카드를 뒤집어 짝을 찾아요',
      'emoji': '🃏',
      'color': Colors.orange,
      'scenario': 'S 3.4.2',
      'category': '기억 폭 확장',
    },
    {
      'id': 'instruction_follow',
      'title': '지시 따르기',
      'subtitle': '여러 지시를 순서대로 수행해요',
      'emoji': '📝',
      'color': Colors.indigo,
      'scenario': 'S 3.4.3',
      'category': '기억 폭 확장',
    },
    {
      'id': 'reverse_touch',
      'title': '거꾸로 터치',
      'subtitle': '순서를 거꾸로 기억해요',
      'emoji': '🔄',
      'color': Color(0xFF1A1A2E),
      'scenario': 'S 3.4.4',
      'category': '역순 기억',
    },
    {
      'id': 'reverse_speak',
      'title': '거꾸로 기억하기',
      'subtitle': '단어를 거꾸로 기억해요',
      'emoji': '🔊',
      'color': Colors.teal,
      'scenario': 'S 3.4.5',
      'category': '역순 기억',
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
    final percentage =
        _lastTotal > 0 ? (_lastScore / _lastTotal * 100).round() : 0;

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
                  ? '작업 기억 능력이 좋아지고 있어요!'
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
      case 'n_back':
        return NBackGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'card_match':
        return CardMatchGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'instruction_follow':
        return InstructionFollowGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'reverse_touch':
        return ReverseTouchGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'reverse_speak':
        return ReverseSpeakGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      default:
        return _buildGameList();
    }
  }

  Widget _buildGameList() {
    // 카테고리별 그룹화
    final expansionGames =
        _games.where((g) => g['category'] == '기억 폭 확장').toList();
    final reverseGames = _games.where((g) => g['category'] == '역순 기억').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('🧠 작업 기억 훈련'),
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
                    colors: [Colors.purple[100]!, Colors.indigo[100]!],
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
                        Text('💭', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Text(
                          '기억하고 생각하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '정보를 기억하면서 동시에 생각하는 능력을 키워요.\n'
                      '이 능력은 읽고 계산하는 데 중요해요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 기억 폭 확장 섹션
              _buildSectionHeader('📚 기억 폭 확장', '더 많이 기억해요'),
              ...expansionGames.map((game) => _buildGameCard(game)),

              const SizedBox(height: 16),

              // 역순 기억 섹션
              _buildSectionHeader('🔄 역순 기억', '거꾸로 생각해요'),
              ...reverseGames.map((game) => _buildGameCard(game)),

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

