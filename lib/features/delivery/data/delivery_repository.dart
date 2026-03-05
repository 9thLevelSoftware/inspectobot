import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/delivery/domain/delivery_action.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DeliveryActionGateway {
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });
}

class DeliveryRepository {
  DeliveryRepository(this._gateway);

  factory DeliveryRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return DeliveryRepository(
        SupabaseDeliveryActionGateway(SupabaseClientProvider.client),
      );
    }
    return DeliveryRepository(InMemoryDeliveryActionGateway());
  }

  final DeliveryActionGateway _gateway;

  Future<DeliveryAction> recordAction({
    required String artifactId,
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String actionType,
    required String channel,
    String? correlationId,
    required Map<String, dynamic> payload,
    DateTime? occurredAt,
  }) async {
    final action = DeliveryAction(
      id: SyncOperation.newId(),
      artifactId: artifactId,
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      actionType: actionType,
      channel: channel,
      correlationId: correlationId,
      payload: payload,
      occurredAt: (occurredAt ?? DateTime.now().toUtc()).toUtc(),
    );
    final row = await _gateway.insert(action.toJson());
    return DeliveryAction.fromJson(row);
  }

  Future<List<DeliveryAction>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final rows = await _gateway.listByInspection(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    return rows.map(DeliveryAction.fromJson).toList(growable: false);
  }
}

class SupabaseDeliveryActionGateway implements DeliveryActionGateway {
  SupabaseDeliveryActionGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload) async {
    final result = await _client
        .from('report_delivery_actions')
        .insert(payload)
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('report_delivery_actions')
        .select()
        .eq('inspection_id', inspectionId)
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .order('occurred_at', ascending: false);
    return (result as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }
}

class InMemoryDeliveryActionGateway implements DeliveryActionGateway {
  final List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> payload) async {
    _rows.add(Map<String, dynamic>.from(payload));
    return Map<String, dynamic>.from(payload);
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return _rows
        .where(
          (row) =>
              row['inspection_id'] == inspectionId &&
              row['organization_id'] == organizationId &&
              row['user_id'] == userId,
        )
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
