import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../../../../config/firebase/firebase_repositories.dart';

/// 인증 토큰 서비스
/// 
/// 자동 로그인 및 토큰 갱신을 처리합니다.
class AuthTokenService {
  /// Firebase Auth 인스턴스
  final firebase_auth.FirebaseAuth? _auth;

  AuthTokenService() : _auth = FirebaseRepositories.auth;

  /// 현재 사용자의 토큰 가져오기
  /// 
  /// 자동으로 토큰을 갱신합니다.
  Future<String?> getCurrentToken({bool forceRefresh = false}) async {
    if (_auth == null) {
      return null;
    }

    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return null;
      }

      // 토큰 가져오기 (필요시 자동 갱신)
      final token = await user.getIdToken(forceRefresh);
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Get token error: $e');
      }
      return null;
    }
  }

  /// 토큰 갱신
  /// 
  /// 현재 사용자의 토큰을 강제로 갱신합니다.
  Future<String?> refreshToken() async {
    return await getCurrentToken(forceRefresh: true);
  }

  /// 자동 로그인 확인
  /// 
  /// Firebase Auth의 현재 사용자가 있는지 확인합니다.
  /// Firebase Auth는 자동으로 토큰을 관리하므로 별도의 저장이 필요 없습니다.
  bool hasStoredAuth() {
    return _auth?.currentUser != null;
  }

  /// 토큰 만료 시간 확인
  /// 
  /// 토큰이 곧 만료될 예정인지 확인합니다 (1시간 이내).
  Future<bool> isTokenExpiringSoon() async {
    if (_auth == null) {
      return false;
    }

    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return false;
      }

      // 토큰 결과 가져오기
      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;

      if (expirationTime == null) {
        return false;
      }

      // 만료 시간까지 1시간 이내인지 확인
      final now = DateTime.now();
      final timeUntilExpiration = expirationTime.difference(now);
      
      return timeUntilExpiration.inHours < 1;
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Check token expiration error: $e');
      }
      return false;
    }
  }

  /// 주기적 토큰 갱신 시작
  /// 
  /// 앱 실행 중 주기적으로 토큰을 갱신합니다.
  /// Firebase Auth가 자동으로 토큰을 관리하므로, 
  /// 이 메서드는 필요시 수동으로 토큰을 갱신할 때 사용합니다.
  Future<void> startTokenRefresh() async {
    // Firebase Auth는 자동으로 토큰을 갱신하므로
    // 여기서는 만료 임박 시에만 갱신
    final isExpiring = await isTokenExpiringSoon();
    if (isExpiring) {
      await refreshToken();
    }
  }
}

