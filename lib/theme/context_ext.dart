import 'package:flutter/material.dart';

import 'extensions.dart';

/// Convenience accessor for [AppTokens] from any widget's [BuildContext].
extension AppTokensExtension on BuildContext {
  /// Access app-specific design tokens from the current theme.
  ///
  /// Throws if [AppTokens] extension is not registered in [ThemeData].
  AppTokens get appTokens {
    final tokens = Theme.of(this).extension<AppTokens>();
    assert(
      tokens != null,
      'AppTokens ThemeExtension not found in ThemeData. '
      'Ensure AppTokens.dark() is registered in ThemeData.extensions.',
    );
    return tokens!;
  }
}
