import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/inspection/presentation/dashboard_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, AuthRepository? repository})
    : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthRepository _repository;
  StreamSubscription<AuthSession?>? _subscription;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? AuthRepository.live();
    _isAuthenticated = _repository.currentSession != null;
    _subscription = _repository.authStateChanges.listen(_onAuthStateChange);
  }

  void _onAuthStateChange(AuthSession? session) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthenticated = session != null;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return DashboardPage();
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
