import 'package:flutter_test/flutter_test.dart';
import 'package:inspectobot/app/bootstrap/supabase_bootstrap.dart';
import 'package:inspectobot/data/supabase/supabase_client_provider.dart';

void main() {
  tearDown(SupabaseClientProvider.reset);

  test('bootstrapSupabase throws when required config is missing', () async {
    await expectLater(
      () => bootstrapSupabase(url: '', anonKey: ''),
      throwsA(isA<StateError>()),
    );
  });

  test('bootstrapSupabase uses provided initializer with env values', () async {
    String? capturedUrl;
    String? capturedAnonKey;

    await bootstrapSupabase(
      url: 'https://example.supabase.co',
      anonKey: 'anon-key',
      initializer: ({required String url, required String anonKey}) async {
        capturedUrl = url;
        capturedAnonKey = anonKey;
      },
    );

    expect(capturedUrl, 'https://example.supabase.co');
    expect(capturedAnonKey, 'anon-key');
  });
}
