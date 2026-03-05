class TenantContext {
  const TenantContext({required this.userId, required this.organizationId});

  final String userId;
  final String organizationId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TenantContext &&
            other.userId == userId &&
            other.organizationId == organizationId;
  }

  @override
  int get hashCode => Object.hash(userId, organizationId);
}
