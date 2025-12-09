# Firebase 보안 규칙 가이드

## 개요

이 문서는 Firebase Storage와 Firestore의 보안 규칙 설정 가이드를 제공합니다.
S 1.2.4 데이터 보안 정책에 따라 음성 데이터 접근 권한을 관리합니다.

## Firebase Storage 보안 규칙

### 프로덕션 규칙

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 음성 녹음 파일: 부모만 자신의 아동 데이터에 접근 가능
    match /audio_recordings/{assessmentId}/{childId}/{allPaths=**} {
      // 인증된 사용자만 접근 가능
      allow read, write: if request.auth != null
        && resource.metadata.parentId == request.auth.uid;
      
      // 새 파일 업로드 시: 부모 ID 확인
      allow create: if request.auth != null
        && request.resource.metadata.parentId == request.auth.uid;
    }
    
    // 기타 파일은 인증된 사용자만 접근
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 개발 단계 규칙 (테스트용)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true; // 개발 단계에서만 사용
    }
  }
}
```

## Firestore 보안 규칙

### 프로덕션 규칙

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 정보: 본인만 접근 가능
    match /users/{userId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId;
    }
    
    // 아동 프로필: 부모만 자신의 아동 데이터에 접근 가능
    match /children/{childId} {
      allow read, write: if request.auth != null
        && resource.data.parentId == request.auth.uid;
      
      // 새 아동 프로필 생성 시: 부모 ID 확인
      allow create: if request.auth != null
        && request.resource.data.parentId == request.auth.uid;
    }
    
    // 검사 세션: 부모만 자신의 아동 검사에 접근 가능
    match /assessments/{assessmentId} {
      allow read, write: if request.auth != null
        && resource.data.parentId == request.auth.uid;
    }
    
    // 검사 결과: 부모만 자신의 아동 결과에 접근 가능
    match /assessment_results/{resultId} {
      allow read, write: if request.auth != null
        && resource.data.parentId == request.auth.uid;
    }
    
    // 오디오 녹음 레코드: 부모만 자신의 아동 녹음에 접근 가능
    match /audio_recordings/{recordingId} {
      allow read, write: if request.auth != null
        && resource.data.parentId == request.auth.uid;
    }
    
    // 채점 데이터: 부모만 자신의 아동 채점에 접근 가능
    match /scores/{scoreId} {
      allow read, write: if request.auth != null
        && resource.data.parentId == request.auth.uid;
    }
  }
}
```

### 개발 단계 규칙 (테스트용)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // 개발 단계에서만 사용
    }
  }
}
```

## 접근 권한 관리

### 음성 데이터 접근 권한

- **부모/교사**: 자신의 아동 데이터에만 접근 가능
- **아동**: 음성 데이터에 직접 접근 불가 (부모를 통해서만)
- **채점 완료 후**: 음성 파일 자동 삭제 (PRD 요구사항)

### 개인정보 보호

- **암호화**: 민감한 개인정보는 암호화하여 저장
- **접근 제어**: Firebase 보안 규칙으로 접근 제한
- **데이터 보존**: 보존 기간 경과 후 자동 삭제

## 데이터 보존 정책

### 보존 기간

- **음성 파일**: 채점 완료 후 즉시 삭제
- **검사 결과**: 3년 보관 후 자동 삭제
- **미완료 검사**: 1년 보관 후 자동 삭제

### 자동 정리

`DataRetentionService.cleanupOldData()` 메서드를 주기적으로 실행하여 오래된 데이터를 자동으로 삭제합니다.

## 개인정보 삭제 요청 (GDPR 준수)

사용자가 개인정보 삭제를 요청할 경우:

1. `DataRetentionService.deleteAllChildData(childId)` 호출
2. 해당 아동의 모든 데이터 삭제:
   - 검사 세션
   - 검사 결과
   - 음성 파일
   - 채점 데이터

## 참고

- Firebase Console에서 보안 규칙 설정: https://console.firebase.google.com
- 보안 규칙 테스트: Firebase Console의 Rules Playground 사용
- 프로덕션 배포 전 반드시 보안 규칙 테스트 필요

