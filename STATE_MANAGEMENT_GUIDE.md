# 전역 상태 관리 설계 가이드 (S 1.1.3)

## 개요

이 프로젝트는 **Riverpod**을 사용하여 전역 상태를 관리합니다.

## 선택 이유

### Riverpod 선택 이유

1. **타입 안전성**: 컴파일 타임에 타입 오류를 잡을 수 있습니다.
2. **테스트 용이성**: Provider를 쉽게 모킹하고 테스트할 수 있습니다.
3. **Firebase 통합**: Firebase Auth와 Firestore와 자연스럽게 통합됩니다.
4. **성능**: 불필요한 재빌드를 방지하고 최적화된 상태 관리가 가능합니다.
5. **확장성**: 복잡한 상태 로직도 쉽게 관리할 수 있습니다.

### Provider vs Bloc vs Riverpod

- **Provider**: 간단하지만 타입 안전성이 부족하고 테스트가 어렵습니다.
- **Bloc**: 강력하지만 보일러플레이트가 많고 학습 곡선이 높습니다.
- **Riverpod**: 타입 안전하고 테스트하기 쉬우며, Provider의 단순함과 Bloc의 강력함을 모두 갖추고 있습니다.

## 상태 구조

### 1. 인증 상태 (Authentication State)

**목적**: 사용자 인증 상태 및 사용자 정보 관리

**Provider**:
- `authStatusProvider`: 현재 인증 상태 (`AuthStatus`)
- `currentUserProvider`: Firebase Auth 사용자
- `userModelProvider`: Firestore 사용자 정보 (`UserModel`)

**사용 시나리오**:
- 로그인/로그아웃 상태 확인
- 사용자 정보 표시
- 인증이 필요한 화면 접근 제어

### 2. 앱 모드 (App Mode)

**목적**: 부모 모드와 아동 모드 전환 관리

**Provider**:
- `appModeProvider`: 현재 앱 모드 (`AppMode`)

**사용 시나리오**:
- 부모 모드: 아동 프로필 관리, 검사 결과 확인, 채점 작업
- 아동 모드: 검사 실행, 학습 콘텐츠 이용

### 3. 아동 프로필 (Child Profile)

**목적**: 선택된 아동 프로필 및 아동 목록 관리

**Provider**:
- `selectedChildProvider`: 현재 선택된 아동 프로필
- `childrenListProvider`: 아동 프로필 목록

**사용 시나리오**:
- 아동 프로필 선택 화면
- 검사 실행 시 아동 정보 사용
- 아동별 검사 이력 확인

### 4. 검사 진행 상태 (Assessment State)

**목적**: 검사 진행 상태 및 일시 정지/재개 관리

**Provider**:
- `assessmentStateProvider`: 검사 진행 상태

**사용 시나리오**:
- 검사 진행 중 상태 표시
- 검사 일시 정지 및 재개
- 검사 완료 처리

## 구현 상태

### ✅ 완료된 항목

- [x] Riverpod 패키지 추가
- [x] 상태 모델 클래스 정의 (`app_state.dart`)
- [x] 인증 상태 Provider 구현
- [x] 앱 모드 Provider 구현
- [x] 아동 프로필 Provider 구현
- [x] 검사 진행 상태 Provider 구현
- [x] main.dart에 ProviderScope 추가

### 🔄 향후 구현 예정

- [ ] S 1.2.1: 인증 시스템 구현 시 `userModelProvider` 완성
- [ ] S 1.2.2: 아동 프로필 관리 시 `childrenListProvider` 완성
- [ ] WP 1.3: 검사 실행 프레임워크와 `assessmentStateProvider` 통합

## 사용 방법

### 기본 사용법

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerWidget 사용
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appMode = ref.watch(appModeProvider);
    return Text('현재 모드: $appMode');
  }
}

// ConsumerStatefulWidget 사용
class MyStatefulWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final appMode = ref.watch(appModeProvider);
    return Text('현재 모드: $appMode');
  }
}
```

### 상태 변경

```dart
// StateNotifier를 사용하는 경우
final notifier = ref.read(appModeProvider.notifier);
notifier.switchToChildMode();

// 직접 상태를 변경하는 경우 (StateProvider)
ref.read(someProvider.notifier).state = newValue;
```

## 테스트

### Provider 테스트 예시

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/app_mode_providers.dart';
import 'package:literacy_assessment/core/state/app_state.dart';

void main() {
  test('앱 모드 전환 테스트', () {
    final container = ProviderContainer();
    
    // 초기 상태 확인
    expect(container.read(appModeProvider), AppMode.parent);
    
    // 모드 전환
    container.read(appModeProvider.notifier).switchToChildMode();
    expect(container.read(appModeProvider), AppMode.child);
    
    // 다시 부모 모드로
    container.read(appModeProvider.notifier).switchToParentMode();
    expect(container.read(appModeProvider), AppMode.parent);
  });
}
```

## 참고 자료

- [Riverpod 공식 문서](https://riverpod.dev/)
- [상태 관리 코드](./lib/core/state/)
- [상태 관리 README](./lib/core/state/README.md)

