import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:literacy_assessment/core/widgets/child_friendly_button.dart';

void main() {
  group('ChildFriendlyButton 테스트', () {
    testWidgets('버튼이 정상적으로 렌더링되어야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChildFriendlyButton(
              label: '테스트',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('테스트'), findsOneWidget);
    });

    testWidgets('아이콘 버튼이 정상적으로 렌더링되어야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChildFriendlyButton(
              icon: Icons.check,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('비활성화된 버튼은 클릭할 수 없어야 함', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChildFriendlyButton(
              label: '비활성화',
              enabled: false,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('비활성화'));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('버튼 클릭 시 콜백이 호출되어야 함', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChildFriendlyButton(
              label: '클릭',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('클릭'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });
}

