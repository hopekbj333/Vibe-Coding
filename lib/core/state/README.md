# 전역 상태 관리 가이드

이 디렉토리는 Riverpod을 사용한 전역 상태 관리를 담당합니다.

## 구조

```
lib/core/state/
├── app_state.dart              # 상태 모델 정의
├── auth_providers.dart         # 인증 관련 Provider
├── app_mode_providers.dart     # 앱 모드 (부모/아동) Provider
├── child_providers.dart        # 아동 프로필 관련 Provider
├── assessment_providers.dart   # 검사 진행 상태 Provider
└── README.md                   # 이 파일
```

## 상태 구조

### 1. 인증 상태 (Auth)

- `authStatusProvider`: 현재 인증 상태 (`AuthStatus`)
- `currentUserProvider`: Firebase Auth 사용자
- `userModelProvider`: Firestore 사용자 정보 (`UserModel`)

### 2. 앱 모드 (App Mode)

- `appModeProvider`: 현재 앱 모드 (`AppMode.parent` / `AppMode.child`)

### 3. 아동 프로필 (Child)

- `selectedChildProvider`: 현재 선택된 아동 프로필 (`ChildModel?`)
- `childrenListProvider`: 아동 프로필 목록 (`List<ChildModel>`)

### 4. 검사 진행 상태 (Assessment)

- `assessmentStateProvider`: 검사 진행 상태 (`AssessmentStateModel`)

## 사용 예시

### 1. 인증 상태 확인

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/auth_providers.dart';
import 'package:literacy_assessment/core/state/app_state.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);
    final userModel = ref.watch(userModelProvider);

    return authStatus.when(
      data: (status) {
        if (status == AuthStatus.authenticated) {
          return Text('로그인됨: ${userModel.value?.email}');
        }
        return Text('로그인 필요');
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('오류: $error'),
    );
  }
}
```

### 2. 앱 모드 전환

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/app_mode_providers.dart';
import 'package:literacy_assessment/core/state/app_state.dart';

class ModeSwitchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appMode = ref.watch(appModeProvider);
    final appModeNotifier = ref.read(appModeProvider.notifier);

    return Row(
      children: [
        Text('현재 모드: ${appMode == AppMode.parent ? "부모" : "아동"}'),
        ElevatedButton(
          onPressed: () => appModeNotifier.toggleMode(),
          child: Text('모드 전환'),
        ),
      ],
    );
  }
}
```

### 3. 아동 프로필 선택

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/child_providers.dart';
import 'package:literacy_assessment/core/state/app_state.dart';

class ChildSelectionWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenListProvider);
    final selectedChild = ref.watch(selectedChildProvider);
    final childNotifier = ref.read(selectedChildProvider.notifier);

    return children.when(
      data: (childrenList) {
        return Column(
          children: [
            if (selectedChild != null)
              Text('선택된 아동: ${selectedChild.name}'),
            ...childrenList.map((child) => ListTile(
              title: Text(child.name),
              subtitle: Text('${child.age}세'),
              onTap: () => childNotifier.selectChild(child),
            )),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('오류: $error'),
    );
  }
}
```

### 4. 검사 진행 상태 관리

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/assessment_providers.dart';
import 'package:literacy_assessment/core/state/app_state.dart';

class AssessmentWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentState = ref.watch(assessmentStateProvider);
    final assessmentNotifier = ref.read(assessmentStateProvider.notifier);

    return Column(
      children: [
        Text('검사 상태: ${assessmentState.status}'),
        if (assessmentState.isInProgress)
          Text('현재 모듈: ${assessmentState.currentModule}'),
        ElevatedButton(
          onPressed: () {
            assessmentNotifier.startAssessment(
              assessmentId: 'assessment-123',
              childId: 'child-456',
              module: 'phonological',
              step: 1,
            );
          },
          child: Text('검사 시작'),
        ),
        if (assessmentState.isInProgress)
          ElevatedButton(
            onPressed: () => assessmentNotifier.pauseAssessment(),
            child: Text('일시 정지'),
          ),
        if (assessmentState.isPaused)
          ElevatedButton(
            onPressed: () => assessmentNotifier.resumeAssessment(),
            child: Text('재개'),
          ),
      ],
    );
  }
}
```

## Provider 타입

### StateProvider
단순한 값을 관리할 때 사용합니다.

### StateNotifierProvider
복잡한 상태 로직이 있을 때 사용합니다. (예: `appModeProvider`, `assessmentStateProvider`)

### StreamProvider
Firebase Auth 같은 스트림을 감지할 때 사용합니다. (예: `authStateChangesProvider`)

### FutureProvider
비동기 작업의 결과를 관리할 때 사용합니다. (예: `userModelProvider`, `childrenListProvider`)

## 주의사항

1. **ConsumerWidget 사용**: Provider를 사용하는 위젯은 `ConsumerWidget`을 상속해야 합니다.
2. **ref.watch vs ref.read**: 
   - `ref.watch`: 상태 변화를 감지하고 위젯을 재빌드합니다.
   - `ref.read`: 상태를 읽기만 하고 재빌드하지 않습니다.
3. **Firebase 연동**: Firebase가 초기화되지 않은 경우 안전하게 처리됩니다.

## 향후 확장

- S 1.2.1: 인증 시스템 구현 시 `userModelProvider` 완성
- S 1.2.2: 아동 프로필 관리 시 `childrenListProvider` 완성
- WP 1.3: 검사 실행 프레임워크와 `assessmentStateProvider` 통합

