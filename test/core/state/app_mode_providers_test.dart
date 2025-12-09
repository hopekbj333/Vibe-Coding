import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/app_mode_providers.dart';
import 'package:literacy_assessment/core/state/app_state.dart';

void main() {
  group('AppModeProvider 테스트', () {
    test('초기 상태는 parent 모드여야 함', () {
      final container = ProviderContainer();
      expect(container.read(appModeProvider), AppMode.parent);
    });

    test('아동 모드로 전환 가능해야 함', () {
      final container = ProviderContainer();
      container.read(appModeProvider.notifier).switchToChildMode();
      expect(container.read(appModeProvider), AppMode.child);
    });

    test('부모 모드로 다시 전환 가능해야 함', () {
      final container = ProviderContainer();
      container.read(appModeProvider.notifier).switchToChildMode();
      container.read(appModeProvider.notifier).switchToParentMode();
      expect(container.read(appModeProvider), AppMode.parent);
    });

    test('모드 토글이 정상 작동해야 함', () {
      final container = ProviderContainer();
      final initialMode = container.read(appModeProvider);
      container.read(appModeProvider.notifier).toggleMode();
      expect(container.read(appModeProvider), isNot(initialMode));
      
      // 다시 토글하면 원래 모드로 돌아와야 함
      container.read(appModeProvider.notifier).toggleMode();
      expect(container.read(appModeProvider), initialMode);
    });
  });
}

