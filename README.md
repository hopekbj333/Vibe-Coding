# 문해력 기초 검사 앱

문해력 기초 검사 및 훈련을 위한 Flutter 앱입니다.

## 프로젝트 구조

이 프로젝트는 **feature-first** 구조를 따릅니다:

```
lib/
├── config/              # 앱 설정
│   ├── app_config.dart  # 환경 설정 관리
│   └── routes/          # 라우팅 설정
├── core/                # 공통 모듈
│   ├── assets/          # 에셋 매니저 (S 1.1.4) ✅
│   ├── state/           # 상태 관리 (S 1.1.3) ✅
│   └── theme/           # 테마 설정
├── features/            # 기능별 모듈 (feature-first)
│   ├── splash/          # 스플래시 화면
│   ├── home/            # 홈 화면
│   ├── auth/            # 인증 (S 1.2.1) ✅
│   ├── profile/         # 프로필 관리 (향후 S 1.2.2)
│   ├── assessment/      # 검사 실행 (향후 WP 1.3)
│   │   ├── framework/   # 검사 프레임워크
│   │   ├── modules/     # 검사 모듈
│   │   │   ├── phonological/  # 음운 인식 (WP 1.4)
│   │   │   ├── sensory/       # 감각 처리 (WP 1.5)
│   │   │   └── executive/     # 인지 제어 (WP 1.6)
│   ├── scoring/         # 채점 시스템 (향후 WP 1.7)
│   └── report/          # 결과 리포트 (향후 WP 1.8)
└── main.dart            # 앱 진입점
```

## 환경 설정

### 1. 환경 변수 파일 복사

```bash
cp .env.example .env.dev
```

### 2. 환경별 실행

개발 환경:
```bash
flutter run --dart-define=ENV_FILE=.env.dev
```

스테이징 환경:
```bash
flutter run --dart-define=ENV_FILE=.env.staging
```

프로덕션 환경:
```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## 개발 가이드

### 라우팅 추가

`lib/config/routes/app_router.dart`에 새로운 라우트를 추가하세요:

```dart
GoRoute(
  path: '/your-route',
  name: 'your-route',
  builder: (context, state) => const YourPage(),
),
```

### 새로운 기능 추가

1. `lib/features/` 하위에 새 폴더 생성
2. feature 내부 구조:
   ```
   feature_name/
   ├── data/          # 데이터 레이어
   ├── domain/        # 도메인 레이어
   └── presentation/  # 프레젠테이션 레이어
       ├── pages/
       ├── widgets/
       └── providers/
   ```

## Firebase 설정

Firebase 연동을 위한 상세 가이드는 [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)를 참고하세요.

### 빠른 시작

1. Firebase 프로젝트 생성 및 앱 등록
2. FlutterFire CLI 설치 및 설정:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Firebase 서비스 활성화 (Firestore, Storage, Authentication)
4. 환경 변수 설정 (`.env.dev` 파일에 Firebase 설정 추가)

## 다음 단계

- [x] S 1.1.2: Firebase 연동
- [x] S 1.1.3: 전역 상태 관리 설계
- [x] S 1.1.4: 에셋 매니저 구현
- [x] S 1.1.5: 공통 UI 라이브러리

## 참고 문서

- [마일스톤 1](./milestone1.md)
- [PRD](./mh_basic_PRD_v1.1.md)
- [Firebase 설정 가이드](./FIREBASE_SETUP.md)
- [환경 변수 설정](./ENV_SETUP.md)

