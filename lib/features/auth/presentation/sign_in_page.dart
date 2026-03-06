import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:inspectobot/app/navigation_service.dart';
import 'package:inspectobot/app/routes.dart';
import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/auth/presentation/widgets/auth_widgets.dart';

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

  AuthRepository get _repository =>
      widget._repository ?? AuthRepository.live();

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
    return AuthFormScaffold(
      title: 'Sign In',
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
      feedbackBanner: _error != null || _infoMessage != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  ErrorBanner(message: _error!, type: ErrorBannerType.error),
                if (_infoMessage != null)
                  ErrorBanner(
                    message: _infoMessage!,
                    type: ErrorBannerType.info,
                  ),
              ],
            )
          : null,
      submitButton: AppButton(
        label: 'Sign In',
        onPressed: _submit,
        isLoading: _submitting,
        loadingLabel: 'Signing In...',
        variant: AppButtonVariant.filled,
      ),
      actions: [
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
    );
  }
}
