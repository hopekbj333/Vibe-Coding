# 📱 앱 실행 흐름 (App Execution Flow)

이 문서는 프로젝트가 실행될 때 어떤 코드가 어떤 순서로 실행되는지 상세히 설명합니다.

---

## 🚀 전체 실행 흐름 개요

```
main() 
  → WidgetsFlutterBinding.ensureInitialized()
  → 환경 변수 로드 (.env 파일)
  → Firebase 초기화
  → Crashlytics 설정
  → runApp(ProviderScope(LiteracyAssessmentApp))
    → LiteracyAssessmentApp.build()
      → MaterialApp.router
        → AppRouter.createRouter()
          → GoRouter (initialLocation: '/splash')
            → redirect 로직 실행
              → SplashPage 빌드
                → SplashPage.initState()
                  → _initializeApp()
                    → 인증 상태 확인
                    → 최소 1초 대기
                    → 인증 상태에 따라 라우팅
                      → /home 또는 /auth/login
```

---

## 📋 단계별 상세 설명

### 1️⃣ **main() 함수 실행** 
**파일**: `lib/main.dart:11`

```dart
void main() async {
  // 앱의 진입점
}
```

**실행 순서**:
1. `WidgetsFlutterBinding.ensureInitialized()` 호출
   - Flutter 엔진 초기화 (필수)
   - 비동기 작업 전에 반드시 호출해야 함

---

### 2️⃣ **환경 변수 로드**
**파일**: `lib/main.dart:17-31`

```dart
const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env.dev');
await dotenv.load(fileName: envFile);
```

**실행 내용**:
- 빌드 시 전달된 `ENV_FILE` 환경 변수 확인
- 기본값: `.env.dev`
- `.env` 파일에서 환경 설정 로드
- 실패해도 앱은 계속 실행 (개발 편의성)

**로드되는 설정**:
- `ENVIRONMENT`: development/staging/production
- `APP_NAME`: 앱 이름
- `APP_VERSION`: 앱 버전
- `FIREBASE_PROJECT_ID`: Firebase 프로젝트 ID
- 기타 Firebase 설정

---

### 3️⃣ **Firebase 초기화**
**파일**: `lib/main.dart:35` → `lib/config/firebase/firebase_config.dart:29`

```dart
await FirebaseConfig.initialize();
```

**실행 내용**:
1. `Firebase.initializeApp()` 호출
   - `DefaultFirebaseOptions.currentPlatform` 사용
   - 플랫폼별 Firebase 설정 적용
2. Firestore 설정
   - `persistenceEnabled: true` (오프라인 지원)
   - `cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED` (무제한 캐시)
3. 초기화 실패해도 앱은 계속 실행 (안전 처리)

---

### 4️⃣ **Crashlytics 설정**
**파일**: `lib/main.dart:38-40` → `lib/config/firebase/firebase_config.dart:75`

```dart
if (FirebaseConfig.isInitialized) {
  FirebaseConfig.setupCrashlytics();
}
```

**실행 내용**:
- Firebase가 초기화된 경우에만 실행
- 프로덕션 환경에서만 활성화
- Flutter 오류를 Firebase Crashlytics로 전송

---

### 5️⃣ **runApp() 호출**
**파일**: `lib/main.dart:42-46`

```dart
runApp(
  const ProviderScope(
    child: LiteracyAssessmentApp(),
  ),
);
```

**실행 내용**:
- `ProviderScope`: Riverpod 상태 관리 초기화
- `LiteracyAssessmentApp`: 최상위 위젯 생성

---

