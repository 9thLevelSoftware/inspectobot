import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, AuthRepository? repository})
    : _repository = repository;

  final AuthRepository? _repository;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  AuthRepository get _repository =>
      widget._repository ?? AuthRepository.live();

  @override
  void dispose() {
    _emailController.dispose();
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
      await _repository.signUp(
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
    return AuthFormScaffold(
      title: 'Create Account',
      formKey: _formKey,
      fields: [
        AuthEmailField(
          controller: _emailController,
          textInputAction: TextInputAction.next,
        ),
        AuthPasswordField(
          controller: _passwordController,
          textInputAction: TextInputAction.done,
        ),
      ],
      feedbackBanner: _error != null
          ? ErrorBanner(message: _error!, type: ErrorBannerType.error)
          : null,
      submitButton: AppButton(
        label: 'Create Account',
        onPressed: _submit,
        isLoading: _submitting,
        loadingLabel: 'Creating Account...',
        variant: AppButtonVariant.filled,
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () =>
                    GetIt.I<NavigationService>().replace(AppRoutes.signIn),
          child: const Text('Already have an account? Sign in'),
        ),
      ],
    );
  }
}
