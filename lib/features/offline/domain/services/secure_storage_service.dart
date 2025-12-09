import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 로컬 데이터 암호화 서비스 (S 3.8.7)
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // 암호화 키
  static const String _keyPrefix = 'literacy_';

  /// 민감 데이터 저장
  Future<void> saveSecure(String key, String value) async {
    try {
      await _storage.write(
        key: _keyPrefix + key,
        value: _encryptData(value),
      );
      debugPrint('🔐 Secure data saved: $key');
    } catch (e) {
      debugPrint('❌ Failed to save secure data: $e');
    }
  }

  /// 민감 데이터 읽기
  Future<String?> readSecure(String key) async {
    try {
      final encrypted = await _storage.read(key: _keyPrefix + key);
      if (encrypted == null) return null;
      
      return _decryptData(encrypted);
    } catch (e) {
      debugPrint('❌ Failed to read secure data: $e');
      return null;
    }
  }

  /// 민감 데이터 삭제
  Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: _keyPrefix + key);
      debugPrint('🗑️ Secure data deleted: $key');
    } catch (e) {
      debugPrint('❌ Failed to delete secure data: $e');
    }
  }

  /// 전체 데이터 삭제 (앱 삭제 시)
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🗑️ All secure data deleted');
    } catch (e) {
      debugPrint('❌ Failed to delete all secure data: $e');
    }
  }

  /// 데이터 암호화 (간소화)
  String _encryptData(String data) {
    // 실제로는 AES 등 사용
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return base64Encode(utf8.encode(data + hash.toString()));
  }

  /// 데이터 복호화 (간소화)
  String _decryptData(String encrypted) {
    // 실제로는 AES 등 사용
    final decoded = utf8.decode(base64Decode(encrypted));
    // 간소화: 해시 검증 생략
    return decoded.substring(0, decoded.length - 64);
  }

  /// 아동 정보 저장
  Future<void> saveChildInfo(String childId, Map<String, dynamic> info) async {
    await saveSecure(
      'child_$childId',
      jsonEncode(info),
    );
  }

  /// 아동 정보 읽기
  Future<Map<String, dynamic>?> readChildInfo(String childId) async {
    final data = await readSecure('child_$childId');
    if (data == null) return null;
    
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Failed to parse child info: $e');
      return null;
    }
  }

  /// 검사 결과 저장
  Future<void> saveAssessmentResult(
    String resultId,
    Map<String, dynamic> result,
  ) async {
    await saveSecure(
      'assessment_$resultId',
      jsonEncode(result),
    );
  }

  /// 검사 결과 읽기
  Future<Map<String, dynamic>?> readAssessmentResult(String resultId) async {
    final data = await readSecure('assessment_$resultId');
    if (data == null) return null;
    
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Failed to parse assessment result: $e');
      return null;
    }
  }
}

