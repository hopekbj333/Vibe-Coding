import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/training_content_model.dart';
import '../../data/models/difficulty_params_model.dart';
import '../games/patterns/game_patterns.dart';

/// 게임 패턴 데모 페이지
/// 
/// WP 2.2에서 구현한 6가지 게임 패턴을 테스트할 수 있는 페이지입니다.
class GamePatternsDemoPage extends StatefulWidget {
  final String childId;
  
  const GamePatternsDemoPage({
    super.key,
    required this.childId,
  });

  @override
  State<GamePatternsDemoPage> createState() => _GamePatternsDemoPageState();
}

class _GamePatternsDemoPageState extends State<GamePatternsDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 패턴 데모'),
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
          const Text(
            '🎮 WP 2.2: 게임 패턴 테스트',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '각 패턴을 선택하여 테스트해보세요.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // O/X 퀴즈
          _buildPatternCard(
            title: 'O/X 퀴즈',
            description: '맞으면 O, 틀리면 X를 선택하세요.',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            pattern: GamePattern.oxQuiz,
          ),
          
          // N지선다
          _buildPatternCard(
            title: 'N지선다 (객관식)',
            description: '여러 보기 중에서 정답을 고르세요.',
            icon: Icons.grid_view,
            color: Colors.blue,
            pattern: GamePattern.multipleChoice,
          ),
          
          // 짝맞추기
          _buildPatternCard(
            title: '짝맞추기',
            description: '서로 관련 있는 것끼리 연결하세요.',
            icon: Icons.link,
            color: Colors.orange,
            pattern: GamePattern.matching,
          ),
          
          // 순서 맞추기
          _buildPatternCard(
            title: '순서 맞추기',
            description: '올바른 순서대로 정렬하세요.',
            icon: Icons.sort,
            color: Colors.purple,
            pattern: GamePattern.sequencing,
          ),
          
          // Go/No-Go
          _buildPatternCard(
            title: 'Go/No-Go',
            description: '특정 자극에만 반응하세요.',
            icon: Icons.touch_app,
            color: Colors.red,
            pattern: GamePattern.goNoGo,
          ),
          
          // 리듬 탭
          _buildPatternCard(
            title: '리듬 탭',
            description: '리듬에 맞춰 화면을 탭하세요.',
            icon: Icons.music_note,
            color: Colors.teal,
            pattern: GamePattern.rhythmTap,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPatternCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required GamePattern pattern,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _openPatternDemo(pattern),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openPatternDemo(GamePattern pattern) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatternDemoScreen(
          pattern: pattern,
          childId: widget.childId,
        ),
      ),
    );
  }
}

/// 개별 패턴 데모 화면
class PatternDemoScreen extends StatefulWidget {
  final GamePattern pattern;
  final String childId;
  
  const PatternDemoScreen({
    super.key,
    required this.pattern,
    required this.childId,
  });

  @override
  State<PatternDemoScreen> createState() => _PatternDemoScreenState();
}

class _PatternDemoScreenState extends State<PatternDemoScreen> {
  int _currentQuestionIndex = 0;
  late List<ContentItem> _demoItems;
  
  @override
  void initState() {
    super.initState();
    _demoItems = _createDemoItems(widget.pattern);
  }
  
