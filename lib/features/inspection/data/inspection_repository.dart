import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/form_requirements.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/features/inspection/domain/report_readiness.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/sync/sync_outbox_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Type alias for directory provider functions (used for testing).
typedef DirectoryProvider = Future<Directory> Function();

abstract class InspectionStore {
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson);

  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });

  Future<Map<String, dynamic>> updateWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required int wizardLastStep,
    required Map<String, bool> wizardCompletion,
    required Map<String, dynamic> wizardBranchContext,
    required String wizardStatus,
  });

  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });

  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  });

  Future<Map<String, dynamic>> upsertReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String status,
    required List<String> missingItems,
    required DateTime computedAt,
  });

  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });
}

class InspectionWizardProgress {
  const InspectionWizardProgress({
    required this.inspectionId,
    required this.organizationId,
    required this.userId,
    required this.enabledForms,
    required this.clientName,
    required this.propertyAddress,
    required this.snapshot,
  });

  final String inspectionId;
  final String organizationId;
  final String userId;
  final Set<FormType> enabledForms;
  final String clientName;
  final String propertyAddress;
  final WizardProgressSnapshot snapshot;

  factory InspectionWizardProgress.fromJson(Map<String, dynamic> json) {
    final forms = (json['forms_enabled'] as List<dynamic>? ?? const <dynamic>[])
        .cast<String>();
    return InspectionWizardProgress(
      inspectionId: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      enabledForms: FormType.fromCodes(forms),
      clientName: (json['client_name'] as String?) ?? 'Inspection',
      propertyAddress: (json['property_address'] as String?) ?? '',
      snapshot: _decodeSnapshot(json),
    );
  }
}

class InspectionRepository {
  InspectionRepository(
    this._store, {
    SyncOutboxStore? outboxStore,
    bool enqueueSyncOperations = false,
    AuditEventRepository? auditRepository,
  })  : _outboxStore = outboxStore,
        _enqueueSyncOperations = enqueueSyncOperations,
        _auditRepository = auditRepository;

  factory InspectionRepository.live() {
    final localStore = FileBasedInspectionStore();
    final remoteStore = SupabaseClientProvider.isConfigured
        ? SupabaseInspectionStore(SupabaseClientProvider.client)
        : null;
    return InspectionRepository(
      OfflineFirstInspectionStore(
        localStore: localStore,
        remoteStore: remoteStore,
      ),
      outboxStore: SyncOutboxStore(),
      enqueueSyncOperations: true,
      auditRepository: AuditEventRepository.live(),
    );
  }

  final InspectionStore _store;
  final SyncOutboxStore? _outboxStore;
  final bool _enqueueSyncOperations;
  final AuditEventRepository? _auditRepository;

  Future<InspectionSetup> createInspection(InspectionSetup setup) async {
    _validate(setup);
    final created = await _store.create(setup.toJson());
    await _enqueueInspectionUpsert(InspectionSetup.fromJson(created));
    return InspectionSetup.fromJson(created);
  }

