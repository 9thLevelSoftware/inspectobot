import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/common/widgets/form_type_card.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/media/pending_media_sync_store.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';
import 'package:inspectobot/features/inspection/presentation/new_inspection_page.dart';
import 'package:inspectobot/theme/app_theme.dart';

class _MockNavigationService extends Mock implements NavigationService {}

void main() {
  const organizationId = 'org-session';
  const userId = 'user-session';

  late _MockNavigationService mockNav;

  setUp(() {
    mockNav = _MockNavigationService();
    when(() => mockNav.go(any(), extra: any(named: 'extra'))).thenReturn(null);
    setupTestServiceLocator(navigationService: mockNav);
  });

  tearDown(() async {
    await resetServiceLocator();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required _TestRepositoryProvider provider,
    MediaSyncRemoteStore? mediaSyncRemoteStore,
    PendingMediaSyncStore? pendingMediaSyncStore,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: NewInspectionPage(
          organizationId: organizationId,
          userId: userId,
          repository: provider,
          mediaSyncRemoteStore: mediaSyncRemoteStore,
          pendingMediaSyncStore: pendingMediaSyncStore,
        ),
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

  // -------------------------------------------------------------------------
  // Task 1: Updated existing tests for ExpansionTile-based layout
  // -------------------------------------------------------------------------

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

    // Continue button is in ReachZoneScaffold stickyBottom, always visible
    await tester.tap(find.text('Continue'));
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

    // Deselect all form types by tapping each FormTypeCard.
    // Must scroll each into view individually and pump between taps.
    for (final form in FormType.values) {
      final cardFinder = find.widgetWithText(FormTypeCard, form.label);
      await tester.scrollUntilVisible(
        cardFinder,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(cardFinder);
      await tester.pumpAndSettle();
      await tester.tap(cardFinder);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Select at least one inspection form.'), findsOneWidget);
    expect(store.createCalls, 0);
  });

  testWidgets('shows exact revision form labels', (tester) async {
    await pumpPage(
      tester,
      provider: _TestRepositoryProvider(
        InspectionRepository(_SpyInspectionStore()),
      ),
    );

    // Labels are inside FormTypeCard widgets within the Inspection Forms
    // ExpansionTile, which starts expanded
    for (final label in const [
      'Insp4pt 03-25',
      'RCF-1 03-25',
      'OIR-B1-1802 Rev 04/26',
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }

    expect(find.text('Insp4pt 03-25'), findsOneWidget);
    expect(find.text('RCF-1 03-25'), findsOneWidget);
    expect(find.text('OIR-B1-1802 Rev 04/26'), findsOneWidget);
  });

  testWidgets('successful submit saves and navigates to checklist',
      (tester) async {
    final store = _SpyInspectionStore();
    final remoteStore = _NoopMediaRemoteStore();
    final pendingStore = PendingMediaSyncStore(outboxStore: SyncOutboxStore());
    await pumpPage(
      tester,
      provider: _TestRepositoryProvider(InspectionRepository(store)),
      mediaSyncRemoteStore: remoteStore,
      pendingMediaSyncStore: pendingStore,
    );

    await fillValidForm(tester);
    // Continue button is always visible in stickyBottom
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(store.createCalls, 1);
    expect(store.lastOrganizationId, organizationId);
    expect(store.lastUserId, userId);
    expect(
      store.lastCreatedId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );

    // Verify NavigationService.go was called with correct checklist route
    final captured = verify(
      () => mockNav.go(
        captureAny(),
        extra: any(named: 'extra'),
      ),
    ).captured;
    final route = captured.first as String;
    expect(route, startsWith('/inspections/'));
    expect(route, endsWith('/checklist'));
  });

  // -------------------------------------------------------------------------
  // Task 2: Progressive disclosure interaction tests
  // -------------------------------------------------------------------------

  group('progressive disclosure', () {
    testWidgets('sections start expanded showing all fields', (tester) async {
      await pumpPage(
        tester,
        provider: _TestRepositoryProvider(
          InspectionRepository(_SpyInspectionStore()),
        ),
      );

      // All 3 section titles exist (some may need scrolling)
      expect(find.text('Client Information'), findsOneWidget);
      expect(find.text('Property Information'), findsOneWidget);
      // Inspection Forms title may be off-screen, scroll to it
      await tester.scrollUntilVisible(
        find.text('Inspection Forms'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Inspection Forms'), findsOneWidget);

      // Fields from Client Information section
      expect(find.text('Client Name'), findsOneWidget);
      expect(find.text('Client Email'), findsOneWidget);
      expect(find.text('Client Phone'), findsOneWidget);

      // Fields from Property Information section -- may need to scroll
      await tester.scrollUntilVisible(
        find.text('Property Address'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Property Address'), findsOneWidget);
      expect(find.text('Inspection Date'), findsOneWidget);
      expect(find.text('Year Built'), findsOneWidget);

      // Inspection Forms section -- FormTypeCard widgets
      await tester.scrollUntilVisible(
        find.text('Insp4pt 03-25'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(FormTypeCard), findsNWidgets(3));
    });

    testWidgets('sections can be collapsed and expanded', (tester) async {
      await pumpPage(
        tester,
        provider: _TestRepositoryProvider(
          InspectionRepository(_SpyInspectionStore()),
        ),
      );

      // Client Name should be visible initially (section starts expanded)
      expect(find.text('Client Name'), findsOneWidget);

      // Tap Client Information header to collapse
      await tester.tap(find.text('Client Information'));
      await tester.pumpAndSettle();

      // Client Name should now be hidden
      expect(find.text('Client Name'), findsNothing);

      // Tap again to expand
      await tester.tap(find.text('Client Information'));
      await tester.pumpAndSettle();

      // Client Name should be visible again
      expect(find.text('Client Name'), findsOneWidget);
    });

    testWidgets('collapsed section does not affect other sections',
        (tester) async {
      await pumpPage(
        tester,
        provider: _TestRepositoryProvider(
          InspectionRepository(_SpyInspectionStore()),
        ),
      );

      // Collapse Client Information
      await tester.tap(find.text('Client Information'));
      await tester.pumpAndSettle();

      // Client fields hidden
      expect(find.text('Client Name'), findsNothing);

      // Property Information fields still visible
      expect(find.text('Property Address'), findsOneWidget);

      // Inspection Forms cards still visible -- scroll if needed
      await tester.scrollUntilVisible(
        find.text('Insp4pt 03-25'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(FormTypeCard), findsNWidgets(3));
    });
  });

  // -------------------------------------------------------------------------
  // Task 3: FormTypeCard selection and description tests
  // -------------------------------------------------------------------------

  group('FormTypeCard selection', () {
    testWidgets('form type cards show descriptions', (tester) async {
      await pumpPage(
        tester,
        provider: _TestRepositoryProvider(
          InspectionRepository(_SpyInspectionStore()),
        ),
      );

      // Scroll to the Inspection Forms section
      await tester.scrollUntilVisible(
        find.text('Insp4pt 03-25'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byType(FormTypeCard), findsNWidgets(3));

      expect(
        find.text(
          'Electrical, HVAC, plumbing, and water heater inspection',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Roof age, condition, and remaining useful life assessment',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Wind resistance features and discount qualification',
        ),
        findsOneWidget,
      );
    });

    testWidgets('form type card toggles selection on tap', (tester) async {
      await pumpPage(
        tester,
        provider: _TestRepositoryProvider(
          InspectionRepository(_SpyInspectionStore()),
        ),
      );

      // Scroll to form cards
      await tester.scrollUntilVisible(
        find.text('Insp4pt 03-25'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // All cards start selected -- find the first FormTypeCard
      final firstCard = find.byType(FormTypeCard).first;

      // Verify it starts selected by checking the Checkbox inside
      Checkbox findCheckboxInCard() {
        // Find Checkbox descendants within the first FormTypeCard
        final checkboxFinder = find.descendant(
          of: firstCard,
          matching: find.byType(Checkbox),
        );
        return tester.widget<Checkbox>(checkboxFinder);
      }

      expect(findCheckboxInCard().value, isTrue);

      // Tap to deselect
      await tester.tap(firstCard);
      await tester.pump();

      expect(findCheckboxInCard().value, isFalse);

      // Tap to re-select
      await tester.tap(firstCard);
      await tester.pump();

      expect(findCheckboxInCard().value, isTrue);
    });

    testWidgets('can submit with subset of forms selected', (tester) async {
      final store = _SpyInspectionStore();
      final remoteStore = _NoopMediaRemoteStore();
      final pendingStore =
          PendingMediaSyncStore(outboxStore: SyncOutboxStore());
      await pumpPage(
        tester,
        provider: _TestRepositoryProvider(InspectionRepository(store)),
        mediaSyncRemoteStore: remoteStore,
        pendingMediaSyncStore: pendingStore,
      );

      await fillValidForm(tester);

      // Deselect one form type (the first one: fourPoint / Insp4pt 03-25)
      final firstCardFinder =
          find.widgetWithText(FormTypeCard, 'Insp4pt 03-25');
      await tester.scrollUntilVisible(
        firstCardFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(firstCardFinder);
      await tester.pump();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // create() should have been called with only 2 forms
      expect(store.createCalls, 1);
      expect(store.lastFormsEnabled, hasLength(2));
      expect(store.lastFormsEnabled, isNot(contains('four_point')));
      expect(store.lastFormsEnabled, contains('roof_condition'));
      expect(store.lastFormsEnabled, contains('wind_mitigation'));
    });
  });
}

class _NoopMediaRemoteStore extends MediaSyncRemoteStore {
  _NoopMediaRemoteStore()
    : super(storage: _NoopStorageGateway(), metadata: _NoopMetadataGateway());

  @override
  Future<void> upload({
    required String mediaId,
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String requirementKey,
    required CapturedMediaType mediaType,
    required String evidenceInstanceId,
    required RequiredPhotoCategory category,
    required String filePath,
    DateTime? capturedAt,
  }) async {}
}

class _NoopStorageGateway implements MediaStorageGateway {
  @override
  Future<Uint8List?> readBytes({required String path}) async {
    return null;
  }

  @override
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {}
}

class _NoopMetadataGateway implements MediaMetadataGateway {
  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<void> upsertMetadata({
    required String mediaId,
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String requirementKey,
    required CapturedMediaType mediaType,
    required String evidenceInstanceId,
    required RequiredPhotoCategory category,
    required String storagePath,
    required String contentType,
    required DateTime capturedAt,
  }) async {}
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
  String? lastOrganizationId;
  String? lastUserId;
  List<dynamic>? lastFormsEnabled;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    createCalls += 1;
    final payload = Map<String, dynamic>.from(inspectionJson);
    lastCreatedId = payload['id']?.toString();
    lastOrganizationId = payload['organization_id']?.toString();
    lastUserId = payload['user_id']?.toString();
    lastFormsEnabled = payload['forms_enabled'] as List<dynamic>?;
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
