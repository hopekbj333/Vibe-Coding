# Firebase 설정 상태 확인 보고서

## 현재 설정 상태

### ✅ 올바르게 설정된 항목

1. **프로젝트 ID**: `literacy-assessment-dev`
   - `firebase.json`: ✅ 설정됨
   - `lib/firebase_options.dart`: ✅ 모든 플랫폼에서 설정됨
   - `android/app/google-services.json`: ✅ 설정됨

2. **Android 설정**
   - 패키지명: `com.example.literacy_assessment`
   - `google-services.json` 위치: `android/app/google-services.json` ✅
   - Gradle 플러그인: `com.google.gms.google-services` ✅

3. **Firebase 옵션 파일**
   - `lib/firebase_options.dart`: ✅ 생성됨
   - 모든 플랫폼 (Android, iOS, Web, Windows) 설정됨

### ⚠️ 확인이 필요한 항목

1. **Firebase Console 확인 필요**
   - Firebase Console에서 `literacy-assessment-dev` 프로젝트가 실제로 존재하는지 확인
   - 프로젝트 ID가 정확히 일치하는지 확인

2. **Firebase Authentication 활성화 확인**
   - Firebase Console → Authentication → Sign-in method
   - 이메일/비밀번호 로그인이 활성화되어 있는지 확인 필요

3. **Firestore 활성화 확인**
   - Firebase Console → Firestore Database
   - 데이터베이스가 생성되어 있는지 확인 필요
   - 위치: `asia-northeast3` (서울) 권장

4. **환경 변수 파일 (선택사항)**
   - `.env.dev` 파일에 Firebase 설정이 없지만, `firebase_options.dart`를 사용하므로 필수는 아님
   - 다만, 일관성을 위해 추가하는 것을 권장

## 올바른 설정 상태

### 1. Firebase 프로젝트 설정

**프로젝트 ID**: `literacy-assessment-dev`
- 모든 설정 파일에서 일치해야 함 ✅

**프로젝트 번호**: `459381156534`
- `google-services.json`에서 확인됨

### 2. Android 앱 설정

**패키지명**: `com.example.literacy_assessment`
- `android/app/build.gradle.kts`의 `applicationId`와 일치해야 함 ✅
- `google-services.json`의 `package_name`과 일치해야 함 ✅

**App ID**: `1:459381156534:android:de2b108a7d712ff3ac9417`
- `firebase_options.dart`와 `google-services.json`에서 일치 확인 ✅

### 3. Firebase 서비스 활성화 상태

다음 서비스들이 Firebase Console에서 활성화되어 있어야 합니다:

1. **Firebase Authentication**
   - 이메일/비밀번호 로그인: 활성화 필요
   - Google 로그인 (선택사항): 활성화 권장
   - Apple 로그인 (선택사항): iOS 사용 시 활성화 필요

2. **Cloud Firestore**
   - 데이터베이스 생성 필요
   - 위치: `asia-northeast3` (서울) 권장
   - 보안 규칙: 개발 단계에서는 테스트 모드 가능

3. **Firebase Storage**
   - Storage 활성화 필요
   - 위치: Firestore와 동일한 위치 권장

### 4. 코드 설정

**Firebase 초기화**: `lib/config/firebase/firebase_config.dart`
- `DefaultFirebaseOptions.currentPlatform` 사용 ✅
- 올바르게 설정됨

**인증 저장소**: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Firebase Auth와 Firestore 사용 ✅
- 올바르게 설정됨

## 회원가입 오류 해결 체크리스트

### 1단계: Firebase Console 확인

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. `literacy-assessment-dev` 프로젝트 선택
3. 프로젝트가 존재하는지 확인

### 2단계: Authentication 활성화 확인

1. Firebase Console → Authentication
2. "시작하기" 클릭 (아직 활성화되지 않은 경우)
3. Sign-in method 탭에서:
   - **이메일/비밀번호** 활성화 확인
   - "사용 설정" 토글이 켜져 있는지 확인

### 3단계: Firestore 활성화 확인

1. Firebase Console → Firestore Database
2. 데이터베이스가 생성되어 있는지 확인
3. 생성되지 않은 경우:
   - "데이터베이스 만들기" 클릭
   - 프로덕션 모드 또는 테스트 모드 선택
   - 위치 선택: `asia-northeast3` (서울) 권장

### 4단계: Storage 활성화 확인

1. Firebase Console → Storage
2. Storage가 활성화되어 있는지 확인
3. 활성화되지 않은 경우:
   - "시작하기" 클릭
   - 보안 규칙 설정 (개발 단계에서는 테스트 모드 가능)
   - 위치 선택 (Firestore와 동일한 위치 권장)

### 5단계: 앱 재빌드

Firebase 설정을 변경한 후에는 앱을 완전히 재빌드해야 합니다:

```bash
# Flutter 클린 빌드
flutter clean
flutter pub get

# Android 앱 재빌드
flutter run
```

## 현재 설정 파일 요약

### firebase.json
```json
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "literacy-assessment-dev",
          "appId": "1:459381156534:android:de2b108a7d712ff3ac9417"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "literacy-assessment-dev"
        }
      }
    }
  }
}
```

### lib/firebase_options.dart
- 프로젝트 ID: `literacy-assessment-dev` ✅
- Android App ID: `1:459381156534:android:de2b108a7d712ff3ac9417` ✅
- 모든 플랫폼 설정 완료 ✅

### android/app/google-services.json
- 프로젝트 ID: `literacy-assessment-dev` ✅
- 패키지명: `com.example.literacy_assessment` ✅
- 프로젝트 번호: `459381156534` ✅

## 결론

**코드 설정은 모두 올바르게 되어 있습니다.** ✅

회원가입 오류의 원인은 다음 중 하나일 가능성이 높습니다:

1. **Firebase Console에서 Authentication이 활성화되지 않음**
   - 가장 가능성 높음
   - Firebase Console → Authentication → Sign-in method에서 이메일/비밀번호 활성화 필요

2. **Firestore가 활성화되지 않음**
   - 회원가입 시 사용자 정보를 Firestore에 저장하므로 필요

3. **Firebase 프로젝트가 실제로 존재하지 않음**
   - 프로젝트 ID가 일치하지 않거나 프로젝트가 삭제된 경우

**다음 단계**: Firebase Console에서 위의 1-4단계를 확인하고, 문제가 있으면 수정한 후 앱을 재빌드하세요.

