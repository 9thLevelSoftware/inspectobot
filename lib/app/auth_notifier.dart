import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

/// Manages authentication state for GoRouter redirect logic.
///
/// Replaces [AuthGate]'s stream subscription and conditional widget tree with
/// a [ChangeNotifier] that GoRouter's `refreshListenable` can observe.
///
/// Edge cases replicated from AuthGate:
/// 1. Dispose-safety via [_disposed] flag — prevents [notifyListeners] after
///    disposal.
/// 2. Double recovery prevention via [_isHandlingRecovery] — duplicate
///    `passwordRecovery` events are ignored.
/// 3. Recovery events skip tenant resolution — avoids unnecessary async work
///    during password reset flow.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._repository) {
    _session = _repository.currentSession;
    _isResolvingTenant = _session != null && _session!.tenantContext == null;
    _subscription = _repository.authStateChanges.listen(_onAuthStateChange);
    if (_isResolvingTenant) {
      unawaited(_resolveTenantContext());
    }
  }

  final AuthRepository _repository;
  StreamSubscription<AuthStateChange>? _subscription;

  AuthSession? _session;
  bool _isResolvingTenant = false;
  bool _isHandlingRecovery = false;
  bool _isRecovery = false;
  bool _disposed = false;
  int _resolveGeneration = 0;

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  /// The current auth session, or `null` if signed out.
  AuthSession? get session => _session;

  /// Whether the user is fully authenticated (session + tenant context).
  bool get isAuthenticated => _session?.tenantContext != null;

  /// Whether tenant context is being resolved asynchronously.
  bool get isResolvingTenant => _isResolvingTenant;

  /// Whether a password-recovery event is active.
  bool get isRecovery => _isRecovery;

  // ---------------------------------------------------------------------------
  // Auth state listener
  // ---------------------------------------------------------------------------

  void _onAuthStateChange(AuthStateChange change) {
    if (_disposed) return;

    if (change.event == AuthChangeEvent.passwordRecovery) {
      if (_isHandlingRecovery) return; // Edge case 2: duplicate prevention
      _isHandlingRecovery = true;
      _isRecovery = true;
      _session = change.session;
      _isResolvingTenant = false; // Edge case 3: skip tenant resolution
      _safeNotify();
      return;
    }

    final session = change.session;
    final requiresResolve = session != null && session.tenantContext == null;

    _resolveGeneration++; // Invalidate any in-flight tenant resolution
    _session = session;
    _isResolvingTenant = requiresResolve;
    _safeNotify();

    if (requiresResolve) {
      unawaited(_resolveTenantContext());
    }
  }

  // ---------------------------------------------------------------------------
  // Tenant resolution
  // ---------------------------------------------------------------------------

  Future<void> _resolveTenantContext() async {
    final gen = _resolveGeneration;
    final resolved = await _repository.resolveCurrentSession();
    if (_disposed) return; // Race condition guard
    // If a newer auth event arrived while we were resolving, discard this
    // stale result to avoid overwriting the current session.
    if (gen != _resolveGeneration) return;
    _session = resolved;
    _isResolvingTenant = false;
    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // Recovery helpers
  // ---------------------------------------------------------------------------

  /// Clear the recovery flag after the reset-password screen has been shown.
  /// Must be called by the router redirect or the reset-password page itself.
  void clearRecovery() {
    _isRecovery = false;
    _isHandlingRecovery = false;
    _safeNotify();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
