import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/media/media_sync_remote_store.dart';
import 'package:inspectobot/features/media/media_sync_task.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';
import 'package:inspectobot/features/sync/sync_runner.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';

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

    final scheduler = _TestSyncScheduler();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(repository: repository, syncScheduler: scheduler),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume In-Progress Inspections'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.textContaining('last incomplete step 2'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
    await tester.pumpAndSettle();

    expect(scheduler.runCalls, 1);
    expect(find.text('Guided Inspection Wizard'), findsOneWidget);
    expect(find.textContaining('Step 2 of'), findsOneWidget);
  });
}

class _TestSyncScheduler extends SyncScheduler {
  _TestSyncScheduler()
      : super(
          runner: _NoopSyncRunner(),
          connectivityChanges: null,
        );

  int runCalls = 0;

  @override
  Future<SyncRunResult> runPending() async {
    runCalls += 1;
    return const SyncRunResult(attempted: 0, succeeded: 0, failed: 0, skipped: 0);
  }
}

class _NoopSyncRunner extends SyncRunner {
  _NoopSyncRunner()
      : super(
          outboxStore: SyncOutboxStore(),
          inspectionRemoteStore: _NoopInspectionStore(),
          mediaRemoteStore: _NoopMediaRemoteStore(),
        );
}

class _NoopInspectionStore implements InspectionStore {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    return inspectionJson;
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
    return <String, dynamic>{};
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

class _NoopMediaRemoteStore extends MediaSyncRemoteStore {
  _NoopMediaRemoteStore()
      : super(
          storage: _NoopStorageGateway(),
          metadata: _NoopMetadataGateway(),
        );

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
  Future<void> upload({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {}
}

class _NoopMetadataGateway implements MediaMetadataGateway {
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
    required DateTime capturedAt,
  }) async {}
}
