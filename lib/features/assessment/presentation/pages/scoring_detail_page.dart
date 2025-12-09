import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/question_model.dart';
import '../../data/models/scoring_model.dart';
import '../../data/repositories/mock_assessment_repository.dart';
import '../providers/scoring_providers.dart';

/// S 1.7.3 ~ S 1.7.5: 음성 채점 상세 화면
/// 
/// 녹음 파일을 재생하고 O/X/△로 채점합니다.
class ScoringDetailPage extends ConsumerStatefulWidget {
  final String resultId;

  const ScoringDetailPage({
    super.key,
    required this.resultId,
  });

  @override
  ConsumerState<ScoringDetailPage> createState() => _ScoringDetailPageState();
}

class _ScoringDetailPageState extends ConsumerState<ScoringDetailPage> {
  int _currentQuestionIndex = 0;
  final TextEditingController _memoController = TextEditingController();
  double _playbackSpeed = 1.0;
  bool _isPlaying = false;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _scoreQuestion(ScoringResult result) async {
    final assessmentResult =
        await ref.read(assessmentResultProvider(widget.resultId).future);
    
    // 미채점 문항만 필터링
    final unscoredQuestions = assessmentResult.scores
        .where((s) => s.result == ScoringResult.notScored)
        .toList();

    if (_currentQuestionIndex >= unscoredQuestions.length) return;

    final currentScore = unscoredQuestions[_currentQuestionIndex];
    final updatedScore = currentScore.copyWith(
      result: result,
      memo: _memoController.text.trim().isNotEmpty
          ? _memoController.text.trim()
          : null,
      scoredAt: DateTime.now(),
      scoredBy: 'current_user', // 실제로는 현재 사용자 ID
    );

    // 저장
    await ref
        .read(scoringRepositoryProvider)
        .saveQuestionScore(widget.resultId, updatedScore);

    // 다음 문항으로
    setState(() {
      _currentQuestionIndex++;
      _memoController.clear();
    });

    // 모든 문항 채점 완료 시
    if (_currentQuestionIndex >= unscoredQuestions.length) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('채점 완료'),
        content: const Text('모든 문항의 채점이 완료되었습니다!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // 다이얼로그 닫기
              Navigator.pop(context); // 채점 화면 닫기
            },
            child: const Text('목록으로'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // 다이얼로그 닫기
              Navigator.pop(context); // 채점 화면 닫기
              // 리포트 화면으로 이동
              context.push('/report/${widget.resultId}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('리포트 보기'),
          ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    // 실제로는 오디오 플레이어 제어
    if (_isPlaying) {
      print('🎵 재생 시작 (속도: ${_playbackSpeed}x)');
    } else {
      print('⏸️ 재생 일시정지');
    }
  }

  @override
  Widget build(BuildContext context) {
    final assessmentResultAsync =
        ref.watch(assessmentResultProvider(widget.resultId));

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray50,
      appBar: AppBar(
        title: const Text('음성 채점'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: assessmentResultAsync.when(
        data: (assessmentResult) {
          // 미채점 문항만 필터링
          final unscoredQuestions = assessmentResult.scores
              .where((s) => s.result == ScoringResult.notScored)
              .toList();

          if (unscoredQuestions.isEmpty) {
            return _buildAllScoredState();
          }

          if (_currentQuestionIndex >= unscoredQuestions.length) {
            return _buildAllScoredState();
          }

          final currentScore = unscoredQuestions[_currentQuestionIndex];
          
          // 문항 정보 가져오기 (실제로는 API에서)
          return _buildScoringInterface(
            assessmentResult,
            currentScore,
            unscoredQuestions.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류: $error'),
        ),
      ),
    );
  }

  Widget _buildAllScoredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 100,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            '모든 문항 채점 완료!',
            style: DesignSystem.textStyleLarge.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('목록으로 돌아가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringInterface(
    AssessmentResult assessmentResult,
    QuestionScore currentScore,
    int totalUnscoredQuestions,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 진행 상태
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '진행: ${_currentQuestionIndex + 1} / $totalUnscoredQuestions',
                    style: DesignSystem.textStyleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '문항 ID: ${currentScore.questionId}',
                    style: DesignSystem.textStyleSmall.copyWith(
                      color: DesignSystem.neutralGray600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 문제 지시문 (실제로는 문항 데이터에서 가져와야 함)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: DesignSystem.shadowSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '문제',
                    style: DesignSystem.textStyleSmall.copyWith(
                      color: DesignSystem.neutralGray500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getQuestionPrompt(currentScore.questionId),
                    style: DesignSystem.textStyleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    '정답 예시',
                    style: DesignSystem.textStyleSmall.copyWith(
                      color: DesignSystem.neutralGray500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCorrectAnswer(currentScore.questionId),
                    style: DesignSystem.textStyleMedium.copyWith(
                      color: DesignSystem.semanticSuccess,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 녹음 재생 섹션
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: DesignSystem.shadowSmall,
              ),
              child: Column(
                children: [
                  // 재생 버튼
                  InkWell(
                    onTap: _togglePlayback,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DesignSystem.primaryBlue,
                        boxShadow: _isPlaying
                            ? [
                                BoxShadow(
                                  color: DesignSystem.primaryBlue
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 재생 속도 조절
                  Text(
                    '재생 속도',
                    style: DesignSystem.textStyleSmall.copyWith(
                      color: DesignSystem.neutralGray500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SpeedButton(
                        speed: 0.75,
                        isSelected: _playbackSpeed == 0.75,
                        onTap: () => setState(() => _playbackSpeed = 0.75),
                      ),
                      const SizedBox(width: 12),
                      _SpeedButton(
                        speed: 1.0,
                        isSelected: _playbackSpeed == 1.0,
                        onTap: () => setState(() => _playbackSpeed = 1.0),
                      ),
                      const SizedBox(width: 12),
                      _SpeedButton(
                        speed: 1.25,
                        isSelected: _playbackSpeed == 1.25,
                        onTap: () => setState(() => _playbackSpeed = 1.25),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 메모 입력
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '메모 (선택사항)',
                hintText: '예: ㄱ/ㅋ 혼동, 발음이 불명확함',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // 채점 버튼
            Text(
              '채점하기',
              style: DesignSystem.textStyleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ScoringButton(
                    label: 'X\n오답',
                    color: DesignSystem.semanticError,
                    onTap: () => _scoreQuestion(ScoringResult.incorrect),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoringButton(
                    label: '△\n부분정답',
                    color: DesignSystem.semanticWarning,
                    onTap: () => _scoreQuestion(ScoringResult.partial),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScoringButton(
                    label: 'O\n정답',
                    color: DesignSystem.semanticSuccess,
                    onTap: () => _scoreQuestion(ScoringResult.correct),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionPrompt(String questionId) {
    // 실제로는 문항 데이터에서 가져와야 함
    if (questionId.contains('syllable_reverse')) {
      return '다음 단어를 거꾸로 말해보세요: "나비"';
    } else if (questionId.contains('digit')) {
      return '숫자를 따라 말하거나 거꾸로 말해보세요';
    } else if (questionId.contains('word')) {
      return '단어를 따라 말하거나 거꾸로 말해보세요';
    }
    return '음성 녹음 문항입니다. 녹음을 재생하고 채점하세요.';
  }

  String _getCorrectAnswer(String questionId) {
    if (questionId.contains('syllable_reverse')) {
      return '비나';
    } else if (questionId == 'q35_digit_forward') {
      return '2-5-9';
    } else if (questionId == 'q36_digit_backward') {
      return '7-3';
    }
    return '녹음 파일 확인 필요';
  }
}

/// 재생 속도 버튼
class _SpeedButton extends StatelessWidget {
  final double speed;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedButton({
    required this.speed,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primaryBlue
              : DesignSystem.neutralGray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? DesignSystem.primaryBlue
                : DesignSystem.neutralGray300,
            width: 2,
          ),
        ),
        child: Text(
          '${speed}x',
          style: DesignSystem.textStyleRegular.copyWith(
            color: isSelected ? Colors.white : DesignSystem.neutralGray800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 채점 버튼
class _ScoringButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ScoringButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: DesignSystem.textStyleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

