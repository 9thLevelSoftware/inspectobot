import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/completion_chip.dart';
import 'package:inspectobot/theme/theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('CompletionChip', () {
    testWidgets('displays fraction text', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 3, total: 5),
      ));

      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('displays fraction with label suffix', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 3, total: 5, label: 'items'),
      ));

      expect(find.text('3/5 items'), findsOneWidget);
    });

    testWidgets('uses Chip widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 1, total: 2),
      ));

      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('complete state uses success color', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 5, total: 5),
      ));

      final chip = tester.widget<Chip>(find.byType(Chip));
      final side = chip.side!;
      expect(side.color, equals(Palette.success));
    });

    testWidgets('incomplete state uses primary color', (tester) async {
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 2, total: 5),
      ));

      final chip = tester.widget<Chip>(find.byType(Chip));
      final side = chip.side!;
      expect(side.color, equals(Palette.primary));
    });

    testWidgets('complete and incomplete have different background colors',
        (tester) async {
      // Render complete chip
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 5, total: 5),
      ));
      final completeChip = tester.widget<Chip>(find.byType(Chip));
      final completeBg = completeChip.backgroundColor;

      // Render incomplete chip
      await tester.pumpWidget(_wrap(
        const CompletionChip(completed: 2, total: 5),
      ));
      final incompleteChip = tester.widget<Chip>(find.byType(Chip));
      final incompleteBg = incompleteChip.backgroundColor;

      expect(completeBg, isNot(equals(incompleteBg)));
    });
  });
}
