import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gcmp_web/shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  group('ScrollHelper', () {
    testWidgets('to() with unmounted key does not throw', (tester) async {
      final key = GlobalKey();
      // key has no context (never mounted) — should be a silent no-op
      expect(() => ScrollHelper.to(key), returnsNormally);
    });
  });

  group('SectionContainer', () {
    testWidgets('applies 80px vertical and 24px horizontal padding on narrow screen',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionContainer(child: Text('test')),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      final insets = padding.padding as EdgeInsets;
      expect(insets.top, 80.0);
      expect(insets.bottom, 80.0);
      expect(insets.left, 24.0);
      expect(insets.right, 24.0);
    });
  });

  group('RevealWrapper', () {
    setUp(() {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    });

    testWidgets('renders child without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RevealWrapper(child: Text('visible')),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('visible'), findsOneWidget);
    });

    testWidgets('child starts with zero opacity before visibility fires', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RevealWrapper(child: Text('hello')),
          ),
        ),
      );
      // Immediately after pumpWidget, before pump() lets the VisibilityDetector
      // callback fire, _visible is still false so opacity must be 0.
      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 0.0);
      await tester.pump(); // drain pending timer so the test ends cleanly
    });

    testWidgets('accepts a non-zero delay without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RevealWrapper(
              delay: Duration(milliseconds: 200),
              child: Text('delayed'),
            ),
          ),
        ),
      );
      // pump() lets VisibilityDetector fire → starts 200ms Future.delayed
      await tester.pump();
      // advance time past the delay to drain the pending timer
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('delayed'), findsOneWidget);
    });
  });
}
