import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/sub_views/evidence_capture_view.dart';
import 'package:inspectobot/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('EvidenceCaptureView cross-form badges', () {
    testWidgets(
        'shows "Also satisfies: GEN" when exteriorFront displayed for '
        '4-Point with General enabled', (tester) async {
      // Enable both fourPoint and generalInspection — exteriorFront is shared
      // between them (via semantic equivalence with generalFrontElevation).
      final wizardState = InspectionWizardState(
        enabledForms: {FormType.fourPoint, FormType.generalInspection},
        snapshot: WizardProgressSnapshot.empty,
      );

      await tester.pumpWidget(_wrap(
        EvidenceCaptureView(wizardState: wizardState),
      ));

      // The badge should mention "GEN" for the 4-Point form summary because
      // exteriorFront / electricalPanelLabel / hvacDataPlate are shared
      // categories with generalInspection.
      expect(find.text('Also satisfies: GEN'), findsWidgets);
    });

    testWidgets('shows no badge for non-shared category', (tester) async {
      // Enable only fourPoint — no other forms to share with.
      final wizardState = InspectionWizardState(
        enabledForms: {FormType.fourPoint},
        snapshot: WizardProgressSnapshot.empty,
      );

      await tester.pumpWidget(_wrap(
        EvidenceCaptureView(wizardState: wizardState),
      ));

      // No sharing badges should appear when only one form is enabled.
      expect(find.textContaining('Also satisfies:'), findsNothing);
    });

    testWidgets('shows badge for roofSlopeMain shared between 4PT and ROOF',
        (tester) async {
      final wizardState = InspectionWizardState(
        enabledForms: {FormType.fourPoint, FormType.roofCondition},
        snapshot: WizardProgressSnapshot.empty,
      );

      await tester.pumpWidget(_wrap(
        EvidenceCaptureView(wizardState: wizardState),
      ));

      // roofSlopeMain and roofSlopeSecondary are natively shared between
      // fourPoint and roofCondition.
      // For the 4PT summary, the badge should show ROOF.
      expect(find.text('Also satisfies: ROOF'), findsWidgets);
      // For the ROOF summary, the badge should show 4PT.
      expect(find.text('Also satisfies: 4PT'), findsWidgets);
    });
  });
}
