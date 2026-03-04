import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_draft.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/presentation/form_checklist_page.dart';

void main() {
  testWidgets('wizard enforces linear guarded progression', (tester) async {
    final store = _ChecklistStore();
    final repository = InspectionRepository(store);
    final draft = InspectionDraft(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Jane Doe',
      clientEmail: 'jane@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Palm Ave',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2008,
      enabledForms: {FormType.fourPoint},
    );

    await tester.pumpWidget(
      MaterialApp(home: FormChecklistPage(draft: draft, repository: repository)),
    );

    expect(find.textContaining('Step 1 of'), findsOneWidget);

    await tester.tap(find.text('Continue to Next Step'));
    await tester.pumpAndSettle();

    expect(store.updateCalls, 1);
    expect(find.textContaining('Step 2 of'), findsOneWidget);
    expect(find.text('Exterior Front'), findsWidgets);
  });

  testWidgets('resume step uses persisted last incomplete step', (tester) async {
    final requirementKeys = FormRequirements.requirementKeysForForm(
      FormType.fourPoint,
    );
    final completion = <String, bool>{};
    for (final key in requirementKeys) {
      completion[key] = true;
    }

    final draft = InspectionDraft(
      inspectionId: 'insp-2',
      organizationId: 'org-1',
      userId: 'user-1',
      clientName: 'Resume User',
      clientEmail: 'resume@example.com',
      clientPhone: '555-0100',
      propertyAddress: '456 Gulf Dr',
      inspectionDate: DateTime.utc(2026, 3, 4),
      yearBuilt: 2001,
      enabledForms: {FormType.fourPoint, FormType.roofCondition},
      wizardSnapshot: WizardProgressSnapshot(
        lastStepIndex: 2,
        completion: completion,
        branchContext: const <String, dynamic>{},
        status: WizardProgressStatus.inProgress,
      ),
      initialStepIndex: 2,
    );

    await tester.pumpWidget(MaterialApp(home: FormChecklistPage(draft: draft)));

    expect(find.textContaining('Step 3 of'), findsOneWidget);
  });
}

class _ChecklistStore implements InspectionStore {
  int updateCalls = 0;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> updateWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required int wizardLastStep,
    required Map<String, bool> wizardCompletion,
    required Map<String, dynamic> wizardBranchContext,
    required String wizardStatus,
  }) async {
    updateCalls += 1;
    return <String, dynamic>{
      'id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'client_name': 'Jane Doe',
      'property_address': '123 Palm Ave',
      'forms_enabled': <String>['four_point'],
      'wizard_last_step': wizardLastStep,
      'wizard_completion': wizardCompletion,
      'wizard_branch_context': wizardBranchContext,
      'wizard_status': wizardStatus,
    };
  }
}
