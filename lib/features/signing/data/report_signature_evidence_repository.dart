import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/sync/sync_operation.dart';
import 'package:inspectobot/features/signing/domain/report_signature_evidence.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReportSignatureEvidenceGateway {
  Future<Map<String, dynamic>> upsert(Map<String, dynamic> payload);

  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  });
}

class ReportSignatureEvidenceRepository {
  ReportSignatureEvidenceRepository(this._gateway, {AuditEventRepository? auditRepository})
      : _auditRepository = auditRepository;

  factory ReportSignatureEvidenceRepository.live() {
    if (SupabaseClientProvider.isConfigured) {
      return ReportSignatureEvidenceRepository(
        SupabaseReportSignatureEvidenceGateway(SupabaseClientProvider.client),
        auditRepository: AuditEventRepository.live(),
      );
    }
    return ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
      auditRepository: AuditEventRepository.live(),
    );
  }

  final ReportSignatureEvidenceGateway _gateway;
  final AuditEventRepository? _auditRepository;

  Future<ReportSignatureEvidence> persist({
    required PdfGenerationInput input,
    required String signerRole,
    required String signatureHash,
    required ReportSignatureAttribution attribution,
    DateTime? signedAt,
  }) async {
    final now = DateTime.now().toUtc();
    final evidence = ReportSignatureEvidence(
      id: SyncOperation.newId(),
      inspectionId: input.inspectionId,
      organizationId: input.organizationId,
      userId: input.userId,
      signerRole: signerRole,
      signedAt: (signedAt ?? now).toUtc(),
      signatureHash: signatureHash,
      payloadHash: computePayloadHash(input),
      attribution: attribution,
      createdAt: now,
    );
    final stored = await _gateway.upsert(evidence.toJson());
    final saved = ReportSignatureEvidence.fromJson(stored);
    if (_auditRepository != null) {
      await _auditRepository.append(
        inspectionId: saved.inspectionId,
        organizationId: saved.organizationId,
        userId: saved.userId,
        eventType: 'signature_persisted',
        payload: <String, dynamic>{
          'signature_evidence_id': saved.id,
          'payload_hash': saved.payloadHash,
          'signature_hash': saved.signatureHash,
          'signer_role': saved.signerRole,
        },
        occurredAt: saved.signedAt,
      );
    }
    return saved;
  }

  Future<List<ReportSignatureEvidence>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final rows = await _gateway.listByInspection(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
    );
    return rows.map(ReportSignatureEvidence.fromJson).toList(growable: false);
  }

  static String computePayloadHash(PdfGenerationInput input) {
    final canonicalPayload = jsonEncode(input.toCanonicalPayload());
    return sha256.convert(utf8.encode(canonicalPayload)).toString();
  }
}

class SupabaseReportSignatureEvidenceGateway
    implements ReportSignatureEvidenceGateway {
  SupabaseReportSignatureEvidenceGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    final result = await _client
        .from('report_signature_evidence')
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
        .from('report_signature_evidence')
        .upsert(
          payload,
          onConflict: 'inspection_id,payload_hash,signer_role',
        )
        .select()
        .single();
    return Map<String, dynamic>.from(result);
  }
}

class InMemoryReportSignatureEvidenceGateway
    implements ReportSignatureEvidenceGateway {
  final Map<String, Map<String, dynamic>> _records =
      <String, Map<String, dynamic>>{};

  String _key(String inspectionId, String payloadHash, String signerRole) {
    return '$inspectionId::$payloadHash::$signerRole';
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return _records.values
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
      payload['payload_hash'] as String,
      payload['signer_role'] as String,
    );
    _records[key] = Map<String, dynamic>.from(payload);
    return Map<String, dynamic>.from(_records[key]!);
  }
}
