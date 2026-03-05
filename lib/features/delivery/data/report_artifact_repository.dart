import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/delivery/domain/report_artifact.dart';
import 'package:inspectobot/features/retention/data/retention_policy_repository.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReportArtifactGateway {
  Future<Map<String, dynamic>> upsert(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });
}

class ReportArtifactRepository {
  ReportArtifactRepository(
    this._gateway, {
    RetentionPolicyRepository? retentionPolicyRepository,
  }) : _retentionPolicyRepository =
            retentionPolicyRepository ?? const RetentionPolicyRepository();

  factory ReportArtifactRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return ReportArtifactRepository(
        SupabaseReportArtifactGateway(SupabaseClientProvider.client),
      );
    }
    return ReportArtifactRepository(InMemoryReportArtifactGateway());
  }

  final ReportArtifactGateway _gateway;
  final RetentionPolicyRepository _retentionPolicyRepository;

  Future<ReportArtifact> upsertGeneratedArtifact({
    required String inspectionId,
    required String organizationId,
    required String userId,
    required String storageBucket,
    required String storagePath,
    required String fileName,
    required String contentType,
    required int sizeBytes,
    required DateTime createdAt,
    int? organizationRetentionYears,
    String? payloadHash,
    String? signatureHash,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    final retainUntil = _retentionPolicyRepository.computeRetainUntil(
      createdAt: createdAt,
      organizationRetentionYears: organizationRetentionYears,
    );
    _retentionPolicyRepository.validateRetainUntil(
      createdAt: createdAt,
      retainUntil: retainUntil,
    );
    final now = DateTime.now().toUtc();
    final payload = <String, dynamic>{
      'id': SyncOperation.newId(),
      'inspection_id': inspectionId,
      'organization_id': organizationId,
      'user_id': userId,
      'storage_bucket': storageBucket,
      'storage_path': storagePath,
      'file_name': fileName,
      'content_type': contentType,
      'size_bytes': sizeBytes,
      'payload_hash': payloadHash,
      'signature_hash': signatureHash,
      'retain_until': retainUntil.toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': now.toIso8601String(),
      'metadata': metadata,
    };
    final row = await _gateway.upsert(payload);
    return ReportArtifact.fromJson(row);
  }

  Future<List<ReportArtifact>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final rows = await _gateway.listByInspection(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    return rows.map(ReportArtifact.fromJson).toList(growable: false);
  }
}

class SupabaseReportArtifactGateway implements ReportArtifactGateway {
  SupabaseReportArtifactGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('report_artifacts')
        .select()
        .eq('inspection_id', inspectionId)
        .eq('organization_id', organizationId)
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (result as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> upsert(Map<String, dynamic> payload) async {
    final result = await _client
        .from('report_artifacts')
        .upsert(payload, onConflict: 'inspection_id,storage_path')
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }
}

class InMemoryReportArtifactGateway implements ReportArtifactGateway {
  final Map<String, Map<String, dynamic>> _rows = <String, Map<String, dynamic>>{};

  String _key(String inspectionId, String storagePath) {
    return '$inspectionId::$storagePath';
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return _rows.values
        .where(
          (row) =>
              row['inspection_id'] == inspectionId &&
              row['organization_id'] == organizationId &&
              row['user_id'] == userId,
        )
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> upsert(Map<String, dynamic> payload) async {
    final key = _key(
      payload['inspection_id'] as String,
      payload['storage_path'] as String,
    );
    _rows[key] = Map<String, dynamic>.from(payload);
    return Map<String, dynamic>.from(_rows[key]!);
  }
}
