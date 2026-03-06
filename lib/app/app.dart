import 'package:flutter/material.dart';

import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../theme/app_theme.dart';
import 'routes.dart';

class InspectoBotApp extends StatelessWidget {
  const InspectoBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InspectoBot',
      theme: AppTheme.dark(),
      initialRoute: AppRoutes.authGate,
      routes: {
        AppRoutes.authGate: (context) => const AuthGate(),
        AppRoutes.dashboard: (context) => const AuthGate(),
        AppRoutes.signIn: (context) => const SignInPage(),
        AppRoutes.signUp: (context) => const SignUpPage(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
        AppRoutes.resetPassword: (context) => const ResetPasswordPage(),
        AppRoutes.inspectorIdentity: (context) => const AuthGate(),
      },
    );
  }
}

