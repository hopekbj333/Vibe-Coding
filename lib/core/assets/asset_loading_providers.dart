import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'asset_manager.dart';

/// 에셋 로딩 상태 Provider
/// 
/// 에셋 사전 로딩 상태를 관리합니다.
final assetLoadingStatusProvider = StateNotifierProvider<AssetLoadingStatusNotifier, AssetLoadingStatus>((ref) {
  return AssetLoadingStatusNotifier();
});

/// 에셋 로딩 진행률 Provider
/// 
/// 에셋 로딩 진행률을 관리합니다 (0.0 ~ 1.0).
final assetLoadingProgressProvider = StateNotifierProvider<AssetLoadingProgressNotifier, double>((ref) {
  return AssetLoadingProgressNotifier();
});

/// 에셋 로딩 상태 Notifier
class AssetLoadingStatusNotifier extends StateNotifier<AssetLoadingStatus> {
  AssetLoadingStatusNotifier() : super(AssetLoadingStatus.initial);

  /// 로딩 시작
  void startLoading() {
    state = AssetLoadingStatus.loading;
  }

  /// 로딩 완료
  void completeLoading() {
    state = AssetLoadingStatus.loaded;
  }

  /// 로딩 실패
  void failLoading() {
    state = AssetLoadingStatus.error;
  }

  /// 상태 초기화
  void reset() {
    state = AssetLoadingStatus.initial;
  }
}

/// 에셋 로딩 진행률 Notifier
class AssetLoadingProgressNotifier extends StateNotifier<double> {
  AssetLoadingProgressNotifier() : super(0.0);

  /// 진행률 업데이트
  void updateProgress(double progress) {
    state = progress.clamp(0.0, 1.0);
  }

  /// 진행률 초기화
  void reset() {
    state = 0.0;
  }
}

/// 에셋 사전 로딩 Provider
/// 
/// 특정 에셋 목록을 사전 로딩합니다.
final preloadAssetsProvider = FutureProvider.family<bool, List<String>>((ref, assetPaths) async {
  final statusNotifier = ref.read(assetLoadingStatusProvider.notifier);
  final progressNotifier = ref.read(assetLoadingProgressProvider.notifier);

  try {
    statusNotifier.startLoading();
    progressNotifier.reset();

    final success = await AssetManager.instance.preloadAssets(
      assetPaths: assetPaths,
      onProgress: (progress) {
        progressNotifier.updateProgress(progress);
      },
    );

    if (success) {
      statusNotifier.completeLoading();
    } else {
      statusNotifier.failLoading();
    }

    return success;
  } catch (e) {
    statusNotifier.failLoading();
    return false;
  }
});

