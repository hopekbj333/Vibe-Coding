# Firebase 연동 검증 가이드 (S 1.1.2)

## 요구사항 검증

### ✅ 1. Firebase 프로젝트 생성 및 앱 등록

**검증 항목:**
- [x] Firebase 패키지 추가 (firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_crashlytics)
- [x] Firebase 초기화 설정 파일 생성 (`lib/config/firebase/firebase_config.dart`)
- [x] Firebase 미설정 시에도 앱 실행 보장
- [x] Firebase 초기화 상태 확인 메서드 제공

**구현 확인:**
```dart
// lib/config/firebase/firebase_config.dart
// - FirebaseConfig.initialize() 메서드
// - FirebaseConfig.isInitialized 속성
// - 안전한 초기화 처리 (Firebase 없어도 앱 실행)
```

**테스트 방법:**
1. Firebase 없이 앱 실행 확인:
   ```bash
   flutter run --dart-define=ENV_FILE=.env.dev
   ```
   - 앱이 정상적으로 실행되어야 함
   - 콘솔에 Firebase 초기화 스킵 메시지 출력

2. Firebase 설정 후 초기화 확인:
   ```bash
   flutterfire configure
   # firebase_config.dart에서 주석 해제
   flutter run
   ```
   - Firebase가 정상적으로 초기화되어야 함

### ✅ 2. Firestore 데이터베이스 초기 스키마 설계

**검증 항목:**
- [x] Firestore 스키마 문서화 (`lib/config/firebase/firestore_schema.dart`)
- [x] 컬렉션 구조 정의 (users, children, assessments, assessment_results, audio_recordings, scores)
- [x] 데이터 모델 클래스 구현 (ModuleProgress, ModuleScore)
- [x] Firestore 접근 헬퍼 클래스 (`lib/config/firebase/firebase_repositories.dart`)

**스키마 구조:**
```
users/
  {userId}/
    - email, displayName, role, createdAt, updatedAt, children[]

children/
  {childId}/
    - parentId, name, birthDate, gender, createdAt, updatedAt, 
      lastAssessmentDate, assessmentCount

assessments/
  {assessmentId}/
    - childId, parentId, status, startedAt, completedAt, pausedAt,
      currentModule, currentStep, modules{}
    - responses/ (하위 컬렉션)

assessment_results/
  {resultId}/
    - assessmentId, childId, parentId, completedAt, totalScore,
      moduleScores{}, reportGeneratedAt

audio_recordings/
  {recordingId}/
    - assessmentId, childId, module, step, questionId, storagePath,
      duration, recordedAt, scoringStatus, score

scores/
  {scoreId}/
    - assessmentId, childId, module, questionId, isCorrect, score,
      responseData{}, scoredAt, scoredBy, scoringMethod
```

**테스트 방법:**
```dart
// Firestore 접근 테스트
final usersRef = FirebaseRepositories.usersCollection;
if (usersRef != null) {
  // Firebase가 초기화된 경우에만 접근 가능
  print('Firestore accessible');
} else {
  print('Firestore not available (Firebase not initialized)');
}
```

### ✅ 3. Storage 버킷 설정 (음성 파일 저장용)

**검증 항목:**
- [x] Firebase Storage 연동 코드 구현 (`lib/config/firebase/firebase_storage.dart`)
- [x] 오디오 파일 업로드 메서드
- [x] 오디오 파일 다운로드 URL 가져오기
- [x] 오디오 파일 삭제 메서드 (채점 완료 후)
- [x] Storage 경로 생성 헬퍼

**구현 확인:**
```dart
// lib/config/firebase/firebase_storage.dart
// - FirebaseStorageService.uploadAudioRecording()
// - FirebaseStorageService.getDownloadUrl()
// - FirebaseStorageService.deleteAudioRecording()
// - FirebaseStorageService.buildAudioPath()
```

**Storage 경로 구조:**
```
audio_recordings/
  {assessmentId}/
    {childId}/
      {module}/
        {step}/
          {questionId}.wav
```

**테스트 방법:**
```dart
// Storage 업로드 테스트 (Firebase 설정 후)
final path = await FirebaseStorageService.uploadAudioRecording(
  localFilePath: '/path/to/audio.wav',
  assessmentId: 'assessment-123',
  childId: 'child-456',
  module: 'executive',
  step: 'working_memory',
  questionId: 'question-789',
);
```

### ✅ 4. Cloud Functions 기본 설정

**검증 항목:**
- [x] Cloud Functions 설정 가이드 작성 (`FIREBASE_SETUP.md`)
- [x] Functions 초기화 방법 문서화
- [x] 기본 Functions 예시 제공

**구현 확인:**
- `FIREBASE_SETUP.md` 파일에 Cloud Functions 설정 섹션 포함
- 검사 완료 시 처리 로직 예시 제공

**테스트 방법:**
```bash
# Cloud Functions 초기화
firebase init functions

# Functions 배포
firebase deploy --only functions
```

