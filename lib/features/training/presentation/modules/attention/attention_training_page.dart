import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/design/design_system.dart';
import 'target_hunt_game.dart';
import 'stroop_game.dart';
import 'auditory_attention_game.dart';
import 'focus_marathon_game.dart';
import 'flow_tracking_game.dart';

/// 주의 집중 훈련 메인 페이지 (WP 3.5)
class AttentionTrainingPage extends StatefulWidget {
  final String childId;

  const AttentionTrainingPage({
    super.key,
    required this.childId,
  });

  @override
  State<AttentionTrainingPage> createState() => _AttentionTrainingPageState();
}

class _AttentionTrainingPageState extends State<AttentionTrainingPage> {
  // 게임 목록
  static const List<Map<String, dynamic>> _games = [
    {
      'id': 'target_hunt',
      'title': '목표물 사냥',
      'subtitle': '움직이는 목표물만 잡아요',
      'emoji': '🎯',
      'color': Color(0xFF4CAF50),
      'scenario': 'S 3.5.1',
      'category': '선택적 주의',
    },
    {
      'id': 'stroop',
      'title': '색깔 맞추기',
      'subtitle': '그림과 색깔이 맞는지 판단해요',
      'emoji': '🎨',
      'color': Colors.deepPurple,
      'scenario': 'S 3.5.2',
      'category': '선택적 주의',
    },
    {
      'id': 'auditory_attention',
      'title': '소리 찾기',
      'subtitle': '목표 소리가 나면 터치해요',
      'emoji': '👂',
      'color': Color(0xFF263238),
      'scenario': 'S 3.5.3',
      'category': '선택적 주의',
    },
    {
      'id': 'focus_marathon',
      'title': '집중력 마라톤',
      'subtitle': '2분 동안 별만 터치해요',
      'emoji': '🏃',
      'color': Color(0xFF1E88E5),
      'scenario': 'S 3.5.4',
      'category': '지속적 주의',
    },
    {
      'id': 'flow_tracking',
      'title': '흐름 따라가기',
      'subtitle': '움직이는 것을 계속 따라가요',
      'emoji': '👆',
      'color': Color(0xFF26A69A),
      'scenario': 'S 3.5.5',
      'category': '지속적 주의',
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
                    '$_lastScore',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 70 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const Text(
                    '점수',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 70
                  ? '집중력이 좋아지고 있어요!'
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
      case 'target_hunt':
        return TargetHuntGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'stroop':
        return StroopGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'auditory_attention':
        return AuditoryAttentionGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'focus_marathon':
        return FocusMarathonGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'flow_tracking':
        return FlowTrackingGame(
          onComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      default:
        return _buildGameList();
    }
  }

  Widget _buildGameList() {
    // 카테고리별 그룹화
    final selectiveGames =
        _games.where((g) => g['category'] == '선택적 주의').toList();
    final sustainedGames =
        _games.where((g) => g['category'] == '지속적 주의').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('🎯 주의 집중 훈련'),
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
                    colors: [Colors.blue[100]!, Colors.cyan[100]!],
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
                        Text('🎯', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Text(
                          '집중력 키우기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '필요한 것에만 집중하고, 오랫동안 집중을 유지하는\n'
                      '능력을 키워요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 선택적 주의 섹션
              _buildSectionHeader('🔍 선택적 주의', '원하는 것만 집중해요'),
              ...selectiveGames.map((game) => _buildGameCard(game)),

              const SizedBox(height: 16),

              // 지속적 주의 섹션
              _buildSectionHeader('⏱️ 지속적 주의', '오래 집중해요'),
              ...sustainedGames.map((game) => _buildGameCard(game)),

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

