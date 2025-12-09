import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/training_content_model.dart';

/// 문항 로딩 서비스
/// 
/// 로컬 JSON 파일과 Firebase Firestore에서 
/// 학습 문항을 로드하는 서비스입니다.
/// 
/// **로컬 JSON**: 검사용 표준 문항 (50개)
/// **Firebase**: 학습용 대량 문항 (15,000개+)
class QuestionLoaderService {
  final FirebaseFirestore _firestore;
  
  QuestionLoaderService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==========================================
  // 로컬 JSON 로딩 (검사용 문항)
  // ==========================================
  
  /// 로컬 JSON 파일에서 문항을 로드합니다.
  /// 
  /// [fileName]: assets/questions/training/ 폴더 내의 파일명
  /// 예: 'same_sound.json', 'syllable_clap.json'
  Future<TrainingContentModel> loadFromLocalJson(String fileName) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/questions/training/$fileName',
      );
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return TrainingContentModel.fromJson(jsonData);
    } catch (e) {
      throw QuestionLoadException(
        'Failed to load local question file: $fileName',
        originalError: e,
      );
    }
  }

  /// 여러 로컬 JSON 파일을 한 번에 로드합니다.
  Future<List<TrainingContentModel>> loadMultipleLocalJson(
    List<String> fileNames,
  ) async {
    final results = <TrainingContentModel>[];
    
    for (final fileName in fileNames) {
      try {
        final content = await loadFromLocalJson(fileName);
        results.add(content);
      } catch (e) {
        // 개별 파일 로드 실패는 로그만 남기고 계속 진행
        print('Warning: Failed to load $fileName - $e');
      }
    }
    
    return results;
  }

  // ==========================================
  // Firebase Firestore 로딩 (학습용 문항)
  // ==========================================
  
  /// Firebase에서 콘텐츠 ID로 문항을 로드합니다.
  Future<TrainingContentModel?> loadFromFirebase(String contentId) async {
    try {
      final doc = await _firestore
          .collection('training_contents')
          .doc(contentId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      final data = doc.data();
      if (data == null) {
        return null;
      }
      
      return TrainingContentModel.fromJson(data);
    } catch (e) {
      throw QuestionLoadException(
        'Failed to load from Firebase: $contentId',
        originalError: e,
      );
    }
  }

  /// 모듈 ID로 여러 문항을 로드합니다.
  /// 
  /// [moduleId]: 모듈 ID (예: 'phonological_basic')
  /// [limit]: 로드할 최대 개수
  Future<List<TrainingContentModel>> loadByModule({
    required String moduleId,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('training_contents')
          .where('moduleId', isEqualTo: moduleId)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => TrainingContentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw QuestionLoadException(
        'Failed to load module: $moduleId',
        originalError: e,
      );
    }
  }

  /// 타입별로 문항을 로드합니다.
  /// 
  /// [type]: 콘텐츠 타입
  /// [difficultyLevel]: 난이도 레벨 (선택)
  /// [limit]: 로드할 최대 개수
  Future<List<TrainingContentModel>> loadByType({
    required TrainingContentType type,
    int? difficultyLevel,
    int limit = 20,
  }) async {
    try {
      var query = _firestore
          .collection('training_contents')
          .where('type', isEqualTo: type.name);
      
      if (difficultyLevel != null) {
        query = query.where('difficulty.level', isEqualTo: difficultyLevel);
      }
      
      final querySnapshot = await query.limit(limit).get();
      
      return querySnapshot.docs
          .map((doc) => TrainingContentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw QuestionLoadException(
        'Failed to load by type: ${type.name}',
        originalError: e,
      );
    }
  }

  /// 난이도 범위로 문항을 로드합니다.
  /// 
  /// 적응형 학습에서 사용됩니다.
  Future<List<TrainingContentModel>> loadByDifficultyRange({
    required String moduleId,
    required int minLevel,
    required int maxLevel,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('training_contents')
          .where('moduleId', isEqualTo: moduleId)
          .where('difficulty.level', isGreaterThanOrEqualTo: minLevel)
          .where('difficulty.level', isLessThanOrEqualTo: maxLevel)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => TrainingContentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw QuestionLoadException(
        'Failed to load by difficulty range: $moduleId ($minLevel-$maxLevel)',
        originalError: e,
      );
    }
  }

  // ==========================================
  // 하이브리드 로딩 (로컬 + Firebase)
  // ==========================================
  
  /// 하이브리드 로딩: 로컬 우선, 실패 시 Firebase
  /// 
  /// 검사용 문항은 로컬에서, 학습용 문항은 Firebase에서 로드합니다.
  Future<TrainingContentModel?> loadHybrid({
    String? localFileName,
    String? firebaseContentId,
  }) async {
    // 1. 로컬 파일 시도
    if (localFileName != null) {
      try {
        return await loadFromLocalJson(localFileName);
      } catch (e) {
        print('Local load failed, trying Firebase: $e');
      }
    }
    
    // 2. Firebase 시도
    if (firebaseContentId != null) {
      return await loadFromFirebase(firebaseContentId);
    }
    
    throw QuestionLoadException(
      'Both local and Firebase loading failed',
    );
  }

  // ==========================================
  // 캐싱 (향후 구현)
  // ==========================================
  
  final Map<String, TrainingContentModel> _cache = {};
  
  /// 캐시에서 로드 (없으면 Firebase에서 로드 후 캐싱)
  Future<TrainingContentModel?> loadWithCache(String contentId) async {
    // 캐시 확인
    if (_cache.containsKey(contentId)) {
      return _cache[contentId];
    }
    
    // Firebase에서 로드
    final content = await loadFromFirebase(contentId);
    
    // 캐싱
    if (content != null) {
      _cache[contentId] = content;
    }
    
    return content;
  }

  /// 캐시 클리어
  void clearCache() {
    _cache.clear();
  }
}

/// 문항 로딩 예외
class QuestionLoadException implements Exception {
  final String message;
  final Object? originalError;
  
  QuestionLoadException(this.message, {this.originalError});
  
  @override
  String toString() {
    if (originalError != null) {
      return 'QuestionLoadException: $message\nCaused by: $originalError';
    }
    return 'QuestionLoadException: $message';
  }
}

/// 문항 로딩 전략
enum LoadStrategy {
  localOnly,      // 로컬만
  firebaseOnly,   // Firebase만
  localFirst,     // 로컬 우선, 실패 시 Firebase
  firebaseFirst,  // Firebase 우선, 실패 시 로컬
}

/// 로딩 옵션
class LoadOptions {
  final LoadStrategy strategy;
  final bool useCache;
  final int? limit;
  final int? difficultyLevel;
  
  const LoadOptions({
    this.strategy = LoadStrategy.localFirst,
    this.useCache = true,
    this.limit,
    this.difficultyLevel,
  });
}
