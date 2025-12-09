# S 1.1.4: 에셋 매니저 구현 검증

이 문서는 S 1.1.4의 요구사항 달성 여부를 검증합니다.

## 📋 요구사항 체크리스트

### ✅ 1. 이미지/오디오 리소스 사전 로딩(Pre-fetch) 모듈

**검증 항목:**
- [x] `AssetManager` 클래스 구현 (`lib/core/assets/asset_manager.dart`)
- [x] `preloadAssets()` 메서드로 여러 에셋을 한 번에 로드
- [x] 진행률 콜백 지원 (0.0 ~ 1.0)
- [x] 로컬 에셋 로드 지원 (assets/ 폴더)
- [x] 네트워크 에셋 다운로드 지원 (Firebase Storage 등)

**구현 확인:**
```dart
// lib/core/assets/asset_manager.dart
// - AssetManager.preloadAssets() - 여러 에셋 사전 로딩
// - AssetManager.loadAsset() - 개별 로컬 에셋 로드
// - AssetManager.loadNetworkAsset() - 네트워크 에셋 다운로드
```

**사용 예시:**
```dart
final assetPaths = [
  'assets/images/apple.png',
  'assets/audio/question_1.mp3',
];

await AssetManager.instance.preloadAssets(
  assetPaths: assetPaths,
  onProgress: (progress) {
    print('로딩 진행률: ${(progress * 100).toInt()}%');
  },
);
```

**테스트:**
- [x] `test/core/assets/asset_manager_test.dart` - 에셋 경로 유틸리티 테스트
- [x] `test/core/assets/asset_manager_test.dart` - 캐시 정보 테스트

---

### ✅ 2. 캐싱 전략 설계 (메모리/디스크 캐시)

**검증 항목:**
- [x] 메모리 캐시 구현 (이미지/오디오 분리)
- [x] 디스크 캐시 구현 (`flutter_cache_manager` 사용)
- [x] 캐시 만료 정책 (7일)
- [x] 캐시 크기 제한 (최대 100개 파일)
- [x] 캐시 클리어 기능 (메모리/디스크)

**구현 확인:**
```dart
// lib/core/assets/asset_manager.dart
// - _imageMemoryCache, _audioMemoryCache - 메모리 캐시
// - CacheManager - 디스크 캐시 (flutter_cache_manager)
// - clearMemoryCache() - 메모리 캐시 클리어
// - clearDiskCache() - 디스크 캐시 클리어
// - getCacheInfo() - 캐시 정보 조회
```

**캐싱 전략:**
1. **메모리 캐시**: 자주 사용하는 에셋을 RAM에 저장 (빠른 접근)
2. **디스크 캐시**: 네트워크에서 다운로드한 에셋을 디스크에 저장 (오프라인 지원)
3. **캐시 우선순위**: 메모리 → 디스크 → 네트워크 순서로 확인

**테스트:**
```dart
// 캐시 정보 확인
final cacheInfo = await AssetManager.instance.getCacheInfo();
print('메모리 캐시 이미지: ${cacheInfo['memoryCacheImages']}');
print('메모리 캐시 오디오: ${cacheInfo['memoryCacheAudio']}');
print('디스크 캐시 파일: ${cacheInfo['diskCacheFiles']}');
print('디스크 캐시 크기: ${cacheInfo['diskCacheSizeMB']} MB');
```

---

### ✅ 3. 로딩 상태 표시 컴포넌트

**검증 항목:**
- [x] `AssetLoadingStatusProvider` - 로딩 상태 관리 (initial/loading/loaded/error)
- [x] `AssetLoadingProgressProvider` - 진행률 관리 (0.0 ~ 1.0)
- [x] `AssetLoadingIndicator` - 로딩 인디케이터 위젯
- [x] `AssetLoadingOverlay` - 전체 화면 로딩 오버레이
- [x] 아동 친화적 애니메이션 (캐릭터 준비 운동)

**구현 확인:**
```dart
// lib/core/assets/asset_loading_providers.dart
// - assetLoadingStatusProvider - 로딩 상태 Provider
// - assetLoadingProgressProvider - 진행률 Provider
// - preloadAssetsProvider - 에셋 사전 로딩 Provider

// lib/core/assets/asset_loading_widget.dart
// - AssetLoadingIndicator - 로딩 인디케이터
// - AssetLoadingOverlay - 전체 화면 오버레이
// - _CharacterAnimation - 캐릭터 애니메이션
```

**사용 예시:**
```dart
// 로딩 상태 확인
final status = ref.watch(assetLoadingStatusProvider);
final progress = ref.watch(assetLoadingProgressProvider);

if (status == AssetLoadingStatus.loading) {
  return AssetLoadingIndicator(
    message: '준비 중이에요...',
    showCharacterAnimation: true,
  );
}
```

