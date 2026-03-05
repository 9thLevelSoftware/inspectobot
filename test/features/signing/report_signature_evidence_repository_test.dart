import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/required_photo_category.dart';
import 'package:inspectobot/features/pdf/pdf_generation_input.dart';
import 'package:inspectobot/features/signing/data/report_signature_evidence_repository.dart';
import 'package:inspectobot/features/signing/domain/report_signature_evidence.dart';

void main() {
  PdfGenerationInput buildInput({
    String inspectionId = 'insp-1',
    String organizationId = 'org-1',
    String userId = 'user-1',
    String address = '123 Palm Ave',
  }) {
    return PdfGenerationInput(
      inspectionId: inspectionId,
      organizationId: organizationId,
      userId: userId,
      clientName: 'Jane Doe',
      propertyAddress: address,
      enabledForms: {FormType.fourPoint, FormType.windMitigation},
      capturedCategories: {
        RequiredPhotoCategory.exteriorFront,
        RequiredPhotoCategory.windRoofDeck,
      },
      wizardCompletion: const <String, bool>{
        'photo:exterior_front': true,
        'photo:wind_roof_deck': true,
      },
      branchContext: const <String, dynamic>{
        'wind_opening_document_required': true,
      },
    );
  }

  test('persist computes deterministic payload hash linkage from canonical input', () async {
    final repository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
    );

    final input = buildInput();
    final persisted = await repository.persist(
      input: input,
      signerRole: 'inspector',
      signatureHash: 'sig-hash-123',
      signedAt: DateTime.utc(2026, 3, 5, 12),
      attribution: const ReportSignatureAttribution(
        appVersion: '1.0.0+1',
        device: 'pixel-test',
        sessionId: 'session-1',
        network: 'wifi',
      ),
    );

    final expectedHash = sha256
        .convert(utf8.encode(jsonEncode(input.toCanonicalPayload())))
        .toString();
    expect(persisted.payloadHash, expectedHash);
    expect(persisted.signatureHash, 'sig-hash-123');
    expect(persisted.signerRole, 'inspector');
  });

  test('persist preserves SEC-02 metadata fields and attribution shape', () async {
    final repository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
    );

    final persisted = await repository.persist(
      input: buildInput(inspectionId: 'insp-2'),
      signerRole: 'inspector',
      signatureHash: 'sig-hash-xyz',
      signedAt: DateTime.utc(2026, 3, 5, 14, 22),
      attribution: const ReportSignatureAttribution(
        appVersion: null,
        device: null,
        sessionId: null,
        network: null,
      ),
    );

    expect(persisted.inspectionId, 'insp-2');
    expect(persisted.organizationId, 'org-1');
    expect(persisted.userId, 'user-1');
    expect(persisted.signedAt.toIso8601String(), '2026-03-05T14:22:00.000Z');
    expect(persisted.attribution.toJson().containsKey('app_version'), isTrue);
    expect(persisted.attribution.toJson().containsKey('session_id'), isTrue);
  });

  test('upsert uniqueness is keyed by inspection payload hash and signer role', () async {
    final repository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
    );
    final input = buildInput(inspectionId: 'insp-3');

    await repository.persist(
      input: input,
      signerRole: 'inspector',
      signatureHash: 'sig-first',
      attribution: const ReportSignatureAttribution(),
    );
    await repository.persist(
      input: input,
      signerRole: 'inspector',
      signatureHash: 'sig-second',
      attribution: const ReportSignatureAttribution(),
    );

    final records = await repository.listByInspection(
      inspectionId: 'insp-3',
      organizationId: 'org-1',
      userId: 'user-1',
    );
    expect(records, hasLength(1));
    expect(records.single.signatureHash, 'sig-second');
  });

  test('different payload versions keep separate evidence records', () async {
    final repository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
    );

    await repository.persist(
      input: buildInput(inspectionId: 'insp-4', address: '123 Palm Ave'),
      signerRole: 'inspector',
      signatureHash: 'sig-v1',
      attribution: const ReportSignatureAttribution(),
    );
    await repository.persist(
      input: buildInput(inspectionId: 'insp-4', address: '999 New Address'),
      signerRole: 'inspector',
      signatureHash: 'sig-v2',
      attribution: const ReportSignatureAttribution(),
    );

    final records = await repository.listByInspection(
      inspectionId: 'insp-4',
      organizationId: 'org-1',
      userId: 'user-1',
    );
    expect(records, hasLength(2));
    expect(records.map((row) => row.payloadHash).toSet(), hasLength(2));
  });

  test('persist appends immutable audit event with hash linkage', () async {
    final auditGateway = InMemoryAuditEventGateway();
    final repository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
      auditRepository: AuditEventRepository(auditGateway),
    );

    final persisted = await repository.persist(
      input: buildInput(inspectionId: 'insp-5'),
      signerRole: 'inspector',
      signatureHash: 'sig-hash-audit',
      attribution: const ReportSignatureAttribution(),
    );

    final events = await AuditEventRepository(auditGateway).listByInspection(
      inspectionId: 'insp-5',
      organizationId: 'org-1',
      userId: 'user-1',
    );
    expect(events, hasLength(1));
    expect(events.single.eventType, 'signature_persisted');
    expect(events.single.payload['payload_hash'], persisted.payloadHash);
  });

  test('persist fails closed when audit write fails', () async {
    final repository = ReportSignatureEvidenceRepository(
      InMemoryReportSignatureEvidenceGateway(),
      auditRepository: AuditEventRepository(_AlwaysFailAuditGateway()),
    );

    await expectLater(
      () => repository.persist(
        input: buildInput(inspectionId: 'insp-6'),
        signerRole: 'inspector',
        signatureHash: 'sig-hash-fail',
        attribution: const ReportSignatureAttribution(),
      ),
      throwsA(isA<StateError>()),
    );
  });
}

class _AlwaysFailAuditGateway implements AuditEventGateway {
  @override
  Future<Map<String, dynamic>> append(Map<String, dynamic> payload) async {
    throw StateError('audit write failed');
  }

  @override
  Future<List<Map<String, dynamic>>> listByInspection({
    required String inspectionId,
    required String organizationId,
    required String userId,
  }) async {
    return const <Map<String, dynamic>>[];
  }
}