### 6️⃣ **LiteracyAssessmentApp.build() 실행**
**파일**: `lib/main.dart:49-71`

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return MaterialApp.router(
    title: '문해력 기초 검사',
    theme: AppTheme.lightTheme,
    routerConfig: AppRouter.createRouter(ref),
    // ... 로케일 설정
  );
}
```

**실행 내용**:
1. `MaterialApp.router` 생성
   - Material Design 3 사용
   - GoRouter 기반 라우팅
2. 테마 설정
   - `AppTheme.lightTheme` 적용
   - 아동 친화적 느린 애니메이션 (1.5배 느리게)
3. 라우터 설정
   - `AppRouter.createRouter(ref)` 호출

---

### 7️⃣ **AppRouter.createRouter() 실행**
**파일**: `lib/config/routes/app_router.dart:54`

```dart
static GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) { ... },
    routes: [ ... ],
  );
}
```

**실행 내용**:
1. `GoRouter` 인스턴스 생성
2. `initialLocation: '/splash'` 설정
   - 앱 시작 시 스플래시 화면으로 이동
3. `redirect` 로직 실행
   - 인증 상태 확인
   - 인증되지 않았고 `/auth` 경로가 아니면 `/auth/login`으로 리다이렉트
   - 인증되었고 `/auth` 경로면 `/home`으로 리다이렉트
   - `/splash`는 리다이렉트 제외

---

### 8️⃣ **SplashPage 빌드**
**파일**: `lib/features/splash/presentation/pages/splash_page.dart:60`

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        children: [
          Icon(Icons.book, size: 80),
          Text(AppConfig.appName),
          // ...
        ],
      ),
    ),
  );
}
```

**화면 표시**:
- 책 아이콘 (80px)
- 앱 이름 ("문해력 기초 검사")
- 디버그 모드일 경우 환경 정보 표시

---

### 9️⃣ **SplashPage.initState() 실행**
**파일**: `lib/features/splash/presentation/pages/splash_page.dart:21`

```dart
@override
void initState() {
  super.initState();
  _initializeApp();
}
```

**실행 내용**:
- 위젯이 생성되자마자 `_initializeApp()` 호출

---

### 🔟 **_initializeApp() 실행**
**파일**: `lib/features/splash/presentation/pages/splash_page.dart:27`

```dart
Future<void> _initializeApp() async {
  // 1. 환경 설정 출력
  AppConfig.printEnvironment();
  
  // 2. 인증 상태 확인
  final authStatus = ref.read(authStatusProvider);
  
  // 3. 최소 1초 대기 (아동 친화적 느린 전환)
  await Future.delayed(AppConstants.splashMinDuration);
  
  // 4. 인증 상태에 따라 라우팅
  if (authStatus == AuthStatus.authenticated) {
    context.go('/home');
  } else {
    context.go('/auth/login');
  }
}
```

**단계별 실행**:

#### 10-1. 환경 설정 출력
- 디버그 모드에서만 콘솔에 출력
- 환경, 앱 이름, 버전 등 표시

#### 10-2. 인증 상태 확인
**파일**: `lib/core/state/auth_providers.dart:24`

```dart
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return AuthStatus.unauthenticated;
      }
      return AuthStatus.authenticated;
    },
    loading: () => AuthStatus.initial,
    error: (_, __) => AuthStatus.error,
  );
});
```

**동작**:
- `authStateChangesProvider`를 통해 Firebase Auth 상태 스트림 구독
- Firebase Auth가 초기화되지 않았으면 빈 스트림 반환
- 사용자가 있으면 `AuthStatus.authenticated`
- 사용자가 없으면 `AuthStatus.unauthenticated`

#### 10-3. 최소 1초 대기
**파일**: `lib/core/constants/app_constants.dart:22`

```dart
static const Duration splashMinDuration = Duration(seconds: 1);
```

**목적**:
- PRD 요구사항: 아동 친화적 느린 전환
- 스플래시 화면이 너무 빨리 사라지지 않도록

#### 10-4. 라우팅 분기
- **인증됨**: `/home` → `HomePage` 표시
- **인증 안 됨**: `/auth/login` → `LoginPage` 표시

---

## 🔄 인증 상태 확인 상세 흐름

### authStateChangesProvider
**파일**: `lib/core/state/auth_providers.dart:12`

```dart
final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  final auth = FirebaseRepositories.auth;
  if (auth == null) {
    return Stream.value(null);
  }
  return auth.authStateChanges();
});
```

