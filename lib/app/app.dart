import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class InspectoBotApp extends StatelessWidget {
  const InspectoBotApp({super.key, GoRouter? router})
      : _router = router;

  final GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InspectoBot',
      theme: AppTheme.dark(),
      routerConfig: _router ?? GetIt.I<GoRouter>(),
    );
  }
}

