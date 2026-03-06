import 'package:flutter/material.dart';

/// A read-only [TextFormField] that opens a platform date picker on tap.
///
/// Displays the selected date in US format (M/D/YYYY) and calls [onChanged]
/// when the user picks a new date. Inherits all styling from the app's
/// [InputDecorationTheme].
class AppDatePicker extends StatefulWidget {
  const AppDatePicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.validator,
  });

  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String?)? validator;

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant AppDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(DateTime? date) {
    if (date == null) return '';
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? now,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _controller.text = _format(picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: _pickDate,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
}
