import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_service.dart';

/// 로그인 상태 Provider
/// 
/// 로그인 진행 상태를 관리합니다.
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// 인증 에러 Provider
/// 
/// 인증 중 발생한 에러를 관리합니다.
final authErrorProvider = StateProvider<String?>((ref) => null);

/// 이메일/비밀번호 로그인 Provider
/// 
/// 주의: Provider 초기화 중에는 다른 Provider를 수정할 수 없습니다.
/// 상태 관리는 UI 레벨에서 처리해야 합니다.
final signInWithEmailProvider =
    FutureProvider.family<UserModel, SignInParams>((ref, params) async {
  // Provider 초기화 중에는 상태를 변경하지 않음
  // 상태 관리는 호출하는 쪽에서 처리
  final authService = ref.read(authServiceProvider);
  try {
    final user = await authService.signInWithEmail(
      email: params.email,
      password: params.password,
    );
    return user;
  } catch (e) {
    // 에러는 호출하는 쪽에서 처리
    rethrow;
  }
});

/// 이메일/비밀번호 회원가입 Provider
/// 
/// 주의: Provider 초기화 중에는 다른 Provider를 수정할 수 없습니다.
/// 상태 관리는 UI 레벨에서 처리해야 합니다.
final signUpWithEmailProvider =
    FutureProvider.family<UserModel, SignUpParams>((ref, params) async {
  // Provider 초기화 중에는 상태를 변경하지 않음
  // 상태 관리는 호출하는 쪽에서 처리
  final authService = ref.read(authServiceProvider);
  try {
    final user = await authService.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
    return user;
  } catch (e) {
    // 에러는 호출하는 쪽에서 처리
    rethrow;
  }
});

/// Google 로그인 Provider
/// 
/// 주의: Provider 초기화 중에는 다른 Provider를 수정할 수 없습니다.
/// 상태 관리는 UI 레벨에서 처리해야 합니다.
final signInWithGoogleProvider = FutureProvider<UserModel?>((ref) async {
  // Provider 초기화 중에는 상태를 변경하지 않음
  // 상태 관리는 호출하는 쪽에서 처리
  final authService = ref.read(authServiceProvider);
  try {
    final user = await authService.signInWithGoogle();
    return user;
  } catch (e) {
    // 에러는 호출하는 쪽에서 처리
    rethrow;
  }
});

/// Apple 로그인 Provider
/// 
/// 주의: Provider 초기화 중에는 다른 Provider를 수정할 수 없습니다.
/// 상태 관리는 UI 레벨에서 처리해야 합니다.
final signInWithAppleProvider = FutureProvider<UserModel?>((ref) async {
  // Provider 초기화 중에는 상태를 변경하지 않음
  // 상태 관리는 호출하는 쪽에서 처리
  final authService = ref.read(authServiceProvider);
  try {
    final user = await authService.signInWithApple();
    return user;
  } catch (e) {
    // 에러는 호출하는 쪽에서 처리
    rethrow;
  }
});

/// 로그아웃 Provider
final signOutProvider = FutureProvider<void>((ref) async {
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;

  try {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();

    ref.read(authLoadingProvider.notifier).state = false;
  } catch (e) {
    ref.read(authLoadingProvider.notifier).state = false;
    final errorMessage = e is AuthException ? e.message : '로그아웃 중 오류가 발생했습니다.';
    ref.read(authErrorProvider.notifier).state = errorMessage;
    rethrow;
  }
});

/// 비밀번호 재설정 Provider
final resetPasswordProvider =
    FutureProvider.family<void, String>((ref, email) async {
  ref.read(authLoadingProvider.notifier).state = true;
  ref.read(authErrorProvider.notifier).state = null;

  try {
    final authService = ref.read(authServiceProvider);
    await authService.resetPassword(email);

    ref.read(authLoadingProvider.notifier).state = false;
  } catch (e) {
    ref.read(authLoadingProvider.notifier).state = false;
    final errorMessage = e is AuthException ? e.message : '비밀번호 재설정 중 오류가 발생했습니다.';
    ref.read(authErrorProvider.notifier).state = errorMessage;
    rethrow;
  }
});

/// 로그인 파라미터
class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}

/// 회원가입 파라미터
class SignUpParams {
  final String email;
  final String password;
  final String? displayName;

  SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

