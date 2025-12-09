import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_config.dart';
import 'firestore_schema.dart';

/// Firebase 서비스 접근을 위한 헬퍼 클래스
/// 
/// Firebase가 초기화되지 않은 경우 안전하게 처리합니다.
class FirebaseRepositories {
  FirebaseRepositories._();

  /// Firestore 인스턴스 가져오기
  /// 
  /// Firebase가 초기화되지 않은 경우 null을 반환합니다.
  static FirebaseFirestore? get firestore {
    if (!FirebaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠ Firestore: Firebase not initialized');
      }
      return null;
    }
    return FirebaseFirestore.instance;
  }

  /// Firebase Auth 인스턴스 가져오기
  /// 
  /// Firebase가 초기화되지 않은 경우 null을 반환합니다.
  static FirebaseAuth? get auth {
    if (!FirebaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠ Firebase Auth: Firebase not initialized');
      }
      return null;
    }
    return FirebaseAuth.instance;
  }

  /// 사용자 컬렉션 참조
  static CollectionReference? get usersCollection {
    final db = firestore;
    if (db == null) return null;
    return db.collection(FirestoreSchema.users);
  }

  /// 아동 프로필 컬렉션 참조
  static CollectionReference? get childrenCollection {
    final db = firestore;
    if (db == null) return null;
    return db.collection(FirestoreSchema.children);
  }

  /// 검사 세션 컬렉션 참조
  static CollectionReference? get assessmentsCollection {
    final db = firestore;
    if (db == null) return null;
    return db.collection(FirestoreSchema.assessments);
  }

  /// 검사 결과 컬렉션 참조
  static CollectionReference? get assessmentResultsCollection {
    final db = firestore;
    if (db == null) return null;
    return db.collection(FirestoreSchema.assessmentResults);
  }

  /// 오디오 녹음 컬렉션 참조
  static CollectionReference? get audioRecordingsCollection {
    final db = firestore;
    if (db == null) return null;
    return db.collection(FirestoreSchema.audioRecordings);
  }

  /// 채점 데이터 컬렉션 참조
  static CollectionReference? get scoresCollection {
    final db = firestore;
    if (db == null) return null;
    return db.collection(FirestoreSchema.scores);
  }
}

