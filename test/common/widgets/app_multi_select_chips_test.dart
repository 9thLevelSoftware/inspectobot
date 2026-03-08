import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/common/widgets/app_multi_select_chips.dart';
import 'package:inspectobot/theme/app_theme.dart' show AppTheme;

void main() {
  Widget buildTestWidget({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
    String label = 'Test Label',
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: AppMultiSelectChips(
          label: label,
          options: options,
          selected: selected,
          onChanged: onChanged,
        ),
      ),
    );
  }

  group('AppMultiSelectChips', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        options: const ['A', 'B'],
        selected: const [],
        onChanged: (_) {},
        label: 'Choose Items',
      ));

      expect(find.text('Choose Items'), findsOneWidget);
    });

    testWidgets('renders all options as FilterChips', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        options: const ['Alpha', 'Beta', 'Gamma'],
        selected: const [],
        onChanged: (_) {},
      ));

      expect(find.byType(FilterChip), findsNWidgets(3));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('tapping unselected chip adds it to selection', (tester) async {
      List<String>? result;

      await tester.pumpWidget(buildTestWidget(
        options: const ['A', 'B', 'C'],
        selected: const ['A'],
        onChanged: (value) => result = value,
      ));

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result, containsAll(['A', 'B']));
    });

    testWidgets('tapping selected chip removes it from selection',
        (tester) async {
      List<String>? result;

      await tester.pumpWidget(buildTestWidget(
        options: const ['A', 'B', 'C'],
        selected: const ['A', 'B'],
        onChanged: (value) => result = value,
      ));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result, ['B']);
    });

    testWidgets('onChanged fires with updated list', (tester) async {
      var callCount = 0;
      List<String>? lastValue;

      await tester.pumpWidget(buildTestWidget(
        options: const ['X', 'Y'],
        selected: const [],
        onChanged: (value) {
          callCount++;
          lastValue = value;
        },
      ));

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(lastValue, ['X']);
    });
  });
}
