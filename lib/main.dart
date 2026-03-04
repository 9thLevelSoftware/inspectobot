import 'package:flutter/widgets.dart';

import 'package:inspectobot/app/bootstrap/supabase_bootstrap.dart';
import 'package:inspectobot/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapSupabase();
  runApp(const InspectoBotApp());
}
