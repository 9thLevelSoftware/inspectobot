import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/signature_pad.dart';
import 'package:inspectobot/theme/theme.dart';
import 'package:signature/signature.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('SignaturePad', () {
    late SignatureController controller;

    setUp(() {
      controller = SignatureController(penStrokeWidth: 3.0);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with default props', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller),
      ));

      expect(find.byType(Signature), findsOneWidget);
      expect(find.text('Draw your signature here'), findsOneWidget);
    });

    testWidgets('shows custom hint text when empty', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller, hintText: 'Sign here'),
      ));

      expect(find.text('Sign here'), findsOneWidget);
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
      // Pick the first DecoratedBox — that's our themed border/background.
      final decoratedBox =
          tester.widget<DecoratedBox>(decoratedBoxFinder.first);
      final decoration = decoratedBox.decoration as BoxDecoration;

      final theme = AppTheme.dark();
      expect(decoration.color, theme.colorScheme.surfaceContainerHighest);
    });

    testWidgets('blocks input when disabled', (tester) async {
      await tester.pumpWidget(_wrap(
        SignaturePad(controller: controller, enabled: false),
      ));

      // AbsorbPointer overlay should be present when disabled.
      expect(
        find.descendant(
          of: find.byType(SignaturePad),
          matching: find.byType(AbsorbPointer),
        ),
        findsOneWidget,
      );
    });
  });
}
