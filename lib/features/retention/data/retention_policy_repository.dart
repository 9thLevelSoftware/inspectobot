import 'package:inspectobot/features/retention/domain/retention_policy.dart';

class RetentionPolicyRepository {
  const RetentionPolicyRepository();

  DateTime computeRetainUntil({
    required DateTime createdAt,
    int? organizationRetentionYears,
  }) {
    final years = _resolveYears(organizationRetentionYears);
    final utcCreated = createdAt.toUtc();
    return DateTime.utc(
      utcCreated.year + years,
      utcCreated.month,
      utcCreated.day,
      utcCreated.hour,
      utcCreated.minute,
      utcCreated.second,
      utcCreated.millisecond,
      utcCreated.microsecond,
    );
  }

  void validateRetainUntil({
    required DateTime createdAt,
    required DateTime retainUntil,
  }) {
    final floor = computeRetainUntil(createdAt: createdAt);
    if (retainUntil.toUtc().isBefore(floor)) {
      throw ArgumentError(
        'Retention policy cannot be lower than ${RetentionPolicy.minimumYears} years.',
      );
    }
  }

  int _resolveYears(int? organizationRetentionYears) {
    if (organizationRetentionYears == null) {
      return RetentionPolicy.minimumYears;
    }
    return organizationRetentionYears < RetentionPolicy.minimumYears
        ? RetentionPolicy.minimumYears
        : organizationRetentionYears;
  }
}
