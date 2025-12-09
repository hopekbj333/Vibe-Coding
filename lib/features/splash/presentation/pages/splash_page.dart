import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/state/auth_providers.dart';

/// 스플래시 화면
/// 앱 초기화 및 환경 설정 확인
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    // 환경 설정 출력 (디버그 모드에서만)
    AppConfig.printEnvironment();

    // 초기화 작업:
    // - Firebase 초기화 (S 1.1.2) ✅
    // - 상태 관리 초기화 (S 1.1.3) ✅
    // - 에셋 프리로딩 (S 1.1.4) ✅
    // - 사용자 인증 상태 확인 (S 1.2.1) ✅

    // 인증 상태 확인 대기
    final authStatus = ref.read(authStatusProvider);
    
    // 스플래시 화면 표시 시간 (최소 1초)
    // PRD 요구사항: 아동 친화적 느린 전환
    await Future.delayed(AppConstants.splashMinDuration);

    if (mounted) {
      // 인증 상태에 따라 라우팅 분기
      if (authStatus == AuthStatus.authenticated) {
        // 로그인 됨: 홈 화면으로 이동
        // 향후 프로필 선택 여부에 따라 분기
        // - 프로필 선택 안 됨: /profile/select
        // - 프로필 선택 됨: /home
        context.go('/home');
      } else {
        // 로그인 안 됨: 로그인 화면으로 이동
        context.go('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 향후 로고 이미지로 교체
            Icon(
              Icons.book,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (AppConfig.isDebugMode)
              Text(
                '${AppConfig.environment.name.toUpperCase()} Mode',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