**동작**:
1. `FirebaseRepositories.auth`에서 Firebase Auth 인스턴스 가져오기
2. `authStateChanges()` 스트림 구독
3. 사용자 로그인/로그아웃 시 자동으로 상태 변경 감지

---

## 📊 실행 시간 순서도

```
시간축 →
│
├─ 0ms:   main() 시작
├─ 1ms:   WidgetsFlutterBinding.ensureInitialized()
├─ 2ms:   dotenv.load() 시작 (비동기)
├─ 50ms:  dotenv.load() 완료
├─ 51ms:  Firebase.initializeApp() 시작 (비동기)
├─ 200ms: Firebase.initializeApp() 완료
├─ 201ms: setupCrashlytics()
├─ 202ms: runApp() 호출
├─ 203ms: ProviderScope 초기화
├─ 204ms: LiteracyAssessmentApp.build() 실행
├─ 205ms: MaterialApp.router 생성
├─ 206ms: AppRouter.createRouter() 실행
├─ 207ms: GoRouter 생성 (initialLocation: '/splash')
├─ 208ms: redirect 로직 실행
├─ 209ms: SplashPage 빌드 시작
├─ 210ms: SplashPage.build() 완료 → 화면 표시
├─ 211ms: SplashPage.initState() 실행
├─ 212ms: _initializeApp() 시작
├─ 213ms: AppConfig.printEnvironment()
├─ 214ms: authStatusProvider 읽기
├─ 215ms: Firebase Auth 상태 확인 (비동기)
├─ 300ms: Firebase Auth 상태 확인 완료
├─ 301ms: Future.delayed(1초) 시작
├─ 1301ms: Future.delayed(1초) 완료
├─ 1302ms: context.go('/home') 또는 context.go('/auth/login')
└─ 1303ms: 최종 화면 표시 (HomePage 또는 LoginPage)
```

---

## 🎯 주요 파일 위치

| 단계 | 파일 경로 | 설명 |
|------|----------|------|
| 진입점 | `lib/main.dart` | 앱의 시작점 |
| Firebase 설정 | `lib/config/firebase/firebase_config.dart` | Firebase 초기화 |
| 라우터 설정 | `lib/config/routes/app_router.dart` | 라우팅 규칙 |
| 스플래시 화면 | `lib/features/splash/presentation/pages/splash_page.dart` | 초기 화면 |
| 인증 상태 | `lib/core/state/auth_providers.dart` | 인증 상태 관리 |
| 테마 설정 | `lib/core/theme/app_theme.dart` | 앱 테마 |
| 상수 정의 | `lib/core/constants/app_constants.dart` | 전역 상수 |

---

## 🔍 디버깅 팁

### 1. 실행 흐름 추적
각 단계에서 `print()` 문을 추가하여 실행 순서 확인:

```dart
void main() async {
  print('1. main() 시작');
  WidgetsFlutterBinding.ensureInitialized();
  print('2. WidgetsFlutterBinding 완료');
  // ...
}
```

### 2. 인증 상태 확인
`authStatusProvider`를 watch하여 실시간 상태 확인:

```dart
final authStatus = ref.watch(authStatusProvider);
print('인증 상태: $authStatus');
```

### 3. 라우팅 디버깅
GoRouter의 `routerDelegate`를 통해 현재 경로 확인:

```dart
final router = GoRouter.of(context);
print('현재 경로: ${router.routerDelegate.currentConfiguration}');
```

---

## 📝 참고 사항

1. **비동기 처리**: 대부분의 초기화 작업은 비동기로 실행되므로 순서가 보장되지 않을 수 있습니다.
2. **에러 처리**: Firebase 초기화 실패 시에도 앱은 계속 실행됩니다 (개발 편의성).
3. **상태 관리**: Riverpod의 `ProviderScope`가 최상위에 있어야 모든 Provider가 정상 작동합니다.
4. **라우팅**: GoRouter의 `redirect` 로직은 매번 라우팅 시 실행됩니다.

---

*Last Updated: 2025-01-XX*
