import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/auth/domain/tenant_context.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TenantContextResolutionFailure implements Exception {
  TenantContextResolutionFailure(this.message);

  final String message;

  @override
  String toString() => 'TenantContextResolutionFailure: $message';
}

abstract class TenantMembershipLookup {
  Future<String?> findOrganizationIdForUser(String userId);
}

class SupabaseTenantMembershipLookup implements TenantMembershipLookup {
  SupabaseTenantMembershipLookup(this._client);

  final SupabaseClient _client;

  @override
  Future<String?> findOrganizationIdForUser(String userId) async {
    final row = await _client
        .from('organization_memberships')
        .select('organization_id')
        .eq('user_id', userId)
        .maybeSingle();

    return row?['organization_id'] as String?;
  }
}

class TenantContextResolver {
  TenantContextResolver({
    TenantMembershipLookup? membershipLookup,
    Map<String, String>? fallbackOrganizations,
    bool allowDeterministicFallback = true,
  }) : _membershipLookup = membershipLookup,
       _fallbackOrganizations = fallbackOrganizations ?? const {},
       _allowDeterministicFallback = allowDeterministicFallback;

  factory TenantContextResolver.live() {
    if (SupabaseClientProvider.isConfigured) {
      return TenantContextResolver(
        membershipLookup: SupabaseTenantMembershipLookup(
          SupabaseClientProvider.client,
        ),
        allowDeterministicFallback: false,
      );
    }
    return TenantContextResolver();
  }

  final TenantMembershipLookup? _membershipLookup;
  final Map<String, String> _fallbackOrganizations;
  final bool _allowDeterministicFallback;
  final Map<String, TenantContext> _cache = {};

  TenantContext? getCachedForUser(String userId) {
    return _cache[userId.trim()];
  }

  Future<TenantContext> resolveForUser(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw TenantContextResolutionFailure(
        'User id is required to resolve tenant context.',
      );
    }

    final cached = _cache[normalizedUserId];
    if (cached != null) {
      return cached;
    }

    if (_membershipLookup != null) {
      try {
        final organizationId = await _membershipLookup
            .findOrganizationIdForUser(normalizedUserId);
        if (organizationId != null && organizationId.isNotEmpty) {
          return _store(normalizedUserId, organizationId);
        }
      } catch (error) {
        if (!_allowDeterministicFallback) {
          throw TenantContextResolutionFailure(
            'Failed to resolve organization membership for user $normalizedUserId: $error',
          );
        }
      }
    }

    if (_allowDeterministicFallback) {
      return _store(
        normalizedUserId,
        _fallbackOrganizations[normalizedUserId] ??
            _buildDeterministicFallbackOrganizationId(normalizedUserId),
      );
    }

    throw TenantContextResolutionFailure(
      'No organization membership found for user $normalizedUserId.',
    );
  }

  TenantContext _store(String userId, String organizationId) {
    final context = TenantContext(
      userId: userId,
      organizationId: organizationId,
    );
    _cache[userId] = context;
    return context;
  }

  String _buildDeterministicFallbackOrganizationId(String userId) {
    final suffix = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
    return 'org-local-$suffix';
  }
}
