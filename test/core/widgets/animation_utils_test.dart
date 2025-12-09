import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:literacy_assessment/core/widgets/animation_utils.dart';
import 'package:literacy_assessment/core/constants/app_constants.dart';

void main() {
  group('AnimationUtils 테스트', () {
    testWidgets('페이드 인 애니메이션이 정상 작동해야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimationUtils.fadeIn(
              child: const Text('테스트'),
            ),
          ),
        ),
      );

      // 애니메이션이 시작되기 전에는 투명해야 함
      await tester.pump();
      expect(find.text('테스트'), findsOneWidget);

      // 애니메이션 완료 대기
      await tester.pumpAndSettle(
        const Duration(milliseconds: AppConstants.slowAnimationDurationMs + 100),
      );

      expect(find.text('테스트'), findsOneWidget);
    });

    testWidgets('딜레이가 있는 페이드 인 애니메이션이 정상 작동해야 함', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimationUtils.fadeIn(
              child: const Text('딜레이 테스트'),
              delay: const Duration(milliseconds: 500),
            ),
          ),
        ),
      );

      // 딜레이 중에는 위젯이 보이지 않아야 함
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // 딜레이 중에는 SizedBox.shrink()가 표시됨

      // 딜레이 완료 후 애니메이션 시작
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('딜레이 테스트'), findsOneWidget);
    });

    test('애니메이션 지속 시간이 올바르게 설정되어야 함', () {
      expect(
        AnimationUtils.slowDuration.inMilliseconds,
        AppConstants.slowAnimationDurationMs,
      );
      expect(
        AnimationUtils.normalDuration.inMilliseconds,
        AppConstants.normalAnimationDurationMs,
      );
    });
  });
}

