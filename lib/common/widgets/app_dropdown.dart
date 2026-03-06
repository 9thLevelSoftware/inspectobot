import 'package:flutter/material.dart';

/// A convenience wrapper around [DropdownButtonFormField] that inherits styling
/// from the app's [InputDecorationTheme].
///
/// Generic over `T` so callers can use any value type for dropdown items.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.validator,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: items,
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
