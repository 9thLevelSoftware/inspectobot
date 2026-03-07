import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/signature_pad.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('SignaturePad', () {
    testWidgets('renders with default props', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (_) {},
        ),
      ));

      // CustomPaint exists as a descendant of SignaturePad.
      expect(
        find.descendant(
          of: find.byType(SignaturePad),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('Draw your signature here'), findsOneWidget);
    });

    testWidgets('shows hint text when points list is empty', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (_) {},
          hintText: 'Sign here',
        ),
      ));

      expect(find.text('Sign here'), findsOneWidget);
    });

    testWidgets('hides hint text when points are present', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [Offset(10, 10)],
          onPointsChanged: (_) {},
        ),
      ));

      expect(find.text('Draw your signature here'), findsNothing);
    });

    testWidgets('captures pointer events and calls onPointsChanged',
        (tester) async {
      List<Offset>? capturedPoints;

      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (pts) => capturedPoints = pts,
        ),
      ));

      final center = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      expect(capturedPoints, isNotNull);
      expect(capturedPoints, isNotEmpty);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (_) {},
          height: 300,
        ),
      ));

      final sizedBoxFinder = find.descendant(
        of: find.byType(SignaturePad),
        matching: find.byType(SizedBox),
      );
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.height, 300);
    });

    testWidgets('does not respond to pointer events when disabled',
        (tester) async {
      var called = false;

      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (_) => called = true,
          enabled: false,
        ),
      ));

      final center = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      expect(called, isFalse);
    });

    testWidgets('applies semantic label', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (_) {},
          semanticLabel: 'My signature',
        ),
      ));

      final semanticsFinder = find.descendant(
        of: find.byType(SignaturePad),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'My signature',
        ),
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('uses theme colors by default', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(
          points: const [],
          onPointsChanged: (_) {},
        ),
      ));

      final decoratedBoxFinder = find.descendant(
        of: find.byType(SignaturePad),
        matching: find.byType(DecoratedBox),
      );
      final decoratedBox = tester.widget<DecoratedBox>(decoratedBoxFinder);
      final decoration = decoratedBox.decoration as BoxDecoration;

      final theme = AppTheme.dark();
      expect(decoration.color, theme.colorScheme.surfaceContainerHighest);
    });
  });
}
