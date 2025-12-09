# 앱 기능 테스트 가이드

실제 앱 기능을 테스트하기 위한 단계별 가이드입니다.

## 현재 상태 확인

### 1단계: 현재 상태 확인

현재 Firebase가 설정되지 않아서 회원가입/로그인 기능이 작동하지 않습니다.

**확인 사항:**
- [ ] `.env.dev` 파일 존재 여부
- [ ] Firebase 프로젝트 생성 여부
- [ ] `firebase_options.dart` 파일 존재 여부
- [ ] Firebase 서비스 활성화 여부 (Auth, Firestore, Storage)

## 단계별 진행

### 2단계: 환경 변수 파일 생성

프로젝트 루트에 `.env.dev` 파일을 생성하세요:

```bash
# 개발 환경 설정
ENVIRONMENT=development
APP_NAME=문해력 기초 검사 (개발)
APP_VERSION=1.0.0-dev

# Firebase 설정 (Firebase 프로젝트 생성 후 추가)
# FIREBASE_PROJECT_ID=your-project-id
# FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
# FIRESTORE_DATABASE_ID=(default)
```

**작업:**
1. 프로젝트 루트에 `.env.dev` 파일 생성
2. 위 내용 복사하여 붙여넣기

### 3단계: Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: `literacy-assessment-dev`)
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

**작업 완료 후 알려주세요!**

### 4단계: FlutterFire CLI 설정

Firebase 프로젝트를 Flutter 앱에 연결합니다.

**필수 사전 준비:**
- Firebase 프로젝트 생성 완료
- Flutter CLI 설치 확인

**명령어:**
```bash
# FlutterFire CLI 설치 (처음 한 번만)
dart pub global activate flutterfire_cli

# Firebase 프로젝트 연결
flutterfire configure
```

**작업:**
1. 위 명령어 실행
2. Firebase 프로젝트 선택
3. 플랫폼 선택 (Android, iOS, Web 등)
4. `lib/firebase_options.dart` 파일 자동 생성 확인

**작업 완료 후 알려주세요!**

### 5단계: Firebase 서비스 활성화

#### 5-1. Firebase Authentication 활성화

1. Firebase Console → Authentication
2. "시작하기" 클릭
3. 로그인 제공업체 활성화:
   - **이메일/비밀번호**: 활성화 (필수)
   - **Google**: 활성화 (선택사항)
   - **Apple**: 활성화 (선택사항)

#### 5-2. Firestore Database 생성

1. Firebase Console → Firestore Database
2. "데이터베이스 만들기" 클릭
3. **테스트 모드** 선택 (개발 단계)
4. 위치 선택 (예: `asia-northeast3` - 서울)

#### 5-3. Firebase Storage 활성화

1. Firebase Console → Storage
2. "시작하기" 클릭
3. **테스트 모드** 선택 (개발 단계)
4. 위치 선택 (Firestore와 동일한 위치 권장)

**각 단계 완료 후 알려주세요!**

### 6단계: 코드 업데이트

Firebase가 설정되면 `firebase_config.dart` 파일을 업데이트해야 합니다.

**작업:**
1. `lib/config/firebase/firebase_config.dart` 파일 열기
2. 주석 처리된 Firebase 초기화 코드 활성화
3. `firebase_options.dart` import 추가

**작업 완료 후 알려주세요!**

### 7단계: 앱 실행 및 테스트

```bash
flutter run --dart-define=ENV_FILE=.env.dev
```

**테스트 항목:**
1. 회원가입 테스트
2. 로그인 테스트
3. 아동 프로필 등록 테스트
4. 아동 모드 전환 테스트

## 문제 해결

### Firebase 초기화 오류

**증상:** `Firebase not initialized` 메시지

**해결:**
1. `firebase_options.dart` 파일이 생성되었는지 확인
2. `firebase_config.dart`에서 초기화 코드가 활성화되었는지 확인
3. `.env.dev` 파일이 올바른 위치에 있는지 확인

### 회원가입 실패

**증상:** 회원가입 버튼 클릭 시 에러

**해결:**
1. Firebase Authentication에서 이메일/비밀번호 로그인이 활성화되었는지 확인
2. Firestore가 생성되었는지 확인
3. 콘솔 로그 확인

## 다음 단계

각 단계를 완료한 후 알려주시면 다음 단계로 진행하겠습니다!

