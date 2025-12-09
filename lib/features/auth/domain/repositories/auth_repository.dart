import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/state/app_state.dart';

/// 인증 예외
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// 인증 저장소 인터페이스
/// 
/// 인증 관련 데이터 접근을 추상화합니다.
abstract class AuthRepository {
  /// 이메일/비밀번호로 회원가입
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// 이메일/비밀번호로 로그인
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Google 로그인
  Future<UserModel> signInWithGoogle();

  /// Apple 로그인
  Future<UserModel> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 현재 인증된 사용자 가져오기
  firebase_auth.User? getCurrentUser();

  /// 사용자 정보 가져오기 (Firestore)
  Future<UserModel?> getUserModel(String uid);

  /// 사용자 정보 저장/업데이트 (Firestore)
  Future<void> saveUserModel(UserModel user);

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증 이메일 전송
  Future<void> sendEmailVerification();

  /// 이메일 인증 여부 확인
  Future<bool> isEmailVerified();
}

