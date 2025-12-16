# 🔢 코드 실행 순서 (Code Execution Sequence)

이 문서는 프로젝트가 실행될 때 **실제로 실행되는 코드를 빌드 순서대로** 나열합니다.

---

## 📌 실행 순서 개요

실제 코드가 실행되는 순서를 따라가며, 각 단계에서 실행되는 코드 라인을 순서대로 보여줍니다.

---

## 1️⃣ main() 함수 시작

**파일**: `lib/main.dart`

```dart
// 라인 11: main() 함수 진입
void main() async {
  // 라인 12: Flutter 엔진 초기화 (동기)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 라인 17: 환경 변수 파일명 결정 (컴파일 타임 상수)
  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env.dev');
  
  // 라인 18-31: 환경 변수 로드 (비동기)
  try {
    // 라인 19: .env 파일 로드 시작
    await dotenv.load(fileName: envFile);
    
    // 라인 20-22: 디버그 모드에서만 출력
    if (kDebugMode) {
      print('✓ Environment file loaded: $envFile');
    }
  } catch (e) {
    // 라인 26-30: 에러 처리 (앱은 계속 실행)
    if (kDebugMode) {
      print('⚠ Warning: Could not load $envFile. Using default values.');
      print('  Error: $e');
      print('  Please create $envFile file or use --dart-define=ENV_FILE=<file>');
    }
  }
  
  // 라인 35: Firebase 초기화 시작 (비동기)
  await FirebaseConfig.initialize();
  
  // 라인 38-40: Crashlytics 설정 (조건부)
  if (FirebaseConfig.isInitialized) {
    FirebaseConfig.setupCrashlytics();
  }
  
  // 라인 42-46: 앱 실행
  runApp(
    const ProviderScope(
      child: LiteracyAssessmentApp(),
    ),
  );
}
```

---

## 2️⃣ FirebaseConfig.initialize() 실행

**파일**: `lib/config/firebase/firebase_config.dart`

```dart
// 라인 29: initialize() 메서드 진입
static Future<void> initialize() async {
  // 라인 31-33: 이미 초기화되었는지 확인
  if (_isInitialized) {
    return;
  }

  // 라인 36-69: Firebase 초기화 시도
  try {
    // 라인 37-39: Firebase.initializeApp() 호출
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // 라인 40: 초기화 완료 플래그 설정
    _isInitialized = true;
    
    // 라인 43-56: Firestore 설정
    try {
      // 라인 44: Firestore 인스턴스 가져오기
      final firestore = FirebaseFirestore.instance;
      
      // 라인 45-48: Firestore 설정 적용
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      // 라인 49-51: 디버그 출력
      if (kDebugMode) {
        print('✓ Firestore settings configured');
      }
    } catch (e) {
      // 라인 53-55: Firestore 설정 에러 처리
      if (kDebugMode) {
        print('⚠ Firestore settings error: $e');
      }
    }
    
    // 라인 58-61: 초기화 성공 출력
    if (kDebugMode) {
      print('✓ Firebase initialized successfully');
      print('  Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    }
  } catch (e) {
    // 라인 63-68: 초기화 실패 처리
    if (kDebugMode) {
      print('⚠ Firebase initialization failed: $e');
      print('  App will continue without Firebase features.');
    }
    _isInitialized = false;
  }
}
```

---

## 3️⃣ FirebaseConfig.setupCrashlytics() 실행

**파일**: `lib/config/firebase/firebase_config.dart`

```dart
// 라인 75: setupCrashlytics() 메서드 진입
static void setupCrashlytics() {
  // 라인 76-78: 초기화 확인
  if (!_isInitialized) {
    return;
  }

  // 라인 80-102: Crashlytics 설정
  try {
    // 라인 82: 프로덕션 환경에서만 활성화
    if (!kDebugMode && AppConfig.isProduction) {
      // 라인 83-85: Flutter 오류 핸들러 설정
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      // 라인 88-91: 비동기 오류 핸들러 설정
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      // 라인 93-95: 디버그 출력
      if (kDebugMode) {
        print('✓ Firebase Crashlytics configured');
      }
    }
  } catch (e) {
    // 라인 98-100: 에러 처리
    if (kDebugMode) {
      print('⚠ Crashlytics setup error: $e');
    }
  }
}
```

---

## 4️⃣ runApp() 호출 및 ProviderScope 초기화