**테스트:**
- [x] `test/core/assets/asset_loading_providers_test.dart` - 로딩 상태 Provider 테스트
- [x] `test/core/assets/asset_loading_providers_test.dart` - 진행률 Provider 테스트

---

## 📦 패키지 의존성

**추가된 패키지:**
- [x] `flutter_cache_manager: ^3.3.1` - 디스크 캐싱
- [x] `cached_network_image: ^3.3.1` - 네트워크 이미지 캐싱

**pubspec.yaml 확인:**
```yaml
dependencies:
  flutter_cache_manager: ^3.3.1
  cached_network_image: ^3.3.1
```

---

## 📁 파일 구조

**생성된 파일:**
```
lib/core/assets/
├── asset_manager.dart              # 에셋 매니저 (사전 로딩, 캐싱)
├── asset_loading_providers.dart    # 로딩 상태 Provider
├── asset_loading_widget.dart       # 로딩 인디케이터 위젯
├── asset_utils.dart                # 에셋 경로 유틸리티
└── README.md                       # 사용 가이드

test/core/assets/
├── asset_manager_test.dart         # 에셋 매니저 테스트
└── asset_loading_providers_test.dart # 로딩 Provider 테스트
```

---

## 🎯 목적 달성 검증

### 목적: 검사 중 이미지/음성 로딩 지연 최소화

**검증:**
- [x] 사전 로딩 기능으로 검사 시작 전 모든 에셋 로드
- [x] 메모리 캐시로 자주 사용하는 에셋 즉시 접근
- [x] 디스크 캐시로 네트워크 에셋 재사용

### 목적: 아동의 집중력 유지

**검증:**
- [x] 로딩 중 아동 친화적 애니메이션 표시
- [x] 진행률 표시로 대기 시간 명확히 전달
- [x] 느린 애니메이션 (1.5배 느리게) 적용

### 목적: 오프라인 지원

**검증:**
- [x] 디스크 캐시로 네트워크 에셋 저장
- [x] 캐시된 에셋은 오프라인에서도 접근 가능
- [x] 캐시 만료 정책 (7일) 설정

---

## 🔄 향후 통합 (S 1.3.1)

**검사 실행 프레임워크와의 통합:**
- [ ] 검사 시작 전 에셋 사전 로딩 (S 1.3.1)
- [ ] Firebase Storage에서 에셋 다운로드
- [ ] 검사 모듈별 에셋 목록 관리

**예상 사용 시나리오:**
```dart
// 검사 시작 전
final assetPaths = AssetUtils.createAssetList(
  module: 'phonological',
  imageFiles: ['q1.png', 'q2.png', ...],
  audioFiles: ['i1.mp3', 'i2.mp3', ...],
);

await ref.read(preloadAssetsProvider(assetPaths).future);

// 로딩 완료 후 검사 시작
```

---

## 🔧 개선 사항 (검증 후 수정)

### ✅ 1. 네트워크 에셋 다운로드 타임아웃 추가
- [x] 30초 타임아웃 설정
- [x] `TimeoutException` 처리 추가
- [x] 네트워크 오류 시 명확한 에러 메시지

### ✅ 2. 메모리 캐시 크기 제한
- [x] 최대 50MB 제한 설정
- [x] 크기 초과 시 오래된 캐시 자동 제거 (LRU 방식)
- [x] 캐시 크기 계산 메서드 추가

### ✅ 3. 에셋 타입 판별 개선
- [x] 확장자가 없는 경우 경로로 판별
- [x] 추가 이미지 형식 지원 (svg)
- [x] 추가 오디오 형식 지원 (aac)

### ✅ 4. 오프라인 지원 검증
- [x] `isAssetAvailableOffline()` 메서드 추가
- [x] 로컬 에셋은 항상 오프라인 접근 가능
- [x] 네트워크 에셋은 디스크 캐시 확인

### ✅ 5. 통합 테스트 추가
- [x] `asset_manager_integration_test.dart` 생성
- [x] 검사 모듈 에셋 사전 로딩 시나리오 테스트
- [x] 오프라인 지원 확인 테스트

---

## ✅ 검증 완료

**모든 요구사항이 구현되었습니다:**
- ✅ 이미지/오디오 리소스 사전 로딩 모듈
- ✅ 캐싱 전략 (메모리/디스크)
- ✅ 로딩 상태 표시 컴포넌트
- ✅ 네트워크 다운로드 타임아웃 및 오류 처리
- ✅ 메모리 캐시 크기 제한
- ✅ 오프라인 지원 검증

**다음 단계:**
- S 1.1.5: 공통 UI 라이브러리
- S 1.3.1: 검사 데이터 로딩 및 캐싱 (에셋 매니저 활용)

