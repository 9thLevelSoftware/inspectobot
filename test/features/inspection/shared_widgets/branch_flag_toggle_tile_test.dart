import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/presentation/shared_widgets/branch_flag_toggle_tile.dart';
import 'package:inspectobot/theme/app_theme.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget buildSubject({
    String flagKey = 'hazard_present',
    String label = 'Hazard present?',
    bool value = false,
    ValueChanged<bool>? onChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: BranchFlagToggleTile(
          flagKey: flagKey,
          label: label,
          value: value,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('BranchFlagToggleTile', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildSubject(label: 'Roof defect present?'));

      expect(find.text('Roof defect present?'), findsOneWidget);
    });

    testWidgets('renders "Decision Point" subtitle', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Decision Point'), findsOneWidget);
    });

    testWidgets('ValueKey is branch-flag-{flagKey}', (tester) async {
      await tester.pumpWidget(buildSubject(flagKey: 'roof_defect'));

      expect(
        find.byKey(const ValueKey('branch-flag-roof_defect')),
        findsOneWidget,
      );
    });

    testWidgets('calls onChanged when toggled', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(buildSubject(
        value: false,
        onChanged: (v) => receivedValue = v,
      ));

      // Tap the SwitchListTile to toggle it
      final tile = find.byKey(const ValueKey('branch-flag-hazard_present'));
      expect(tile, findsOneWidget);
      await tester.tap(tile);
      await tester.pump();

      expect(receivedValue, isTrue);
    });
  });
}
