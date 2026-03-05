import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/delivery/data/report_artifact_repository.dart';
import 'package:inspectobot/features/retention/data/retention_policy_repository.dart';

void main() {
  test('upsertGeneratedArtifact applies default five-year retention floor', () async {
    final repository = ReportArtifactRepository(
      InMemoryReportArtifactGateway(),
      retentionPolicyRepository: const RetentionPolicyRepository(),
    );
    final createdAt = DateTime.utc(2026, 3, 5, 12);

    final artifact = await repository.upsertGeneratedArtifact(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      storageBucket: 'report-artifacts-private',
      storagePath: 'org-1/user-1/reports/insp-1/report.pdf',
      fileName: 'report.pdf',
      contentType: 'application/pdf',
      sizeBytes: 1200,
      createdAt: createdAt,
    );

    expect(artifact.retainUntil, DateTime.utc(2031, 3, 5, 12));
  });

  test('upsertGeneratedArtifact accepts organization-level retention extensions', () async {
    final repository = ReportArtifactRepository(InMemoryReportArtifactGateway());

    final artifact = await repository.upsertGeneratedArtifact(
      inspectionId: 'insp-2',
      organizationId: 'org-1',
      userId: 'user-1',
      storageBucket: 'report-artifacts-private',
      storagePath: 'org-1/user-1/reports/insp-2/report.pdf',
      fileName: 'report.pdf',
      contentType: 'application/pdf',
      sizeBytes: 1200,
      createdAt: DateTime.utc(2026, 3, 5),
      organizationRetentionYears: 7,
    );

    expect(artifact.retainUntil, DateTime.utc(2033, 3, 5));
  });
}
