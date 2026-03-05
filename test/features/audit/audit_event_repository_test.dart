import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/audit/data/audit_event_repository.dart';

void main() {
  test('append and listByInspection preserve immutable timeline order', () async {
    final repository = AuditEventRepository(InMemoryAuditEventGateway());

    await repository.append(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      eventType: 'inspection_progress_updated',
      occurredAt: DateTime.utc(2026, 3, 5, 10, 10),
      payload: const <String, dynamic>{'step_index': 1},
    );
    await repository.append(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
      eventType: 'signature_persisted',
      occurredAt: DateTime.utc(2026, 3, 5, 10, 30),
      payload: const <String, dynamic>{'payload_hash': 'hash-1'},
    );

    final events = await repository.listByInspection(
      inspectionId: 'insp-1',
      organizationId: 'org-1',
      userId: 'user-1',
    );

    expect(events, hasLength(2));
    expect(events.first.eventType, 'signature_persisted');
    expect(events.last.eventType, 'inspection_progress_updated');
    expect(events.first.payload['payload_hash'], 'hash-1');
  });

  test('listByInspection is tenant scoped', () async {
    final repository = AuditEventRepository(InMemoryAuditEventGateway());

    await repository.append(
      inspectionId: 'insp-2',
      organizationId: 'org-1',
      userId: 'user-1',
      eventType: 'inspection_progress_updated',
      payload: const <String, dynamic>{'step_index': 1},
    );
    await repository.append(
      inspectionId: 'insp-2',
      organizationId: 'org-2',
      userId: 'user-1',
      eventType: 'inspection_progress_updated',
      payload: const <String, dynamic>{'step_index': 2},
    );

    final events = await repository.listByInspection(
      inspectionId: 'insp-2',
      organizationId: 'org-1',
      userId: 'user-1',
    );

    expect(events, hasLength(1));
    expect(events.single.payload['step_index'], 1);
  });
}
