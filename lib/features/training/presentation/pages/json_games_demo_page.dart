import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../modules/phonological/same_sound_game_v2.dart';
import '../modules/phonological/different_sound_game_v2.dart';
import '../modules/phonological3/syllable_clap_game_v2.dart';
import '../modules/working_memory/card_match_game_v2.dart';
import '../modules/phonological2/rhyme_game_v2.dart';
import '../modules/phonological3/syllable_merge_game_v2.dart';
import '../modules/phonological3/syllable_split_game_v2.dart';
import '../modules/phonological/rhythm_follow_game_v2.dart';
import '../modules/phonological4/onset_separation_game_v2.dart';
import '../modules/phonological4/phoneme_synthesis_game_v2.dart';
import '../modules/auditory/animal_sound_story_game_v2.dart';
import '../modules/auditory/sound_rule_game_v2.dart';
import '../modules/visual/hidden_letter_game_v2.dart';
import '../modules/visual/letter_direction_game_v2.dart';
import '../modules/visual/mirror_symmetry_game_v2.dart';
import '../modules/working_memory/instruction_follow_game_v2.dart';
import '../modules/working_memory/n_back_game_v2.dart';
import '../modules/working_memory/reverse_speak_game_v2.dart';
import '../modules/working_memory/reverse_touch_game_v2.dart';
import '../modules/working_memory/digit_span_game_v2.dart';
import '../modules/attention/dual_task_game_v2.dart';
import '../modules/attention/auditory_attention_game_v2.dart';
import '../modules/attention/flow_tracking_game_v2.dart';
import '../modules/attention/focus_marathon_game_v2.dart';
import '../modules/attention/stroop_game_v2.dart';
import '../modules/attention/target_hunt_game_v2.dart';
import '../modules/visual/puzzle_game_v2.dart';
import '../modules/visual/shape_rotation_game_v2.dart';
import '../modules/phonological4/phoneme_substitution_game_v2.dart';
import '../modules/auditory/volume_comparison_game_v2.dart';
import '../modules/auditory/environmental_sound_game_v2.dart';
import '../modules/visual/visual_tracking_game_v2.dart';
import '../modules/attention/go_no_go_basic_game_v2.dart';
import '../modules/working_memory/location_memory_game_v2.dart';
import '../modules/auditory/instrument_sequence_game_v2.dart';
import '../modules/auditory/rhythm_pattern_game_v2.dart';
import '../modules/auditory/simon_says_game_v2.dart';
import '../modules/auditory/sound_sequence_memory_game_v2.dart';
import '../modules/auditory/pitch_discrimination_game_v2.dart';
import '../modules/auditory/tempo_sequence_game_v2.dart';
import '../modules/visual/spot_difference_game_v2.dart';
import '../modules/visual/visual_closure_game_v2.dart';
import '../modules/visual/figure_ground_game_v2.dart';
import '../modules/visual/pattern_completion_game_v2.dart';
import '../modules/working_memory/updating_memory_game_v2.dart';
import '../modules/working_memory/complex_span_game_v2.dart';
import '../modules/attention/selective_attention_game_v2.dart';
import '../modules/attention/divided_attention_game_v2.dart';
import '../modules/attention/sustained_attention_game_v2.dart';
import '../modules/attention/visual_search_game_v2.dart';

/// JSON 기반 게임 데모 페이지
/// 
/// 문항 관리 시스템 테스트용 페이지
class JsonGamesDemoPage extends StatefulWidget {
  final String childId;

  const JsonGamesDemoPage({
    super.key,
    required this.childId,
  });

  @override
  State<JsonGamesDemoPage> createState() => _JsonGamesDemoPageState();
}

class _JsonGamesDemoPageState extends State<JsonGamesDemoPage> {
  String? _selectedGame;
  int _difficultyLevel = 1;
  int _correctCount = 0;
  int _totalCount = 0;

