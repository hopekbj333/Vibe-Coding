import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:literacy_assessment/core/widgets/choice_button_layout.dart';
import 'package:literacy_assessment/core/widgets/child_friendly_button.dart';

void main() {
  group('ChoiceButtonLayout 테스트', () {
    testWidgets('2개 선택지 레이아웃이 정상 작동해야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChoiceButtonLayout(
              buttons: [
                ChildFriendlyButton(
                  label: '선택1',
                  onPressed: () {},
                ),
                ChildFriendlyButton(
                  label: '선택2',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('선택1'), findsOneWidget);
      expect(find.text('선택2'), findsOneWidget);
    });

    testWidgets('3개 선택지 레이아웃이 정상 작동해야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChoiceButtonLayout(
              buttons: [
                ChildFriendlyButton(
                  label: '선택1',
                  onPressed: () {},
                ),
                ChildFriendlyButton(
                  label: '선택2',
                  onPressed: () {},
                ),
                ChildFriendlyButton(
                  label: '선택3',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('선택1'), findsOneWidget);
      expect(find.text('선택2'), findsOneWidget);
      expect(find.text('선택3'), findsOneWidget);
    });

    testWidgets('4개 선택지 레이아웃이 정상 작동해야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChoiceButtonLayout(
              buttons: [
                ChildFriendlyButton(
                  label: '선택1',
                  onPressed: () {},
                ),
                ChildFriendlyButton(
                  label: '선택2',
                  onPressed: () {},
                ),
                ChildFriendlyButton(
                  label: '선택3',
                  onPressed: () {},
                ),
                ChildFriendlyButton(
                  label: '선택4',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('선택1'), findsOneWidget);
      expect(find.text('선택2'), findsOneWidget);
      expect(find.text('선택3'), findsOneWidget);
      expect(find.text('선택4'), findsOneWidget);
    });
  });

  group('OXButtonLayout 테스트', () {
    testWidgets('O/X 버튼 레이아웃이 정상 작동해야 함', (WidgetTester tester) async {
      bool oPressed = false;
      bool xPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OXButtonLayout(
              onO: () {
                oPressed = true;
              },
              onX: () {
                xPressed = true;
              },
            ),
          ),
        ),
      );

      // 즉시 렌더링 확인 (애니메이션 완료 대기)
      await tester.pumpAndSettle();

      expect(find.text('O'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);

      // O 버튼 클릭
      await tester.tap(find.text('O'));
      await tester.pumpAndSettle(); // 애니메이션 완료 대기
      expect(oPressed, isTrue);

      // X 버튼 클릭
      await tester.tap(find.text('X'));
      await tester.pumpAndSettle(); // 애니메이션 완료 대기
      expect(xPressed, isTrue);
    }, timeout: const Timeout(Duration(seconds: 10))); // 타임아웃 설정
  });
}

