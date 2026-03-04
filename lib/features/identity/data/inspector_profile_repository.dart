import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class InspectorProfileStore {
  Future<Map<String, dynamic>?> fetch({
    required String organizationId,
    required String userId,
  });

  Future<void> upsert(Map<String, dynamic> profileJson);
}

class InspectorProfileRepository {
  InspectorProfileRepository(this._store);

  factory InspectorProfileRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return InspectorProfileRepository(
        SupabaseInspectorProfileStore(SupabaseClientProvider.client),
      );
    }
    return InspectorProfileRepository(InMemoryInspectorProfileStore());
  }

  final InspectorProfileStore _store;

  Future<InspectorProfile?> loadProfile({
    required String organizationId,
    required String userId,
  }) async {
    final data = await _store.fetch(
      organizationId: organizationId,
      userId: userId,
    );
    if (data == null) {
      return null;
    }
    return InspectorProfile.fromJson(data);
  }

  Future<void> upsertProfile(InspectorProfile profile) async {
    await _store.upsert(profile.toJson());
  }
}

class SupabaseInspectorProfileStore implements InspectorProfileStore {
  SupabaseInspectorProfileStore(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>?> fetch({
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('inspector_profiles')
        .select()
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .maybeSingle();
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<void> upsert(Map<String, dynamic> profileJson) {
    return _client.from('inspector_profiles').upsert(profileJson);
  }
}

class InMemoryInspectorProfileStore implements InspectorProfileStore {
  final Map<String, Map<String, dynamic>> _profiles = {};

  String _key(String organizationId, String userId) => '$organizationId::$userId';

  @override
  Future<Map<String, dynamic>?> fetch({
    required String organizationId,
    required String userId,
  }) async {
    return _profiles[_key(organizationId, userId)];
  }

  @override
  Future<void> upsert(Map<String, dynamic> profileJson) async {
    final organizationId = profileJson['organization_id'] as String;
    final userId = profileJson['user_id'] as String;
    _profiles[_key(organizationId, userId)] = profileJson;
  }
}