  void _onAnswer(bool isCorrect, int responseTime) {
    setState(() {
      _totalCount++;
      if (isCorrect) _correctCount++;
    });
    
    debugPrint('Answer: ${isCorrect ? "Correct" : "Wrong"} (${responseTime}ms)');
  }

  void _onComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 게임 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 문항: $_totalCount개'),
            Text('정답: $_correctCount개'),
            Text('정답률: ${(_correctCount / _totalCount * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _correctCount = 0;
                _totalCount = 0;
              });
            },
            child: const Text('다시 하기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedGame = null;
                _correctCount = 0;
                _totalCount = 0;
              });
            },
            child: const Text('다른 게임'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton({
    required String title,
    required String subtitle,
    required String gameId,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGame = gameId;
            _correctCount = 0;
            _totalCount = 0;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 JSON 문항 관리 시스템 데모'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        leading: _selectedGame != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedGame = null;
                    _correctCount = 0;
                    _totalCount = 0;
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/home'),
              ),
      ),
      body: _selectedGame == null ? _buildGameList() : _buildGameScreen(),
    );
  }

  Widget _buildGameList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ 새로운 문항 관리 시스템',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'JSON 파일 기반으로 대량 문항 제작 가능',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatChip('650개 문항', Icons.quiz),
                    const SizedBox(width: 8),
                    _buildStatChip('50개 게임', Icons.gamepad),
                    const SizedBox(width: 8),
                    _buildStatChip('JSON 기반', Icons.data_object),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 난이도 선택
          const Text(
            '난이도 선택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [1, 2, 3].map((level) {
              return ChoiceChip(
                label: Text('난이도 $level'),
                selected: _difficultyLevel == level,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _difficultyLevel = level);
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 게임 목록
          const Text(
            'POC 게임 (JSON 기반)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildGameButton(
            title: '같은 소리 찾기',
            subtitle: '50개 문항 • 악기/동물/환경음',
            gameId: 'same_sound',
            icon: Icons.volume_up,
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '다른 소리 찾기',
            subtitle: '50개 문항 • 3개 중 다른 1개',
            gameId: 'different_sound',
            icon: Icons.hearing,
            color: Colors.deepOrange,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '박수로 음절 쪼개기',
            subtitle: '50개 문항 • 2~6음절',
            gameId: 'syllable_clap',
            icon: Icons.touch_app,
            color: Colors.purple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '카드 짝 맞추기',
            subtitle: '16개 문항 • 3~6쌍',
            gameId: 'card_match',
            icon: Icons.style,
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '각운 찾기',
            subtitle: '50개 문항 • 끝소리가 같은 단어',
            gameId: 'rhyme',
            icon: Icons.music_note_outlined,
            color: Colors.pink,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '음절 합성',
            subtitle: '50개 문항 • 2~4음절 블록 합치기',
            gameId: 'syllable_merge',
            icon: Icons.add_circle_outline,
            color: Colors.teal,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '음절 분리',
            subtitle: '50개 문항 • 단어를 음절로 쪼개기',
            gameId: 'syllable_split',
            icon: Icons.call_split,
            color: Colors.indigo,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '리듬 따라하기',
            subtitle: '50개 문항 • 리듬 패턴 따라 치기',
            gameId: 'rhythm_follow',
            icon: Icons.music_note,
            color: Colors.green,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '초성 분리',
            subtitle: '50개 문항 • 단어의 첫소리 찾기',
            gameId: 'onset_separation',
            icon: Icons.text_fields,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '음소 합성',
            subtitle: '50개 문항 • 자음+모음 합치기',
            gameId: 'phoneme_synthesis',
            icon: Icons.merge_type,
            color: Colors.amber,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '동물 소리 이야기',
            subtitle: '50개 문항 • 소리 순서 기억하기',
            gameId: 'animal_sound_story',
            icon: Icons.pets,
            color: Colors.brown,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '숨은 글자 찾기',
            subtitle: '6개 문항 • 그리드에서 찾기',
            gameId: 'hidden_letter',
            icon: Icons.search,
            color: Colors.cyan,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '글자 방향 구별',
            subtitle: '50개 문항 • 방향이 다른 글자',
            gameId: 'letter_direction',
            icon: Icons.compare_arrows,
            color: Colors.lime,
          ),

          const SizedBox(height: 12),


          _buildGameButton(
            title: '소리 규칙 찾기',
            subtitle: '10개 문항 • 패턴 예측',
            gameId: 'sound_rule',
            icon: Icons.psychology,
            color: Colors.purple.shade300,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '거울 대칭',
            subtitle: '10개 문항 • 대칭 찾기',
            gameId: 'mirror_symmetry',
            icon: Icons.flip,
            color: Colors.cyan.shade600,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '소리 크기 비교',
            subtitle: '5개 문항 • 크고 작은 소리',
            gameId: 'volume_comparison',
            icon: Icons.volume_up,
            color: Colors.green,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '환경음 식별',
            subtitle: '6개 문항 • 주변 소리',
            gameId: 'environmental_sound',
            icon: Icons.public,
            color: Colors.teal,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '악기 순서 기억',
            subtitle: '3개 문항 • 악기 시퀀스',
            gameId: 'instrument_sequence',
            icon: Icons.queue_music,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '리듬 패턴',
            subtitle: '3개 문항 • 패턴 완성',
            gameId: 'rhythm_pattern',
            icon: Icons.graphic_eq,
            color: Colors.pink,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '사이먼 가라사대',
            subtitle: '2개 문항 • 색깔 순서',
            gameId: 'simon_says',
            icon: Icons.lightbulb,
            color: Colors.yellow.shade700,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '소리 순서 기억',
            subtitle: '2개 문항 • 순서 기억',
            gameId: 'sound_sequence_memory',
            icon: Icons.list,
            color: Colors.indigo,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '음높이 구별',
            subtitle: '3개 문항 • 높낮이',
            gameId: 'pitch_discrimination',
            icon: Icons.music_note,
            color: Colors.purple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '빠르기 순서',
            subtitle: '1개 문항 • 템포 비교',
            gameId: 'tempo_sequence',
            icon: Icons.speed,
            color: Colors.orange,
          ),

          const SizedBox(height: 24),

          // Working Memory 게임
          const Text(
            'Working Memory 게임',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildGameButton(
            title: '지시 따르기',
            subtitle: '2개 문항 • 지시 수행',
            gameId: 'instruction_follow',
            icon: Icons.rule,
            color: Colors.indigo,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: 'N-Back',
            subtitle: '2개 문항 • 기억 비교',
            gameId: 'n_back',
            icon: Icons.memory,
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '거꾸로 말하기',
            subtitle: '2개 문항 • 역순 말하기',
            gameId: 'reverse_speak',
            icon: Icons.record_voice_over,
            color: Colors.purple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '거꾸로 터치하기',
            subtitle: '2개 문항 • 역순 터치',
            gameId: 'reverse_touch',
            icon: Icons.touch_app,
            color: Colors.teal,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '숫자 외우기',
            subtitle: '2개 문항 • 숫자 기억',
            gameId: 'digit_span',
            icon: Icons.numbers,
            color: Colors.indigo,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '위치 기억',
            subtitle: '1개 문항 • 공간 기억',
            gameId: 'location_memory',
            icon: Icons.location_on,
            color: Colors.amber,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '업데이트 기억',
            subtitle: '1개 문항 • 최신 정보',
            gameId: 'updating_memory',
            icon: Icons.update,
            color: Colors.cyan,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '복합 기억 폭',
            subtitle: '1개 문항 • 복합 기억',
            gameId: 'complex_span',
            icon: Icons.layers,
            color: Colors.deepOrange,
          ),

          const SizedBox(height: 24),

          // Attention 게임
          const Text(
            'Attention 게임',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildGameButton(
            title: '이중 과제',
            subtitle: '1개 문항 • 두 가지 조건',
            gameId: 'dual_task',
            icon: Icons.splitscreen,
            color: Colors.deepOrange,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '청각 주의력',
            subtitle: '1개 문항 • 소리 듣기',
            gameId: 'auditory_attention',
            icon: Icons.hearing,
            color: Colors.cyan,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '흐름 추적',
            subtitle: '1개 문항 • 움직임 따라가기',
            gameId: 'flow_tracking',
            icon: Icons.track_changes,
            color: Colors.lightBlue,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '집중력 마라톤',
            subtitle: '1개 문항 • 지속 주의력',
            gameId: 'focus_marathon',
            icon: Icons.timer,
            color: Colors.amber,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '스트룹 과제',
            subtitle: '1개 문항 • 색상 판단',
            gameId: 'stroop',
            icon: Icons.palette,
            color: Colors.purple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '목표 찾기',
            subtitle: '1개 문항 • 시각 탐색',
            gameId: 'target_hunt',
            icon: Icons.search,
            color: Colors.teal,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: 'Go/No-Go 기본',
            subtitle: '5개 문항 • 선택적 반응',
            gameId: 'go_no_go_basic',
            icon: Icons.sports_score,
            color: Colors.lightGreen,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '선택적 주의',
            subtitle: '1개 문항 • 타겟 집중',
            gameId: 'selective_attention',
            icon: Icons.filter_alt,
            color: Colors.indigo,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '분할 주의',
            subtitle: '1개 문항 • 동시 처리',
            gameId: 'divided_attention',
            icon: Icons.call_split,
            color: Colors.pink,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '지속적 주의',
            subtitle: '1개 문항 • 30초 집중',
            gameId: 'sustained_attention',
            icon: Icons.access_time,
            color: Colors.red,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '시각 탐색',
            subtitle: '1개 문항 • 빠른 탐색',
            gameId: 'visual_search',
            icon: Icons.search_off,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 24),

          // Visual 게임
          const Text(
            'Visual 게임',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildGameButton(
            title: '퍼즐',
            subtitle: '1개 문항 • 조각 맞추기',
            gameId: 'puzzle',
            icon: Icons.extension,
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '도형 회전',
            subtitle: '1개 문항 • 회전 예측',
            gameId: 'shape_rotation',
            icon: Icons.rotate_right,
            color: Colors.brown,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '시각 추적',
            subtitle: '6개 문항 • 방향 경로',
            gameId: 'visual_tracking',
            icon: Icons.trending_up,
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '틀린 그림 찾기',
            subtitle: '1개 문항 • 차이 발견',
            gameId: 'spot_difference',
            icon: Icons.compare,
            color: Colors.red,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '부분으로 전체 추측',
            subtitle: '1개 문항 • 시각 완결',
            gameId: 'visual_closure',
            icon: Icons.visibility,
            color: Colors.lime,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '배경-전경 구별',
            subtitle: '1개 문항 • 물체 찾기',
            gameId: 'figure_ground',
            icon: Icons.layers_outlined,
            color: Colors.brown,
          ),

          const SizedBox(height: 12),

          _buildGameButton(
            title: '패턴 완성',
            subtitle: '3개 문항 • 규칙 찾기',
            gameId: 'pattern_completion',
            icon: Icons.grid_on,
            color: Colors.lightBlue,
          ),

          const SizedBox(height: 24),

          // Phonological 고급 게임
          const Text(
            'Phonological 고급',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildGameButton(
            title: '음소 대치',
            subtitle: '2개 문항 • 소리 바꾸기',
            gameId: 'phoneme_substitution',
            icon: Icons.swap_horiz,
            color: Colors.orange,
          ),

          const SizedBox(height: 24),

          // 시스템 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      '시스템 정보',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('데이터 소스', 'assets/questions/training/*.json'),
                _buildInfoRow('로딩 방식', 'QuestionLoaderService'),
                _buildInfoRow('모델', 'TrainingContentModel'),
                _buildInfoRow('확장성', '무제한 (Firebase 지원)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // 진행 상황
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreStat('정답', _correctCount, Colors.green),
              _buildScoreStat('오답', _totalCount - _correctCount, Colors.red),
              _buildScoreStat('총 문항', _totalCount, Colors.blue),
            ],
          ),
        ),
        
        // 게임 위젯
        Expanded(
          child: _buildGameWidget(),
        ),
      ],
    );
  }

  Widget _buildScoreStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGameWidget() {
    switch (_selectedGame) {
      case 'same_sound':
        return SameSoundGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'different_sound':
        return DifferentSoundGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'syllable_clap':
        return SyllableClapGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'card_match':
        return CardMatchGameV2(
          onComplete: _onComplete,
          onScoreUpdate: (score, level) {
            debugPrint('Score: $score, Level: $level');
          },
        );
      
      case 'rhyme':
        return RhymeGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'syllable_merge':
        return SyllableMergeGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'syllable_split':
        return SyllableSplitGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'rhythm_follow':
        return RhythmFollowGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'onset_separation':
        return OnsetSeparationGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'phoneme_synthesis':
        return PhonemeSynthesisGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'animal_sound_story':
        return AnimalSoundStoryGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'hidden_letter':
        return HiddenLetterGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'letter_direction':
        return LetterDirectionGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'sound_rule':
        return SoundRuleGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'mirror_symmetry':
        return MirrorSymmetryGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'instruction_follow':
        return InstructionFollowGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'n_back':
        return NBackGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'reverse_speak':
        return ReverseSpeakGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'reverse_touch':
        return ReverseTouchGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'digit_span':
        return DigitSpanGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'dual_task':
        return DualTaskGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'auditory_attention':
        return AuditoryAttentionGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'flow_tracking':
        return FlowTrackingGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'focus_marathon':
        return FocusMarathonGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'stroop':
        return StroopGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'target_hunt':
        return TargetHuntGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'puzzle':
        return PuzzleGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'shape_rotation':
        return ShapeRotationGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'phoneme_substitution':
        return PhonemeSubstitutionGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'volume_comparison':
        return VolumeComparisonGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'environmental_sound':
        return EnvironmentalSoundGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'visual_tracking':
        return VisualTrackingGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'go_no_go_basic':
        return GoNoGoBasicGameV2(
          childId: widget.childId,
          onAnswer: _onAnswer,
          onComplete: _onComplete,
          difficultyLevel: _difficultyLevel,
        );
      
      case 'location_memory':
        return LocationMemoryGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'instrument_sequence':
        return InstrumentSequenceGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'rhythm_pattern':
        return RhythmPatternGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'simon_says':
        return SimonSaysGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'sound_sequence_memory':
        return SoundSequenceMemoryGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'pitch_discrimination':
        return PitchDiscriminationGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'tempo_sequence':
        return TempoSequenceGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'spot_difference':
        return SpotDifferenceGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'visual_closure':
        return VisualClosureGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'figure_ground':
        return FigureGroundGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'pattern_completion':
        return PatternCompletionGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'updating_memory':
        return UpdatingMemoryGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'complex_span':
        return ComplexSpanGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'selective_attention':
        return SelectiveAttentionGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'divided_attention':
        return DividedAttentionGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'sustained_attention':
        return SustainedAttentionGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      case 'visual_search':
        return VisualSearchGameV2(childId: widget.childId, onAnswer: _onAnswer, onComplete: _onComplete, difficultyLevel: _difficultyLevel);
      
      default:
        return const Center(
          child: Text('게임을 선택하세요'),
        );
    }
  }
}
