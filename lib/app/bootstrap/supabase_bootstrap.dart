import 'package:inspectobot/data/supabase/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef SupabaseInitializer = Future<void> Function({
  required String url,
  required String anonKey,
});

Future<void> bootstrapSupabase({
  String? url,
  String? anonKey,
  SupabaseInitializer? initializer,
}) async {
  final resolvedUrl = (url ?? const String.fromEnvironment('SUPABASE_URL')).trim();
  final resolvedAnonKey =
      (anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY')).trim();

  if (resolvedUrl.isEmpty || resolvedAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Define SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  final init =
      initializer ??
      ({required String url, required String anonKey}) {
        return Supabase.initialize(url: url, anonKey: anonKey);
      };

  await init(url: resolvedUrl, anonKey: resolvedAnonKey);
  if (initializer == null) {
    SupabaseClientProvider.setClient(Supabase.instance.client);
  }
}
