import 'package:flutter/material.dart';
import 'package:inspectobot/common/widgets/app_text_field.dart';

/// Pre-configured email field with built-in validation for auth screens.
///
/// Wraps [AppTextField] with email-specific defaults: keyboard type, autofill
/// hints, and a validator that checks for non-empty input containing '@'.
class AuthEmailField extends StatelessWidget {
  const AuthEmailField({
    super.key,
    this.controller,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: textInputAction,
      validator: _validate,
    );
  }

  static String? _validate(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}
