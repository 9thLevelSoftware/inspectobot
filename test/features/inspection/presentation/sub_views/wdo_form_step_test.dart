import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/wdo_section_definitions.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/wdo_form_step.dart';
import 'package:inspectobot/features/inspection/presentation/widgets/form_section_ui.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(
      body: SizedBox(
        height: 600,
        width: 400,
        child: child,
      ),
    ),
  );
}

void main() {
  group('WdoFormStep', () {
    testWidgets('renders 5 tabs matching WdoSectionDefinitions', (tester) async {
      await tester.pumpWidget(_wrap(
        WdoFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
      expect(tabs.length, WdoSectionDefinitions.all.length);
      expect(tabs.length, 5);

      // Each section title appears in tab + SectionHeader, so at least once
      for (final section in WdoSectionDefinitions.all) {
        expect(find.text(section.title), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('renders FormSectionUI for each tab', (tester) async {
      await tester.pumpWidget(_wrap(
        WdoFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // TabBarView creates children lazily, so at least the first is rendered
      expect(find.byType(FormSectionUI), findsAtLeastNWidgets(1));
    });

    testWidgets('tab navigation switches visible section', (tester) async {
      await tester.pumpWidget(_wrap(
        WdoFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Initially on first tab (General Info) — verify a field from section 1
      expect(find.text('Inspection Company Name'), findsOneWidget);

      // Tap second tab (Findings) — use descendant of TabBar to avoid ambiguity
      final findingsTab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Findings'),
      );
      await tester.tap(findingsTab);
      await tester.pumpAndSettle();

      // Fields from Findings section should be visible
      expect(find.text('Findings Notes'), findsOneWidget);
    });

    testWidgets('onFieldChanged fires with correct key', (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        WdoFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (k, v) {
            changedKey = k;
            changedValue = v;
          },
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Find the first text field and enter text
      final textFields = find.byType(TextFormField);
      expect(textFields, findsAtLeastNWidgets(1));
      await tester.enterText(textFields.first, 'Test Company');

      expect(changedKey, isNotNull);
      expect(changedValue, 'Test Company');
    });

    testWidgets('onBranchFlagChanged fires on toggle', (tester) async {
      String? flagKey;
      bool? flagValue;

      // Navigate to Findings tab which has branch flags
      await tester.pumpWidget(_wrap(
        WdoFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (k, v) {
            flagKey = k;
            flagValue = v;
          },
        ),
      ));

      // Tap Findings tab using descendant of TabBar to avoid ambiguity
      final findingsTab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Findings'),
      );
      await tester.tap(findingsTab);
      await tester.pumpAndSettle();

      // Findings has branch flags — find and tap a SwitchListTile
      final switches = find.byType(SwitchListTile);
      expect(switches, findsAtLeastNWidgets(1));
      await tester.tap(switches.first);
      await tester.pump();

      expect(flagKey, isNotNull);
      expect(flagValue, true);
    });

    testWidgets('renders all sections without error with empty data',
        (tester) async {
      await tester.pumpWidget(_wrap(
        WdoFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Iterate through all tabs to ensure no errors
      for (var i = 0; i < WdoSectionDefinitions.all.length; i++) {
        final section = WdoSectionDefinitions.all[i];
        final tabFinder = find.descendant(
          of: find.byType(TabBar),
          matching: find.text(section.title),
        );
        await tester.tap(tabFinder);
        await tester.pumpAndSettle();
        // Just verifying no exceptions are thrown
      }

      // If we get here, all sections rendered without error
      expect(true, isTrue);
    });
  });
}
