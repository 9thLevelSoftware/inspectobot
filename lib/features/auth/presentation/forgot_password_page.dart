import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_widgets.dart';

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

  AuthRepository get _repository =>
      widget._repository ?? AuthRepository.live();

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
    return AuthFormScaffold(
      title: 'Forgot Password',
      formKey: _formKey,
      fields: [
        AuthEmailField(
          controller: _emailController,
          textInputAction: TextInputAction.done,
        ),
      ],
      feedbackBanner: _error != null || _message != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  ErrorBanner(message: _error!, type: ErrorBannerType.error),
                if (_message != null)
                  ErrorBanner(
                    message: _message!,
                    type: ErrorBannerType.success,
                  ),
              ],
            )
          : null,
      submitButton: AppButton(
        label: 'Send Recovery Link',
        onPressed: _submit,
        isLoading: _submitting,
        loadingLabel: 'Sending...',
        variant: AppButtonVariant.filled,
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () =>
                    GetIt.I<NavigationService>().go(AppRoutes.resetPassword),
          child: const Text('Already have a recovery link? Reset password'),
        ),
        Text(
          'Check your email for the recovery link before proceeding.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
