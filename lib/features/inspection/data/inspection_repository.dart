import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class InspectionStore {
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson);

  Future<Map<String, dynamic>?> fetchById({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });
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
}

class InMemoryInspectionStore implements InspectionStore {
  final Map<String, Map<String, dynamic>> _inspections = {};

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> inspectionJson) async {
    final id = (inspectionJson['id'] as String?) ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final payload = Map<String, dynamic>.from(inspectionJson)..['id'] = id;
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
}
