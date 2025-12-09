import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../data/models/learning_progress_model.dart';
import '../../domain/services/learning_recommendation_service.dart';
import '../providers/learning_management_providers.dart';
import '../widgets/progress_map_widget.dart';
import '../widgets/session_timer_widget.dart';
import '../widgets/today_learning_widget.dart';

/// 학습 관리 메인 페이지
/// 
/// 오늘의 학습, 진도 맵, 추천 콘텐츠를 표시
class LearningManagementPage extends ConsumerStatefulWidget {
  final String childId;
  final String? childName;

  const LearningManagementPage({
    super.key,
    required this.childId,
    this.childName,
  });

  @override
  ConsumerState<LearningManagementPage> createState() => _LearningManagementPageState();
}

class _LearningManagementPageState extends ConsumerState<LearningManagementPage> {
  late LearningManagementInitializer _initializer;
  TodayLearningPlan? _todayPlan;

  @override
  void initState() {
    super.initState();
    _initializer = LearningManagementInitializer(ref);
    
    // 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLearning();
    });
  }

  void _initializeLearning() {
    _initializer.initializeForChild(widget.childId);
    
    // 오늘의 학습 계획 생성
    setState(() {
      _todayPlan = _initializer.generateTodayPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionTimer = ref.watch(sessionTimerProvider);
    final progressData = ref.watch(progressDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.childName ?? "아동"}의 학습'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 세션 타이머 (진행 중일 때만)
          if (sessionTimer.isActive)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SessionTimerWidget(
                remainingSeconds: sessionTimer.remainingSeconds,
                totalSeconds: sessionTimer.currentSession?.durationMinutes ?? 15 * 60,
                isCompact: true,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 학습
            if (_todayPlan != null)
              TodayLearningWidget(
                plan: _todayPlan!,
                onStartAll: _startTodayLearning,
                onActivityTap: _onActivityTap,
              ),

            const SizedBox(height: 24),

            // 학습 진도 맵
            if (progressData != null)
              ProgressMapWidget(
                progress: progressData,
                onStageTap: _onStageTap,
              ),

            const SizedBox(height: 24),

            // 복습 알림
            _buildReviewSection(),

            const SizedBox(height: 24),

            // 추천 모듈
            _buildRecommendedSection(),

            const SizedBox(height: 24),

            // 학습 설정
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    final todayReviews = ref.watch(todayReviewsProvider);
    final wrongAnswers = ref.watch(pendingWrongAnswersProvider);

    if (todayReviews.isEmpty && wrongAnswers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔄', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '복습이 필요해요!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${todayReviews.length + wrongAnswers.length}개',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (todayReviews.isNotEmpty) ...[
            Text(
              '복습 예정: ${todayReviews.length}개',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          if (wrongAnswers.isNotEmpty) ...[
            Text(
              '다시 풀 문제: ${wrongAnswers.length}개',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startReview,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('복습 시작하기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    final recommendations = ref.read(learningRecommendationProvider).getRecommendedModules();

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('💡', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              '추천 학습',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return RecommendedModuleCard(
                module: recommendations[index],
                onTap: () => _onRecommendedModuleTap(recommendations[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 8),
              Text(
                '학습 설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 학습 시간 설정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('일일 학습 시간'),
              DropdownButton<int>(
                value: 15,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10분')),
                  DropdownMenuItem(value: 15, child: Text('15분')),
                  DropdownMenuItem(value: 20, child: Text('20분')),
                  DropdownMenuItem(value: 30, child: Text('30분')),
                ],
                onChanged: (value) {
                  // TODO: 설정 저장
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startTodayLearning() {
    _initializer.startSession(widget.childId);
    
    // 첫 번째 활동 시작
    if (_todayPlan != null && _todayPlan!.activities.isNotEmpty) {
      _navigateToModule(_todayPlan!.activities.first.moduleId);
    }
  }

  void _onActivityTap(LearningActivity activity) {
    _navigateToModule(activity.moduleId);
  }

  void _onStageTap(String stageId) {
    _navigateToModule(stageId);
  }

  void _onRecommendedModuleTap(RecommendedModule module) {
    _navigateToModule(module.moduleId);
  }

  void _startReview() {
    // TODO: 복습 세션 시작
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('복습 기능 준비 중입니다')),
    );
  }

  void _navigateToModule(String moduleId) {
    switch (moduleId) {
      case 'phonological1':
        context.push('/training/${widget.childId}/phonological');
        break;
      case 'phonological2':
        context.push('/training/${widget.childId}/phonological2');
        break;
      case 'phonological3':
        context.push('/training/${widget.childId}/phonological3');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$moduleId 모듈 준비 중입니다')),
        );
    }
  }
}

