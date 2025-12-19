# 네트워크 연결 오류 가이드

## "Connection failed" 메시지 설명

### 메시지 의미
**"Connection failed. If the problem persists, please check your internet connection or VPN"**

이 메시지는 네트워크 연결이 실패했을 때 나타나는 일반적인 오류 메시지입니다.

---

## 발생 가능한 상황

### 1. Firebase 연결 실패
- **원인**: Firebase 서버와 통신 실패
- **발생 위치**: 
  - 앱 시작 시 Firebase 초기화
  - Firestore 데이터 읽기/쓰기
  - Firebase Authentication 요청

### 2. 인증 요청 실패
- **원인**: 로그인/회원가입 시 네트워크 문제
- **발생 위치**: `auth_repository_impl.dart`
- **현재 처리**: `network-request-failed` 에러 코드를 "네트워크 연결을 확인해주세요."로 변환

### 3. 네트워크 에셋 다운로드 실패
- **원인**: 원격 이미지/오디오 파일 다운로드 실패
- **발생 위치**: `asset_manager.dart`
- **타임아웃**: 30초

---

## 프로젝트에서의 처리 방식

### 현재 구현

#### 1. Firebase 초기화 실패 처리
```dart
// lib/config/firebase/firebase_config.dart
try {
  await Firebase.initializeApp(...);
} catch (e) {
  // Firebase 초기화 실패 시에도 앱이 실행되도록 함
  _isInitialized = false;
}
```

#### 2. 인증 네트워크 에러 처리
```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
case 'network-request-failed':
  return '네트워크 연결을 확인해주세요.';
```

#### 3. 네트워크 에셋 다운로드 타임아웃
```dart
// lib/core/assets/asset_manager.dart
final file = await cacheManager.getSingleFile(url).timeout(
  const Duration(seconds: networkDownloadTimeoutSeconds),
);
```

---

## 해결 방법

### 사용자 측면
1. **인터넷 연결 확인**
   - Wi-Fi 또는 모바일 데이터 연결 상태 확인
   - 다른 앱/웹사이트가 정상 작동하는지 확인

2. **VPN 확인**
   - VPN 사용 중이라면 일시적으로 끄고 재시도
   - VPN 서버 변경 또는 재연결

3. **방화벽/보안 소프트웨어 확인**
   - 방화벽이 앱의 네트워크 접근을 차단하는지 확인
   - 보안 소프트웨어 설정 확인

4. **앱 재시작**
   - 앱을 완전히 종료 후 다시 시작
   - 기기 재부팅

### 개발자 측면 (향후 개선)

#### 1. 연결 상태 모니터링
```dart
// connectivity_plus 패키지 활용 (이미 설치됨)
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivity = Connectivity();
final result = await connectivity.checkConnectivity();
```

#### 2. 사용자 친화적 에러 메시지
- 현재: "네트워크 연결을 확인해주세요."
- 개선: "인터넷 연결이 없습니다. Wi-Fi 또는 모바일 데이터를 확인해주세요."

#### 3. 오프라인 모드 지원
- 이미 `offline_sync_service.dart`가 있음
- 오프라인 상태에서도 기본 기능 사용 가능하도록 확장

---

## 현재 프로젝트 상태

### 네트워크 에러 처리 현황
- ✅ Firebase 초기화 실패 시 앱 계속 실행
- ✅ 인증 네트워크 에러 메시지 변환
- ✅ 네트워크 에셋 다운로드 타임아웃 처리
- ⚠️ 연결 상태 실시간 모니터링 미구현
- ⚠️ 오프라인 모드 UI 표시 미구현

### 설치된 패키지
- `connectivity_plus: ^5.0.2` - 연결 상태 확인 (설치됨, 활용 필요)

---

## 향후 개선 사항

### 1. 연결 상태 모니터링 추가
```dart
// lib/core/services/connectivity_service.dart (신규 생성)
class ConnectivityService {
  Stream<ConnectivityResult> get connectivityStream;
  Future<bool> isConnected();
}
```

### 2. 오프라인 UI 표시
- 네트워크 연결이 없을 때 사용자에게 알림
- 오프라인 모드에서 사용 가능한 기능 표시

### 3. 자동 재시도 로직
- 네트워크 에러 발생 시 자동으로 재시도
- 재시도 횟수 제한 및 사용자 알림

---

*Last Updated: 2025-01-XX*
