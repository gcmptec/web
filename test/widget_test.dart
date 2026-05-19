import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gcmp_web/shared.dart';

void main() {
  group('ScrollHelper', () {
    testWidgets('to() with unmounted key does not throw', (tester) async {
      final key = GlobalKey();
      // key has no context (never mounted) — should be a silent no-op
      expect(() => ScrollHelper.to(key), returnsNormally);
    });
  });

  // SectionContainer tests are in Task 5
  // group('SectionContainer', () {
  //   testWidgets('applies 80px vertical and 24px horizontal padding on narrow screen',
  //       (tester) async {
  //     tester.view.physicalSize = const Size(375, 812);
  //     tester.view.devicePixelRatio = 1.0;
  //     addTearDown(tester.view.reset);
  //
  //     await tester.pumpWidget(
  //       const MaterialApp(
  //         home: Scaffold(
  //           body: SectionContainer(child: Text('test')),
  //         ),
  //       ),
  //     );
  //
  //     final padding = tester.widget<Padding>(find.byType(Padding).first);
  //     final insets = padding.padding as EdgeInsets;
  //     expect(insets.top, 80.0);
  //     expect(insets.bottom, 80.0);
  //     expect(insets.left, 24.0);
  //     expect(insets.right, 24.0);
  //   });
  // });
}
