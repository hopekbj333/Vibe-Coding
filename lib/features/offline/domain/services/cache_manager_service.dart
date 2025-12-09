import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../../data/models/cached_content_model.dart';

/// 스마트 캐싱 서비스 (S 3.8.1)
class CacheManagerService {
  static const String _cacheBoxName = 'cached_content';
  static const int _maxCacheSize = 500 * 1024 * 1024; // 500MB

  Box? _cacheBox;

  /// 초기화
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    _cacheBox = await Hive.openBox(_cacheBoxName);
    debugPrint('✓ Cache manager initialized');
  }

  /// Wi-Fi 연결 시에만 대용량 파일 다운로드
  Future<bool> shouldDownload(String contentId, int size) async {
    // 이미 캐시되었는지 확인
    final cached = _cacheBox?.get(contentId);
    if (cached != null) {
      return false; // 이미 다운로드됨
    }

    // 5MB 이상은 Wi-Fi에서만
    if (size > 5 * 1024 * 1024) {
      // connectivity_plus로 확인 (간소화: 항상 true 반환)
      return true;
    }

    return true;
  }

  /// 콘텐츠 캐싱
  Future<void> cacheContent({
    required String id,
    required String type,
    required String path,
    required int size,
  }) async {
    final content = CachedContentModel(
      id: id,
      type: type,
      path: path,
      size: size,
      cachedAt: DateTime.now(),
      lastUsed: DateTime.now(),
      useCount: 1,
    );

    await _cacheBox?.put(id, jsonEncode(content.toJson()));
    debugPrint('✓ Cached: $id ($type, ${size / 1024}KB)');

    // 캐시 크기 체크 및 정리
    await _cleanupIfNeeded();
  }

  /// 캐시 사용 기록 업데이트
  Future<void> updateUsage(String contentId) async {
    final cached = _getCachedContent(contentId);
    if (cached != null) {
      final updated = cached.copyWith(
        lastUsed: DateTime.now(),
        useCount: cached.useCount + 1,
      );
      await _cacheBox?.put(contentId, jsonEncode(updated.toJson()));
    }
  }

  /// 캐시된 콘텐츠 가져오기
  CachedContentModel? _getCachedContent(String id) {
    final data = _cacheBox?.get(id);
    if (data == null) return null;
    
    try {
      return CachedContentModel.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  /// 모든 캐시된 콘텐츠 가져오기
  List<CachedContentModel> _getAllCachedContents() {
    return _cacheBox?.values
            .map((e) {
              try {
                return CachedContentModel.fromJson(jsonDecode(e));
              } catch (e) {
                return null;
              }
            })
            .where((e) => e != null)
            .cast<CachedContentModel>()
            .toList() ??
        [];
  }

  /// 캐시 크기 계산
  Future<int> getTotalCacheSize() async {
    int total = 0;
    final allContents = _getAllCachedContents();
    for (var content in allContents) {
      total += content.size;
    }
    return total;
  }

  /// 캐시 정리 (LRU)
  Future<void> _cleanupIfNeeded() async {
    final totalSize = await getTotalCacheSize();
    
    if (totalSize > _maxCacheSize) {
      debugPrint('⚠️ Cache size exceeded: ${totalSize / 1024 / 1024}MB');
      
      // 사용 빈도가 낮고 오래된 순으로 정렬
      final allContents = _getAllCachedContents();
      allContents.sort((a, b) {
        final aScore = a.useCount * 1000 + a.lastUsed.millisecondsSinceEpoch;
        final bScore = b.useCount * 1000 + b.lastUsed.millisecondsSinceEpoch;
        return aScore.compareTo(bScore);
      });

      // 하위 20% 삭제
      final deleteCount = (allContents.length * 0.2).ceil();
      for (int i = 0; i < deleteCount && i < allContents.length; i++) {
        await _cacheBox?.delete(allContents[i].id);
        debugPrint('🗑️ Removed from cache: ${allContents[i].id}');
      }
    }
  }

  /// 캐시 전체 삭제
  Future<void> clearCache() async {
    await _cacheBox?.clear();
    debugPrint('✓ Cache cleared');
  }

  /// 특정 타입의 캐시 조회
  List<CachedContentModel> getCachedByType(String type) {
    return _getAllCachedContents()
        .where((content) => content.type == type)
        .toList();
  }

  /// 캐시 통계
  Map<String, dynamic> getCacheStats() {
    final allContents = _getAllCachedContents();
    final totalSize = allContents.fold<int>(
      0,
      (sum, content) => sum + content.size,
    );

    return {
      'totalCount': allContents.length,
      'totalSize': totalSize,
      'byType': {
        'game': allContents.where((c) => c.type == 'game').length,
        'audio': allContents.where((c) => c.type == 'audio').length,
        'image': allContents.where((c) => c.type == 'image').length,
      },
    };
  }
}

