import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/auth_notifier.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/sign_in_page.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_widgets.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, AuthRepository? repository})
    : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  AuthRepository get _repository =>
      widget._repository ?? AuthRepository.live();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _repository.updatePassword(newPassword: _passwordController.text);
      if (!mounted) {
        return;
      }
      // Clear recovery flag so the router redirect no longer traps the user
      // on the reset-password route.
      GetIt.I<AuthNotifier>().clearRecovery();
      GetIt.I<NavigationService>().go(
        AppRoutes.signIn,
        extra: const SignInPageArgs(
          infoMessage: AppRoutes.resetPasswordSuccessMessage,
        ),
      );
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
      title: 'Reset Password',
      formKey: _formKey,
      fields: [
        AuthPasswordField(
          controller: _passwordController,
          label: 'New Password',
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
        ),
      ],
      feedbackBanner: _error != null
          ? ErrorBanner(message: _error!, type: ErrorBannerType.error)
          : null,
      submitButton: AppButton(
        label: 'Update Password',
        onPressed: _submit,
        isLoading: _submitting,
        loadingLabel: 'Updating...',
        variant: AppButtonVariant.filled,
      ),
    );
  }
}
