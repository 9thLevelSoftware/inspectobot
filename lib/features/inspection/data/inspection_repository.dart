import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  InspectionRepository(this._store);

  factory InspectionRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return InspectionRepository(
        SupabaseInspectionStore(SupabaseClientProvider.client),
      );
    }
    return InspectionRepository(InMemoryInspectionStore());
  }

  final InspectionStore _store;

  Future<InspectionSetup> createInspection(InspectionSetup setup) async {
    _validate(setup);
    final created = await _store.create(setup.toJson());
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
    final payload = await _store.updateWizardProgress(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      wizardLastStep: snapshot.lastStepIndex,
      wizardCompletion: snapshot.completion,
      wizardBranchContext: snapshot.branchContext,
      wizardStatus: _encodeStatus(snapshot.status),
    );
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

  return WizardProgressSnapshot(
    lastStepIndex: lastStepRaw is int ? lastStepRaw : 0,
    completion: completion,
    branchContext: branchContext,
    status: _decodeStatus(json['wizard_status'] as String?),
  );
}

class SupabaseInspectionStore implements InspectionStore {
  SupabaseInspectionStore(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final result = await _client
        .from('inspections')
        .insert(inspectionJson)
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
    final result = await _client
        .from('inspections')
        .update({
          'wizard_last_step': wizardLastStep,
          'wizard_completion': wizardCompletion,
          'wizard_branch_context': wizardBranchContext,
          'wizard_status': wizardStatus,
        })
        .eq('id', inspectionId)
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
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
}

class InMemoryInspectionStore implements InspectionStore {
  final Map<String, Map<String, dynamic>> _inspections = {};

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final id = (inspectionJson['id'] as String?) ??
        DateTime.now().microsecondsSinceEpoch.toString();
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
}