**파일**: `lib/main.dart`

```dart
// 라인 42-46: runApp() 호출
runApp(
  const ProviderScope(
    child: LiteracyAssessmentApp(),
  ),
);
```

**실행 순서**:
1. `ProviderScope` 생성자 호출
2. `LiteracyAssessmentApp` 생성자 호출
3. Flutter 엔진이 위젯 트리 빌드 시작

---

## 5️⃣ LiteracyAssessmentApp.build() 실행

**파일**: `lib/main.dart`

```dart
// 라인 49: LiteracyAssessmentApp 클래스 정의
class LiteracyAssessmentApp extends ConsumerWidget {
  const LiteracyAssessmentApp({super.key});

  // 라인 52-70: build() 메서드 실행
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라인 54-70: MaterialApp.router 반환
    return MaterialApp.router(
      // 라인 55: 앱 제목
      title: '문해력 기초 검사',
      
      // 라인 56: 디버그 배너 숨김
      debugShowCheckedModeBanner: false,
      
      // 라인 57: 테마 설정
      theme: AppTheme.lightTheme,
      
      // 라인 58: 라우터 설정
      routerConfig: AppRouter.createRouter(ref),
      
      // 라인 60-64: 로케일 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // 라인 65-68: 지원 로케일
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      
      // 라인 69: 기본 로케일
      locale: const Locale('ko', 'KR'),
    );
  }
}
```

---

## 6️⃣ AppTheme.lightTheme 접근

**파일**: `lib/core/theme/app_theme.dart`

```dart
// 라인 20: lightTheme getter 실행
static ThemeData get lightTheme {
  // 라인 21-55: ThemeData 생성
  return ThemeData(
    // 라인 22: Material 3 사용
    useMaterial3: true,
    
    // 라인 23-29: ColorScheme 생성
    colorScheme: ColorScheme.fromSeed(
      seedColor: DesignSystem.primaryBlue,
      brightness: Brightness.light,
      primary: DesignSystem.primaryBlue,
      secondary: DesignSystem.childFriendlyGreen,
      error: DesignSystem.childFriendlyRed,
    ),
    
    // 라인 32-38: 텍스트 테마
    textTheme: const TextTheme(
      displayLarge: DesignSystem.textStyleLarge,
      displayMedium: DesignSystem.textStyleMedium,
      bodyLarge: DesignSystem.textStyleRegular,
      bodyMedium: DesignSystem.textStyleRegular,
      bodySmall: DesignSystem.textStyleSmall,
    ),
    
    // 라인 41-46: 페이지 전환 테마
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    // 라인 49-54: 커스텀 테마 확장
    extensions: const <ThemeExtension<dynamic>>[
      _SlowAnimationTheme(
        duration: slowAnimationDuration,
        factor: animationSlowdownFactor,
      ),
    ],
  );
}
```

---

## 7️⃣ AppRouter.createRouter() 실행

**파일**: `lib/config/routes/app_router.dart`

```dart
// 라인 54: createRouter() 메서드 진입
static GoRouter createRouter(WidgetRef ref) {
  // 라인 55-447: GoRouter 인스턴스 생성 및 반환
  return GoRouter(
    // 라인 56: 초기 경로 설정
    initialLocation: '/splash',
    
    // 라인 57-76: redirect 로직
    redirect: (context, state) {
      // 라인 58: 인증 상태 확인
      final authStatus = ref.read(authStatusProvider);
      
      // 라인 59: 인증 경로인지 확인
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // 라인 62-68: 인증되지 않은 경우 리다이렉트
      if (authStatus == AuthStatus.unauthenticated && !isAuthRoute) {
        // 라인 64-66: 스플래시 화면은 제외
        if (state.matchedLocation == '/splash') {
          return null;
        }
        return '/auth/login';
      }

      // 라인 71-73: 인증된 경우 인증 화면에서 홈으로 리다이렉트
      if (authStatus == AuthStatus.authenticated && isAuthRoute) {
        return '/home';
      }

      // 라인 75: 리다이렉트 없음
      return null;
    },
    
    // 라인 77-446: 라우트 정의
    routes: [
      // 라인 78-82: 스플래시 화면
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      // ... (다른 라우트들)
    ],
  );
}
```

---

## 8️⃣ authStatusProvider 실행 (redirect 로직 내부)

