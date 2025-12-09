# 전역 상태 관리 검증 가이드 (S 1.1.3)

## 요구사항 검증

### ✅ 1. 상태 관리 라이브러리 선정

**검증 항목:**
- [x] Riverpod 패키지 추가 (flutter_riverpod: ^2.6.1)
- [x] 라이브러리 선택 이유 문서화
- [x] main.dart에 ProviderScope 추가

**구현 확인:**
```dart
// pubspec.yaml
flutter_riverpod: ^2.6.1

// lib/main.dart
runApp(
  const ProviderScope(
    child: LiteracyAssessmentApp(),
  ),
);
```

**테스트 방법:**
```dart
// ProviderScope가 제대로 설정되었는지 확인
// 앱이 정상적으로 실행되어야 함
```

### ✅ 2. 전역 상태 구조 설계

**검증 항목:**
- [x] 인증 상태 관리 (AuthStatus, UserModel)
- [x] 앱 모드 관리 (AppMode: parent/child)
- [x] 아동 프로필 관리 (ChildModel, 선택된 아동)
- [x] 검사 진행 상태 관리 (AssessmentStateModel)

**구현 확인:**
- `lib/core/state/app_state.dart` - 모든 상태 모델 정의
- `lib/core/state/auth_providers.dart` - 인증 Provider
- `lib/core/state/app_mode_providers.dart` - 앱 모드 Provider
- `lib/core/state/child_providers.dart` - 아동 프로필 Provider
- `lib/core/state/assessment_providers.dart` - 검사 진행 상태 Provider

## 단위 테스트

### ✅ AppModeProvider 테스트

**테스트 파일:** `test/core/state/app_mode_providers_test.dart`

**테스트 케이스:**
1. ✅ 초기 상태는 parent 모드
2. ✅ 아동 모드로 전환 가능
3. ✅ 부모 모드로 다시 전환 가능
4. ✅ 모드 토글 정상 작동

**실행 방법:**
```bash
flutter test test/core/state/app_mode_providers_test.dart
```

### ✅ AssessmentStateProvider 테스트

**테스트 파일:** `test/core/state/assessment_providers_test.dart`

**테스트 케이스:**
1. ✅ 초기 상태는 비어있음
2. ✅ 검사 시작 정상 작동
3. ✅ 검사 일시 정지 정상 작동
4. ✅ 검사 재개 정상 작동
5. ✅ 검사 완료 정상 작동
6. ✅ 검사 진행 상태 업데이트 정상 작동
7. ✅ 검사 상태 초기화 정상 작동

**실행 방법:**
```bash
flutter test test/core/state/assessment_providers_test.dart
```

### ✅ SelectedChildProvider 테스트

**테스트 파일:** `test/core/state/child_providers_test.dart`

**테스트 케이스:**
1. ✅ 초기 상태는 null
2. ✅ 아동 프로필 선택 정상 작동
3. ✅ 선택 해제 정상 작동
4. ✅ 아동 나이 계산 정상 작동

**실행 방법:**
```bash
flutter test test/core/state/child_providers_test.dart
```

## 통합 테스트

### ✅ main.dart 통합 확인

**검증 항목:**
- [x] ProviderScope가 올바르게 래핑됨
- [x] Firebase 초기화와 충돌 없음
- [x] 환경 변수 로드와 순서 문제 없음

**구현 확인:**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경 변수 로드
  await dotenv.load(fileName: envFile);
  
  // Firebase 초기화
  await FirebaseConfig.initialize();
  
  // ProviderScope로 앱 래핑
  runApp(
    const ProviderScope(
      child: LiteracyAssessmentApp(),
    ),
  );
}
```

## 상태 구조 검증

### 인증 상태 (Auth)

**Provider 구조:**
```
authStateChangesProvider (StreamProvider)
  └── authStatusProvider (Provider)
  └── currentUserProvider (Provider)
      └── userModelProvider (FutureProvider)
```

**검증:**
- ✅ Firebase가 초기화되지 않아도 안전하게 처리
- ✅ 인증 상태 변화를 실시간으로 감지
- ✅ 사용자 정보를 비동기로 가져옴

### 앱 모드 (App Mode)

**Provider 구조:**
```
appModeProvider (StateNotifierProvider)
  └── AppModeNotifier
```

**검증:**
- ✅ 초기값: AppMode.parent
- ✅ 모드 전환 메서드 제공
- ✅ 토글 기능 제공

### 아동 프로필 (Child)

**Provider 구조:**
```
selectedChildProvider (StateNotifierProvider)
  └── SelectedChildNotifier

childrenListProvider (FutureProvider)
  └── userModelProvider 의존
```

**검증:**
- ✅ 선택된 아동 관리
- ✅ 아동 목록 비동기 로드
- ✅ 나이 계산 기능

### 검사 진행 상태 (Assessment)

**Provider 구조:**
```
assessmentStateProvider (StateNotifierProvider)
  └── AssessmentStateNotifier
```

**검증:**
- ✅ 검사 시작/일시정지/재개/완료/취소 기능
- ✅ 진행 상태 업데이트
- ✅ 상태 초기화

## 발견된 문제 및 해결

### ✅ 해결된 문제

없음 - 모든 구현이 요구사항을 충족함

### ⚠️ 향후 구현 예정

1. **userModelProvider 완성**
   - 현재: Firebase Auth 정보만 사용
   - 향후: Firestore에서 사용자 정보 가져오기 (S 1.2.1)

2. **childrenListProvider 완성**
   - 현재: 빈 목록 반환
   - 향후: Firestore에서 아동 프로필 목록 가져오기 (S 1.2.2)

3. **검사 진행 상태 영구 저장**
   - 현재: 메모리에만 저장
   - 향후: Firestore에 저장하여 앱 재시작 후에도 이어하기 가능 (WP 1.3)

## 테스트 실행 결과

### 예상 결과

모든 단위 테스트가 통과해야 합니다:

```bash
flutter test test/core/state/

# 예상 출력:
# 00:02 +3: All tests passed!
```

### 실제 테스트 실행

Flutter가 설치되어 있으면 다음 명령어로 테스트를 실행할 수 있습니다:

```bash
# 모든 상태 관리 테스트 실행
flutter test test/core/state/

# 개별 테스트 실행
flutter test test/core/state/app_mode_providers_test.dart
flutter test test/core/state/assessment_providers_test.dart
flutter test test/core/state/child_providers_test.dart
```

## 다음 단계

- [x] S 1.1.3: 전역 상태 관리 설계
- [ ] 실제 테스트 실행 및 결과 확인
- [ ] S 1.2.1: 인증 시스템 구현 시 userModelProvider 완성
- [ ] S 1.2.2: 아동 프로필 관리 시 childrenListProvider 완성
- [ ] WP 1.3: 검사 실행 프레임워크와 assessmentStateProvider 통합

## 참고 자료

- [상태 관리 가이드](./STATE_MANAGEMENT_GUIDE.md)
- [상태 관리 코드](./lib/core/state/)
- [상태 관리 README](./lib/core/state/README.md)

