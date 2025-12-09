import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/app_state.dart';
import 'package:literacy_assessment/core/state/child_providers.dart';

void main() {
  group('SelectedChildProvider 테스트', () {
    test('초기 상태는 null이어야 함', () {
      final container = ProviderContainer();
      expect(container.read(selectedChildProvider), isNull);
    });

    test('아동 프로필 선택이 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(selectedChildProvider.notifier);
      
      final testChild = ChildModel(
        id: 'test-child-123',
        parentId: 'test-parent-456',
        name: '테스트 아동',
        birthDate: DateTime(2018, 1, 1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      notifier.selectChild(testChild);
      
      final selected = container.read(selectedChildProvider);
      expect(selected, isNotNull);
      expect(selected?.id, 'test-child-123');
      expect(selected?.name, '테스트 아동');
    });

    test('선택 해제가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(selectedChildProvider.notifier);
      
      final testChild = ChildModel(
        id: 'test-child-123',
        parentId: 'test-parent-456',
        name: '테스트 아동',
        birthDate: DateTime(2018, 1, 1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      notifier.selectChild(testChild);
      notifier.clearSelection();
      
      expect(container.read(selectedChildProvider), isNull);
    });

    test('아동 나이 계산이 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(selectedChildProvider.notifier);
      
      // 2018년 1월 1일 생 (2024년 기준으로 약 6세)
      final testChild = ChildModel(
        id: 'test-child-123',
        parentId: 'test-parent-456',
        name: '테스트 아동',
        birthDate: DateTime(2018, 1, 1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      notifier.selectChild(testChild);
      
      final selected = container.read(selectedChildProvider);
      expect(selected?.age, greaterThan(5));
      expect(selected?.age, lessThan(10));
    });
  });
}

