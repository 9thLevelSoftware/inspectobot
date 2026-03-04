import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  SupabaseClientProvider._();

  static SupabaseClient? _client;

  static bool get isConfigured => _client != null;

  static SupabaseClient get client {
    final configured = _client;
    if (configured == null) {
      throw StateError(
        'Supabase client not configured. Call bootstrapSupabase() first.',
      );
    }
    return configured;
  }

  static void setClient(SupabaseClient client) {
    _client = client;
  }

  static void reset() {
    _client = null;
  }
}
