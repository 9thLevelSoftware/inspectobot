import 'package:flutter/material.dart';

/// A convenience wrapper around [CheckboxListTile] that inherits all styling
/// from the app's [CheckboxThemeData] and [ListTileThemeData].
///
/// Places the checkbox on the leading (left) side for consistency across the
/// app's form surfaces.
class AppCheckboxTile extends StatelessWidget {
  const AppCheckboxTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
