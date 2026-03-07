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
    late SignaturePadController controller;

    setUp(() {
      controller = SignaturePadController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with default props', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller),
      ));

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
        SignaturePad(controller: controller, hintText: 'Sign here'),
      ));

      expect(find.text('Sign here'), findsOneWidget);
    });

    testWidgets('hides hint text when points are present', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller),
      ));

      // Draw something
      final center = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      expect(find.text('Draw your signature here'), findsNothing);
    });

    testWidgets('captures pointer events and populates controller',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller),
      ));

      final center = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      expect(controller.isNotEmpty, isTrue);
      expect(controller.points.length, greaterThan(1));
    });

    testWidgets('controller.clear removes all points', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller),
      ));

      // Draw something
      final center = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();
      expect(controller.isNotEmpty, isTrue);

      // Clear
      controller.clear();
      await tester.pump();

      expect(controller.isEmpty, isTrue);
      expect(find.text('Draw your signature here'), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller, height: 300),
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
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller, enabled: false),
      ));

      final center = tester.getCenter(find.byType(SignaturePad));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();
      await tester.pump();

      expect(controller.isEmpty, isTrue);
    });

    testWidgets('applies semantic label', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller, semanticLabel: 'My signature'),
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
        SignaturePad(controller: controller),
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
