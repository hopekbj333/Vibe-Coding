import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';

/// 앱 모드 상태 Provider
/// 
/// 현재 앱 모드(부모/아동)를 관리합니다.
final appModeProvider = StateNotifierProvider<AppModeNotifier, AppMode>((ref) {
  return AppModeNotifier();
});

/// 앱 모드 Notifier
class AppModeNotifier extends StateNotifier<AppMode> {
  AppModeNotifier() : super(AppMode.parent);

  /// 부모 모드로 전환
  void switchToParentMode() {
    state = AppMode.parent;
  }

  /// 아동 모드로 전환
  void switchToChildMode() {
    state = AppMode.child;
  }

  /// 모드 토글
  void toggleMode() {
    state = state == AppMode.parent ? AppMode.child : AppMode.parent;
  }
}

