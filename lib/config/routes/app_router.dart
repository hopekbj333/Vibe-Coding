import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_state.dart';
import '../../core/state/auth_providers.dart';
import '../../features/assessment/presentation/pages/assessment_player_page.dart';
import '../../features/assessment/presentation/pages/assessment_page.dart';
import '../../features/assessment/presentation/pages/scoring_queue_page.dart';
import '../../features/assessment/presentation/pages/scoring_detail_page.dart';
import '../../features/assessment/presentation/pages/report_page.dart';
import '../../features/assessment/presentation/pages/assessment_demo_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/child/presentation/pages/child_form_page.dart';
import '../../features/child/presentation/pages/child_select_page.dart';
import '../../features/child/presentation/pages/children_list_page.dart';
import '../../features/child/presentation/pages/pin_lock_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/training/presentation/pages/training_home_page.dart';
import '../../features/training/presentation/pages/game_patterns_demo_page.dart';
import '../../features/training/presentation/pages/json_games_demo_page.dart';
import '../../features/training/presentation/modules/phonological/phonological_training_page.dart';
import '../../features/training/presentation/modules/phonological2/phonological2_training_page.dart';
import '../../features/training/presentation/modules/phonological3/phonological3_training_page.dart';
import '../../features/training/presentation/modules/phonological4/phonological4_training_page.dart';
import '../../features/training/presentation/modules/auditory/auditory_training_page.dart';
import '../../features/training/presentation/modules/visual/visual_training_page.dart';
import '../../features/training/presentation/modules/working_memory/working_memory_training_page.dart';
import '../../features/training/presentation/modules/attention/attention_training_page.dart';
import '../../features/training/presentation/pages/tracking_page.dart';
import '../../features/training/presentation/pages/learning_management_page.dart';
import '../../features/training/presentation/pages/voice_scoring_demo_page.dart';
import '../../features/training/presentation/pages/retest_demo_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/payment/presentation/pages/subscription_management_page.dart';
import '../../features/offline/presentation/pages/offline_settings_page.dart';

/// 앱 라우터 설정
class AppRouter {
  AppRouter._();

  /// GoRouter 인스턴스
  /// 
  /// 인증 상태에 따라 리다이렉트를 처리합니다.
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authStatus = ref.read(authStatusProvider);
        final isAuthRoute = state.matchedLocation.startsWith('/auth');

        // 인증되지 않은 경우 로그인 화면으로 리다이렉트
        if (authStatus == AuthStatus.unauthenticated && !isAuthRoute) {
          // 스플래시 화면은 제외
          if (state.matchedLocation == '/splash') {
            return null;
          }
          return '/auth/login';
        }