  Future<InspectionSetup?> fetchInspectionById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _store.fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (result == null) {
      return null;
    }
    return InspectionSetup.fromJson(result);
  }

  Future<InspectionWizardProgress> updateWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required WizardProgressSnapshot snapshot,
  }) async {
    final normalizedBranchContext = _normalizeWizardBranchContext(
      snapshot.branchContext,
    );
    final setup = await fetchInspectionById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    final payload = await _store.updateWizardProgress(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      wizardLastStep: snapshot.lastStepIndex,
      wizardCompletion: snapshot.completion,
      wizardBranchContext: normalizedBranchContext,
      wizardStatus: _encodeStatus(snapshot.status),
    );
    if (_auditRepository != null) {
      await _auditRepository.append(
        inspectionId: inspectionId,
        organizationId: organizationId,
        userId: userId,
        eventType: 'inspection_progress_updated',
        payload: <String, dynamic>{
          'step_index': snapshot.lastStepIndex,
          'status': _encodeStatus(snapshot.status),
          'completion_count':
              snapshot.completion.values.where((value) => value).length,
          'correlation_id': 'wizard_progress::$inspectionId::${DateTime.now().toUtc().millisecondsSinceEpoch}',
        },
      );
    }
    if (setup != null) {
      await _enqueueWizardProgressUpsert(
        setup: setup,
        snapshot: snapshot.copyWith(branchContext: normalizedBranchContext),
      );
    }
    return InspectionWizardProgress.fromJson(payload);
  }

  Future<InspectionWizardProgress?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final payload = await _store.fetchWizardProgress(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (payload == null) {
      return null;
    }
    return InspectionWizardProgress.fromJson(payload);
  }

  Future<ReportReadiness> upsertReportReadiness(ReportReadiness readiness) async {
    final payload = await _store.upsertReportReadiness(
      inspectionId: readiness.inspectionId,
      organizationId: readiness.organizationId,
      userId: readiness.userId,
      status: readiness.status.name,
      missingItems: readiness.missingItems,
      computedAt: readiness.computedAt,
    );
    return ReportReadiness.fromJson(payload);
  }

  Future<ReportReadiness?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final payload = await _store.fetchReportReadiness(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (payload == null) {
      return null;
    }
    return ReportReadiness.fromJson(payload);
  }

  Future<void> _enqueueInspectionUpsert(InspectionSetup setup) async {
    if (!_enqueueSyncOperations || _outboxStore == null) {
      return;
    }
    await _outboxStore.enqueue(
      SyncOperation(
        operationId: SyncOperation.newId(),
        type: SyncOperationType.inspectionUpsert,
        aggregateId: setup.id,
        organizationId: setup.organizationId,
        userId: setup.userId,
        payload: setup.toJson(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
      replaceWhere: (existing) {
        return existing.type == SyncOperationType.inspectionUpsert &&
            existing.aggregateId == setup.id;
      },
    );
  }

  Future<void> _enqueueWizardProgressUpsert({
    required InspectionSetup setup,
    required WizardProgressSnapshot snapshot,
  }) async {
    if (!_enqueueSyncOperations || _outboxStore == null) {
      return;
    }
    final dependencyOperationId = await _resolveInspectionDependency(setup);
    await _outboxStore.enqueue(
      SyncOperation(
        operationId: SyncOperation.newId(),
        type: SyncOperationType.wizardProgressUpsert,
        aggregateId: setup.id,
        organizationId: setup.organizationId,
        userId: setup.userId,
        payload: <String, dynamic>{
          'inspection_id': setup.id,
          'organization_id': setup.organizationId,
          'user_id': setup.userId,
          'wizard_last_step': snapshot.lastStepIndex,
          'wizard_completion': snapshot.completion,
          'wizard_branch_context': snapshot.branchContext,
          'wizard_status': _encodeStatus(snapshot.status),
        },
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        dependencyOperationId: dependencyOperationId,
      ),
      replaceWhere: (existing) {
        return existing.type == SyncOperationType.wizardProgressUpsert &&
            existing.aggregateId == setup.id;
      },
    );
  }

  Future<String?> _resolveInspectionDependency(InspectionSetup setup) async {
    if (_outboxStore == null) {
      return null;
    }
    final operations = await _outboxStore.listAll();
    final inspectionOps = operations
        .where(
          (operation) =>
              operation.type == SyncOperationType.inspectionUpsert &&
              operation.aggregateId == setup.id &&
              operation.organizationId == setup.organizationId &&
              operation.userId == setup.userId &&
              operation.status != SyncOperationStatus.completed,
        )
        .toList(growable: false);
    if (inspectionOps.isEmpty) {
      return null;
    }
    inspectionOps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return inspectionOps.first.operationId;
  }

  Future<List<InspectionWizardProgress>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    final payload = await _store.listInProgressInspections(
      organizationId: organizationId,
      userId: userId,
    );
    return payload
        .map(InspectionWizardProgress.fromJson)
        .toList(growable: false);
  }

  void _validate(InspectionSetup setup) {
    if (setup.clientName.trim().isEmpty ||
        setup.clientEmail.trim().isEmpty ||
        setup.clientPhone.trim().isEmpty ||
        setup.propertyAddress.trim().isEmpty) {
      throw ArgumentError('Client and property setup fields are required.');
    }
    if (setup.enabledForms.isEmpty) {
      throw ArgumentError('Select at least one inspection form.');
    }
    final currentYear = DateTime.now().year + 1;
    if (setup.yearBuilt < 1800 || setup.yearBuilt > currentYear) {
      throw ArgumentError('Year built must be between 1800 and $currentYear.');
    }
    final latestAllowedDate = DateTime.now().add(const Duration(days: 365));
    if (setup.inspectionDate.isAfter(latestAllowedDate)) {
      throw ArgumentError('Inspection date is outside the accepted range.');
    }
  }
}

