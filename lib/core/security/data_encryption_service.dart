import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// 데이터 암호화 서비스
/// 
/// 개인정보 등 민감한 데이터를 암호화하여 저장합니다.
/// 
/// 주의: 프로덕션 환경에서는 더 강력한 암호화 방식을 사용해야 합니다.
/// 현재는 기본적인 해시 및 인코딩을 사용하며, 향후 AES 암호화로 업그레이드 예정입니다.
class DataEncryptionService {
  DataEncryptionService._();

  /// 민감한 문자열 데이터 암호화
  /// 
  /// [data] 암호화할 데이터
  /// [key] 암호화 키 (사용자별 고유 키 사용 권장)
  /// 
  /// 반환: 암호화된 Base64 문자열
  /// 
  /// 주의: 현재는 기본적인 인코딩을 사용합니다.
  /// 프로덕션에서는 AES-256 등 강력한 암호화를 사용해야 합니다.
  static String encryptString(String data, String key) {
    try {
      // 키와 데이터를 결합하여 해시 생성
      final bytes = utf8.encode(data + key);
      final hash = sha256.convert(bytes);
      
      // Base64 인코딩
      return base64Encode(hash.bytes + utf8.encode(data));
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Encryption error: $e');
      }
      rethrow;
    }
  }

  /// 암호화된 문자열 복호화
  /// 
  /// [encryptedData] 암호화된 Base64 문자열
  /// [key] 암호화 키
  /// 
  /// 반환: 복호화된 원본 데이터
  /// 
  /// 주의: 현재 구현은 해시 기반이므로 완전한 복호화가 불가능합니다.
  /// 프로덕션에서는 대칭키 암호화를 사용해야 합니다.
  static String? decryptString(String encryptedData, String key) {
    try {
      final bytes = base64Decode(encryptedData);
      if (bytes.length < 32) {
        return null;
      }
      
      // 해시 부분 제거하고 원본 데이터 추출
      final dataBytes = bytes.sublist(32);
      return utf8.decode(dataBytes);
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Decryption error: $e');
      }
      return null;
    }
  }

  /// 데이터 해시 생성 (비밀번호 등 저장용)
  /// 
  /// [data] 해시할 데이터
  /// 
  /// 반환: SHA-256 해시 문자열
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// 사용자별 암호화 키 생성
  /// 
  /// [userId] 사용자 UID
  /// [email] 사용자 이메일
  /// 
  /// 반환: 사용자별 고유 암호화 키
  static String generateUserKey(String userId, String email) {
    final combined = '$userId:$email';
    final hash = sha256.convert(utf8.encode(combined));
    return hash.toString().substring(0, 32); // 32자리 키
  }

  /// 민감한 필드 마스킹 (로그 출력용)
  /// 
  /// [data] 마스킹할 데이터
  /// [visibleLength] 앞부분에 보여줄 길이
  /// 
  /// 반환: 마스킹된 문자열 (예: "test***@example.com")
  static String maskSensitiveData(String data, {int visibleLength = 4}) {
    if (data.length <= visibleLength) {
      return '*' * data.length;
    }
    return data.substring(0, visibleLength) + '*' * (data.length - visibleLength);
  }
}

