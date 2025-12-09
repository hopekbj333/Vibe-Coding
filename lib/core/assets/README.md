# 에셋 매니저 가이드

이 디렉토리는 이미지 및 오디오 리소스의 사전 로딩 및 캐싱을 담당합니다.

## 목적

**왜 필요한가요?**
- 검사 중 이미지/음성 로딩 지연 최소화
- 아동의 집중력 유지 (로딩 시간 단축)
- 오프라인 지원 (디스크 캐싱)

## 구조

```
lib/core/assets/
├── asset_manager.dart              # 에셋 매니저 (사전 로딩, 캐싱)
├── asset_loading_providers.dart    # 로딩 상태 Provider
├── asset_loading_widget.dart       # 로딩 인디케이터 위젯
├── asset_utils.dart                # 에셋 경로 유틸리티
└── README.md                       # 이 파일
```

## 사용 방법

### 1. 에셋 사전 로딩

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/assets/asset_manager.dart';
import 'package:literacy_assessment/core/assets/asset_loading_providers.dart';
import 'package:literacy_assessment/core/assets/asset_utils.dart';

class AssessmentPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 검사 시작 전 에셋 사전 로딩
    final assetPaths = AssetUtils.createAssetList(
      module: 'phonological',
      imageFiles: ['question_1.png', 'question_2.png'],
      audioFiles: ['instruction_1.mp3', 'instruction_2.mp3'],
    );

    ref.read(preloadAssetsProvider(assetPaths));

    return Scaffold(
      body: Stack(
        children: [
          // 메인 콘텐츠
          YourContent(),
          
          // 로딩 오버레이
          AssetLoadingOverlay(
            message: '준비 중이에요...',
          ),
        ],
      ),
    );
  }
}
```

### 2. 로딩 상태 확인

```dart
final status = ref.watch(assetLoadingStatusProvider);
final progress = ref.watch(assetLoadingProgressProvider);

if (status == AssetLoadingStatus.loading) {
  return AssetLoadingIndicator(
    message: '${(progress * 100).toInt()}% 완료',
  );
}
```

### 3. 개별 에셋 로드

```dart
// 로컬 에셋
final imageData = await AssetManager.instance.loadAsset(
  'assets/images/apple.png',
);

// 네트워크 에셋 (Firebase Storage 등)
final audioData = await AssetManager.instance.loadNetworkAsset(
  url: 'https://storage.googleapis.com/.../audio.mp3',
  assetPath: 'audio/question_1.mp3',
);
```

### 4. 캐시 관리

```dart
// 캐시 정보 확인
final cacheInfo = await AssetManager.instance.getCacheInfo();
print('캐시 파일 수: ${cacheInfo['diskCacheFiles']}');
print('캐시 크기: ${cacheInfo['diskCacheSizeMB']} MB');

// 메모리 캐시 클리어 (메모리 부족 시)
AssetManager.instance.clearMemoryCache();

// 디스크 캐시 클리어 (저장 공간 확보 시)
await AssetManager.instance.clearDiskCache();
```

## 캐싱 전략

### 메모리 캐시
- **용도**: 자주 사용하는 에셋을 빠르게 접근
- **저장 위치**: RAM
- **생명주기**: 앱 실행 중 유지
- **제한**: 메모리 사용량에 따라 자동 관리

### 디스크 캐시
- **용도**: 네트워크에서 다운로드한 에셋 저장
- **저장 위치**: 앱 임시 디렉토리
- **생명주기**: 7일간 유지
- **제한**: 최대 100개 파일

## 에셋 경로 규칙

### 로컬 에셋 (assets/ 폴더)
```
assets/
├── images/
│   ├── common/          # 공통 이미지
│   ├── phonological/    # 음운 인식 모듈 이미지
│   ├── sensory/         # 감각 처리 모듈 이미지
│   └── executive/      # 인지 제어 모듈 이미지
├── audio/
│   ├── common/          # 공통 오디오
│   ├── phonological/    # 음운 인식 모듈 오디오
│   ├── sensory/         # 감각 처리 모듈 오디오
│   └── executive/       # 인지 제어 모듈 오디오
└── characters/          # 캐릭터 이미지
```

### 네트워크 에셋 (Firebase Storage)
- Firebase Storage에서 동적으로 다운로드
- 디스크 캐시에 자동 저장
- 오프라인 지원

## 성능 최적화

1. **사전 로딩**: 검사 시작 전 필요한 모든 에셋 로드
2. **지연 로딩**: 사용하지 않는 에셋은 나중에 로드
3. **캐시 활용**: 한 번 로드한 에셋은 캐시에서 재사용
4. **메모리 관리**: 메모리 부족 시 자동으로 오래된 캐시 제거

## 향후 확장

- [ ] Firebase Storage 연동 (S 1.3.1)
- [ ] 에셋 버전 관리
- [ ] 증분 업데이트 (변경된 에셋만 다운로드)
- [ ] 에셋 압축 및 최적화

