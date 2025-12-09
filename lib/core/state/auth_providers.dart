import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/firebase/firebase_repositories.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/auth/domain/services/auth_token_service.dart';
import 'app_state.dart';

/// Firebase Auth 상태 스트림 Provider
/// 
/// Firebase Auth의 인증 상태 변화를 감지합니다.
final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  final auth = FirebaseRepositories.auth;
  if (auth == null) {
    // Firebase가 초기화되지 않은 경우 빈 스트림 반환
    return Stream.value(null);
  }
  return auth.authStateChanges();
});

/// 인증 상태 Provider
/// 
/// 현재 인증 상태를 제공합니다.
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return AuthStatus.unauthenticated;
      }
      return AuthStatus.authenticated;
    },
    loading: () => AuthStatus.initial,
    error: (_, __) => AuthStatus.error,
  );
});

/// 현재 인증된 사용자 Provider
/// 
/// Firebase Auth의 현재 사용자를 제공합니다.
final currentUserProvider = Provider<firebase_auth.User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull;
});

/// 사용자 정보 Provider
/// 
/// Firestore에서 사용자 정보를 가져옵니다.
/// S 1.2.1에서 구현 완료
final userModelProvider = FutureProvider<UserModel?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return null;
  }

  // AuthService를 통해 사용자 정보 가져오기
  final authService = ref.read(authServiceProvider);
  try {
    final userModel = await authService.getCurrentUserModel();
    
    // 사용자 정보가 없으면 기본값 반환
    if (userModel == null) {
      return UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: currentUser.displayName,
        role: UserRole.parent,
        createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: currentUser.metadata.lastSignInTime ?? DateTime.now(),
      );
    }
    
    return userModel;
  } catch (e) {
    // 오류 발생 시 기본값 반환
    return UserModel(
      uid: currentUser.uid,
      email: currentUser.email ?? '',
      displayName: currentUser.displayName,
      role: UserRole.parent,
      createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: currentUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }
});

/// 인증 토큰 서비스 Provider
final authTokenServiceProvider = Provider<AuthTokenService>((ref) {
  return AuthTokenService();
});

/// 자동 로그인 확인 Provider
/// 
/// Firebase Auth가 자동으로 토큰을 관리하므로,
/// 현재 사용자가 있으면 자동 로그인 상태입니다.
final autoLoginProvider = Provider<bool>((ref) {
  final authTokenService = ref.read(authTokenServiceProvider);
  return authTokenService.hasStoredAuth();
});

/// 관리자 권한 확인 Provider
/// 
/// 현재 사용자가 관리자인지 확인합니다.
final isAdminProvider = Provider<bool>((ref) {
  final userModelAsync = ref.watch(userModelProvider);
  
  return userModelAsync.when(
    data: (user) => user?.role == UserRole.admin,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// 교사 또는 관리자 권한 확인 Provider
/// 
/// 현재 사용자가 교사 또는 관리자인지 확인합니다.
final isTeacherOrAdminProvider = Provider<bool>((ref) {
  final userModelAsync = ref.watch(userModelProvider);
  
  return userModelAsync.when(
    data: (user) => user?.role == UserRole.teacher || user?.role == UserRole.admin,
    loading: () => false,
    error: (_, __) => false,
  );
});