  List<ContentItem> _createDemoItems(GamePattern pattern) {
    switch (pattern) {
      case GamePattern.oxQuiz:
        return [
          ContentItem(
            itemId: 'ox1',
            question: '사과는 빨간색이다?',
            options: [
              ContentOption(optionId: 'O', label: 'O'),
              ContentOption(optionId: 'X', label: 'X'),
            ],
            correctAnswer: 'O',
          ),
          ContentItem(
            itemId: 'ox2',
            question: '바나나는 파란색이다?',
            options: [
              ContentOption(optionId: 'O', label: 'O'),
              ContentOption(optionId: 'X', label: 'X'),
            ],
            correctAnswer: 'X',
          ),
        ];
      
      case GamePattern.multipleChoice:
        return [
          ContentItem(
            itemId: 'mc1',
            question: '다음 중 과일은?',
            options: [
              ContentOption(optionId: 'a', label: '당근'),
              ContentOption(optionId: 'b', label: '사과'),
              ContentOption(optionId: 'c', label: '양파'),
            ],
            correctAnswer: 'b',
          ),
          ContentItem(
            itemId: 'mc2',
            question: '동물은 어떤 것?',
            options: [
              ContentOption(optionId: 'a', label: '책상'),
              ContentOption(optionId: 'b', label: '연필'),
              ContentOption(optionId: 'c', label: '강아지'),
              ContentOption(optionId: 'd', label: '의자'),
            ],
            correctAnswer: 'c',
          ),
        ];
      
      case GamePattern.matching:
        return [
          ContentItem(
            itemId: 'match1',
            question: '같은 동물끼리 연결하세요',
            options: [
              ContentOption(
                optionId: 'l1', 
                label: '강아지 🐕',
                optionData: {'group': 'left', 'matchId': 'dog'},
              ),
              ContentOption(
                optionId: 'l2', 
                label: '고양이 🐈',
                optionData: {'group': 'left', 'matchId': 'cat'},
              ),
              ContentOption(
                optionId: 'r1', 
                label: '멍멍이',
                optionData: {'group': 'right', 'matchId': 'dog'},
              ),
              ContentOption(
                optionId: 'r2', 
                label: '야옹이',
                optionData: {'group': 'right', 'matchId': 'cat'},
              ),
            ],
            correctAnswer: '',
          ),
        ];
      
      case GamePattern.sequencing:
        return [
          ContentItem(
            itemId: 'seq1',
            question: '아침에 일어나는 순서대로 정렬하세요',
            options: [
              ContentOption(
                optionId: 's1', 
                label: '일어나기',
                optionData: {'order': 1},
              ),
              ContentOption(
                optionId: 's2', 
                label: '세수하기',
                optionData: {'order': 2},
              ),
              ContentOption(
                optionId: 's3', 
                label: '아침 먹기',
                optionData: {'order': 3},
              ),
              ContentOption(
                optionId: 's4', 
                label: '학교 가기',
                optionData: {'order': 4},
              ),
            ],
            correctAnswer: '',
          ),
        ];
      
      case GamePattern.goNoGo:
        return [
          ContentItem(
            itemId: 'gng1',
            question: '토끼가 나오면 터치, 늑대는 참기!',
            options: [
              ContentOption(
                optionId: 'go1', 
                label: '🐰',
                optionData: {'type': 'go'},
              ),
              ContentOption(
                optionId: 'nogo1', 
                label: '🐺',
                optionData: {'type': 'nogo'},
              ),
            ],
            correctAnswer: '',
          ),
        ];
      
      case GamePattern.rhythmTap:
        return [
          ContentItem(
            itemId: 'rhythm1',
            question: '리듬을 따라 화면을 탭하세요!',
            options: [],
            correctAnswer: '',
            itemData: {
              'rhythm': [500, 500, 500, 500], // 4비트, 500ms 간격
            },
          ),
        ];
      
      case GamePattern.recording:
        return [
          ContentItem(
            itemId: 'rec1',
            question: '단어를 따라 말해보세요!',
            options: [],
            correctAnswer: '나비',
          ),
        ];
    }
  }
  
  void _onAnswer(bool isCorrect, int responseTimeMs) {
    debugPrint('Answer: $isCorrect, Time: ${responseTimeMs}ms');
  }
  
  void _onComplete(dynamic arg1, dynamic arg2) {
    debugPrint('Complete: $arg1, $arg2');
  }
  
  void _onNext() {
    if (_currentQuestionIndex < _demoItems.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('완료! 🎉'),
        content: const Text('모든 문제를 완료했습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
              });
            },
            child: const Text('다시 하기'),
          ),
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

  @override
  Widget build(BuildContext context) {
    final currentItem = _demoItems[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pattern.koreanName),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _buildPatternWidget(widget.pattern, currentItem),
      ),
    );
  }
  
  Widget _buildPatternWidget(GamePattern pattern, ContentItem item) {
    switch (pattern) {
      case GamePattern.oxQuiz:
        return OxQuizPattern(
          item: item,
          onAnswer: _onAnswer,
          onNext: _onNext,
          questionIndex: _currentQuestionIndex,
          totalQuestions: _demoItems.length,
        );
      
      case GamePattern.multipleChoice:
        return MultipleChoicePattern(
          item: item,
          onAnswer: _onAnswer,
          onNext: _onNext,
          questionIndex: _currentQuestionIndex,
          totalQuestions: _demoItems.length,
          choiceStyle: ChoiceStyle.textOnly,
        );
      
      case GamePattern.matching:
        return MatchingPattern(
          item: item,
          onComplete: _onComplete,
          onNext: _onNext,
          mode: MatchingMode.dragLine,
          questionIndex: _currentQuestionIndex,
          totalQuestions: _demoItems.length,
        );
      
      case GamePattern.sequencing:
        return SequencingPattern(
          item: item,
          onComplete: _onComplete,
          onNext: _onNext,
          mode: SequencingMode.sequentialTap,
          questionIndex: _currentQuestionIndex,
          totalQuestions: _demoItems.length,
        );
      
      case GamePattern.goNoGo:
        return GoNoGoPattern(
          item: item,
          onComplete: _onComplete,
          onNext: _onNext,
          totalTrials: 5,
          stimulusDuration: 1200,
          interStimulusInterval: 800,
          questionIndex: _currentQuestionIndex,
          totalQuestions: _demoItems.length,
        );
      
      case GamePattern.rhythmTap:
        return RhythmTapPattern(
          item: item,
          onComplete: _onComplete,
          onNext: _onNext,
          toleranceMs: 350,
          questionIndex: _currentQuestionIndex,
          totalQuestions: _demoItems.length,
        );
      
      case GamePattern.recording:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎤 녹음 패턴', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(item.question, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _onNext,
                child: const Text('다음'),
              ),
            ],
          ),
        );
    }
  }
}

