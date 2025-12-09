import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// 에셋 타입
enum AssetType {
  /// 이미지
  image,
  
  /// 오디오
  audio,
  
  /// 기타
  other,
}

/// 에셋 로딩 상태
enum AssetLoadingStatus {
  /// 초기 상태
  initial,
  
  /// 로딩 중
  loading,
  
  /// 로딩 완료
  loaded,
  
  /// 로딩 실패
  error,
}

/// 에셋 매니저
/// 
/// 이미지 및 오디오 리소스의 사전 로딩 및 캐싱을 관리합니다.
/// 
/// **목적:**
/// - 검사 중 이미지/음성 로딩 지연 최소화
/// - 아동의 집중력 유지 (로딩 시간 단축)
/// - 오프라인 지원 (디스크 캐싱)
/// 
/// **캐싱 전략:**
/// - 메모리 캐시: 자주 사용하는 에셋을 메모리에 보관
/// - 디스크 캐시: 네트워크에서 다운로드한 에셋을 디스크에 저장
class AssetManager {
  AssetManager._();

  /// 싱글톤 인스턴스
  static final AssetManager instance = AssetManager._();

  /// 메모리 캐시 (이미지)
  final Map<String, Uint8List> _imageMemoryCache = {};

  /// 메모리 캐시 (오디오)
  final Map<String, Uint8List> _audioMemoryCache = {};

  /// 메모리 캐시 최대 크기 (MB)
  static const int maxMemoryCacheSizeMB = 50;

  /// 네트워크 다운로드 타임아웃 (초)
  static const int networkDownloadTimeoutSeconds = 30;

  /// CacheManager 인스턴스 (lazy initialization)
  static CacheManager? _cacheManager;

  /// CacheManager 인스턴스 가져오기 (lazy initialization)
  /// 
  /// path_provider 플러그인이 없는 환경에서는 null을 반환합니다.
  static CacheManager? get _cacheManagerInstance {
    if (_cacheManager != null) {
      return _cacheManager;
    }

    try {
      _cacheManager = CacheManager(
        Config(
          'literacy_assessment_cache',
          stalePeriod: const Duration(days: 7), // 7일간 캐시 유지
          maxNrOfCacheObjects: 100, // 최대 100개 파일 캐시
        ),
      );
      return _cacheManager;
    } on MissingPluginException {
      // path_provider 플러그인이 없는 환경(단위 테스트 등)에서는 null 반환
      if (kDebugMode) {
        print('⚠ path_provider plugin not available, CacheManager disabled');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to initialize CacheManager: $e');
      }
      return null;
    }
  }

