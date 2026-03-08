import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/sinkhole_section_definitions.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/sinkhole_form_step.dart';
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
  group('SinkholeFormStep', () {
    testWidgets('renders 7 tabs matching SinkholeSectionDefinitions',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      final tabs = tester.widgetList<Tab>(find.byType(Tab)).toList();
      expect(tabs.length, SinkholeSectionDefinitions.all.length);
      expect(tabs.length, 7);

      for (final section in SinkholeSectionDefinitions.all) {
        expect(find.text(section.title), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('TabBar is scrollable', (tester) async {
      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.isScrollable, isTrue);
    });

    testWidgets('renders FormSectionUI for each tab', (tester) async {
      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // TabBarView creates children lazily, so at least the first is rendered
      expect(find.byType(FormSectionUI), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping tab switches content', (tester) async {
      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Initially on first tab (Property ID) — verify a field label
      expect(find.text('Insured Name'), findsOneWidget);

      // Tap second tab (Exterior)
      final exteriorTab = find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Exterior'),
      );
      await tester.tap(exteriorTab);
      await tester.pumpAndSettle();

      // Fields from Exterior section should be visible (trigger field label
      // with required asterisk appended by TriStateChipGroup)
      expect(
        find.text('Depression, sinkhole, or settlement *'),
        findsOneWidget,
      );
    });

    testWidgets('passes formData and branchContext to FormSectionUI',
        (tester) async {
      final testFormData = <String, dynamic>{
        'insuredName': 'Test Client',
      };
      final testBranchContext = <String, dynamic>{
        'sinkhole_any_exterior_yes': true,
      };

      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
          formData: testFormData,
          branchContext: testBranchContext,
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      final sectionUI =
          tester.widget<FormSectionUI>(find.byType(FormSectionUI).first);
      expect(sectionUI.formValues, testFormData);
      expect(sectionUI.branchContext, testBranchContext);
    });

    testWidgets('onFieldChanged propagates', (tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
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
      await tester.enterText(textFields.first, 'John Doe');

      expect(changedKey, isNotNull);
      expect(changedValue, 'John Doe');
    });

    testWidgets('renders all sections without error with empty data',
        (tester) async {
      await tester.pumpWidget(_wrap(
        SinkholeFormStep(
          formData: const {},
          branchContext: const {},
          onFieldChanged: (key, val) {},
          onBranchFlagChanged: (key, val) {},
        ),
      ));

      // Iterate through all tabs to ensure no errors
      for (var i = 0; i < SinkholeSectionDefinitions.all.length; i++) {
        final section = SinkholeSectionDefinitions.all[i];
        final tabFinder = find.descendant(
          of: find.byType(TabBar),
          matching: find.text(section.title),
        );
        await tester.tap(tabFinder);
        await tester.pumpAndSettle();
      }

      // If we get here, all sections rendered without error
      expect(true, isTrue);
    });
  });
}