String _encodeStatus(WizardProgressStatus status) {
  return status == WizardProgressStatus.complete ? 'complete' : 'in_progress';
}

WizardProgressStatus _decodeStatus(String? statusRaw) {
  return statusRaw == 'complete'
      ? WizardProgressStatus.complete
      : WizardProgressStatus.inProgress;
}

WizardProgressSnapshot _decodeSnapshot(Map<String, dynamic> json) {
  final lastStepRaw = json['wizard_last_step'];
  final completionRaw = json['wizard_completion'];
  final branchContextRaw = json['wizard_branch_context'];

  final completion = <String, bool>{};
  if (completionRaw is Map) {
    completionRaw.forEach((key, value) {
      if (key is String && value is bool) {
        completion[key] = value;
      }
    });
  }

  final branchContext = <String, dynamic>{};
  if (branchContextRaw is Map) {
    branchContextRaw.forEach((key, value) {
      if (key is String) {
        branchContext[key] = value;
      }
    });
  }

  final normalizedBranchContext = _normalizeWizardBranchContext(branchContext);

  return WizardProgressSnapshot(
    lastStepIndex: lastStepRaw is int ? lastStepRaw : 0,
    completion: completion,
    branchContext: normalizedBranchContext,
    status: _decodeStatus(json['wizard_status'] as String?),
  );
}

const String _enabledFormsBranchContextKey = 'enabled_forms';

Map<String, dynamic> _normalizeWizardBranchContext(Map<String, dynamic> input) {
  final normalized = <String, dynamic>{};

  for (final key in FormRequirements.canonicalBranchFlags) {
    final value = input[key];
    if (value is bool) {
      normalized[key] = value;
    }
  }

  final enabledFormsValue = input[_enabledFormsBranchContextKey];
  if (enabledFormsValue is List) {
    normalized[_enabledFormsBranchContextKey] = enabledFormsValue
        .whereType<String>()
        .toList(growable: false);
  }

  return normalized;
}

class SupabaseInspectionStore implements InspectionStore {
  SupabaseInspectionStore(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final result = await _client
        .from('inspections')
        .upsert(inspectionJson, onConflict: 'id')
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('inspections')
        .select()
        .eq('id', inspectionId)
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .maybeSingle();
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
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
    final current = await fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (current == null) {
      throw StateError('Inspection not found for wizard progress update.');
    }
    final merged = Map<String, dynamic>.from(current)
      ..['wizard_last_step'] = wizardLastStep
      ..['wizard_completion'] = wizardCompletion
      ..['wizard_branch_context'] = wizardBranchContext
      ..['wizard_status'] = wizardStatus;

    final result = await _client
        .from('inspections')
        .upsert(merged, onConflict: 'id')
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('inspections')
        .select()
        .eq('id', inspectionId)
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .maybeSingle();
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('inspections')
        .select()
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .eq('wizard_status', 'in_progress')
        .order('updated_at', ascending: false);
    return (result as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('report_readiness')
        .select()
        .eq('inspection_id', inspectionId)
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .maybeSingle();
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
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
    final result = await _client
        .from('report_readiness')
        .upsert(<String, dynamic>{
          'inspection_id': inspectionId,
          'organization_id': organizationId,
          'user_id': userId,
          'status': status,
          'missing_items': missingItems,
          'computed_at': computedAt.toIso8601String(),
        }, onConflict: 'inspection_id')
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }
}

class InMemoryInspectionStore implements InspectionStore {
  final Map<String, Map<String, dynamic>> _inspections = {};
  final Map<String, Map<String, dynamic>> _reportReadiness = {};

