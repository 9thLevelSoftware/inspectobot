import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/inspection/data/inspection_repository.dart';
import 'package:inspectobot/features/inspection/domain/form_type.dart';
import 'package:inspectobot/features/inspection/domain/inspection_setup.dart';

void main() {
  InspectionSetup buildSetup({
    String id = 'insp-1',
    String organizationId = 'org-1',
    String userId = 'user-1',
    DateTime? inspectionDate,
    int yearBuilt = 2004,
    Set<FormType>? enabledForms,
  }) {
    return InspectionSetup(
      id: id,
      organizationId: organizationId,
      userId: userId,
      clientName: 'Jane Doe',
      clientEmail: 'jane@example.com',
      clientPhone: '555-0100',
      propertyAddress: '123 Palm Ave, Tampa, FL',
      inspectionDate: inspectionDate ?? DateTime.utc(2026, 3, 4),
      yearBuilt: yearBuilt,
      enabledForms: enabledForms ?? {FormType.fourPoint, FormType.windMitigation},
    );
  }

  test('create and fetch preserve required setup payload shape', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(buildSetup());

    expect(created.clientName, 'Jane Doe');
    expect(created.clientEmail, 'jane@example.com');
    expect(created.clientPhone, '555-0100');
    expect(created.propertyAddress, '123 Palm Ave, Tampa, FL');
    expect(created.yearBuilt, 2004);
    expect(created.inspectionDate.toIso8601String(), startsWith('2026-03-04'));

    final fetched = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
    );

    expect(fetched, isNotNull);
    expect(fetched!.id, created.id);
    expect(fetched.enabledForms, contains(FormType.fourPoint));
    expect(fetched.enabledForms, contains(FormType.windMitigation));
  });

  test('canonical form codes roundtrip through persistence mapping', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(
      buildSetup(enabledForms: {FormType.roofCondition}),
    );

    expect(created.enabledForms.single.code, 'roof_condition');
    expect(created.enabledForms.single.label, 'RCF-1 03-25');

    final fetched = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: created.userId,
    );
    expect(fetched!.enabledForms.single, FormType.roofCondition);
  });

  test('create rejects empty form selection', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());

    await expectLater(
      () => repository.createInspection(buildSetup(enabledForms: {})),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('create rejects invalid year built range', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());

    await expectLater(
      () => repository.createInspection(buildSetup(yearBuilt: 1700)),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('create rejects far future inspection date', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());

    await expectLater(
      () => repository.createInspection(
        buildSetup(inspectionDate: DateTime.now().add(const Duration(days: 450))),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('fetch is isolated by organization and user scope', () async {
    final repository = InspectionRepository(InMemoryInspectionStore());
    final created = await repository.createInspection(buildSetup());

    final wrongOrg = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: 'org-2',
      userId: created.userId,
    );
    final wrongUser = await repository.fetchInspectionById(
      inspectionId: created.id,
      organizationId: created.organizationId,
      userId: 'user-2',
    );

    expect(wrongOrg, isNull);
    expect(wrongUser, isNull);
  });
}
