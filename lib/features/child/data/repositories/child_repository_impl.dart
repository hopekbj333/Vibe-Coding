import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/state/app_state.dart';
import '../../../../config/firebase/firebase_config.dart';
import '../../../../config/firebase/firestore_schema.dart';
import '../../domain/repositories/child_repository.dart';

/// 아동 프로필 저장소 구현
/// 
/// Firestore를 사용하여 아동 프로필을 관리합니다.
class ChildRepositoryImpl implements ChildRepository {
  final FirebaseFirestore? _firestore;

  ChildRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  /// Firestore 인스턴스 가져오기
  FirebaseFirestore? get _db {
    if (!FirebaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠ ChildRepository: Firebase not initialized');
      }
      return null;
    }
    return _firestore ?? FirebaseFirestore.instance;
  }

  @override
  Future<List<ChildModel>> getChildren(String parentId) async {
    final db = _db;
    if (db == null) {
      if (kDebugMode) {
        print('⚠ ChildRepository.getChildren: Firestore not available');
      }
      return [];
    }

    try {
      // 복합 인덱스 문제로 orderBy 제거하고 메모리에서 정렬
      final snapshot = await db
          .collection(FirestoreSchema.children)
          .where('parentId', isEqualTo: parentId)
          .get();

      final children = snapshot.docs
          .map((doc) => ChildModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // 메모리에서 정렬 (최신순)
      children.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return children;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ ChildRepository.getChildren error: $e');
      }
      return [];
    }
  }

  @override
  Future<ChildModel?> getChild(String childId) async {
    final db = _db;
    if (db == null) {
      if (kDebugMode) {
        print('⚠ ChildRepository.getChild: Firestore not available');
      }
      return null;
    }

    try {
      final doc = await db
          .collection(FirestoreSchema.children)
          .doc(childId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ChildModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      if (kDebugMode) {
        print('⚠ ChildRepository.getChild error: $e');
      }
      return null;
    }
  }

  @override
  Future<ChildModel> createChild(ChildModel child) async {
    final db = _db;
    if (db == null) {
      throw Exception('Firestore not available');
    }

    try {
      final now = DateTime.now();
      final childData = child.copyWith(
        createdAt: now,
        updatedAt: now,
      ).toMap();

      final docRef = await db
          .collection(FirestoreSchema.children)
          .add(childData);

      // 생성된 문서 ID로 업데이트
      return child.copyWith(id: docRef.id);
    } catch (e) {
      if (kDebugMode) {
        print('⚠ ChildRepository.createChild error: $e');
      }
      throw Exception('아동 프로필 생성에 실패했습니다: $e');
    }
  }

  @override
  Future<ChildModel> updateChild(ChildModel child) async {
    final db = _db;
    if (db == null) {
      throw Exception('Firestore not available');
    }

    try {
      final childData = child.copyWith(
        updatedAt: DateTime.now(),
      ).toMap();

      await db
          .collection(FirestoreSchema.children)
          .doc(child.id)
          .update(childData);

      return child.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      if (kDebugMode) {
        print('⚠ ChildRepository.updateChild error: $e');
      }
      throw Exception('아동 프로필 수정에 실패했습니다: $e');
    }
  }

  @override
  Future<bool> deleteChild(String childId) async {
    final db = _db;
    if (db == null) {
      if (kDebugMode) {
        print('⚠ ChildRepository.deleteChild: Firestore not available');
      }
      return false;
    }

    try {
      await db
          .collection(FirestoreSchema.children)
          .doc(childId)
          .delete();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ ChildRepository.deleteChild error: $e');
      }
      return false;
    }
  }
}

