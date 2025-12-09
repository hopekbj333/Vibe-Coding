import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/firebase/firebase_repositories.dart';
import '../../../../core/state/app_state.dart';
import '../repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// 인증 서비스
/// 
/// 인증 관련 비즈니스 로직을 처리합니다.
class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  /// 이메일/비밀번호로 회원가입
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // 이메일 형식 검증
    if (!_isValidEmail(email)) {
      throw AuthException('올바른 이메일 형식이 아닙니다.');
    }

    // 비밀번호 강도 검증
    if (!_isValidPassword(password)) {
      throw AuthException(
        '비밀번호는 최소 8자 이상이어야 하며, 영문과 숫자를 포함해야 합니다.',
      );
    }

    return await _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  /// 이메일/비밀번호로 로그인
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw AuthException('올바른 이메일 형식이 아닙니다.');
    }

    return await _repository.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// Google 로그인
  Future<UserModel> signInWithGoogle() async {
    return await _repository.signInWithGoogle();
  }

  /// Apple 로그인
  Future<UserModel> signInWithApple() async {
    return await _repository.signInWithApple();
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _repository.signOut();
  }

  /// 비밀번호 재설정
  Future<void> resetPassword(String email) async {
    if (!_isValidEmail(email)) {
      throw AuthException('올바른 이메일 형식이 아닙니다.');
    }

    await _repository.sendPasswordResetEmail(email);
  }

  /// 이메일 인증 전송
  Future<void> sendEmailVerification() async {
    await _repository.sendEmailVerification();
  }

  /// 이메일 인증 여부 확인
  Future<bool> checkEmailVerification() async {
    return await _repository.isEmailVerified();
  }

  /// 현재 사용자 정보 가져오기
  Future<UserModel?> getCurrentUserModel() async {
    final user = _repository.getCurrentUser();
    if (user == null) {
      return null;
    }

    return await _repository.getUserModel(user.uid);
  }

  /// 이메일 형식 검증
  /// 
  /// + 문자를 포함한 이메일도 지원합니다 (예: user+tag@example.com)
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  /// 비밀번호 강도 검증
  /// 
  /// 최소 8자 이상, 영문과 숫자 포함
  bool _isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }
}

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  // AuthRepository는 향후 의존성 주입으로 제공될 예정
  // 현재는 직접 생성
  final auth = FirebaseRepositories.auth;
  final firestore = FirebaseRepositories.firestore;

  if (auth == null) {
    throw Exception(
      'Firebase Auth가 초기화되지 않았습니다.\n'
      'Firebase 콘솔에서 Authentication 서비스를 활성화해주세요:\n'
      'https://console.firebase.google.com/project/literacy-assessment-dev/authentication'
    );
  }

  final repository = AuthRepositoryImpl(
    auth: auth,
    firestore: firestore,
  );

  return AuthService(repository);
});

