# 인증 시스템 가이드 (S 1.2.1)

이 디렉토리는 사용자 인증 관련 기능을 포함합니다.

## 목적

**왜 필요한가요?**
- 아동 데이터 보안 보장 (인증된 사용자만 접근)
- 학부모/교사 계정 관리
- 사용자 편의성 (자동 로그인, 소셜 로그인)

## 구조

```
lib/features/auth/
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart              # 인증 저장소 인터페이스
│   └── services/
│       ├── auth_service.dart                 # 인증 서비스 (비즈니스 로직)
│       └── auth_token_service.dart        # 토큰 서비스 (자동 로그인)
├── data/
│   ├── repositories/
│   │   └── auth_repository_impl.dart         # 인증 저장소 구현 (Firebase)
│   ├── models/
│   │   └── user_model_firestore.dart         # Firestore 모델 변환
│   └── exceptions/
│       └── auth_exceptions.dart              # 인증 예외
└── presentation/
    ├── pages/
    │   ├── login_page.dart                   # 로그인 화면
    │   └── signup_page.dart                  # 회원가입 화면
    └── providers/
        └── auth_providers.dart               # 인증 Provider (Riverpod)
```

## 사용 방법

### 1. 로그인

```dart
import 'package:literacy_assessment/features/auth/presentation/providers/auth_providers.dart';

// 이메일/비밀번호 로그인
final result = await ref.read(
  signInWithEmailProvider(
    SignInParams(
      email: 'user@example.com',
      password: 'password123',
    ),
  ).future,
);

// Google 로그인
final result = await ref.read(signInWithGoogleProvider.future);

// Apple 로그인
final result = await ref.read(signInWithAppleProvider.future);
```

### 2. 회원가입

```dart
final result = await ref.read(
  signUpWithEmailProvider(
    SignUpParams(
      email: 'user@example.com',
      password: 'password123',
      displayName: '사용자 이름',
    ),
  ).future,
);
```

### 3. 로그아웃

```dart
await ref.read(signOutProvider.future);
```

### 4. 인증 상태 확인

```dart
import 'package:literacy_assessment/core/state/auth_providers.dart';

// 인증 상태 확인
final authStatus = ref.watch(authStatusProvider);
if (authStatus == AuthStatus.authenticated) {
  // 로그인된 상태
}

// 현재 사용자 정보
final userModel = ref.watch(userModelProvider);
```

### 5. 비밀번호 재설정

```dart
await ref.read(
  resetPasswordProvider('user@example.com').future,
);
```

## 자동 로그인

Firebase Auth가 자동으로 토큰을 관리하므로, 별도의 설정 없이 자동 로그인이 작동합니다.

- 앱 재시작 시 `authStateChangesProvider`가 자동으로 인증 상태 확인
- 인증된 사용자가 있으면 자동 로그인 상태 유지
- 토큰 만료 시 자동 갱신

## 에러 처리

인증 중 발생한 에러는 `authErrorProvider`를 통해 확인할 수 있습니다:

```dart
final error = ref.watch(authErrorProvider);
if (error != null) {
  // 에러 메시지 표시
}
```

## 향후 확장

- [ ] 카카오 로그인 추가
- [ ] 이메일 인증 강제
- [ ] 2단계 인증 (선택적)

