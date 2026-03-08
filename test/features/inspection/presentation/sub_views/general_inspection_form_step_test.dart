import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/general_inspection_form_step.dart';
import 'package:inspectobot/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

Widget _buildStep({
  GeneralInspectionFormData? formData,
  ValueChanged<GeneralInspectionFormData>? onChanged,
}) {
  return _wrap(
    GeneralInspectionFormStep(
      formData: formData ?? GeneralInspectionFormData.empty(),
      onChanged: onChanged ?? (_) {},
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GeneralInspectionFormStep', () {
    testWidgets('renders 11 tabs', (tester) async {
      await tester.pumpWidget(_buildStep());

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 11);
    });

    testWidgets('tab labels match expected names', (tester) async {
      await tester.pumpWidget(_buildStep());

      const expectedLabels = [
        'Scope',
        'Structural',
        'Exterior',
        'Roofing',
        'Plumbing',
        'Electrical',
        'HVAC',
        'Insulation',
        'Appliances',
        'Life Safety',
        'Review',
      ];

      for (final label in expectedLabels) {
        expect(
          find.descendant(of: find.byType(TabBar), matching: find.text(label)),
          findsOneWidget,
          reason: 'Expected tab label "$label" to be present',
        );
      }
    });

    testWidgets('TabBar is scrollable', (tester) async {
      await tester.pumpWidget(_buildStep());

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.isScrollable, isTrue);
    });

    testWidgets('initial tab is Scope (tab index 0)', (tester) async {
      await tester.pumpWidget(_buildStep());

      // The TabController should start at index 0.
      // We verify by checking the TabBar's controller initial index.
      final tabBarWidget = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBarWidget.controller?.index, 0);
    });
  });
}
