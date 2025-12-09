import '../../domain/repositories/auth_repository.dart';

/// 인증 예외 클래스들
/// 
/// 다양한 인증 오류를 구분하기 위한 예외 클래스들

/// 이메일/비밀번호 인증 예외
class EmailAuthException extends AuthException {
  EmailAuthException(super.message, [super.code]);
}

/// 소셜 로그인 예외
class SocialAuthException extends AuthException {
  SocialAuthException(super.message, [super.code]);
}

/// 네트워크 예외
class NetworkAuthException extends AuthException {
  NetworkAuthException(super.message, [super.code]);
}

/// 사용자 정보 예외
class UserDataException extends AuthException {
  UserDataException(super.message, [super.code]);
}

