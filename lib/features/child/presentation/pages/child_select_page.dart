import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_mode_providers.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/state/child_providers.dart' show selectedChildProvider;
import '../../../../core/widgets/child_friendly_button.dart';
import '../../../../core/widgets/child_friendly_loading_indicator.dart';
import '../../domain/services/pin_service.dart';
import '../providers/child_providers.dart';

/// 아동 프로필 선택 화면
/// 
/// 아동 모드에서 아동이 자신의 프로필을 선택하는 화면입니다.
/// 아동 친화적인 UI로 큰 아이콘과 캐릭터를 사용합니다.
class ChildSelectPage extends ConsumerWidget {
  const ChildSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider);
    final appMode = ref.watch(appModeProvider);

    // 부모 모드인 경우 아동 모드로 전환
    if (appMode == AppMode.parent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appModeProvider.notifier).switchToChildMode();
      });
    }

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: DesignSystem.neutralGray500),
            onPressed: () {
               ref.read(appModeProvider.notifier).switchToParentMode();
               context.go('/home');
            },
            tooltip: '부모 모드로 나가기',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spacingLG),
              child: Column(
                children: [
                  const Icon(
                    Icons.child_care,
                    size: DesignSystem.iconSizeXXL,
                    color: DesignSystem.primaryBlue,
                  ),
                  const SizedBox(height: DesignSystem.spacingMD),
                  Text(
                    '누구의 프로필인가요?',
                    style: DesignSystem.textStyleLarge.copyWith(
                      color: DesignSystem.neutralGray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 아동 프로필 목록
            Expanded(
              child: childrenAsync.when(
                data: (children) {
                  if (children.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildChildrenGrid(context, ref, children);
                },
                loading: () => const Center(
                  child: ChildFriendlyLoadingIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignSystem.spacingLG),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: DesignSystem.iconSizeXL,
                          color: DesignSystem.semanticError,
                        ),
                        const SizedBox(height: DesignSystem.spacingMD),
                        Text(
                          '오류가 발생했습니다',
                          style: DesignSystem.textStyleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 부모 모드로 전환 버튼
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spacingMD),
              child: ChildFriendlyButton(
                onPressed: () async {
                  final hasPin = await PinService().hasPin();
                  
                  if (!context.mounted) return;
                  
                  if (hasPin) {
                    // PIN이 설정되어 있으면 PIN 입력 화면으로 이동
                    final result = await context.push('/parent-mode/unlock');
                    if (result == true && context.mounted) {
                      // PIN 확인 성공 시 부모 모드로 전환
                      ref.read(appModeProvider.notifier).switchToParentMode();
                      context.go('/home');
                    }
                  } else {
                    // PIN이 설정되어 있지 않으면 바로 부모 모드로 전환
                    ref.read(appModeProvider.notifier).switchToParentMode();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  }
                },
                label: '부모 모드 (홈으로)',
                color: DesignSystem.neutralGray400,
                icon: Icons.lock,
                size: ChildButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care,
              size: DesignSystem.iconSizeXXL,
              color: DesignSystem.neutralGray400,
            ),
            const SizedBox(height: DesignSystem.spacingLG),
            Text(
              '등록된 프로필이 없습니다',
              style: DesignSystem.textStyleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingSM),
            Text(
              '부모 모드에서 프로필을 등록해주세요',
              style: DesignSystem.textStyleRegular.copyWith(
                color: DesignSystem.neutralGray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenGrid(
    BuildContext context,
    WidgetRef ref,
    List<ChildModel> children,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(DesignSystem.spacingMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DesignSystem.spacingMD,
        mainAxisSpacing: DesignSystem.spacingMD,
        childAspectRatio: 0.85,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return _buildChildCard(context, ref, child);
      },
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    WidgetRef ref,
    ChildModel child,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
      ),
      child: InkWell(
        onTap: () {
          // 아동 프로필 선택 후 검사 대기 화면으로 이동
          ref.read(selectedChildProvider.notifier).selectChild(child);
          context.go('/assessment');
        },
        onLongPress: () {
          // 길게 누르면 스토리형 검사로 이동
          ref.read(selectedChildProvider.notifier).selectChild(child);
          context.push(
            '/story/intro',
            extra: {
              'childId': child.id,
              'childName': child.name,
            },
          );
        },
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusLG),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacingMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프로필 이미지 (향후 캐릭터 이미지로 교체)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: DesignSystem.primaryBlue,
                ),
              ),
              const SizedBox(height: DesignSystem.spacingMD),
              Text(
                child.name,
                style: DesignSystem.textStyleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingXS),
              Text(
                '만 ${child.age}세',
                style: DesignSystem.textStyleSmall.copyWith(
                  color: DesignSystem.neutralGray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

