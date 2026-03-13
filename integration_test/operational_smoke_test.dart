import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inspectobot/common/widgets/form_type_card.dart';

import 'support/operational_review_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'sign-in, create an inspection, and resume it after app relaunch',
    (tester) async {
      final harness = await OperationalReviewAppHarness.create();
      await harness.pumpApp(tester);

      final signInFields = find.byType(TextFormField);
      await tester.enterText(signInFields.at(0), 'reviewer@example.com');
      await tester.enterText(signInFields.at(1), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('InspectoBot'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'New Inspection'));
      await tester.pumpAndSettle();

      final setupFields = find.byType(TextFormField);
      await tester.enterText(setupFields.at(0), 'Jane Reviewer');
      await tester.enterText(setupFields.at(1), 'jane.reviewer@example.com');
      await tester.enterText(setupFields.at(2), '555-0110');
      await tester.enterText(setupFields.at(3), '123 Palm Ave');
      await tester.enterText(setupFields.at(4), '2026-03-12');
      await tester.enterText(setupFields.at(5), '2004');

      await tester.tap(find.text('Deselect All'));
      await tester.pumpAndSettle();
      final fourPointCard = find.widgetWithText(
        FormTypeCard,
        'Insp4pt 03-25',
      );
      await tester.scrollUntilVisible(
        fourPointCard,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(fourPointCard);
      await tester.pumpAndSettle();
      await tester.tap(fourPointCard, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Guided Inspection Wizard'), findsOneWidget);

      final sharedAuthGateway = harness.authGateway;
      final sharedInspectionStore = harness.inspectionStore;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await harness.dispose();

      final restartedHarness = await OperationalReviewAppHarness.create(
        authGateway: sharedAuthGateway,
        inspectionStore: sharedInspectionStore,
      );
      addTearDown(restartedHarness.dispose);
      await restartedHarness.pumpApp(tester);

      expect(find.text('Jane Reviewer'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    },
  );

  testWidgets('checklist smoke captures evidence into the pending queue', (
    tester,
  ) async {
    final harness = await ChecklistOperationalHarness.create(
      draft: buildFourPointDraft(
        inspectionId: 'capture-smoke',
        initialStepIndex: 1,
      ),
    );
    addTearDown(harness.dispose);
    await harness.pump(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Capture').first);
    await tester.pumpAndSettle();

    expect(find.text('Captured'), findsOneWidget);
    expect(await harness.pendingStore.listPending(), isNotEmpty);
  });

  testWidgets(
    'report smoke generates a PDF and exposes delivery actions',
    (tester) async {
      final harness = await ChecklistOperationalHarness.create(
        draft: buildFourPointDraft(
          inspectionId: 'report-smoke',
          ready: true,
          initialStepIndex: 1,
        ),
        seedReadyEvidence: true,
      );
      addTearDown(harness.dispose);
      await harness.pump(tester);

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('generate-pdf-button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('PDF generated'), findsOneWidget);
      expect(await harness.artifactCount(), 1);
      expect(
        find.byKey(const ValueKey('delivery-download-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('delivery-secure-share-button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('delivery-download-button')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('delivery-secure-share-button')),
      );
      await tester.pumpAndSettle();

      final actionTypes = await harness.deliveryActionTypes();
      expect(actionTypes, contains('artifact_saved'));
      expect(actionTypes, contains('download_started'));
      expect(actionTypes, contains('share_started'));
    },
  );
}