  String _readinessKey(String inspectionId, String organizationId, String userId) {
    return '$inspectionId::$organizationId::$userId';
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final id = (inspectionJson['id'] as String?) ?? SyncOperation.newId();
    final payload = Map<String, dynamic>.from(inspectionJson)
      ..['id'] = id
      ..putIfAbsent('wizard_last_step', () => 0)
      ..putIfAbsent('wizard_completion', () => <String, bool>{})
      ..putIfAbsent('wizard_branch_context', () => <String, dynamic>{})
      ..putIfAbsent('wizard_status', () => 'in_progress');
    _inspections[id] = payload;
    return payload;
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final inspection = _inspections[inspectionId];
    if (inspection == null) {
      return null;
    }
    if (inspection['organization_id'] != organizationId ||
        inspection['user_id'] != userId) {
      return null;
    }
    return inspection;
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
    final inspection = await fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (inspection == null) {
      throw StateError('Inspection not found for wizard progress update.');
    }
    inspection['wizard_last_step'] = wizardLastStep;
    inspection['wizard_completion'] = Map<String, bool>.from(wizardCompletion);
    inspection['wizard_branch_context'] = Map<String, dynamic>.from(
      wizardBranchContext,
    );
    inspection['wizard_status'] = wizardStatus;
    return inspection;
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    return fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    return _inspections.values
        .where(
          (inspection) =>
              inspection['organization_id'] == organizationId &&
              inspection['user_id'] == userId &&
              inspection['wizard_status'] == 'in_progress',
        )
        .map((inspection) => Map<String, dynamic>.from(inspection))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return _reportReadiness[_readinessKey(inspectionId, organizationId, userId)];
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
    final payload = <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status,
      'missing_items': List<String>.from(missingItems),
      'computed_at': computedAt.toIso8601String(),
    };
    _reportReadiness[_readinessKey(inspectionId, organizationId, userId)] = payload;
    return payload;
  }
}

/// File-based implementation of [InspectionStore] that persists inspections
/// as JSON files in the application's documents directory.
/// 
/// File structure: `inspections/{inspectionId}.json`
/// 
/// Report readiness is stored separately: `inspections/readiness/{inspectionId}.json`
class FileBasedInspectionStore implements InspectionStore {
  FileBasedInspectionStore({DirectoryProvider? directoryProvider})
      : _directoryProvider = directoryProvider ?? getApplicationDocumentsDirectory;

  final DirectoryProvider _directoryProvider;

  Future<Directory> _inspectionsDirectory() async {
    final dir = await _directoryProvider();
    final inspectionsDir = Directory('${dir.path}/inspections');
    await inspectionsDir.create(recursive: true);
    return inspectionsDir;
  }

  Future<Directory> _readinessDirectory() async {
    final dir = await _directoryProvider();
    final readinessDir = Directory('${dir.path}/inspections/readiness');
    await readinessDir.create(recursive: true);
    return readinessDir;
  }

  Future<File> _inspectionFile(String inspectionId) async {
    final dir = await _inspectionsDirectory();
    return File('${dir.path}/$inspectionId.json');
  }

  Future<File> _readinessFile(String inspectionId) async {
    final dir = await _readinessDirectory();
    return File('${dir.path}/$inspectionId.json');
  }

