import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_gate.dart';
import '../features/inspection/presentation/dashboard_page.dart';
import 'routes.dart';

class InspectoBotApp extends StatelessWidget {
  const InspectoBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InspectoBot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.authGate,
      routes: {
        AppRoutes.authGate: (context) => const AuthGate(),
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.signIn: (context) => const _AuthPlaceholderPage(title: 'Sign In'),
        AppRoutes.signUp: (context) => const _AuthPlaceholderPage(title: 'Sign Up'),
        AppRoutes.forgotPassword: (context) => const _AuthPlaceholderPage(title: 'Forgot Password'),
        AppRoutes.resetPassword: (context) => const _AuthPlaceholderPage(title: 'Reset Password'),
      },
    );
  }
}

class _AuthPlaceholderPage extends StatelessWidget {
  const _AuthPlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title page is being prepared.')),
    );
  }
}