        // 인증된 경우 로그인/회원가입 화면에서 홈으로 리다이렉트
        if (authStatus == AuthStatus.authenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/auth/signup',
          name: 'signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/child',
          name: 'children-list',
          builder: (context, state) => const ChildrenListPage(),
        ),
        GoRoute(
          path: '/child/new',
          name: 'child-new',
          builder: (context, state) => const ChildFormPage(),
        ),
        GoRoute(
          path: '/child/:childId',
          name: 'child-detail',
          builder: (context, state) {
            // 향후 아동 프로필 상세 화면 구현 예정
            return const ChildrenListPage();
          },
        ),
        GoRoute(
          path: '/child/:childId/edit',
          name: 'child-edit',
          builder: (context, state) {
            final childId = state.pathParameters['childId'];
            return ChildFormPage(childId: childId);
          },
        ),
        GoRoute(
          path: '/kids/select',
          name: 'child-select',
          builder: (context, state) => const ChildSelectPage(),
        ),
        GoRoute(
          path: '/parent-mode/unlock',
          name: 'parent-mode-unlock',
          builder: (context, state) => const PinLockPage(),
        ),
        GoRoute(
          path: '/parent-mode/set-pin',
          name: 'parent-mode-set-pin',
          builder: (context, state) => const PinLockPage(isSettingPin: true),
        ),
        GoRoute(
          path: '/assessment',
          name: 'assessment',
          builder: (context, state) => const AssessmentPage(),
        ),
        GoRoute(
          path: '/assessment-demo',
          name: 'assessment-demo',
          builder: (context, state) => const AssessmentDemoPage(),
        ),
        GoRoute(
          path: '/assessment/play',
          name: 'assessment-play',
          builder: (context, state) => const AssessmentPlayerPage(),
        ),
        // WP 1.7: 채점 시스템
        GoRoute(
          path: '/scoring',
          name: 'scoring-queue',
          builder: (context, state) => const ScoringQueuePage(),
        ),
        GoRoute(
          path: '/scoring/:resultId',
          name: 'scoring-detail',
          builder: (context, state) {
            final resultId = state.pathParameters['resultId']!;
            return ScoringDetailPage(resultId: resultId);
          },
        ),
        // WP 1.8: 결과 리포트
        GoRoute(
          path: '/report/:resultId',
          name: 'report',
          builder: (context, state) {
            final resultId = state.pathParameters['resultId']!;
            return ReportPage(resultId: resultId);
          },
        ),
        // WP 2.1: 학습/훈련 (Milestone 2)
        GoRoute(
          path: '/training/:childId',
          name: 'training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            final childName = state.uri.queryParameters['childName'] ?? '아동';
            return TrainingHomePage(
              childId: childId,
              childName: childName,
            );
          },
        ),
        // WP 2.2: 게임 패턴 데모
        GoRoute(
          path: '/training/:childId/patterns-demo',
          name: 'patterns-demo',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return GamePatternsDemoPage(childId: childId);
          },
        ),
        // JSON 문항 관리 시스템 데모 (관리자 전용)
        GoRoute(
          path: '/training/:childId/json-games-demo',
          name: 'json-games-demo',
          redirect: (context, state) {
            // 관리자 권한 체크는 홈 페이지에서 이미 처리됨
            // 추가 보안이 필요한 경우 여기서 role 체크
            return null;
          },
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return JsonGamesDemoPage(childId: childId);
          },
        ),
        // WP 2.3: 음운 인식 1단계 훈련
        GoRoute(
          path: '/training/:childId/phonological',
          name: 'phonological-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            final childName = state.uri.queryParameters['childName'];
            return PhonologicalTrainingPage(
              childId: childId,
              childName: childName,
            );
          },
        ),
        // WP 2.4: 음운 인식 2단계 훈련
        GoRoute(
          path: '/training/:childId/phonological2',
          name: 'phonological2-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            final childName = state.uri.queryParameters['childName'];
            return Phonological2TrainingPage(
              childId: childId,
              childName: childName,
            );
          },
        ),
        // WP 2.5: 음운 인식 3단계 훈련 (음절 조작)
        GoRoute(
          path: '/training/:childId/phonological3',
          name: 'phonological3-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return Phonological3TrainingPage(childId: childId);
          },
        ),
        // WP 2.6: 학습 관리 시스템
        GoRoute(
          path: '/training/:childId/management',
          name: 'learning-management',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            final childName = state.uri.queryParameters['childName'];
            return LearningManagementPage(
              childId: childId,
              childName: childName,
            );
          },
        ),
        // WP 2.7: 음성 채점 고도화
        GoRoute(
          path: '/training/:childId/voice-scoring',
          name: 'voice-scoring',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return VoiceScoringDemoPage(childId: childId);
          },
        ),
        // WP 2.8: 재검사 시스템
        GoRoute(
          path: '/training/:childId/retest',
          name: 'retest',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return RetestDemoPage(childId: childId);
          },
        ),
        // WP 3.1: 음운 인식 4~5단계 훈련
        GoRoute(
          path: '/training/:childId/phonological4',
          name: 'phonological4-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return Phonological4TrainingPage(childId: childId);
          },
        ),
        // WP 3.2: 청각/순차 처리 훈련
        GoRoute(
          path: '/training/:childId/auditory',
          name: 'auditory-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return AuditoryTrainingPage(childId: childId);
          },
        ),
        // WP 3.3: 시각 처리 훈련
        GoRoute(
          path: '/training/:childId/visual',
          name: 'visual-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return VisualTrainingPage(childId: childId);
          },
        ),
        // WP 3.4: 작업 기억 훈련
        GoRoute(
          path: '/training/:childId/working-memory',
          name: 'working-memory-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return WorkingMemoryTrainingPage(childId: childId);
          },
        ),
        // WP 3.5: 주의 집중 훈련
        GoRoute(
          path: '/training/:childId/attention',
          name: 'attention-training',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            return AttentionTrainingPage(childId: childId);
          },
        ),
        // WP 3.6: 장기 추적 시스템
        GoRoute(
          path: '/training/:childId/tracking',
          name: 'tracking',
          builder: (context, state) {
            final childId = state.pathParameters['childId']!;
            final childName = state.uri.queryParameters['childName'];
            return TrackingPage(
              childId: childId,
              childName: childName,
            );
          },
        ),
        // WP 3.7: 결제 및 구독 시스템
        GoRoute(
          path: '/payment',
          name: 'payment',
          builder: (context, state) => const PaymentPage(),
        ),
        GoRoute(
          path: '/payment/subscription',
          name: 'payment-subscription',
          builder: (context, state) => const SubscriptionManagementPage(),
        ),
        // WP 3.8: 오프라인 지원 및 최적화
        GoRoute(
          path: '/offline-settings',
          name: 'offline-settings',
          builder: (context, state) => const OfflineSettingsPage(),
        ),
      ],
    );
  }

  /// 기본 라우터 (리다이렉트 없음)
  /// 
  /// ProviderScope 외부에서 사용할 때 사용합니다.
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

