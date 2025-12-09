# 프로젝트 설정 가이드

## S 1.1.1 완료 후 다음 단계

### 1. Flutter 프로젝트 초기화

현재 코드는 `lib/` 폴더만 있는 상태입니다. 실제 Flutter 프로젝트를 생성하려면:

```bash
cd "문해력 기초 검사"
flutter create .
```

이 명령은 다음을 생성합니다:
- `android/` - Android 플랫폼 설정
- `ios/` - iOS 플랫폼 설정
- `web/` - Web 플랫폼 설정
- `test/` - 테스트 파일 (기존 test/ 폴더와 병합)

### 2. 환경 변수 파일 생성

프로젝트 루트에 환경 변수 파일을 생성하세요:

#### .env.dev (개발 환경)
```env
ENVIRONMENT=development
APP_NAME=문해력 기초 검사 (개발)
APP_VERSION=1.0.0-dev
```

#### .env.staging (스테이징 환경)
```env
ENVIRONMENT=staging
APP_NAME=문해력 기초 검사 (스테이징)
APP_VERSION=1.0.0-staging
```

#### .env.prod (프로덕션 환경)
```env
ENVIRONMENT=production
APP_NAME=문해력 기초 검사
APP_VERSION=1.0.0
```

### 3. 의존성 설치

```bash
flutter pub get
```

### 4. 코드 분석

```bash
flutter analyze
```

### 5. 테스트 실행

```bash
flutter test
```

### 6. 앱 실행

#### 개발 환경
```bash
flutter run --dart-define=ENV_FILE=.env.dev
```

#### 스테이징 환경
```bash
flutter run --dart-define=ENV_FILE=.env.staging
```

#### 프로덕션 환경
```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## 검증 체크리스트

### S 1.1.1 요구사항

- [x] 프로젝트 생성 및 폴더 구조 설계 (feature-first)
- [x] 라우팅 설정 (go_router)
- [x] 환경 변수 관리 (dev/staging/prod)

### 추가 구현 사항

- [x] PRD 요구사항: 1.5배 느린 애니메이션
- [x] 아동 친화적 UX 준비
- [x] 에러 처리 및 기본값 처리
- [x] 코드 품질 (Linter 통과)

## 문제 해결

### 환경 변수 파일을 찾을 수 없음

**증상:**
```
Warning: Could not load .env.dev. Using default values.
```

**해결:**
1. 프로젝트 루트에 `.env.dev` 파일 생성
2. 파일 내용 확인
3. `--dart-define=ENV_FILE=.env.dev` 옵션 확인

### 패키지 버전 충돌

**증상:**
```
Because literacy_assessment depends on go_router ^13.0.0 which doesn't match any versions...
```

**해결:**
```bash
flutter pub upgrade
# 또는 pubspec.yaml에서 버전 범위 조정
```

### 라우팅 오류

**증상:**
```
Route not found: /splash
```

**해결:**
1. `lib/config/routes/app_router.dart` 확인
2. 라우트 경로가 올바른지 확인
3. `initialLocation` 확인

## 다음 단계

- [ ] S 1.1.2: Firebase 연동
- [ ] S 1.1.3: 전역 상태 관리 설계
- [ ] S 1.1.4: 에셋 매니저 구현
- [ ] S 1.1.5: 공통 UI 라이브러리

