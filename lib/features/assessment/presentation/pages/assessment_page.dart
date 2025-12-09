import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/state/child_providers.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../data/services/assessment_storage_service.dart';
import '../providers/assessment_providers.dart';
import '../widgets/assessment_loading_widget.dart';

/// 검사 대기/시작 화면
///
/// 아동이 선택된 후, 실제 검사를 시작하기 전 보여주는 화면입니다.
/// 검사 데이터를 로딩하고, 준비가 되면 연습/본 검사 모드를 선택할 수 있습니다.
/// S 1.3.8: 저장된 진행 상태가 있으면 이어하기 팝업을 표시합니다.
class AssessmentPage extends ConsumerStatefulWidget {
  const AssessmentPage({super.key});

  @override
  ConsumerState<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends ConsumerState<AssessmentPage> {
  bool _checkedSavedProgress = false;
  SavedProgress? _savedProgress;
  bool _showedResumeDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAssessment();
    });
  }

  Future<void> _initializeAssessment() async {
    final selectedChild = ref.read(selectedChildProvider);
    
    // S 1.3.8: 아동 ID 설정
    if (selectedChild != null) {
      ref.read(assessmentProvider.notifier).setChildId(selectedChild.id);
      
      // 저장된 진행 상태 확인
      final saved = await AssessmentStorageService.loadProgress(selectedChild.id);
      if (mounted) {
        setState(() {
          _savedProgress = saved;
          _checkedSavedProgress = true;
        });
      }
    }
    
    // 검사 데이터 로딩 (WP 1.4 + WP 1.5 통합)
    await ref.read(assessmentProvider.notifier).loadAssessment('assessment_001');
    
    // 로딩 완료 후 저장된 진행 상태가 있으면 팝업 표시
    if (mounted && _savedProgress != null && !_showedResumeDialog) {
      _showedResumeDialog = true;
      // 약간의 딜레이 후 팝업 표시 (화면 렌더링 완료 대기)
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _showResumeDialog(_savedProgress!);
      }
    }
  }

  /// S 1.3.8/S 1.3.9: 이어하기 팝업
  void _showResumeDialog(SavedProgress saved) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.play_circle_outline, color: DesignSystem.primaryBlue),
            SizedBox(width: 8),
            Text('이어서 할까?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('지난번에 하던 검사가 있어!'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignSystem.neutralGray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${saved.mode == AssessmentMode.tutorial ? "🎓 연습 모드" : "🚀 검사 모드"}',
                    style: DesignSystem.textStyleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${saved.currentQuestionIndex + 1}번 문제까지 했어요',
                    style: DesignSystem.textStyleSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // 저장된 진행 상태 삭제하고 처음부터
              await AssessmentStorageService.clearProgress(saved.childId);
              if (mounted) {
                Navigator.of(context).pop();
                setState(() {
                  _savedProgress = null;
                });
              }
            },
            child: const Text('처음부터 할래'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 저장된 진행 상태 불러오기
              final success = await ref
                  .read(assessmentProvider.notifier)
                  .loadSavedProgress(saved.childId);
              
              if (mounted) {
                Navigator.of(context).pop();
                if (success) {
                  // 이어하기 시작
                  context.go('/assessment/play');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('이어서 할래!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedChild = ref.watch(selectedChildProvider);
    final assessmentState = ref.watch(assessmentProvider);

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray50,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildContent(context, selectedChild, assessmentState),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ChildModel? selectedChild,
    AssessmentState state,
  ) {
    switch (state.loadStatus) {
      case AssessmentLoadStatus.initial:
      case AssessmentLoadStatus.loading:
        return const AssessmentLoadingWidget(
          key: ValueKey('loading'),
          message: '여행 가방을 챙기고 있어...',
        );
      
      case AssessmentLoadStatus.error:
        return _buildErrorState(state.errorMessage);

      case AssessmentLoadStatus.loaded:
        return _buildReadyState(context, selectedChild, state);
    }
  }

  Widget _buildErrorState(String? message) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: DesignSystem.semanticError,
            ),
            const SizedBox(height: DesignSystem.spacingMD),
            Text(
              '앗! 문제가 생겼어.',
              style: DesignSystem.textStyleLarge,
            ),
            const SizedBox(height: DesignSystem.spacingSM),
            Text(
              message ?? '다시 시도해볼까?',
              style: DesignSystem.textStyleMedium.copyWith(
                color: DesignSystem.neutralGray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingLG),
            ChildFriendlyButton(
              label: '다시 시도하기',
              onPressed: () {
                ref.read(assessmentProvider.notifier).loadAssessment('assessment_001');
              },
              color: DesignSystem.semanticWarning,
              icon: Icons.refresh_rounded,
            ),
            const SizedBox(height: DesignSystem.spacingMD),
            TextButton(
              onPressed: () => context.go('/child'),
              child: Text(
                '뒤로 가기',
                style: DesignSystem.textStyleMedium.copyWith(
                  color: DesignSystem.neutralGray500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState(
    BuildContext context,
    ChildModel? selectedChild,
    AssessmentState state,
  ) {
    return Padding(
      key: const ValueKey('ready'),
      padding: const EdgeInsets.all(DesignSystem.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 상단 메시지
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingMD),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
              boxShadow: DesignSystem.shadowSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.waving_hand,
                  color: DesignSystem.primaryBlue,
                  size: DesignSystem.iconSizeXL,
                ),
                const SizedBox(width: DesignSystem.spacingMD),
                Expanded(
                  child: Text(
                    '안녕, ${selectedChild?.name ?? "친구"}!\n${state.assessment?.title ?? "여행"}을 떠나볼까?',
                    style: DesignSystem.textStyleLarge.copyWith(
                      color: DesignSystem.neutralGray800,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // 메인 캐릭터 이미지
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: DesignSystem.shadowMedium,
              ),
              child: const Center(
                child: Icon(
                  Icons.rocket_launch,
                  size: 100,
                  color: DesignSystem.primaryBlue,
                ),
              ),
            ),
          ),

          const Spacer(),

          // 모드 선택 영역
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingMD),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
              boxShadow: DesignSystem.shadowSmall,
            ),
            child: Column(
              children: [
                Text(
                  '어떻게 시작할까?',
                  style: DesignSystem.textStyleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.neutralGray700,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingMD),
                
                // 연습 모드 버튼
                ChildFriendlyButton(
                  label: '🎓 연습부터 할래!',
                  onPressed: () {
                    final child = ref.read(selectedChildProvider);
                    if (child != null) {
                      ref.read(assessmentProvider.notifier).setChildId(child.id);
                    }
                    ref.read(assessmentProvider.notifier).setMode(AssessmentMode.tutorial);
                    context.go('/assessment/play');
                  },
                  color: DesignSystem.semanticInfo,
                  size: ChildButtonSize.medium,
                  fullWidth: true,
                ),
                const SizedBox(height: DesignSystem.spacingSM),
                Text(
                  '틀려도 다시 할 수 있어요',
                  style: DesignSystem.textStyleSmall.copyWith(
                    color: DesignSystem.neutralGray500,
                  ),
                ),
                
                const SizedBox(height: DesignSystem.spacingMD),
                
                // 본 검사 버튼
                ChildFriendlyButton(
                  label: '🚀 바로 시작할래!',
                  onPressed: () {
                    final child = ref.read(selectedChildProvider);
                    if (child != null) {
                      ref.read(assessmentProvider.notifier).setChildId(child.id);
                    }
                    ref.read(assessmentProvider.notifier).setMode(AssessmentMode.test);
                    context.go('/assessment/play');
                  },
                  color: DesignSystem.primaryBlue,
                  size: ChildButtonSize.medium,
                  fullWidth: true,
                ),
                const SizedBox(height: DesignSystem.spacingSM),
                Text(
                  '진짜 검사를 시작해요',
                  style: DesignSystem.textStyleSmall.copyWith(
                    color: DesignSystem.neutralGray500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignSystem.spacingLG),
        ],
      ),
    );
  }
}
