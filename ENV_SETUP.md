# 환경 변수 설정 가이드

## 환경 변수 파일 생성

프로젝트 루트에 다음 파일들을 생성하세요:

### 1. 개발 환경 (.env.dev)

```bash
# 개발 환경 설정
ENVIRONMENT=development
APP_NAME=문해력 기초 검사 (개발)
APP_VERSION=1.0.0-dev

# Firebase 설정 (선택사항 - flutterfire configure 후 자동 설정됨)
# FIREBASE_PROJECT_ID=your-project-id
# FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
# FIRESTORE_DATABASE_ID=(default)

# API 설정
# API_BASE_URL=http://localhost:3000
```

### 2. 스테이징 환경 (.env.staging)

```bash
# 스테이징 환경 설정
ENVIRONMENT=staging
APP_NAME=문해력 기초 검사 (스테이징)
APP_VERSION=1.0.0-staging

# API 설정
# API_BASE_URL=https://staging-api.example.com
```

### 3. 프로덕션 환경 (.env.prod)

```bash
# 프로덕션 환경 설정
ENVIRONMENT=production
APP_NAME=문해력 기초 검사
APP_VERSION=1.0.0

# API 설정
# API_BASE_URL=https://api.example.com
```

## 실행 방법

### 개발 환경
```bash
flutter run --dart-define=ENV_FILE=.env.dev
```

### 스테이징 환경
```bash
flutter run --dart-define=ENV_FILE=.env.staging
```

### 프로덕션 환경
```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## 주의사항

- `.env.*` 파일들은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다.
- 실제 환경 변수 값은 `.env.example`을 참고하여 생성하세요.
- Firebase 설정은 `flutterfire configure` 명령어로 자동 설정되며, 상세 내용은 [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)를 참고하세요.

