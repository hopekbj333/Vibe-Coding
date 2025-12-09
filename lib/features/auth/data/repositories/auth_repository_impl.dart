import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/state/app_state.dart';
import '../models/user_model_firestore.dart';
import '../../domain/repositories/auth_repository.dart';

/// 인증 저장소 구현
/// 
/// Firebase Auth와 Firestore를 사용하여 인증을 처리합니다.
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;
  GoogleSignIn? _googleSignIn;

  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  /// GoogleSignIn 인스턴스 가져오기 (지연 초기화)
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (kDebugMode) {
        print('✓ Starting sign up process for: $email');
      }
      
      // Firebase Auth로 회원가입
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('회원가입에 실패했습니다.');
      }

      if (kDebugMode) {
        print('✓ Firebase Auth sign up successful: ${user.uid}');
      }

      // 표시 이름 설정
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
        if (kDebugMode) {
          print('✓ Display name updated: $displayName');
        }
      }

      // Firestore에 사용자 정보 저장
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: displayName ?? user.displayName,
        role: UserRole.parent, // 기본값: 부모
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await saveUserModel(userModel);
      } catch (e) {
        // Firestore 저장 실패 시 롤백 (회원가입 취소)
        if (kDebugMode) {
          print('⚠ Firestore save failed, rolling back Auth user creation');
        }
        await user.delete();
        throw AuthException('사용자 정보 저장에 실패하여 회원가입이 취소되었습니다. 다시 시도해주세요. ($e)');
      }

      if (kDebugMode) {
        print('✓ Sign up completed successfully');
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('⚠ Firebase Auth error: ${e.code} - ${e.message}');
      }
      throw AuthException(
        _getAuthErrorMessage(e.code),
        e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Sign up error: $e');
        print('  Stack trace: ${StackTrace.current}');
      }
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('로그인에 실패했습니다.');
      }

      // Firestore에서 사용자 정보 가져오기
      final userModel = await getUserModel(user.uid);

      // 사용자 정보가 없으면 기본값으로 생성
      if (userModel == null) {
        final newUserModel = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.displayName,
          role: UserRole.parent,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserModel(newUserModel);
        return newUserModel;
      }

      // 마지막 로그인 시간 업데이트
      final updatedUserModel = userModel.copyWith(
        updatedAt: DateTime.now(),
      );
      await saveUserModel(updatedUserModel);

      return updatedUserModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Sign in error: $e');
      }
      throw AuthException('로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Google 로그인 플로우 시작
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google 로그인이 취소되었습니다.');
      }

      // Google 인증 정보 가져오기
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth로 로그인
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Google 로그인에 실패했습니다.');
      }

      // Firestore에서 사용자 정보 확인
      var userModel = await getUserModel(user.uid);

      // 신규 사용자인 경우 Firestore에 저장
      if (userModel == null) {
        userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? googleUser.displayName,
          role: UserRole.parent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserModel(userModel);
      } else {
        // 기존 사용자: 마지막 로그인 시간 업데이트
        userModel = userModel.copyWith(
          updatedAt: DateTime.now(),
        );
        await saveUserModel(userModel);
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Google sign in error: $e');
      }
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Apple 로그인 플로우 시작
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase Auth로 로그인
      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Apple 로그인에 실패했습니다.');
      }

      // Firestore에서 사용자 정보 확인
      var userModel = await getUserModel(user.uid);

      // 신규 사용자인 경우 Firestore에 저장
      if (userModel == null) {
        // Apple 로그인은 첫 로그인 시에만 이름 정보 제공
        final displayName = appleCredential.givenName != null &&
                appleCredential.familyName != null
            ? '${appleCredential.givenName} ${appleCredential.familyName}'
            : user.displayName;

        userModel = UserModel(
          uid: user.uid,
          email: user.email ?? appleCredential.email ?? '',
          displayName: displayName,
          role: UserRole.parent,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveUserModel(userModel);
      } else {
        // 기존 사용자: 마지막 로그인 시간 업데이트
        userModel = userModel.copyWith(
          updatedAt: DateTime.now(),
        );
        await saveUserModel(userModel);
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Apple sign in error: $e');
      }
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Apple 로그인 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Google 로그인도 함께 로그아웃 (초기화된 경우에만)
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      
      // Firebase Auth 로그아웃
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Sign out error: $e');
      }
      throw AuthException('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Future<UserModel?> getUserModel(String uid) async {
    if (_firestore == null) {
      if (kDebugMode) {
        print('⚠ Firestore not available');
      }
      return null;
    }

    try {
      final doc = await _firestore!
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModelFirestore.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Get user model error: $e');
      }
      return null;
    }
  }

  @override
  Future<void> saveUserModel(UserModel user) async {
    if (_firestore == null) {
      if (kDebugMode) {
        print('⚠ Firestore not available, skipping save');
      }
      // Firestore가 없어도 회원가입은 성공한 것으로 처리
      // (Firebase Auth는 성공했으므로)
      return;
    }

    try {
      if (kDebugMode) {
        print('✓ Saving user model to Firestore: ${user.uid}');
      }
      
      // 타임아웃 추가 (5초)
      await _firestore!.collection('users').doc(user.uid).set(
            UserModelFirestore.toFirestore(user),
            SetOptions(merge: true),
          ).timeout(const Duration(seconds: 5), onTimeout: () {
            if (kDebugMode) {
              print('⚠ Firestore save timed out');
            }
            throw AuthException('사용자 정보 저장 시간이 초과되었습니다. 인터넷 연결을 확인해주세요.');
          });
          
      if (kDebugMode) {
        print('✓ User model saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Save user model error: $e');
        print('  Stack trace: ${StackTrace.current}');
      }
      // Firestore 저장 실패 시 로그만 남기고 넘어가기보다는,
      // 사용자에게 알려주거나 재시도할 수 있게 해야 함.
      // 하지만 Auth는 이미 성공했으므로, 여기서 에러를 던지면
      // 사용자는 "회원가입 실패"로 인지하고 다시 가입 시도 -> "이미 존재하는 이메일" 에러 발생
      // 따라서 여기서는 에러를 던지지 않고, 성공으로 처리하되 
      // 나중에 프로필 정보가 없으면 다시 입력받는 흐름이 더 나을 수 있음.
      // 하지만 현재 앱 구조상 필수 정보(role 등)가 없으면 곤란할 수 있으므로
      // 일단은 에러를 던지되, Auth 계정 삭제 등의 롤백 로직이 필요함.
      // 간단하게는 에러를 던져서 사용자가 상황을 알게 하는 것이 좋음.
      throw AuthException('사용자 정보 저장 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Send password reset email error: $e');
      }
      throw AuthException('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인된 사용자가 없습니다.');
    }

    try {
      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        e.code,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Send email verification error: $e');
      }
      throw AuthException('이메일 인증 메일 전송 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    // 이메일 인증 상태 새로고침
    await user.reload();
    return user.emailVerified;
  }

  /// Firebase Auth 에러 코드를 사용자 친화적 메시지로 변환
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'invalid-email':
        return '올바른 이메일 형식이 아닙니다.';
      case 'user-disabled':
        return '이 계정은 비활성화되었습니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '이 로그인 방법은 허용되지 않습니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'configuration-not-found':
        return 'Firebase Authentication이 설정되지 않았습니다.\n'
            'Firebase 콘솔에서 Authentication 서비스를 활성화해주세요.';
      default:
        return '인증 중 오류가 발생했습니다. ($code)';
    }
  }
}

