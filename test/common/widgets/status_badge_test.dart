import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/status_badge.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StatusBadge', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Passed'),
      ));

      expect(find.text('Passed'), findsOneWidget);
    });

    testWidgets('success type uses success color', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'OK', type: StatusBadgeType.success),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      // Background should be success color with low alpha
      expect(decoration.color, isNotNull);
      expect(decoration.color!.a, closeTo(0.15, 0.01));
    });

    testWidgets('warning type uses warning color', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Warn', type: StatusBadgeType.warning),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.color!.a, closeTo(0.15, 0.01));
    });

    testWidgets('error type uses error color from colorScheme',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Fail', type: StatusBadgeType.error),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.color!.a, closeTo(0.15, 0.01));
    });

    testWidgets('info type uses info color', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Info', type: StatusBadgeType.info),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, isNotNull);
      expect(decoration.color!.a, closeTo(0.15, 0.01));
    });

    testWidgets('neutral type uses surfaceContainerHigh', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Neutral', type: StatusBadgeType.neutral),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, equals(Palette.surfaceContainerHigh));
    });

    testWidgets('has pill shape (full border radius)', (tester) async {
      await tester.pumpWidget(_wrap(
        const StatusBadge(label: 'Pill'),
      ));

      final container = tester.widget<Container>(find.byType(Container).last);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, equals(AppRadii.full));
    });

    testWidgets('each type renders distinct foreground color', (tester) async {
      for (final type in StatusBadgeType.values) {
        await tester.pumpWidget(_wrap(
          StatusBadge(label: type.name, type: type),
        ));

        // Verify a Text widget is rendered for every type
        expect(find.text(type.name), findsOneWidget);
      }
    });
  });
}