  Future<Map<String, dynamic>?> _readInspectionFile(File file) async {
    if (!await file.exists()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[FileBasedInspectionStore] Invalid JSON structure in ${file.path}');
        return null;
      }
      return decoded;
    } on FormatException catch (e) {
      debugPrint('[FileBasedInspectionStore] JSON parse error in ${file.path}: $e');
      return null;
    } catch (e) {
      debugPrint('[FileBasedInspectionStore] Error reading ${file.path}: $e');
      return null;
    }
  }

  Future<void> _writeInspectionFile(String inspectionId, Map<String, dynamic> data) async {
    final file = await _inspectionFile(inspectionId);
    try {
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('[FileBasedInspectionStore] Error writing inspection $inspectionId: $e');
      rethrow;
    }
  }

  Future<void> _writeReadinessFile(String inspectionId, Map<String, dynamic> data) async {
    final file = await _readinessFile(inspectionId);
    try {
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (e) {
      debugPrint('[FileBasedInspectionStore] Error writing readiness $inspectionId: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final id = (inspectionJson['id'] as String?) ?? SyncOperation.newId();
    final payload = Map<String, dynamic>.from(inspectionJson)
      ..['id'] = id
      ..putIfAbsent('wizard_last_step', () => 0)
      ..putIfAbsent('wizard_completion', () => <String, bool>{})
      ..putIfAbsent('wizard_branch_context', () => <String, dynamic>{})
      ..putIfAbsent('wizard_status', () => 'in_progress');
    
    await _writeInspectionFile(id, payload);
    return payload;
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final file = await _inspectionFile(inspectionId);
    final inspection = await _readInspectionFile(file);
    if (inspection == null) {
      return null;
    }
    if (inspection['organization_id'] != organizationId ||
        inspection['user_id'] != userId) {
      return null;
    }
    return inspection;
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
    final file = await _inspectionFile(inspectionId);
    final inspection = await _readInspectionFile(file);
    if (inspection == null) {
      throw StateError('Inspection not found for wizard progress update: $inspectionId');
    }
    if (inspection['organization_id'] != organizationId ||
        inspection['user_id'] != userId) {
      throw StateError('Inspection not found for organization/user: $inspectionId');
    }
    
    final updated = Map<String, dynamic>.from(inspection)
      ..['wizard_last_step'] = wizardLastStep
      ..['wizard_completion'] = Map<String, bool>.from(wizardCompletion)
      ..['wizard_branch_context'] = Map<String, dynamic>.from(wizardBranchContext)
      ..['wizard_status'] = wizardStatus;
    
    await _writeInspectionFile(inspectionId, updated);
    return updated;
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    return fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    final inspectionsDir = await _inspectionsDirectory();
    if (!await inspectionsDir.exists()) {
      return [];
    }

    final results = <Map<String, dynamic>>[];
    try {
      final files = await inspectionsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();
      
      for (final file in files) {
        final inspection = await _readInspectionFile(file);
        if (inspection == null) continue;
        
        if (inspection['organization_id'] == organizationId &&
            inspection['user_id'] == userId &&
            inspection['wizard_status'] == 'in_progress') {
          results.add(inspection);
        }
      }
      
      // Sort by updated_at if available, otherwise by inspection date
      results.sort((a, b) {
        final aUpdated = a['updated_at'];
        final bUpdated = b['updated_at'];
        if (aUpdated is String && bUpdated is String) {
          return bUpdated.compareTo(aUpdated);
        }
        return 0;
      });
    } catch (e) {
      debugPrint('[FileBasedInspectionStore] Error listing in-progress inspections: $e');
    }
    
    return results;
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final file = await _readinessFile(inspectionId);
    final readiness = await _readInspectionFile(file);
    if (readiness == null) {
      return null;
    }
    if (readiness['inspection_id'] != inspectionId ||
        readiness['organization_id'] != organizationId ||
        readiness['user_id'] != userId) {
      return null;
    }
    return readiness;
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
    final payload = <String, dynamic>{
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'status': status,
      'missing_items': List<String>.from(missingItems),
      'computed_at': computedAt.toIso8601String(),
    };
    await _writeReadinessFile(inspectionId, payload);
    return payload;
  }
}

class OfflineFirstInspectionStore implements InspectionStore {
  OfflineFirstInspectionStore({
    required InspectionStore localStore,
    InspectionStore? remoteStore,
  })  : _localStore = localStore,
        _remoteStore = remoteStore;

  final InspectionStore _localStore;
  final InspectionStore? _remoteStore;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final local = await _localStore.create(inspectionJson);
    if (_remoteStore == null) {
      return local;
    }

    try {
      final remote = await _remoteStore.create(inspectionJson);
      await _localStore.create(remote);
      return remote;
    } catch (e) {
      debugPrint('[OfflineFirstInspectionStore] Remote create failed, returning local: $e');
      return local;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final local = await _localStore.fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (local != null) {
      return local;
    }
    if (_remoteStore == null) {
      return null;
    }

    try {
      final remote = await _remoteStore.fetchById(
        inspectionId: inspectionId,
        organizationId: organizationId,
        userId: userId,
      );
      if (remote != null) {
        await _localStore.create(remote);
      }
      return remote;
    } catch (e) {
      debugPrint('[OfflineFirstInspectionStore] Remote fetch failed: $e');
      return null;
    }
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
    final local = await _localStore.updateWizardProgress(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      wizardLastStep: wizardLastStep,
      wizardCompletion: wizardCompletion,
      wizardBranchContext: wizardBranchContext,
      wizardStatus: wizardStatus,
    );

    if (_remoteStore == null) {
      return local;
    }

    try {
      final remote = await _remoteStore.updateWizardProgress(
        inspectionId: inspectionId,
        organizationId: organizationId,
        userId: userId,
        wizardLastStep: wizardLastStep,
        wizardCompletion: wizardCompletion,
        wizardBranchContext: wizardBranchContext,
        wizardStatus: wizardStatus,
      );
      await _localStore.create(remote);
      return remote;
    } catch (e) {
      debugPrint('[OfflineFirstInspectionStore] Remote update failed, returning local: $e');
      return local;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchWizardProgress({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) {
    return fetchById(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listInProgressInspections({
    required String organizationId,
    required String userId,
  }) async {
    final localRows = await _localStore.listInProgressInspections(
      organizationId: organizationId,
      userId: userId,
    );
    if (_remoteStore == null) {
      return localRows;
    }

    try {
      final remoteRows = await _remoteStore.listInProgressInspections(
        organizationId: organizationId,
        userId: userId,
      );
      for (final row in remoteRows) {
        await _localStore.create(row);
      }
      return remoteRows;
    } catch (e) {
      debugPrint('[OfflineFirstInspectionStore] Remote list failed, returning local: $e');
      return localRows;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchReportReadiness({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final local = await _localStore.fetchReportReadiness(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    if (local != null || _remoteStore == null) {
      return local;
    }

    try {
      final remote = await _remoteStore.fetchReportReadiness(
        inspectionId: inspectionId,
        organizationId: organizationId,
        userId: userId,
      );
      if (remote != null) {
        await _localStore.upsertReportReadiness(
          inspectionId: inspectionId,
          organizationId: organizationId,
          userId: userId,
          status: remote['status'] as String,
          missingItems: List<String>.from(remote['missing_items'] as List<dynamic>),
          computedAt: DateTime.parse(remote['computed_at'] as String).toUtc(),
        );
      }
      return remote;
    } catch (e) {
      debugPrint('[OfflineFirstInspectionStore] Remote fetch readiness failed: $e');
      return local;
    }
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
    final local = await _localStore.upsertReportReadiness(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      status: status,
      missingItems: missingItems,
      computedAt: computedAt,
    );
    if (_remoteStore == null) {
      return local;
    }

    try {
      final remote = await _remoteStore.upsertReportReadiness(
        inspectionId: inspectionId,
        organizationId: organizationId,
        userId: userId,
        status: status,
        missingItems: missingItems,
        computedAt: computedAt,
      );
      await _localStore.upsertReportReadiness(
        inspectionId: inspectionId,
        organizationId: organizationId,
        userId: userId,
        status: remote['status'] as String,
        missingItems: List<String>.from(remote['missing_items'] as List<dynamic>),
        computedAt: DateTime.parse(remote['computed_at'] as String).toUtc(),
      );
      return remote;
    } catch (e) {
      debugPrint('[OfflineFirstInspectionStore] Remote upsert readiness failed, returning local: $e');
      return local;
    }
  }
}
