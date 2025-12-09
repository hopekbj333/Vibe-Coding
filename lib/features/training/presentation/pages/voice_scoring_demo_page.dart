import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/stt_result_model.dart';
import '../../data/services/stt_service.dart';
import '../providers/stt_providers.dart';
import '../widgets/realtime_stt_widget.dart';
import '../widgets/auto_scoring_widget.dart';
import '../widgets/pronunciation_feedback_widget.dart';

/// 음성 채점 데모 페이지 (WP 2.7)
/// 
/// STT 연동, 자동 채점, 발음 피드백 기능을 테스트
class VoiceScoringDemoPage extends ConsumerStatefulWidget {
  final String childId;

  const VoiceScoringDemoPage({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<VoiceScoringDemoPage> createState() => _VoiceScoringDemoPageState();
}

class _VoiceScoringDemoPageState extends ConsumerState<VoiceScoringDemoPage> {
  int _selectedTab = 0;
  final SimulatedSttService _sttService = SimulatedSttService();

  // 테스트용 데이터
  SttResult? _sttResult;
  AutoScoringResult? _autoScoringResult;
  PronunciationScore? _pronunciationScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음성 채점 고도화'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 탭 바
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab(0, '🎙️ 실시간 STT', Icons.mic),
                _buildTab(1, '⚡ 자동 채점', Icons.auto_awesome),
                _buildTab(2, '🗣️ 발음 피드백', Icons.record_voice_over),
              ],
            ),
          ),

          // 탭 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? DesignSystem.primaryBlue
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? DesignSystem.primaryBlue
                    : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? DesignSystem.primaryBlue
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildRealtimeSttDemo();
      case 1:
        return _buildAutoScoringDemo();
      case 2:
        return _buildPronunciationDemo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRealtimeSttDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDemoHeader(
          title: 'S 2.7.2: 실시간 음성 인식',
          description: '녹음과 동시에 STT 변환을 시도합니다. 마이크 버튼을 눌러 테스트하세요.',
        ),

        const SizedBox(height: 24),

        // 실시간 STT 위젯
        RealtimeSttWidget(
          onResult: (result) {
            setState(() {
              _sttResult = result;
            });
          },
        ),

        const SizedBox(height: 24),

        // 결과 표시
        if (_sttResult != null) ...[
          _buildSectionTitle('인식 결과'),
          const SizedBox(height: 12),
          _buildResultCard(_sttResult!),
        ],

        const SizedBox(height: 24),

        // 단일 변환 테스트
        ElevatedButton.icon(
          onPressed: _testSingleTranscription,
          icon: const Icon(Icons.play_arrow),
          label: const Text('단일 음성 인식 테스트'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoScoringDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDemoHeader(
          title: 'S 2.7.3-4: 자동 채점',
          description: 'STT 결과를 정답과 비교하여 자동으로 채점합니다.',
        ),

        const SizedBox(height: 24),

        // 테스트 정답 설정
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '테스트 문제',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('정답: "사과"'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _testAutoScoring,
                child: const Text('자동 채점 테스트'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 자동 채점 결과
        if (_autoScoringResult != null) ...[
          AutoScoringWidget(
            result: _autoScoringResult!,
            onPlayAudio: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔊 오디오 재생 (시뮬레이션)')),
              );
            },
            onConfirm: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ 정답 확정'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            onReject: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ 오답 확정'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],

        const SizedBox(height: 24),

        // 간소화된 채점 위젯 데모
        if (_sttResult != null) ...[
          _buildSectionTitle('간소화 채점 UI'),
          const SizedBox(height: 12),
          QuickScoringWidget(
            expectedAnswer: '사과',
            sttResult: _sttResult!,
            onPlayAudio: () {},
            onConfirmCorrect: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ 빠른 정답 처리')),
              );
            },
            onConfirmIncorrect: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ 빠른 오답 처리')),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPronunciationDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDemoHeader(
          title: 'S 2.7.5: 발음 정확도 피드백',
          description: '음소별 발음 정확도를 측정하고 피드백을 제공합니다.',
        ),

        const SizedBox(height: 24),

        // 발음 분석 테스트
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '테스트 단어',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '"강아지"를 발음해보세요',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _testPronunciationAnalysis,
                icon: const Icon(Icons.record_voice_over),
                label: const Text('발음 분석 테스트'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primaryBlue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 발음 점수 뱃지
        if (_pronunciationScore != null) ...[
          Row(
            children: [
              PronunciationScoreBadge(score: _pronunciationScore!.overallScore),
              const SizedBox(width: 12),
              Text(
                _pronunciationScore!.isGood ? '좋은 발음이에요!' : '연습이 필요해요',
                style: TextStyle(
                  color: _pronunciationScore!.isGood
                      ? DesignSystem.semanticSuccess
                      : DesignSystem.semanticWarning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 상세 피드백
          PronunciationFeedbackWidget(
            score: _pronunciationScore!,
            onRetry: () {
              setState(() {
                _pronunciationScore = null;
              });
            },
            onContinue: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('다음 단계로 진행!')),
              );
            },
          ),
        ],

        const SizedBox(height: 24),

        // 발음 힌트 예시
        _buildSectionTitle('발음 힌트 예시'),
        const SizedBox(height: 12),
        const PronunciationHintWidget(
          phoneme: 'ㄱ',
          hint: '혀 뒤쪽을 목 근처에 붙였다가 터뜨리면서 내는 소리예요. "가"를 말할 때 첫소리를 느껴보세요!',
        ),
      ],
    );
  }

  Widget _buildDemoHeader({
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildResultCard(SttResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('인식 텍스트:', style: TextStyle(color: Colors.grey)),
              SttResultBadge(result: result),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('신뢰도:', style: TextStyle(color: Colors.grey)),
              Text(
                '${result.confidencePercent}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: result.isHighConfidence
                      ? DesignSystem.semanticSuccess
                      : result.isLowConfidence
                          ? DesignSystem.semanticError
                          : DesignSystem.semanticWarning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('수동 확인 필요:', style: TextStyle(color: Colors.grey)),
              Text(
                result.needsManualReview ? '예' : '아니오',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: result.needsManualReview
                      ? DesignSystem.semanticWarning
                      : DesignSystem.semanticSuccess,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _testSingleTranscription() async {
    final result = await _sttService.transcribeAudio('test_audio.wav');
    setState(() {
      _sttResult = result;
    });
  }

  Future<void> _testAutoScoring() async {
    final autoScoringService = AutoScoringService(_sttService);
    final result = await autoScoringService.scoreAnswer(
      questionId: 'test_question_1',
      audioPath: 'test_audio.wav',
      expectedAnswer: '사과',
    );

    setState(() {
      _autoScoringResult = result;
      _sttResult = result.sttResult;
    });
  }

  Future<void> _testPronunciationAnalysis() async {
    final score = await _sttService.analyzePronunciation(
      'test_audio.wav',
      '강아지',
    );

    setState(() {
      _pronunciationScore = score;
    });
  }
}

