import 'package:flutter/material.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, AuthRepository? repository})
    : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  String? _message;
  String? _error;

  AuthRepository get _repository => widget._repository ?? AuthRepository.live();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _message = null;
    });
    try {
      await _repository.resetPasswordForEmail(
        email: _emailController.text,
        redirectTo: AppRoutes.recoveryCallbackUri,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Password reset email sent.';
      });
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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty || !trimmed.contains('@')) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Sending...' : 'Send Recovery Link'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: const TextStyle(color: Colors.green)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: _submitting
                ? null
                : () =>
                      Navigator.of(context).pushNamed(AppRoutes.resetPassword),
            child: const Text('Already have a recovery link? Reset password'),
          ),
        ],
      ),
    );
  }
}
