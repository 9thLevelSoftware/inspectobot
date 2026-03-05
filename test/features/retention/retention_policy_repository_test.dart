import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/retention/data/retention_policy_repository.dart';

void main() {
  test('computeRetainUntil enforces minimum five-year floor', () {
    const repository = RetentionPolicyRepository();
    final retainUntil = repository.computeRetainUntil(
      createdAt: DateTime.utc(2026, 3, 5),
      organizationRetentionYears: 3,
    );

    expect(retainUntil, DateTime.utc(2031, 3, 5));
  });

  test('computeRetainUntil allows retention longer than minimum', () {
    const repository = RetentionPolicyRepository();
    final retainUntil = repository.computeRetainUntil(
      createdAt: DateTime.utc(2026, 3, 5),
      organizationRetentionYears: 8,
    );

    expect(retainUntil, DateTime.utc(2034, 3, 5));
  });

  test('validateRetainUntil rejects values below floor', () {
    const repository = RetentionPolicyRepository();

    expect(
      () => repository.validateRetainUntil(
        createdAt: DateTime.utc(2026, 3, 5),
        retainUntil: DateTime.utc(2028, 3, 5),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
