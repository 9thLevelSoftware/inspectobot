import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    AuthRepository? repository,
    this.dashboardBuilder,
  }) : _repository = repository;

  final AuthRepository? _repository;
  final Widget Function(
    BuildContext context,
    String organizationId,
    String userId,
  )?
  dashboardBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthRepository _repository;
  StreamSubscription<AuthSession?>? _subscription;
  AuthSession? _session;
  bool _isResolvingTenantContext = false;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? AuthRepository.live();
    _session = _repository.currentSession;
    _isResolvingTenantContext =
        _session != null && _session!.tenantContext == null;
    _subscription = _repository.authStateChanges.listen(_onAuthStateChange);
    if (_isResolvingTenantContext) {
      unawaited(_resolveTenantContext());
    }
  }

  void _onAuthStateChange(AuthSession? session) {
    if (!mounted) {
      return;
    }
    final requiresResolve = session != null && session.tenantContext == null;
    setState(() {
      _session = session;
      _isResolvingTenantContext = requiresResolve;
    });
    if (requiresResolve) {
      unawaited(_resolveTenantContext());
    }
  }

  Future<void> _resolveTenantContext() async {
    final resolved = await _repository.resolveCurrentSession();
    if (!mounted) {
      return;
    }
    setState(() {
      _session = resolved;
      _isResolvingTenantContext = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenantContext = _session?.tenantContext;
    if (tenantContext != null) {
      final builder = widget.dashboardBuilder;
      if (builder != null) {
        return builder(
          context,
          tenantContext.organizationId,
          tenantContext.userId,
        );
      }
      return DashboardPage(
        organizationId: tenantContext.organizationId,
        userId: tenantContext.userId,
      );
    }
    if (_isResolvingTenantContext) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const _SignedOutShell();
  }
}

class _SignedOutShell extends StatelessWidget {
  const _SignedOutShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InspectoBot Access')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please sign in to continue your inspections.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/auth/sign-in');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
