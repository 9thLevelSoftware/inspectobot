import 'package:flutter/material.dart';
import 'package:inspectobot/common/widgets/app_text_field.dart';

/// Pre-configured password field with built-in length validation for auth
/// screens.
///
/// Wraps [AppTextField] with password-specific defaults: obscured text,
/// autofill hints, and a validator that enforces a minimum length of 8
/// characters.
class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      obscureText: true,
      autofillHints: const [AutofillHints.password],
      textInputAction: textInputAction,
      validator: _validate,
    );
  }

  static String? _validate(String? value) {
    if ((value ?? '').length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }
}