**파일**: `lib/core/state/auth_providers.dart`

```dart
// 라인 24: authStatusProvider 정의
final authStatusProvider = Provider<AuthStatus>((ref) {
  // 라인 25: authStateChangesProvider 구독
  final authState = ref.watch(authStateChangesProvider);
  
  // 라인 27-36: 상태에 따라 AuthStatus 반환
  return authState.when(
    // 라인 28-33: 데이터가 있는 경우
    data: (user) {
      // 라인 29-32: 사용자 존재 여부 확인
      if (user == null) {
        return AuthStatus.unauthenticated;
      }
      return AuthStatus.authenticated;
    },
    // 라인 34: 로딩 중
    loading: () => AuthStatus.initial,
    // 라인 35: 에러 발생
    error: (_, __) => AuthStatus.error,
  );
});
```

---

## 9️⃣ authStateChangesProvider 실행

**파일**: `lib/core/state/auth_providers.dart`

```dart
// 라인 12: authStateChangesProvider 정의
final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  // 라인 13: Firebase Auth 인스턴스 가져오기
  final auth = FirebaseRepositories.auth;
  
  // 라인 14-17: Firebase가 초기화되지 않은 경우
  if (auth == null) {
    // 빈 스트림 반환
    return Stream.value(null);
  }
  
  // 라인 18: Firebase Auth 상태 스트림 반환
  return auth.authStateChanges();
});
```

---

## 🔟 FirebaseRepositories.auth 접근

**파일**: `lib/config/firebase/firebase_repositories.dart`

```dart
// 라인 30: auth getter 실행
static FirebaseAuth? get auth {
  // 라인 31-35: Firebase 초기화 확인
  if (!FirebaseConfig.isInitialized) {
    if (kDebugMode) {
      print('⚠ Firebase Auth: Firebase not initialized');
    }
    return null;
  }
  
  // 라인 37: Firebase Auth 인스턴스 반환
  return FirebaseAuth.instance;
}
```

---

## 1️⃣1️⃣ SplashPage 빌드

**파일**: `lib/features/splash/presentation/pages/splash_page.dart`

```dart
// 라인 12: SplashPage 클래스 정의
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  // 라인 15-17: createState() 호출
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

// 라인 19: _SplashPageState 클래스 정의
class _SplashPageState extends ConsumerState<SplashPage> {
  // 라인 20-24: initState() 실행
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // 라인 26-57: _initializeApp() 실행
  Future<void> _initializeApp() async {
    // 라인 29: 환경 설정 출력
    AppConfig.printEnvironment();
    
    // 라인 38: 인증 상태 확인
    final authStatus = ref.read(authStatusProvider);
    
    // 라인 42: 최소 1초 대기
    await Future.delayed(AppConstants.splashMinDuration);
    
    // 라인 44-56: 인증 상태에 따라 라우팅
    if (mounted) {
      if (authStatus == AuthStatus.authenticated) {
        // 라인 51: 홈 화면으로 이동
        context.go('/home');
      } else {
        // 라인 54: 로그인 화면으로 이동
        context.go('/auth/login');
      }
    }
  }

  // 라인 59-91: build() 메서드 실행
  @override
  Widget build(BuildContext context) {
    // 라인 61-90: Scaffold 반환
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라인 67-71: 로고 아이콘
            Icon(
              Icons.book,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            // 라인 72: 간격
            const SizedBox(height: 24),
            // 라인 73-78: 앱 이름
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // 라인 79: 간격
            const SizedBox(height: 8),
            // 라인 80-86: 디버그 모드 환경 정보
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
```

---

## 1️⃣2️⃣ AppConfig.printEnvironment() 실행

**파일**: `lib/config/app_config.dart`

```dart
// 라인 92: printEnvironment() 메서드 실행
static void printEnvironment() {
  // 라인 93: 디버그 모드 확인
  if (kDebugMode) {
    // 라인 94-100: 환경 정보 출력
    print('=== App Configuration ===');
    print('Environment: $environment');
    print('App Name: $appName');
    print('App Version: $appVersion');
    print('API Base URL: $apiBaseUrl');
    print('Debug Mode: $isDebugMode');
    print('========================');
  }
}
```

---

## 1️⃣3️⃣ AppConstants.splashMinDuration 접근

**파일**: `lib/core/constants/app_constants.dart`

