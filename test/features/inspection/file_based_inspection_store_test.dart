import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:inspectobot/features/inspection/data/inspection_repository.dart';

void main() {
  group('FileBasedInspectionStore', () {
    late Directory tempDir;
    late FileBasedInspectionStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('inspectobot_test_');
      store = FileBasedInspectionStore(
        directoryProvider: () async => tempDir,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('create()', () {
      test('writes JSON file with inspection data', () async {
        final input = <String, dynamic>{
          'client_name': 'Test Client',
          'property_address': '123 Test St',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        final result = await store.create(input);

        expect(result['id'], isNotNull);
        expect(result['client_name'], 'Test Client');
        expect(result['property_address'], '123 Test St');
        expect(result['organization_id'], 'org-123');
        expect(result['user_id'], 'user-456');

        // Verify file was written
        final inspectionsDir = Directory('${tempDir.path}/inspections');
        final files = await inspectionsDir
            .list()
            .where((e) => e is File && e.path.endsWith('.json'))
            .toList();
        expect(files.length, 1);
      });

      test('generates ID if not provided', () async {
        final input = <String, dynamic>{
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        final result = await store.create(input);

        expect(result['id'], isNotNull);
        expect(result['id'].toString().length, greaterThan(0));
      });

      test('preserves provided ID', () async {
        final input = <String, dynamic>{
          'id': 'my-custom-id',
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        final result = await store.create(input);

        expect(result['id'], 'my-custom-id');
      });

      test('sets default values for wizard fields', () async {
        final input = <String, dynamic>{
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        final result = await store.create(input);

        expect(result['wizard_last_step'], 0);
        expect(result['wizard_completion'], <String, bool>{});
        expect(result['wizard_branch_context'], <String, dynamic>{});
        expect(result['wizard_status'], 'in_progress');
      });
    });

    group('fetchById()', () {
      test('reads inspection from file', () async {
        final input = <String, dynamic>{
          'id': 'test-id-123',
          'client_name': 'Test Client',
          'property_address': '123 Test St',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input);

        final result = await store.fetchById(
          inspectionId: 'test-id-123',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNotNull);
        expect(result!['id'], 'test-id-123');
        expect(result['client_name'], 'Test Client');
      });

      test('returns null when inspection not found', () async {
        final result = await store.fetchById(
          inspectionId: 'non-existent-id',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('returns null when organization ID does not match', () async {
        final input = <String, dynamic>{
          'id': 'test-id-123',
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input);

        final result = await store.fetchById(
          inspectionId: 'test-id-123',
          organizationId: 'wrong-org',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('returns null when user ID does not match', () async {
        final input = <String, dynamic>{
          'id': 'test-id-123',
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input);

        final result = await store.fetchById(
          inspectionId: 'test-id-123',
          organizationId: 'org-123',
          userId: 'wrong-user',
        );

        expect(result, isNull);
      });
    });

    group('updateWizardProgress()', () {
      test('updates wizard progress fields', () async {
        final input = <String, dynamic>{
          'id': 'test-id-123',
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input);

        final result = await store.updateWizardProgress(
          inspectionId: 'test-id-123',
          organizationId: 'org-123',
          userId: 'user-456',
          wizardLastStep: 3,
          wizardCompletion: {'step1': true, 'step2': false},
          wizardBranchContext: {'has_mold': true},
          wizardStatus: 'complete',
        );

        expect(result['wizard_last_step'], 3);
        expect(result['wizard_completion'], {'step1': true, 'step2': false});
        expect(result['wizard_branch_context'], {'has_mold': true});
        expect(result['wizard_status'], 'complete');
        expect(result['client_name'], 'Test Client'); // Original fields preserved
      });

      test('throws StateError when inspection not found', () async {
        expect(
          () => store.updateWizardProgress(
            inspectionId: 'non-existent',
            organizationId: 'org-123',
            userId: 'user-456',
            wizardLastStep: 1,
            wizardCompletion: {},
            wizardBranchContext: {},
            wizardStatus: 'in_progress',
          ),
          throwsStateError,
        );
      });

      test('throws StateError when organization ID does not match', () async {
        final input = <String, dynamic>{
          'id': 'test-id-123',
          'client_name': 'Test Client',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input);

        expect(
          () => store.updateWizardProgress(
            inspectionId: 'test-id-123',
            organizationId: 'wrong-org',
            userId: 'user-456',
            wizardLastStep: 1,
            wizardCompletion: {},
            wizardBranchContext: {},
            wizardStatus: 'in_progress',
          ),
          throwsStateError,
        );
      });
    });

    group('listInProgressInspections()', () {
      test('returns empty list when no inspections exist', () async {
        final result = await store.listInProgressInspections(
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isEmpty);
      });

      test('returns only in-progress inspections', () async {
        // Create first inspection - in progress
        final inProgress = <String, dynamic>{
          'id': 'in-progress-id',
          'client_name': 'In Progress',
          'organization_id': 'org-123',
          'user_id': 'user-456',
          'wizard_status': 'in_progress',
          'updated_at': DateTime.now().toIso8601String(),
        };
        await store.create(inProgress);

        // Create second inspection - complete
        final complete = <String, dynamic>{
          'id': 'complete-id',
          'client_name': 'Complete',
          'organization_id': 'org-123',
          'user_id': 'user-456',
          'wizard_status': 'complete',
          'updated_at': DateTime.now().toIso8601String(),
        };
        await store.create(complete);

        final result = await store.listInProgressInspections(
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result.length, 1);
        expect(result.first['id'], 'in-progress-id');
        expect(result.first['client_name'], 'In Progress');
      });

      test('filters by organization and user', () async {
        final inspection = <String, dynamic>{
          'id': 'test-id',
          'client_name': 'Test',
          'organization_id': 'org-123',
          'user_id': 'user-456',
          'wizard_status': 'in_progress',
          'updated_at': DateTime.now().toIso8601String(),
        };
        await store.create(inspection);

        final resultOrg = await store.listInProgressInspections(
          organizationId: 'wrong-org',
          userId: 'user-456',
        );
        expect(resultOrg, isEmpty);

        final resultUser = await store.listInProgressInspections(
          organizationId: 'org-123',
          userId: 'wrong-user',
        );
        expect(resultUser, isEmpty);
      });

      test('returns multiple in-progress inspections', () async {
        for (var i = 0; i < 3; i++) {
          final inspection = <String, dynamic>{
            'id': 'inspection-$i',
            'client_name': 'Client $i',
            'organization_id': 'org-123',
            'user_id': 'user-456',
            'wizard_status': 'in_progress',
            'updated_at': DateTime.now().add(Duration(minutes: i)).toIso8601String(),
          };
          await store.create(inspection);
        }

        final result = await store.listInProgressInspections(
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result.length, 3);
      });
    });

    group('upsertReportReadiness()', () {
      test('writes report readiness to separate directory', () async {
        final now = DateTime.now();
        final result = await store.upsertReportReadiness(
          inspectionId: 'test-id-123',
          organizationId: 'org-123',
          userId: 'user-456',
          status: 'ready',
          missingItems: <String>[],
          computedAt: now,
        );

        expect(result['inspection_id'], 'test-id-123');
        expect(result['organization_id'], 'org-123');
        expect(result['user_id'], 'user-456');
        expect(result['status'], 'ready');
        expect(result['missing_items'], <String>[]);
        expect(result['computed_at'], now.toIso8601String());

        // Verify file was written to readiness directory
        final readinessDir = Directory('${tempDir.path}/inspections/readiness');
        final files = await readinessDir
            .list()
            .where((e) => e is File && e.path.endsWith('.json'))
            .toList();
        expect(files.length, 1);
      });

      test('updates existing report readiness', () async {
        final inspectionId = 'test-id-123';

        await store.upsertReportReadiness(
          inspectionId: inspectionId,
          organizationId: 'org-123',
          userId: 'user-456',
          status: 'pending',
          missingItems: ['photo1', 'photo2'],
          computedAt: DateTime.now(),
        );

        final later = DateTime.now().add(const Duration(minutes: 5));
        final result = await store.upsertReportReadiness(
          inspectionId: inspectionId,
          organizationId: 'org-123',
          userId: 'user-456',
          status: 'ready',
          missingItems: <String>[],
          computedAt: later,
        );

        expect(result['status'], 'ready');
        expect(result['missing_items'], <String>[]);
      });
    });

    group('fetchReportReadiness()', () {
      test('reads report readiness from file', () async {
        final inspectionId = 'test-id-123';
        final now = DateTime.now();

        await store.upsertReportReadiness(
          inspectionId: inspectionId,
          organizationId: 'org-123',
          userId: 'user-456',
          status: 'ready',
          missingItems: <String>[],
          computedAt: now,
        );

        final result = await store.fetchReportReadiness(
          inspectionId: inspectionId,
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNotNull);
        expect(result!['inspection_id'], inspectionId);
        expect(result['status'], 'ready');
        expect(result['computed_at'], now.toIso8601String());
      });

      test('returns null when report readiness not found', () async {
        final result = await store.fetchReportReadiness(
          inspectionId: 'non-existent',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('returns null when inspection ID does not match', () async {
        await store.upsertReportReadiness(
          inspectionId: 'test-id',
          organizationId: 'org-123',
          userId: 'user-456',
          status: 'ready',
          missingItems: <String>[],
          computedAt: DateTime.now(),
        );

        final result = await store.fetchReportReadiness(
          inspectionId: 'different-id',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('returns null when organization ID does not match', () async {
        await store.upsertReportReadiness(
          inspectionId: 'test-id',
          organizationId: 'org-123',
          userId: 'user-456',
          status: 'ready',
          missingItems: <String>[],
          computedAt: DateTime.now(),
        );

        final result = await store.fetchReportReadiness(
          inspectionId: 'test-id',
          organizationId: 'wrong-org',
          userId: 'user-456',
        );

        expect(result, isNull);
      });
    });

    group('data persistence across operations', () {
      test('data persists across multiple create and fetch operations', () async {
        final input1 = <String, dynamic>{
          'id': 'id-1',
          'client_name': 'Client One',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };
        final input2 = <String, dynamic>{
          'id': 'id-2',
          'client_name': 'Client Two',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input1);
        await store.create(input2);

        final result1 = await store.fetchById(
          inspectionId: 'id-1',
          organizationId: 'org-123',
          userId: 'user-456',
        );
        final result2 = await store.fetchById(
          inspectionId: 'id-2',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result1!['client_name'], 'Client One');
        expect(result2!['client_name'], 'Client Two');
      });

      test('wizard progress updates persist and can be retrieved', () async {
        final input = <String, dynamic>{
          'id': 'wizard-test',
          'client_name': 'Wizard Test',
          'organization_id': 'org-123',
          'user_id': 'user-456',
        };

        await store.create(input);

        await store.updateWizardProgress(
          inspectionId: 'wizard-test',
          organizationId: 'org-123',
          userId: 'user-456',
          wizardLastStep: 5,
          wizardCompletion: {'step1': true, 'step2': true, 'step3': true},
          wizardBranchContext: {'has_roof_damage': true},
          wizardStatus: 'complete',
        );

        final progress = await store.fetchWizardProgress(
          inspectionId: 'wizard-test',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(progress, isNotNull);
        expect(progress!['wizard_last_step'], 5);
        expect(progress['wizard_completion'], {'step1': true, 'step2': true, 'step3': true});
        expect(progress['wizard_status'], 'complete');
      });
    });

    group('error handling for corrupted files', () {
      test('returns null for corrupted JSON file', () async {
        final inspectionsDir = Directory('${tempDir.path}/inspections');
        await inspectionsDir.create(recursive: true);

        final corruptFile = File('${inspectionsDir.path}/corrupt-id.json');
        await corruptFile.writeAsString('not valid json {{{');

        final result = await store.fetchById(
          inspectionId: 'corrupt-id',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('returns null for empty file', () async {
        final inspectionsDir = Directory('${tempDir.path}/inspections');
        await inspectionsDir.create(recursive: true);

        final emptyFile = File('${inspectionsDir.path}/empty-id.json');
        await emptyFile.writeAsString('');

        final result = await store.fetchById(
          inspectionId: 'empty-id',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('returns null for file with non-map JSON', () async {
        final inspectionsDir = Directory('${tempDir.path}/inspections');
        await inspectionsDir.create(recursive: true);

        final arrayFile = File('${inspectionsDir.path}/array-id.json');
        await arrayFile.writeAsString('[1, 2, 3]');

        final result = await store.fetchById(
          inspectionId: 'array-id',
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result, isNull);
      });

      test('listInProgressInspections skips corrupted files', () async {
        final inspectionsDir = Directory('${tempDir.path}/inspections');
        await inspectionsDir.create(recursive: true);

        // Create valid inspection
        final validInput = <String, dynamic>{
          'id': 'valid-id',
          'client_name': 'Valid',
          'organization_id': 'org-123',
          'user_id': 'user-456',
          'wizard_status': 'in_progress',
          'updated_at': DateTime.now().toIso8601String(),
        };
        await store.create(validInput);

        // Create corrupted file
        final corruptFile = File('${inspectionsDir.path}/corrupt-id.json');
        await corruptFile.writeAsString('invalid json');

        final result = await store.listInProgressInspections(
          organizationId: 'org-123',
          userId: 'user-456',
        );

        expect(result.length, 1);
        expect(result.first['id'], 'valid-id');
      });
    });
  });
}
