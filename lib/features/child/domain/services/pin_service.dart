import 'package:shared_preferences/shared_preferences.dart';

/// PIN 잠금 서비스
/// 
/// 부모 모드 전환 시 사용하는 4자리 PIN을 관리합니다.
class PinService {
  static const String _pinKey = 'parent_mode_pin';
  static const int _pinLength = 4;

  /// PIN 설정
  /// 
  /// [pin] 4자리 숫자 PIN
  /// 
  /// 반환: 설정 성공 여부
  Future<bool> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_pinKey, pin);
    } catch (e) {
      return false;
    }
  }

  /// PIN 확인
  /// 
  /// [pin] 확인할 PIN
  /// 
  /// 반환: PIN 일치 여부
  Future<bool> verifyPin(String pin) async {
    if (!_isValidPin(pin)) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString(_pinKey);
      return storedPin == pin;
    } catch (e) {
      return false;
    }
  }

  /// PIN이 설정되어 있는지 확인
  /// 
  /// 반환: PIN 설정 여부
  Future<bool> hasPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_pinKey);
    } catch (e) {
      return false;
    }
  }

  /// PIN 삭제
  /// 
  /// 반환: 삭제 성공 여부
  Future<bool> clearPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_pinKey);
    } catch (e) {
      return false;
    }
  }

  /// PIN 유효성 검사
  /// 
  /// [pin] 검사할 PIN
  /// 
  /// 반환: 유효 여부 (4자리 숫자)
  bool _isValidPin(String pin) {
    if (pin.length != _pinLength) {
      return false;
    }
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }

  /// PIN 길이 반환
  static int get pinLength => _pinLength;
}

