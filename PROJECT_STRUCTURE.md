# 프로젝트 구조

## 개요

이 프로젝트는 **feature-first** 아키텍처를 따릅니다. 각 기능 모듈이 독립적으로 구성되어 있어 확장성과 유지보수성이 뛰어납니다.

## 디렉토리 구조

```
문해력 기초 검사/
├── lib/
│   ├── config/                    # 앱 설정
│   │   ├── app_config.dart        # 환경 설정 관리 (dev/staging/prod)
│   │   └── routes/
│   │       └── app_router.dart    # GoRouter 라우팅 설정
│   │
│   ├── core/                      # 공통 모듈
│   │   ├── assets/                # 에셋 매니저 (S 1.1.4) ✅
│   │   │   ├── asset_manager.dart
│   │   │   ├── asset_loading_providers.dart
│   │   │   ├── asset_loading_widget.dart
│   │   │   └── asset_utils.dart
│   │   ├── design/                # 디자인 시스템 (S 1.1.5) ✅
│   │   │   └── design_system.dart
│   │   ├── state/                  # 상태 관리 (S 1.1.3) ✅
│   │   │   ├── app_mode_providers.dart
│   │   │   ├── assessment_providers.dart
│   │   │   ├── auth_providers.dart
│   │   │   └── child_providers.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart    # 앱 테마 설정
│   │   └── widgets/               # 공통 UI 컴포넌트 (S 1.1.5) ✅
│   │       ├── child_friendly_button.dart
│   │       ├── child_friendly_dialog.dart
│   │       ├── child_friendly_loading_indicator.dart
│   │       └── animation_utils.dart
│   │
│   ├── features/                  # 기능별 모듈 (feature-first)
│   │   ├── splash/                # 스플래시 화면
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── splash_page.dart
│   │   │
│   │   ├── home/                  # 홈 화면
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── home_page.dart
│   │   │
│   │   ├── auth/                  # 인증 (S 1.2.1) ✅
│   │   ├── profile/               # 프로필 관리 (향후 S 1.2.2)
│   │   ├── assessment/            # 검사 실행 (향후 WP 1.3)
│   │   │   ├── framework/         # 검사 프레임워크
│   │   │   └── modules/           # 검사 모듈
│   │   │       ├── phonological/ # 음운 인식 (WP 1.4)
│   │   │       ├── sensory/      # 감각 처리 (WP 1.5)
│   │   │       └── executive/    # 인지 제어 (WP 1.6)
│   │   ├── scoring/               # 채점 시스템 (향후 WP 1.7)
│   │   └── report/                # 결과 리포트 (향후 WP 1.8)
│   │
│   └── main.dart                  # 앱 진입점
│
├── assets/                        # 에셋 파일 (S 1.1.4) ✅
│   ├── images/                    # 이미지 에셋
│   ├── audio/                     # 오디오 에셋
│   └── characters/                # 캐릭터 이미지
│
├── pubspec.yaml                   # 프로젝트 설정 및 의존성
├── analysis_options.yaml         # Linter 설정
├── .gitignore                    # Git 제외 파일
├── README.md                      # 프로젝트 개요
├── ENV_SETUP.md                   # 환경 변수 설정 가이드
└── PROJECT_STRUCTURE.md           # 이 파일
```

## Feature 구조

각 feature는 다음과 같은 구조를 가집니다:

```
feature_name/
├── data/              # 데이터 레이어 (향후 추가)
│   ├── models/        # 데이터 모델
│   ├── repositories/  # 데이터 저장소
│   └── datasources/   # 데이터 소스 (API, 로컬 DB)
│
├── domain/            # 도메인 레이어 (향후 추가)
│   ├── entities/      # 도메인 엔티티
│   ├── usecases/     # 비즈니스 로직
│   └── repositories/  # 리포지토리 인터페이스
│
└── presentation/      # 프레젠테이션 레이어
    ├── pages/         # 화면 페이지
    ├── widgets/       # 재사용 가능한 위젯
    └── providers/     # 상태 관리 (향후 S 1.1.3)
```

## 아키텍처 선택 이유

### Feature-First 구조

1. **모듈화**: 각 검사 모듈(음운 인식, 감각 처리, 인지 제어)이 독립적으로 개발 가능
2. **확장성**: 새로운 검사 모듈 추가가 용이
3. **협업**: 여러 개발자가 동시에 다른 feature를 작업하기 쉬움
4. **테스트**: 각 feature를 독립적으로 테스트 가능

### Layer-First 대비 장점

- 검사 모듈별로 명확한 경계
- 기능 중심의 코드 조직
- 향후 마이크로서비스로 분리 가능

## 환경 변수 관리

환경별 설정은 `AppConfig` 클래스를 통해 관리됩니다:

- **개발 환경**: `.env.dev`
- **스테이징 환경**: `.env.staging`
- **프로덕션 환경**: `.env.prod`

자세한 내용은 [ENV_SETUP.md](./ENV_SETUP.md)를 참고하세요.

## 라우팅

`go_router`를 사용한 선언적 라우팅:

- 중첩 라우팅 지원
- 딥 링크 처리
- 타입 안전한 네비게이션

라우트는 `lib/config/routes/app_router.dart`에서 관리됩니다.

## 다음 단계

- [x] S 1.1.2: Firebase 연동
- [x] S 1.1.3: 전역 상태 관리 설계
- [x] S 1.1.4: 에셋 매니저 구현
- [x] S 1.1.5: 공통 UI 라이브러리
- [ ] S 1.1.5: 공통 UI 라이브러리

