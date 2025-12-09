import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_mode_providers.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../../../core/widgets/child_friendly_dialog.dart';
import '../../../../core/widgets/child_friendly_loading_indicator.dart';
import '../providers/child_providers.dart';

/// 아동 프로필 목록 화면
/// 
/// 부모/관리자 모드에서 아동 프로필을 관리하는 화면입니다.
class ChildrenListPage extends ConsumerWidget {
  const ChildrenListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('아동 프로필 관리'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // 홈으로 갈 때는 항상 부모 모드로 전환
            ref.read(appModeProvider.notifier).switchToParentMode();
            
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: '홈으로',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/child/new');
            },
            tooltip: '새 아동 프로필 추가',
          ),
          IconButton(
            icon: const Icon(Icons.face),
            onPressed: () {
              ref.read(appModeProvider.notifier).switchToChildMode();
              context.go('/kids/select');
            },
            tooltip: '아동 모드로 전환',
          ),
        ],
      ),
      body: childrenAsync.when(
        data: (children) {
          if (children.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildChildrenList(context, ref, children);
        },
        loading: () => const Center(
          child: ChildFriendlyLoadingIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: DesignSystem.semanticError,
              ),
              const SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: DesignSystem.parentTextStyleTitle,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: DesignSystem.parentTextStyleBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ChildFriendlyButton(
                onPressed: () {
                  ref.invalidate(childrenListProvider);
                },
                label: '다시 시도',
                color: DesignSystem.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.child_care,
            size: 80,
            color: DesignSystem.neutralGray400,
          ),
          const SizedBox(height: 24),
          Text(
            '등록된 아동 프로필이 없습니다',
            style: DesignSystem.parentTextStyleTitle,
          ),
          const SizedBox(height: 8),
          Text(
            '새 아동 프로필을 추가해주세요',
            style: DesignSystem.parentTextStyleBody.copyWith(
              color: DesignSystem.neutralGray500,
            ),
          ),
          const SizedBox(height: 32),
          ChildFriendlyButton(
            onPressed: () {
              context.push('/child/new');
            },
            label: '아동 프로필 추가',
            color: DesignSystem.primaryBlue,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList(
    BuildContext context,
    WidgetRef ref,
    List<ChildModel> children,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(childrenListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignSystem.spacingMD),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return _buildChildCard(context, ref, child);
        },
      ),
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    WidgetRef ref,
    ChildModel child,
  ) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final birthDateStr = dateFormat.format(child.birthDate);

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingMD),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMD),
      ),
      child: InkWell(
        onTap: () {
          context.push('/child/${child.id}');
        },
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMD),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacingMD),
          child: Row(
            children: [
              // 프로필 이미지 (향후 추가)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: DesignSystem.primaryBlue,
                ),
              ),
              const SizedBox(width: DesignSystem.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: DesignSystem.parentTextStyleTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '만 ${child.age}세 • $birthDateStr',
                      style: DesignSystem.parentTextStyleBody.copyWith(
                        color: DesignSystem.neutralGray600,
                      ),
                    ),
                    if (child.assessmentCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '검사 ${child.assessmentCount}회 완료',
                        style: DesignSystem.textStyleSmall.copyWith(
                          color: DesignSystem.primaryGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/child/${child.id}/edit');
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, ref, child);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: DesignSystem.semanticError),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: DesignSystem.semanticError)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    ChildModel child,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ChildFriendlyDialog(
        title: '아동 프로필 삭제',
        content: '${child.name}의 프로필을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
        confirmText: '삭제',
        cancelText: '취소',
        confirmColor: DesignSystem.semanticError,
      ),
    );

    if (confirmed == true && context.mounted) {
      final deleteAsync = ref.read(deleteChildProvider(child.id));
      deleteAsync.whenData((success) {
        if (success) {
          ref.invalidate(childrenListProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${child.name}의 프로필이 삭제되었습니다'),
              backgroundColor: DesignSystem.semanticSuccess,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('삭제에 실패했습니다'),
              backgroundColor: DesignSystem.semanticError,
            ),
          );
        }
      });
    }
  }
}

