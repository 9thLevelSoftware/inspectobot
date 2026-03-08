import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/common/widgets/tri_state_chip_group.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('TriStateChipGroup', () {
    testWidgets('renders 3 chips labeled Yes, No, N/A', (tester) async {
      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Test Label',
          value: null,
          onChanged: (_) {},
        ),
      ));

      expect(find.widgetWithText(ChoiceChip, 'Yes'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'No'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'N/A'), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Cracks Found',
          value: null,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Cracks Found'), findsOneWidget);
    });

    testWidgets('shows required indicator when isRequired is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Cracks Found',
          value: null,
          isRequired: true,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Cracks Found *'), findsOneWidget);
    });

    testWidgets('renders with correct initial value selected', (tester) async {
      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Test',
          value: 'No',
          onChanged: (_) {},
        ),
      ));

      final noChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'No'),
      );
      expect(noChip.selected, isTrue);

      final yesChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Yes'),
      );
      expect(yesChip.selected, isFalse);

      final naChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'N/A'),
      );
      expect(naChip.selected, isFalse);
    });

    testWidgets('selecting Yes calls onChanged with Yes', (tester) async {
      String? result;

      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Test',
          value: null,
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.widgetWithText(ChoiceChip, 'Yes'));
      await tester.pump();

      expect(result, 'Yes');
    });

    testWidgets('selecting already-selected chip calls onChanged with null',
        (tester) async {
      String? result = 'Yes';

      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Test',
          value: 'Yes',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.widgetWithText(ChoiceChip, 'Yes'));
      await tester.pump();

      expect(result, isNull);
    });

    testWidgets('selecting different chip calls onChanged with new value',
        (tester) async {
      String? result;

      await tester.pumpWidget(_wrap(
        TriStateChipGroup(
          label: 'Test',
          value: 'Yes',
          onChanged: (v) => result = v,
        ),
      ));

      await tester.tap(find.widgetWithText(ChoiceChip, 'N/A'));
      await tester.pump();

      expect(result, 'N/A');
    });
  });
}
