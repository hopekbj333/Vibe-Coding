import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'auth_providers.dart';
import '../../features/child/presentation/providers/child_providers.dart' as child_feature;

/// 선택된 아동 프로필 Provider
/// 
/// 현재 선택된 아동 프로필을 관리합니다.
final selectedChildProvider = StateNotifierProvider<SelectedChildNotifier, ChildModel?>((ref) {
  return SelectedChildNotifier(ref);
});

/// 선택된 아동 Notifier
class SelectedChildNotifier extends StateNotifier<ChildModel?> {
  SelectedChildNotifier(Ref ref) : super(null);

  /// 아동 프로필 선택
  void selectChild(ChildModel child) {
    state = child;
  }

  /// 선택 해제
  void clearSelection() {
    state = null;
  }
}

/// 아동 프로필 목록 Provider
/// 
/// 현재 사용자의 아동 프로필 목록을 가져옵니다.
/// 
/// 실제 구현은 features/child/presentation/providers/child_providers.dart에 있습니다.
/// 이 Provider는 하위 호환성을 위해 유지되며, 실제 구현을 참조합니다.
final childrenListProvider = child_feature.childrenListProvider;

