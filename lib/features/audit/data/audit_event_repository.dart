import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/audit/domain/audit_event.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuditEventGateway {
  Future<Map<String, dynamic>> append(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });
}

class AuditEventRepository {
  AuditEventRepository(this._gateway);

  factory AuditEventRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return AuditEventRepository(
        SupabaseAuditEventGateway(SupabaseClientProvider.client),
      );
    }
    return AuditEventRepository(InMemoryAuditEventGateway());
  }

  final AuditEventGateway _gateway;

  Future<AuditEvent> append({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String eventType,
    required Map<String, dynamic> payload,
    DateTime? occurredAt,
  }) async {
    final now = DateTime.now().toUtc();
    final event = AuditEvent(
      id: SyncOperation.newId(),
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      eventType: eventType,
      occurredAt: (occurredAt ?? now).toUtc(),
      payload: Map<String, dynamic>.from(payload),
      createdAt: now,
    );
    final row = await _gateway.append(event.toJson());
    return AuditEvent.fromJson(row);
  }

  Future<List<AuditEvent>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final rows = await _gateway.listByInspection(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    return rows.map(AuditEvent.fromJson).toList(growable: false);
  }
}

class SupabaseAuditEventGateway implements AuditEventGateway {
  SupabaseAuditEventGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> append(Map<String, dynamic> payload) async {
    final result = await _client
        .from('inspection_audit_events')
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
        .from('inspection_audit_events')
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

class InMemoryAuditEventGateway implements AuditEventGateway {
  final List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> append(Map<String, dynamic> payload) async {
    _rows.add(Map<String, dynamic>.from(payload));
    return Map<String, dynamic>.from(payload);
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final rows = _rows
        .where(
          (row) =>
              row['inspection_id'] == inspectionId &&
              row['organization_id'] == organizationId &&
              row['user_id'] == userId,
        )
        .toList(growable: false);
    rows.sort(
      (a, b) => DateTime.parse(b['occurred_at'] as String)
          .compareTo(DateTime.parse(a['occurred_at'] as String)),
    );
    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
