class RetentionPolicy {
  const RetentionPolicy({
    required this.organizationId,
    required this.userId,
    required this.years,
  });

  static const int minimumYears = 5;

  final String organizationId;
  final String userId;
  final int years;
}
