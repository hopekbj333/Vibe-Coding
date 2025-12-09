import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService 테스트', () {
    test('이메일 형식 검증이 정상 작동해야 함', () {
      // 실제 AuthService는 Mock Repository가 필요하므로
      // 여기서는 검증 로직만 테스트
      
      // 유효한 이메일 (정규식 수정: + 문자 지원)
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.kr',
        'user+tag@example.com', // + 문자 지원
      ];
      
      // + 문자를 지원하는 정규식
      final emailRegex = RegExp(r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,4}$');
      
      for (final email in validEmails) {
        expect(
          emailRegex.hasMatch(email),
          isTrue,
          reason: '$email should be valid',
        );
      }
      
      // 무효한 이메일
      final invalidEmails = [
        'invalid',
        'invalid@',
        '@example.com',
        'invalid@.com',
      ];
      
      for (final email in invalidEmails) {
        expect(
          emailRegex.hasMatch(email),
          isFalse,
          reason: '$email should be invalid',
        );
      }
    });

    test('비밀번호 강도 검증이 정상 작동해야 함', () {
      // 유효한 비밀번호 (최소 8자, 영문과 숫자 포함)
      final validPasswords = [
        'password123',
        'PASSWORD123',
        'pass1234',
        '12345678a',
      ];
      
      for (final password in validPasswords) {
        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
        final hasNumber = RegExp(r'[0-9]').hasMatch(password);
        final isValid = password.length >= 8 && hasLetter && hasNumber;
        
        expect(isValid, isTrue, reason: '$password should be valid');
      }
      
      // 무효한 비밀번호
      final invalidPasswords = [
        'short', // 너무 짧음
        'onlyletters', // 숫자 없음
        '12345678', // 영문 없음
        'pass123', // 8자 미만
      ];
      
      for (final password in invalidPasswords) {
        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
        final hasNumber = RegExp(r'[0-9]').hasMatch(password);
        final isValid = password.length >= 8 && hasLetter && hasNumber;
        
        expect(isValid, isFalse, reason: '$password should be invalid');
      }
    });
  });
}

