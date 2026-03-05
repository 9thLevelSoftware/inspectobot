import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/features/auth/data/tenant_context_resolver.dart';

void main() {
  test('resolves tenant context from membership lookup', () async {
    final resolver = TenantContextResolver(
      membershipLookup: _FakeMembershipLookup({'user-1': 'org-1'}),
      allowDeterministicFallback: false,
    );

    final context = await resolver.resolveForUser('user-1');

    expect(context.userId, 'user-1');
    expect(context.organizationId, 'org-1');
  });

  test('throws when membership is missing and fallback is disabled', () async {
    final resolver = TenantContextResolver(
      membershipLookup: _FakeMembershipLookup(const {}),
      allowDeterministicFallback: false,
    );

    await expectLater(
      () => resolver.resolveForUser('user-2'),
      throwsA(isA<TenantContextResolutionFailure>()),
    );
  });

  test('returns deterministic fallback context when enabled', () async {
    final resolver = TenantContextResolver(
      fallbackOrganizations: const {'user-3': 'org-test'},
    );

    final context = await resolver.resolveForUser('user-3');

    expect(context.userId, 'user-3');
    expect(context.organizationId, 'org-test');
    expect(resolver.getCachedForUser('user-3')?.organizationId, 'org-test');
  });
}

class _FakeMembershipLookup implements TenantMembershipLookup {
  _FakeMembershipLookup(this._memberships);

  final Map<String, String> _memberships;

  @override
  Future<String?> findOrganizationIdForUser(String userId) async {
    return _memberships[userId];
  }
}
