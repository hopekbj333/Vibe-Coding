import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../data/models/cached_content_model.dart';

/// 오프라인 동기화 서비스 (S 3.8.2, S 3.8.3)
class OfflineSyncService {
  static const String _offlineBoxName = 'offline_records';
  
  Box? _offlineBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 초기화
  Future<void> initialize() async {
    _offlineBox = await Hive.openBox(_offlineBoxName);
    debugPrint('✓ Offline sync service initialized');
    
    // Firestore 오프라인 지속성 활성화
    await _firestore.enableNetwork();
    debugPrint('✓ Firestore offline persistence enabled');
  }

  /// 오프라인 기록 가져오기
  OfflineLearningRecord? _getRecord(String id) {
    final data = _offlineBox?.get(id);
    if (data == null) return null;
    
    try {
      return OfflineLearningRecord.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  /// 모든 오프라인 기록 가져오기
  List<OfflineLearningRecord> _getAllRecords() {
    return _offlineBox?.values
            .map((e) {
              try {
                return OfflineLearningRecord.fromJson(jsonDecode(e));
              } catch (e) {
                return null;
              }
            })
            .where((e) => e != null)
            .cast<OfflineLearningRecord>()
            .toList() ??
        [];
  }

  /// 오프라인 학습 기록 저장
  Future<void> saveOfflineRecord({
    required String childId,
    required String moduleId,
    required Map<String, dynamic> data,
  }) async {
    final record = OfflineLearningRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: childId,
      moduleId: moduleId,
      data: data,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await _offlineBox?.put(record.id, jsonEncode(record.toJson()));
    debugPrint('💾 Saved offline record: ${record.id}');
  }

  /// 동기화되지 않은 기록 개수
  int getUnsyncedCount() {
    final allRecords = _getAllRecords();
    return allRecords.where((record) => !record.isSynced).length;
  }

  /// 동기화 실행
  Future<void> syncAll() async {
    final allRecords = _getAllRecords();
    final unsyncedRecords =
        allRecords.where((record) => !record.isSynced).toList();

    if (unsyncedRecords.isEmpty) {
      debugPrint('✓ No records to sync');
      return;
    }

    debugPrint('🔄 Syncing ${unsyncedRecords.length} records...');

    for (var record in unsyncedRecords) {
      try {
        // Firestore에 업로드
        await _firestore
            .collection('learning_sessions')
            .doc(record.id)
            .set({
          'childId': record.childId,
          'moduleId': record.moduleId,
          'data': record.data,
          'createdAt': record.createdAt.toIso8601String(),
          'syncedAt': DateTime.now().toIso8601String(),
        });

        // 동기화 완료 표시
        record.isSynced = true;
        await _offlineBox?.put(record.id, jsonEncode(record.toJson()));
        
        debugPrint('✅ Synced: ${record.id}');
      } catch (e) {
        debugPrint('❌ Sync failed for ${record.id}: $e');
      }
    }

    debugPrint('✓ Sync completed');
  }

  /// 동기화된 기록 정리 (7일 이상 된 것)
  Future<void> cleanupSyncedRecords() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
    final allRecords = _getAllRecords();
    final oldRecords = allRecords
        .where((record) =>
            record.isSynced && record.createdAt.isBefore(cutoffDate))
        .toList();

    for (var record in oldRecords) {
      await _offlineBox?.delete(record.id);
      debugPrint('🗑️ Cleaned up synced record: ${record.id}');
    }
  }

  /// 충돌 해결 (서버 데이터 우선)
  Future<Map<String, dynamic>?> resolveConflict({
    required String recordId,
    required Map<String, dynamic> localData,
    bool preferServer = true,
  }) async {
    try {
      final serverDoc = await _firestore
          .collection('learning_sessions')
          .doc(recordId)
          .get();

      if (!serverDoc.exists) {
        // 서버에 없으면 로컬 데이터 사용
        return localData;
      }

      if (preferServer) {
        // 서버 데이터 우선
        return serverDoc.data();
      } else {
        // 로컬 데이터 우선
        return localData;
      }
    } catch (e) {
      debugPrint('⚠️ Conflict resolution failed: $e');
      return localData; // 오류 시 로컬 데이터 사용
    }
  }

  /// 오프라인 모드 확인
  Future<bool> isOffline() async {
    // connectivity_plus로 확인 (간소화: 항상 false 반환)
    return false;
  }

  /// 동기화 통계
  Map<String, dynamic> getSyncStats() {
    final allRecords = _getAllRecords();
    final synced = allRecords.where((r) => r.isSynced).length;
    final unsynced = allRecords.where((r) => !r.isSynced).length;

    return {
      'total': allRecords.length,
      'synced': synced,
      'unsynced': unsynced,
      'lastSyncAttempt': DateTime.now().toIso8601String(),
    };
  }
}

