import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';

class SignInPageArgs {
  const SignInPageArgs({this.infoMessage});

  final String? infoMessage;
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, AuthRepository? repository, this.args})
    : _repository = repository;

  final AuthRepository? _repository;
  final SignInPageArgs? args;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;
  String? _infoMessage;

  AuthRepository get _repository => widget._repository ?? AuthRepository.live();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _infoMessage = widget.args?.infoMessage;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _infoMessage = null;
    });
    try {
      await _repository.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      GetIt.I<NavigationService>().go(AppRoutes.dashboard);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty || !trimmed.contains('@')) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if ((value ?? '').length < 8) {
                      return 'Password must be at least 8 characters.';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                if (_infoMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _infoMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(_submitting ? 'Signing In...' : 'Sign In'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _submitting
                ? null
                : () => GetIt.I<NavigationService>().go(AppRoutes.signUp),
            child: const Text('Create account'),
          ),
          TextButton(
            onPressed: _submitting
                ? null
                : () =>
                      GetIt.I<NavigationService>().go(AppRoutes.forgotPassword),
            child: const Text('Forgot password?'),
          ),
        ],
      ),
    );
  }
}
