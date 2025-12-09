# Firebase 설정 가이드

이 문서는 Firebase 연동을 위한 설정 가이드입니다.

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: `literacy-assessment`)
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

## 2. Flutter 앱 등록

### Android 앱 등록

1. Firebase Console에서 프로젝트 선택
2. "앱 추가" → Android 선택
3. 패키지 이름 입력: `com.example.literacy_assessment` (실제 패키지 이름으로 변경)
4. `google-services.json` 파일 다운로드
5. `android/app/` 디렉토리에 `google-services.json` 파일 복사

### iOS 앱 등록

1. Firebase Console에서 "앱 추가" → iOS 선택
2. 번들 ID 입력: `com.example.literacyAssessment` (실제 번들 ID로 변경)
3. `GoogleService-Info.plist` 파일 다운로드
4. `ios/Runner/` 디렉토리에 `GoogleService-Info.plist` 파일 복사

## 3. FlutterFire CLI 설정

### FlutterFire CLI 설치

```bash
dart pub global activate flutterfire_cli
```

### Firebase 프로젝트 연결

```bash
flutterfire configure
```

이 명령어를 실행하면:
- Firebase 프로젝트 선택
- 플랫폼 선택 (Android, iOS, Web 등)
- `lib/firebase_options.dart` 파일 자동 생성

## 4. Firebase 서비스 활성화

### Firestore 데이터베이스

1. Firebase Console → Firestore Database
2. "데이터베이스 만들기" 클릭
3. 프로덕션 모드 또는 테스트 모드 선택
   - **개발 단계**: 테스트 모드 (모든 읽기/쓰기 허용)
   - **프로덕션**: 보안 규칙 설정 필요
4. 위치 선택 (예: `asia-northeast3` - 서울)

### Firebase Storage

1. Firebase Console → Storage
2. "시작하기" 클릭
3. 보안 규칙 설정
   - **개발 단계**: 테스트 모드
   - **프로덕션**: 인증된 사용자만 접근 가능하도록 설정
4. 위치 선택 (Firestore와 동일한 위치 권장)

### Firebase Authentication

1. Firebase Console → Authentication
2. "시작하기" 클릭
3. 로그인 제공업체 활성화
   - 이메일/비밀번호 (필수)
   - Google (선택사항)
   - 기타 필요시 추가

## 5. 환경 변수 설정

`.env.dev` 파일에 Firebase 관련 설정 추가:

```bash
# Firebase 설정
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIRESTORE_DATABASE_ID=(default)
```

## 6. 코드 업데이트

`lib/config/firebase/firebase_config.dart` 파일을 업데이트하여 실제 Firebase 옵션을 사용하도록 수정:

```dart
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart'; // flutterfire configure로 생성된 파일

static Future<void> initialize() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ...
}
```

## 7. 보안 규칙 설정

### Firestore 보안 규칙

개발 단계 (테스트 모드):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

프로덕션 (인증된 사용자만):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /children/{childId} {
      allow read, write: if request.auth != null;
    }
    match /assessments/{assessmentId} {
      allow read, write: if request.auth != null;
    }
    // ... 기타 컬렉션 규칙
  }
}
```

### Storage 보안 규칙

개발 단계:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

프로덕션:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /audio_recordings/{recordingId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.resource.size < 10 * 1024 * 1024; // 10MB 제한
    }
  }
}
```

## 8. Cloud Functions 설정 (선택사항)

### Firebase Functions 초기화

```bash
firebase init functions
```

### Functions 디렉토리 구조

```
functions/
├── src/
│   ├── index.ts
│   └── assessments/
│       └── scoring.ts
├── package.json
└── tsconfig.json
```

### 기본 Functions 예시

```typescript
import * as functions from 'firebase-functions';

export const onAssessmentComplete = functions.firestore
  .document('assessments/{assessmentId}')
  .onUpdate(async (change, context) => {
    const data = change.after.data();
    if (data.status === 'completed') {
      // 검사 완료 시 처리 로직
      // 예: 리포트 생성, 알림 전송 등
    }
  });
```

## 9. 테스트

### Firebase 연결 테스트

```dart
// main.dart에서 Firebase 초기화 확인
await FirebaseConfig.initialize();
print('Firebase initialized: ${Firebase.app().name}');
```

### Firestore 읽기/쓰기 테스트

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// 쓰기 테스트
await FirebaseFirestore.instance
    .collection('test')
    .doc('test-doc')
    .set({'message': 'Hello Firebase!'});

// 읽기 테스트
final doc = await FirebaseFirestore.instance
    .collection('test')
    .doc('test-doc')
    .get();
print('Data: ${doc.data()}');
```

## 10. 다음 단계

- [ ] Firebase 프로젝트 생성 완료
- [ ] Flutter 앱 등록 완료 (Android/iOS)
- [ ] FlutterFire CLI 설정 완료
- [ ] Firestore 데이터베이스 생성
- [ ] Firebase Storage 활성화
- [ ] Firebase Authentication 활성화
- [ ] 보안 규칙 설정
- [ ] 환경 변수 설정
- [ ] 코드 업데이트 및 테스트

## 참고 자료

- [Firebase 공식 문서](https://firebase.google.com/docs)
- [FlutterFire 문서](https://firebase.flutter.dev/)
- [Firestore 보안 규칙](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage 보안 규칙](https://firebase.google.com/docs/storage/security)

