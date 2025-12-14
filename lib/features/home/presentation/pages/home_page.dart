import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_mode_providers.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/state/auth_providers.dart';
import '../../../../core/state/child_providers.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../../auth/domain/services/auth_service.dart';

/// 홈 화면
/// 
/// 앱 모드에 따라 다른 화면을 보여줍니다.
/// - 부모 모드: 아동 프로필 관리, 설정 등
/// - 아동 모드: 아동 프로필 선택 화면으로 리다이렉트
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아동 모드 리다이렉트 로직 제거 - 버튼 클릭 시에만 이동하도록 변경
    
    // 관리자 권한 확인
    final isAdmin = ref.watch(isAdminProvider);
    final isTeacherOrAdmin = ref.watch(isTeacherOrAdminProvider);
    
    // 부모 모드 화면
    return Scaffold(
      appBar: AppBar(
        title: const Text('문해력 기초 검사'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              context.push('/parent-mode/set-pin');
            },
            tooltip: 'PIN 설정',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, ref),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '홈 화면',
              style: DesignSystem.parentTextStyleTitle,
            ),
            const SizedBox(height: 32),
            ChildFriendlyButton(
              onPressed: () {
                context.push('/child');
              },
              label: '아동 프로필 관리',
              color: DesignSystem.primaryBlue,
              icon: Icons.child_care,
            ),
            const SizedBox(height: 16),
            ChildFriendlyButton(
              onPressed: () {
                context.push('/assessment-demo');
              },
              label: '📝 검사 시작 (데모)',
              color: Colors.deepPurple,
              icon: Icons.quiz,
            ),
            const SizedBox(height: 16),
            ChildFriendlyButton(
              onPressed: () {
                _startStoryAssessment(context, ref);
              },
              label: '📖 스토리형 검사 시작',
              color: const Color(0xFF4CAF50), // 초록색
              icon: Icons.auto_stories,
            ),
            const SizedBox(height: 16),
            ChildFriendlyButton(
              onPressed: () {
                // 아동 모드로 전환
                ref.read(appModeProvider.notifier).switchToChildMode();
                context.go('/kids/select');
              },
              label: '아동 모드로 전환',
              color: DesignSystem.primaryGreen,
              icon: Icons.face,
            ),
            const SizedBox(height: 16),
            ChildFriendlyButton(
              onPressed: () {
                context.push('/scoring');
              },
              label: '채점 관리',
              color: DesignSystem.primaryOrange,
              icon: Icons.assignment_turned_in,
            ),
            const SizedBox(height: 16),
            ChildFriendlyButton(
              onPressed: () {
                // TODO: 아동 선택 후 학습 화면으로 이동
                // 임시로 첫 번째 아동의 학습 화면으로 이동 (데모용)
                context.push('/training/child_demo?childName=테스트아동');
              },
              label: '학습/훈련 (Milestone 2)',
              color: const Color(0xFF9C27B0), // Purple
              icon: Icons.school,
            ),
            // 관리자 전용: JSON 문항 시스템 데모
            if (isAdmin) ...[
              const SizedBox(height: 16),
              ChildFriendlyButton(
                onPressed: () {
                  context.push('/training/child_demo/json-games-demo');
                },
                label: '📊 JSON 문항 시스템 데모 (관리자)',
                color: const Color(0xFF00ACC1), // Cyan
                icon: Icons.admin_panel_settings,
              ),
            ],
            const SizedBox(height: 16),
            ChildFriendlyButton(
              onPressed: () {
                context.push('/offline-settings');
              },
              label: '오프라인 및 최적화 설정 (WP 3.8)',
              color: const Color(0xFF607D8B), // Blue Grey
              icon: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }

  void _startStoryAssessment(BuildContext context, WidgetRef ref) {
    // 아동 목록 확인
    final childrenAsync = ref.read(childrenListProvider);
    
    childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          // 아동이 없으면 아동 프로필 관리 페이지로 이동
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('아동 프로필 필요'),
              content: const Text('스토리형 검사를 시작하려면 먼저 아동 프로필을 등록해주세요.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.push('/child/new');
                  },
                  child: const Text('아동 등록하기'),
                ),
              ],
            ),
          );
        } else if (children.length == 1) {
          // 아동이 1명이면 바로 시작
          final child = children.first;
          context.push(
            '/story/intro',
            extra: {
              'childId': child.id,
              'childName': child.name,
            },
          );
        } else {
          // 아동이 여러 명이면 선택 페이지로 이동
          // 아동 선택 후 스토리 검사로 이동할 수 있도록 처리
          context.push('/kids/select');
        }
      },
      loading: () {
        // 로딩 중이면 잠시 대기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아동 정보를 불러오는 중...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $error')),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                // authService를 직접 사용하여 로그아웃
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
                debugPrint('✓ 로그아웃 성공');
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                debugPrint('✗ 로그아웃 실패: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그아웃 실패: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: DesignSystem.semanticError,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

