import 'package:flutter/widgets.dart';

import 'package:inspectobot/app/bootstrap/supabase_bootstrap.dart';
import 'package:inspectobot/app/app.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:inspectobot/features/sync/sync_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapSupabase();
  if (SupabaseClientProvider.isConfigured) {
    try {
      await SyncScheduler.instance.start();
    } catch (_) {
      // Scheduler requires remote dependencies and should never block app startup.
    }
  }
  runApp(const InspectoBotApp());
}
