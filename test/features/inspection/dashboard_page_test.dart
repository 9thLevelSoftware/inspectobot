import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';

void main() {
  testWidgets('dashboard lists in-progress inspections with resume action', (
    tester,
  ) async {
    final store = InMemoryInspectionStore();
    final repository = InspectionRepository(store);
    final setup = InspectionSetup(
      id: 'insp-1',
      organizationId: 'org-local',
      userId: 'user-local',
      clientName: 'Jane Doe',
      clientEmail: 'jane@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Palm Ave',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2008,
      enabledForms: {FormType.fourPoint, FormType.roofCondition},
    );
    final created = await repository.createInspection(setup);
    final completion = <String, bool>{};
    for (final key in FormRequirements.requirementKeysForForm(FormType.fourPoint)) {
      completion[key] = true;
    }
    await repository.updateWizardProgress(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
      snapshot: WizardProgressSnapshot(
        lastStepIndex: 1,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
    );

    await tester.pumpWidget(MaterialApp(home: DashboardPage(repository: repository)));
    await tester.pumpAndSettle();

    expect(find.text('Resume In-Progress Inspections'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.textContaining('last incomplete step 3'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
    expect(find.textContaining('Step 3 of'), findsOneWidget);
  });
}
