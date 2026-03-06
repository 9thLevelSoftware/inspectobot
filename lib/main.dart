import 'package:flutter/material.dart';

import 'package:inspectobot/app/bootstrap/supabase_bootstrap.dart';
import 'package:inspectobot/app/app.dart';
import 'package:inspectobot/app/service_locator.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/auth/data/auth_repository.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await bootstrapSupabase();
    await setupServiceLocator(AuthRepository.live());
    if (SupabaseClientProvider.isConfigured) {
      try {
        await SyncScheduler.instance.start();
      } catch (_) {
        // Scheduler requires remote dependencies and should never block app startup.
      }
    }
    runApp(const InspectoBotApp());
  } catch (e, stackTrace) {
    debugPrint('App initialization failed: $e\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Initialization Error:\n$e\n\nEnsure that you are passing the required environment variables (e.g., via --dart-define-from-file=.env).',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
