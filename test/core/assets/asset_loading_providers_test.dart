import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/assets/asset_manager.dart';
import 'package:literacy_assessment/core/assets/asset_loading_providers.dart';

void main() {
  group('AssetLoadingStatusProvider 테스트', () {
    test('초기 상태는 initial이어야 함', () {
      final container = ProviderContainer();
      expect(
        container.read(assetLoadingStatusProvider),
        AssetLoadingStatus.initial,
      );
    });

    test('로딩 상태 전환이 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assetLoadingStatusProvider.notifier);
      
      notifier.startLoading();
      expect(
        container.read(assetLoadingStatusProvider),
        AssetLoadingStatus.loading,
      );
      
      notifier.completeLoading();
      expect(
        container.read(assetLoadingStatusProvider),
        AssetLoadingStatus.loaded,
      );
      
      notifier.failLoading();
      expect(
        container.read(assetLoadingStatusProvider),
        AssetLoadingStatus.error,
      );
    });

    test('상태 초기화가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assetLoadingStatusProvider.notifier);
      
      notifier.startLoading();
      notifier.reset();
      
      expect(
        container.read(assetLoadingStatusProvider),
        AssetLoadingStatus.initial,
      );
    });
  });

  group('AssetLoadingProgressProvider 테스트', () {
    test('초기 진행률은 0.0이어야 함', () {
      final container = ProviderContainer();
      expect(container.read(assetLoadingProgressProvider), 0.0);
    });

    test('진행률 업데이트가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assetLoadingProgressProvider.notifier);
      
      notifier.updateProgress(0.5);
      expect(container.read(assetLoadingProgressProvider), 0.5);
      
      notifier.updateProgress(1.0);
      expect(container.read(assetLoadingProgressProvider), 1.0);
    });

    test('진행률이 0.0~1.0 범위를 벗어나면 클램프되어야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assetLoadingProgressProvider.notifier);
      
      notifier.updateProgress(-0.5);
      expect(container.read(assetLoadingProgressProvider), 0.0);
      
      notifier.updateProgress(1.5);
      expect(container.read(assetLoadingProgressProvider), 1.0);
    });

    test('진행률 초기화가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assetLoadingProgressProvider.notifier);
      
      notifier.updateProgress(0.8);
      notifier.reset();
      
      expect(container.read(assetLoadingProgressProvider), 0.0);
    });
  });
}