  /// 에셋 사전 로딩
  /// 
  /// [assetPaths] 로드할 에셋 경로 목록
  /// [onProgress] 진행률 콜백 (0.0 ~ 1.0)
  /// 
  /// 반환: 로딩 성공 여부
  Future<bool> preloadAssets({
    required List<String> assetPaths,
    void Function(double progress)? onProgress,
  }) async {
    if (assetPaths.isEmpty) {
      return true;
    }

    try {
      int loadedCount = 0;
      final totalCount = assetPaths.length;

      for (final assetPath in assetPaths) {
        try {
          await _loadAsset(assetPath);
          loadedCount++;
          
          if (onProgress != null) {
            onProgress(loadedCount / totalCount);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠ Failed to load asset: $assetPath - $e');
          }
          // 개별 에셋 실패는 무시하고 계속 진행
        }
      }

      if (kDebugMode) {
        print('✓ Preloaded $loadedCount/$totalCount assets');
      }

      return loadedCount == totalCount;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Asset preload error: $e');
      }
      return false;
    }
  }

  /// 개별 에셋 로드 (공개 메서드)
  /// 
  /// [assetPath] 에셋 경로 (예: 'assets/images/apple.png')
  /// 
  /// 반환: 에셋 데이터
  Future<Uint8List> loadAsset(String assetPath) async {
    return _loadAsset(assetPath);
  }

  /// 개별 에셋 로드 (내부 메서드)
  /// 
  /// [assetPath] 에셋 경로 (예: 'assets/images/apple.png')
  /// 
  /// 반환: 에셋 데이터
  Future<Uint8List> _loadAsset(String assetPath) async {
    // 메모리 캐시 확인
    final cached = _getFromMemoryCache(assetPath);
    if (cached != null) {
      return cached;
    }

    // 로컬 에셋 로드 (assets/ 폴더)
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      
      // 메모리 캐시에 저장
      _saveToMemoryCache(assetPath, bytes);
      
      return bytes;
    } catch (e) {
      // 로컬 에셋이 없으면 네트워크에서 다운로드 시도
      // (향후 Firebase Storage에서 에셋을 가져올 때 사용)
      throw Exception('Asset not found: $assetPath');
    }
  }

  /// 네트워크 에셋 다운로드 및 캐싱
  /// 
  /// [url] 네트워크 URL
  /// [assetPath] 로컬 저장 경로 (캐시 키로 사용)
  /// 
  /// 반환: 에셋 데이터
  Future<Uint8List> loadNetworkAsset({
    required String url,
    String? assetPath,
  }) async {
    final cacheKey = assetPath ?? url;

    // 메모리 캐시 확인
    final cached = _getFromMemoryCache(cacheKey);
    if (cached != null) {
      return cached;
    }

    final cacheManager = _cacheManagerInstance;
    if (cacheManager == null) {
      // CacheManager가 사용 불가능한 경우 예외 발생
      throw Exception('CacheManager not available (path_provider plugin required)');
    }

    try {
      // 디스크 캐시 확인 및 네트워크 다운로드
      // getSingleFile은 캐시에 없으면 자동으로 다운로드함
      final file = await cacheManager.getSingleFile(url).timeout(
        const Duration(seconds: networkDownloadTimeoutSeconds),
        onTimeout: () {
          throw TimeoutException(
            'Network asset download timeout: $url',
            const Duration(seconds: networkDownloadTimeoutSeconds),
          );
        },
      );
      
      final bytes = await file.readAsBytes();
      
      // 메모리 캐시에 저장
      _saveToMemoryCache(cacheKey, bytes);
      
      return bytes;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('⚠ Network asset download timeout: $url - $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to load network asset: $url - $e');
      }
      rethrow;
    }
  }

  /// 메모리 캐시에서 가져오기
  Uint8List? _getFromMemoryCache(String assetPath) {
    final assetType = _getAssetType(assetPath);
    
    switch (assetType) {
      case AssetType.image:
        return _imageMemoryCache[assetPath];
      case AssetType.audio:
        return _audioMemoryCache[assetPath];
      default:
        return _imageMemoryCache[assetPath] ?? _audioMemoryCache[assetPath];
    }
  }

  /// 메모리 캐시 크기 계산 (MB)
  double _getMemoryCacheSizeMB() {
    int totalSize = 0;
    for (final bytes in _imageMemoryCache.values) {
      totalSize += bytes.length;
    }
    for (final bytes in _audioMemoryCache.values) {
      totalSize += bytes.length;
    }
    return totalSize / (1024 * 1024);
  }

  /// 메모리 캐시에 저장
  /// 
  /// 크기 제한을 초과하면 오래된 캐시를 제거합니다.
  void _saveToMemoryCache(String assetPath, Uint8List data) {
    final currentSizeMB = _getMemoryCacheSizeMB();
    final newSizeMB = data.length / (1024 * 1024);
    
    // 크기 제한 초과 시 오래된 캐시 제거
    if (currentSizeMB + newSizeMB > maxMemoryCacheSizeMB) {
      _evictOldestCache();
    }
    
    final assetType = _getAssetType(assetPath);
    
    switch (assetType) {
      case AssetType.image:
        _imageMemoryCache[assetPath] = data;
        break;
      case AssetType.audio:
        _audioMemoryCache[assetPath] = data;
        break;
      default:
        _imageMemoryCache[assetPath] = data;
    }
  }

  /// 오래된 캐시 제거 (LRU 방식)
  /// 
  /// 메모리 캐시 크기가 제한을 초과할 때 호출됩니다.
  void _evictOldestCache() {
    // 간단한 구현: 각 캐시의 절반 제거
    if (_imageMemoryCache.length > 10) {
      final keysToRemove = _imageMemoryCache.keys.take(_imageMemoryCache.length ~/ 2).toList();
      for (final key in keysToRemove) {
        _imageMemoryCache.remove(key);
      }
    }
    
    if (_audioMemoryCache.length > 10) {
      final keysToRemove = _audioMemoryCache.keys.take(_audioMemoryCache.length ~/ 2).toList();
      for (final key in keysToRemove) {
        _audioMemoryCache.remove(key);
      }
    }
    
    if (kDebugMode) {
      print('✓ Evicted old cache. Current size: ${_getMemoryCacheSizeMB().toStringAsFixed(2)} MB');
    }
  }

  /// 에셋 타입 판별
  AssetType _getAssetType(String assetPath) {
    // 경로에서 확장자 추출
    final parts = assetPath.split('.');
    
    // 확장자가 있는 경우
    if (parts.length >= 2) {
      final extension = parts.last.toLowerCase();
      
      switch (extension) {
        case 'png':
        case 'jpg':
        case 'jpeg':
        case 'gif':
        case 'webp':
        case 'svg':
          return AssetType.image;
        case 'mp3':
        case 'wav':
        case 'ogg':
        case 'm4a':
        case 'aac':
          return AssetType.audio;
        default:
          // 확장자가 없거나 알 수 없는 경우 경로로 판별 시도
          break;
      }
    }
    
    // 확장자가 없거나 알 수 없는 경우 경로로 판별
    final lowerPath = assetPath.toLowerCase();
    if (lowerPath.contains('/images/') || 
        lowerPath.contains('/image') ||
        lowerPath.contains('image')) {
      return AssetType.image;
    } else if (lowerPath.contains('/audio/') || 
               lowerPath.contains('/audio') ||
               lowerPath.contains('audio')) {
      return AssetType.audio;
    }
    
    return AssetType.other;
  }

  /// 메모리 캐시 클리어
  /// 
  /// 메모리 부족 시 호출
  void clearMemoryCache() {
    _imageMemoryCache.clear();
    _audioMemoryCache.clear();
    
    if (kDebugMode) {
      print('✓ Memory cache cleared');
    }
  }

  /// 디스크 캐시 클리어
  /// 
  /// 저장 공간 확보 시 호출
  Future<void> clearDiskCache() async {
    final cacheManager = _cacheManagerInstance;
    if (cacheManager == null) {
      // CacheManager가 사용 불가능한 경우 무시
      if (kDebugMode) {
        print('⚠ path_provider plugin not available, skipping disk cache clear');
      }
      return;
    }

    try {
      await cacheManager.emptyCache();
      
      if (kDebugMode) {
        print('✓ Disk cache cleared');
      }
    } on MissingPluginException {
      // path_provider 플러그인이 없는 환경(단위 테스트 등)에서는 무시
      if (kDebugMode) {
        print('⚠ path_provider plugin not available, skipping disk cache clear');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to clear disk cache: $e');
      }
      // 예외를 다시 throw하지 않고 무시 (테스트 환경에서 안전하게 처리)
    }
  }

  /// 캐시 정보 가져오기
  Future<Map<String, dynamic>> getCacheInfo() async {
    int fileCount = 0;
    int totalSize = 0;
    
    try {
      final cacheDir = await getTemporaryDirectory();
      final cachePath = '${cacheDir.path}/literacy_assessment_cache';
      final cacheDirFile = Directory(cachePath);
      
      if (await cacheDirFile.exists()) {
        await for (final entity in cacheDirFile.list()) {
          if (entity is File) {
            fileCount++;
            totalSize += await entity.length();
          }
        }
      }
    } on MissingPluginException {
      // path_provider 플러그인이 없는 환경(단위 테스트 등)에서는 디스크 캐시 정보를 0으로 반환
      if (kDebugMode) {
        print('⚠ path_provider plugin not available, disk cache info unavailable');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to get cache info: $e');
      }
    }

    return {
      'memoryCacheImages': _imageMemoryCache.length,
      'memoryCacheAudio': _audioMemoryCache.length,
      'diskCacheFiles': fileCount,
      'diskCacheSize': totalSize,
      'diskCacheSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
    };
  }

  /// 특정 에셋이 로드되었는지 확인
  bool isAssetLoaded(String assetPath) {
    return _getFromMemoryCache(assetPath) != null;
  }

  /// 오프라인 모드에서 에셋 접근 가능 여부 확인
  /// 
  /// [assetPath] 에셋 경로 또는 URL
  /// 
  /// 반환: 오프라인에서 접근 가능한지 여부
  Future<bool> isAssetAvailableOffline(String assetPath) async {
    // 메모리 캐시 확인
    if (_getFromMemoryCache(assetPath) != null) {
      return true;
    }
    
    // 로컬 에셋은 항상 오프라인에서 접근 가능
    if (assetPath.startsWith('assets/')) {
      return true;
    }
    
    // 네트워크 URL인 경우 디스크 캐시 확인
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      final cacheManager = _cacheManagerInstance;
      if (cacheManager == null) {
        // CacheManager가 사용 불가능한 경우 false 반환
        if (kDebugMode) {
          print('⚠ path_provider plugin not available, assuming offline unavailable');
        }
        return false;
      }

      try {
        final file = await cacheManager.getFileFromCache(assetPath);
        return file != null;
      } on MissingPluginException {
        // path_provider 플러그인이 없는 환경(단위 테스트 등)에서는 false 반환
        if (kDebugMode) {
          print('⚠ path_provider plugin not available, assuming offline unavailable');
        }
        return false;
      } catch (e) {
        if (kDebugMode) {
          print('⚠ Failed to check offline availability: $assetPath - $e');
        }
        return false;
      }
    }
    
    return false;
  }
}