```dart
// 라인 22: splashMinDuration 상수
static const Duration splashMinDuration = Duration(seconds: 1);
```

---

## 1️⃣4️⃣ 최종 화면으로 이동

### 케이스 1: 인증된 경우 → HomePage

**파일**: `lib/features/home/presentation/pages/home_page.dart`

```dart
// 라인 18: HomePage 클래스 정의
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // 라인 21-146: build() 메서드 실행
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라인 26-27: 관리자 권한 확인
    final isAdmin = ref.watch(isAdminProvider);
    final isTeacherOrAdmin = ref.watch(isTeacherOrAdminProvider);
    
    // 라인 30-145: Scaffold 반환
    return Scaffold(
      // 라인 31-48: AppBar
      appBar: AppBar(
        title: const Text('문해력 기초 검사'),
        centerTitle: true,
        actions: [
          // ... (액션 버튼들)
        ],
      ),
      // 라인 49-144: Body
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... (버튼들)
          ],
        ),
      ),
    );
  }
}
```

### 케이스 2: 인증되지 않은 경우 → LoginPage

**파일**: `lib/features/auth/presentation/pages/login_page.dart`

```dart
// 라인 16: LoginPage 클래스 정의
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  // 라인 19-21: createState() 호출
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

// 라인 23: _LoginPageState 클래스 정의
class _LoginPageState extends ConsumerState<LoginPage> {
  // 라인 24-27: 필드 초기화
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // 라인 33-42: initState() 실행
  @override
  void initState() {
    super.initState();
    // 개발 모드에서 자동 로그인
    if (AppConfig.isDevelopment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoLoginForDev();
      });
    }
  }

  // 라인 163-362: build() 메서드 실행
  @override
  Widget build(BuildContext context) {
    // 라인 165-166: 상태 확인
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

    // 라인 181-361: Scaffold 반환
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ... (메인 콘텐츠)
          ],
        ),
      ),
    );
  }
}
```

---

## 📊 실행 순서 요약

```
1. main() 시작
   ↓
2. WidgetsFlutterBinding.ensureInitialized()
   ↓
3. dotenv.load() (비동기)
   ↓
4. FirebaseConfig.initialize() (비동기)
   ├─ Firebase.initializeApp()
   ├─ Firestore 설정
   └─ _isInitialized = true
   ↓
5. FirebaseConfig.setupCrashlytics()
   ↓
6. runApp(ProviderScope(LiteracyAssessmentApp))
   ↓
7. LiteracyAssessmentApp.build()
   ├─ AppTheme.lightTheme 접근
   └─ AppRouter.createRouter(ref)
       ├─ GoRouter 생성
       ├─ redirect 로직 실행
       │   ├─ authStatusProvider 읽기
       │   │   └─ authStateChangesProvider 구독
       │   │       └─ FirebaseRepositories.auth 접근
       │   └─ 리다이렉트 결정
       └─ routes 정의
   ↓
8. SplashPage 빌드
   ├─ initState() 실행
   │   └─ _initializeApp() 시작
   │       ├─ AppConfig.printEnvironment()
   │       ├─ authStatusProvider 읽기
   │       ├─ Future.delayed(1초) 대기
   │       └─ context.go() 호출
   └─ build() 실행 → 화면 표시
   ↓
9. 최종 화면 표시
   ├─ 인증됨: HomePage
   └─ 인증 안 됨: LoginPage
```

---

## 🔍 주요 실행 경로

### 경로 A: 인증된 사용자
```
SplashPage → context.go('/home') → HomePage
```

### 경로 B: 인증되지 않은 사용자
```
SplashPage → context.go('/auth/login') → LoginPage
```

---

## 📝 참고 사항

1. **비동기 실행**: `dotenv.load()`, `Firebase.initializeApp()`, `Future.delayed()` 등은 비동기로 실행되므로 실제 시간 순서는 다를 수 있습니다.

2. **Provider 초기화**: Riverpod의 Provider는 처음 접근할 때 초기화됩니다 (lazy initialization).

3. **위젯 빌드**: Flutter는 위젯 트리를 빌드할 때 `build()` 메서드를 호출하며, 상태가 변경되면 다시 빌드됩니다.

4. **라우팅**: GoRouter의 `redirect` 로직은 매번 라우팅 시 실행됩니다.

---

*Last Updated: 2025-01-XX*
