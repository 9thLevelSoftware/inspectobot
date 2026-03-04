import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/identity/data/inspector_profile_repository.dart';
import 'package:inspectobot/features/identity/domain/inspector_profile.dart';

void main() {
  test('upsert and load preserve org-scoped inspector profile', () async {
    final repository = InspectorProfileRepository(InMemoryInspectorProfileStore());
    const profile = InspectorProfile(
      organizationId: 'org-1',
      userId: 'user-1',
      licenseType: 'Florida Home Inspector',
      licenseNumber: 'HI-12345',
    );

    await repository.upsertProfile(profile);
    final loaded = await repository.loadProfile(
      organizationId: 'org-1',
      userId: 'user-1',
    );

    expect(loaded, isNotNull);
    expect(loaded!.licenseType, 'Florida Home Inspector');
    expect(loaded.licenseNumber, 'HI-12345');
  });

  test('profiles are isolated by organization and user', () async {
    final repository = InspectorProfileRepository(InMemoryInspectorProfileStore());

    await repository.upsertProfile(
      const InspectorProfile(
        organizationId: 'org-a',
        userId: 'user-a',
        licenseType: 'Type A',
        licenseNumber: 'A-1',
      ),
    );

    final missing = await repository.loadProfile(
      organizationId: 'org-b',
      userId: 'user-a',
    );
    expect(missing, isNull);
  });
}