## 추가 검증 사항

### ✅ 5. 환경 변수 통합

**검증 항목:**
- [x] Firebase 프로젝트 ID 환경 변수 읽기
- [x] Firestore 데이터베이스 ID 환경 변수 읽기
- [x] Storage 버킷 이름 환경 변수 읽기

**구현 확인:**
```dart
// lib/config/firebase/firebase_config.dart
// - FirebaseConfig.projectId
// - FirebaseConfig.firestoreDatabaseId
// - FirebaseConfig.storageBucket
```

**환경 변수 설정 (.env.dev):**
```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIRESTORE_DATABASE_ID=(default)
```

### ✅ 6. 안전성 및 에러 처리

**검증 항목:**
- [x] Firebase 미설정 시 앱 실행 보장
- [x] Firebase 초기화 실패 시 안전한 처리
- [x] 모든 Firebase 서비스 접근 시 null 체크
- [x] 디버그 모드에서 명확한 로그 메시지

**구현 확인:**
- `FirebaseConfig.initialize()`는 항상 성공 (Firebase 없어도)
- `FirebaseRepositories`의 모든 메서드는 null 반환 가능
- `FirebaseStorageService`는 null 체크 후 동작

## 실행 테스트

### 1. Firebase 없이 앱 실행

```bash
flutter run --dart-define=ENV_FILE=.env.dev
```

**예상 결과:**
- 앱이 정상적으로 실행됨
- 콘솔에 "⚠ Firebase initialization skipped" 메시지 출력
- Firebase 기능은 사용 불가하지만 앱은 정상 작동

### 2. Firebase 설정 후 초기화

```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 프로젝트 연결
flutterfire configure

# firebase_config.dart 수정
# - firebase_options.dart import 추가
# - Firebase.initializeApp() 주석 해제
# - _isInitialized = true; 설정

# 앱 실행
flutter run
```

**예상 결과:**
- Firebase가 정상적으로 초기화됨
- Firestore, Storage, Auth 서비스 사용 가능

### 3. Firestore 읽기/쓰기 테스트

```dart
// Firebase 초기화 후
final usersRef = FirebaseRepositories.usersCollection;
if (usersRef != null) {
  // 테스트 문서 생성
  await usersRef.doc('test-user').set({
    'email': 'test@example.com',
    'role': 'parent',
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // 문서 읽기
  final doc = await usersRef.doc('test-user').get();
  print('User data: ${doc.data()}');
}
```

### 4. Storage 업로드 테스트

```dart
// Firebase 초기화 후
final path = await FirebaseStorageService.uploadAudioRecording(
  localFilePath: '/path/to/test.wav',
  assessmentId: 'test-assessment',
  childId: 'test-child',
  module: 'executive',
  step: 'working_memory',
  questionId: 'test-question',
);

if (path != null) {
  print('File uploaded to: $path');
  
  // 다운로드 URL 가져오기
  final url = await FirebaseStorageService.getDownloadUrl(path);
  print('Download URL: $url');
}
```

## 발견된 문제 및 해결

### ✅ 해결된 문제

1. **Firebase 초기화 실패 시 앱 크래시**
   - 문제: Firebase 초기화 실패 시 앱이 실행되지 않음
   - 해결: try-catch로 안전하게 처리, Firebase 없어도 앱 실행 보장

2. **환경 변수 읽기 미구현**
   - 문제: projectId, storageBucket 등이 하드코딩되어 있음
   - 해결: dotenv를 통한 환경 변수 읽기 구현

3. **Firestore 스키마 문서화만 존재**
   - 문제: 실제 사용 가능한 모델 클래스가 없음
   - 해결: ModuleProgress, ModuleScore에 fromMap/toMap 메서드 추가

4. **Storage 연동 코드 부재**
   - 문제: Storage 사용을 위한 코드가 없음
   - 해결: FirebaseStorageService 클래스 구현

5. **Firebase 서비스 접근 헬퍼 부재**
   - 문제: 각 feature에서 직접 Firestore/Auth 접근
   - 해결: FirebaseRepositories 헬퍼 클래스 구현

## 다음 단계

- [ ] 실제 Firebase 프로젝트 생성 및 설정
- [ ] firebase_options.dart 파일 생성 (flutterfire configure)
- [ ] Firebase 초기화 코드 활성화
- [ ] Firestore 보안 규칙 설정
- [ ] Storage 보안 규칙 설정
- [ ] 실제 디바이스/에뮬레이터에서 테스트
- [ ] S 1.1.3: 전역 상태 관리 설계

## 참고 자료

- [Firebase 설정 가이드](./FIREBASE_SETUP.md)
- [Firestore 스키마](./lib/config/firebase/firestore_schema.dart)
- [Firebase Storage 서비스](./lib/config/firebase/firebase_storage.dart)
- [Firebase Repositories](./lib/config/firebase/firebase_repositories.dart)

