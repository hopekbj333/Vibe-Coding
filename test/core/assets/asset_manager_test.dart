import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:literacy_assessment/core/assets/asset_manager.dart';
import 'package:literacy_assessment/core/assets/asset_utils.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../helpers/mock_path_provider.dart';

void main() {
  // Flutter binding 초기화 (path_provider 사용을 위해 필요)
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fakePlatform = await TestPathProviderPlatform.create();
    PathProviderPlatform.instance = fakePlatform;
  });

  group('AssetManager 테스트', () {
    test('에셋 경로 유틸리티가 올바른 경로를 생성해야 함', () {
      expect(
        AssetUtils.imagePath('apple.png'),
        'assets/images/apple.png',
      );
      
      expect(
        AssetUtils.audioPath('question_1.mp3'),
        'assets/audio/question_1.mp3',
      );
      
      expect(
        AssetUtils.characterPath('character_idle.png'),
        'assets/characters/character_idle.png',
      );
    });

    test('모듈별 에셋 경로가 올바르게 생성되어야 함', () {
      final path = AssetUtils.moduleAssetPath(
        module: 'phonological',
        type: 'images',
        fileName: 'question_1.png',
      );
      
      expect(path, 'assets/images/phonological/question_1.png');
    });

    test('에셋 목록이 올바르게 생성되어야 함', () {
      final assets = AssetUtils.createAssetList(
        module: 'phonological',
        imageFiles: ['q1.png', 'q2.png'],
        audioFiles: ['i1.mp3', 'i2.mp3'],
      );
      
      expect(assets.length, 4);
      expect(assets[0], 'assets/images/phonological/q1.png');
      expect(assets[1], 'assets/images/phonological/q2.png');
      expect(assets[2], 'assets/audio/phonological/i1.mp3');
      expect(assets[3], 'assets/audio/phonological/i2.mp3');
    });

    test('에셋 타입이 올바르게 판별되어야 함', () {
      // AssetManager.instance는 사용하지 않지만, 타입 검증을 위해 참조
      
      // 리플렉션을 사용할 수 없으므로, 실제 사용 시나리오로 테스트
      // 이미지 경로는 imagePath로, 오디오 경로는 audioPath로 생성
      expect(
        AssetUtils.imagePath('test.png'),
        contains('images'),
      );
      
      expect(
        AssetUtils.audioPath('test.mp3'),
        contains('audio'),
      );
    });

    test('캐시 정보를 가져올 수 있어야 함', () async {
      final manager = AssetManager.instance;
      
      // AssetManager 내부에서 MissingPluginException을 처리하므로
      // 예외 없이 정상적으로 작동해야 합니다.
      final cacheInfo = await manager.getCacheInfo();
      
      expect(cacheInfo, isA<Map<String, dynamic>>());
      expect(cacheInfo.containsKey('memoryCacheImages'), isTrue);
      expect(cacheInfo.containsKey('memoryCacheAudio'), isTrue);
      expect(cacheInfo.containsKey('diskCacheFiles'), isTrue);
      expect(cacheInfo.containsKey('diskCacheSize'), isTrue);
    });

    test('메모리 캐시를 클리어할 수 있어야 함', () {
      final manager = AssetManager.instance;
      
      // 캐시 클리어는 예외 없이 실행되어야 함
      expect(() => manager.clearMemoryCache(), returnsNormally);
    });

    test('디스크 캐시를 클리어할 수 있어야 함', () async {
      final manager = AssetManager.instance;
      
      // AssetManager 내부에서 MissingPluginException을 처리하므로
      // 예외 없이 정상적으로 작동해야 합니다.
      await manager.clearDiskCache();
      // 성공적으로 완료되어야 함
    });
  });
}

