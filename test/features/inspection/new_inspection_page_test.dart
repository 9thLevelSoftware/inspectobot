import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/presentation/new_inspection_page.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required _TestRepositoryProvider provider,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewInspectionPage(repository: provider),
      ),
    );
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'jane@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), '555-0100');
    await tester.enterText(find.byType(TextFormField).at(3), '123 Palm Ave');
    await tester.enterText(find.byType(TextFormField).at(4), '2026-03-04');
    await tester.enterText(find.byType(TextFormField).at(5), '2008');
  }

  Future<void> scrollToContinue(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Continue to Required Photos'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets('shows format validation messages before save', (tester) async {
    final store = _SpyInspectionStore();
    await pumpPage(
      tester,
      provider: _TestRepositoryProvider(InspectionRepository(store)),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'bad-email');
    await tester.enterText(find.byType(TextFormField).at(2), '555-0100');
    await tester.enterText(find.byType(TextFormField).at(3), '123 Palm Ave');
    await tester.enterText(find.byType(TextFormField).at(4), 'bad-date');
    await tester.enterText(find.byType(TextFormField).at(5), '1500');

    await scrollToContinue(tester);
    await tester.tap(find.text('Continue to Required Photos'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter a valid date (YYYY-MM-DD)'), findsOneWidget);
    expect(find.textContaining('Year built must be between 1800'), findsOneWidget);
    expect(store.createCalls, 0);
  });

  testWidgets('enforces at least one selected form', (tester) async {
    final store = _SpyInspectionStore();
    await pumpPage(
      tester,
      provider: _TestRepositoryProvider(InspectionRepository(store)),
    );

    await fillValidForm(tester);

    for (final label in const [
      'Insp4pt 03-25',
      'RCF-1 03-25',
      'OIR-B1-1802 Rev 04/26',
    ]) {
      await tester.scrollUntilVisible(
        find.widgetWithText(CheckboxListTile, label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(CheckboxListTile, label));
    }
    await tester.pump();

    await scrollToContinue(tester);
    await tester.tap(find.text('Continue to Required Photos'));
    await tester.pump();

    expect(find.text('Select at least one inspection form.'), findsOneWidget);
    expect(store.createCalls, 0);
  });

  testWidgets('shows exact revision form labels', (tester) async {
    await pumpPage(
      tester,
      provider: _TestRepositoryProvider(InspectionRepository(_SpyInspectionStore())),
    );

    await tester.scrollUntilVisible(
      find.text('Insp4pt 03-25'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('RCF-1 03-25'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('OIR-B1-1802 Rev 04/26'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Insp4pt 03-25'), findsOneWidget);
    expect(find.text('RCF-1 03-25'), findsOneWidget);
    expect(find.text('OIR-B1-1802 Rev 04/26'), findsOneWidget);
  });

  testWidgets('successful submit saves and navigates to checklist', (tester) async {
    final store = _SpyInspectionStore();
    await pumpPage(
      tester,
      provider: _TestRepositoryProvider(InspectionRepository(store)),
    );

    await fillValidForm(tester);
    await scrollToContinue(tester);
    await tester.tap(find.text('Continue to Required Photos'));
    await tester.pumpAndSettle();

    expect(store.createCalls, 1);
    expect(
      store.lastCreatedId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
    expect(find.textContaining('Inspection for Jane Doe'), findsOneWidget);
  });
}

class _TestRepositoryProvider implements NewInspectionRepositoryProvider {
  _TestRepositoryProvider(this._repository);

  final InspectionRepository _repository;

  @override
  InspectionRepository resolve() => _repository;
}

class _SpyInspectionStore implements InspectionStore {
  int createCalls = 0;
  String? lastCreatedId;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    createCalls += 1;
    final payload = Map<String, dynamic>.from(inspectionJson);
    lastCreatedId = payload['id']?.toString();
    payload['id'] = payload['id'] ?? 'generated-id';
    return payload;
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
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
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return null;
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
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> upsertReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String status,
    required List<String> missingItems,
    required DateTime computedAt,
  }) async {
    return <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status,
      'missing_items': missingItems,
      'computed_at': computedAt.toIso8601String(),
    };
  }
}
