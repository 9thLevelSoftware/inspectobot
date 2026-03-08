import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/app_checkbox_tile.dart';
import 'package:inspectobot/common/widgets/app_date_picker.dart';
import 'package:inspectobot/common/widgets/app_multi_select_chips.dart';
import 'package:inspectobot/common/widgets/app_text_field.dart';
import 'package:inspectobot/features/inspection/domain/field_definition.dart';
import 'package:inspectobot/features/inspection/domain/field_type.dart';

/// Renders a single [FieldDefinition] as the appropriate input widget.
///
/// This is a [StatefulWidget] because text-based fields require a
/// [TextEditingController] whose lifecycle must be managed.
class FormFieldInput extends StatefulWidget {
  const FormFieldInput({
    super.key,
    required this.field,
    this.value,
    required this.onChanged,
  });

  final FieldDefinition field;
  final dynamic value;
  final void Function(String key, dynamic value) onChanged;

  @override
  State<FormFieldInput> createState() => _FormFieldInputState();
}

class _FormFieldInputState extends State<FormFieldInput> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    if (_isTextBased) {
      _controller = TextEditingController(
        text: widget.value?.toString() ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant FormFieldInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isTextBased && _controller != null) {
      final incoming = widget.value?.toString() ?? '';
      if (_controller!.text != incoming) {
        _controller!.text = incoming;
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool get _isTextBased =>
      widget.field.type == FieldType.text ||
      widget.field.type == FieldType.textarea;

  TextInputType _mapKeyboardType(String? type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;

    switch (field.type) {
      case FieldType.text:
        return AppTextField(
          controller: _controller,
          label: field.label,
          hint: field.hint,
          keyboardType: _mapKeyboardType(field.keyboardType),
          onChanged: (v) => widget.onChanged(field.key, v),
        );

      case FieldType.textarea:
        return AppTextField(
          controller: _controller,
          label: field.label,
          hint: field.hint,
          maxLines: field.maxLines ?? 4,
          keyboardType: _mapKeyboardType(field.keyboardType),
          onChanged: (v) => widget.onChanged(field.key, v),
        );

      case FieldType.checkbox:
        return AppCheckboxTile(
          title: field.label,
          value: widget.value as bool? ?? false,
          onChanged: (v) => widget.onChanged(field.key, v ?? false),
        );

      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: widget.value as String?,
          items: (field.dropdownOptions ?? <String>[])
              .map(
                (opt) => DropdownMenuItem<String>(value: opt, child: Text(opt)),
              )
              .toList(),
          onChanged: (v) => widget.onChanged(field.key, v),
          dropdownColor:
              Theme.of(context).colorScheme.surfaceContainerHigh,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.hint,
          ),
        );

      case FieldType.date:
        final dateValue = _parseDate(widget.value);
        return AppDatePicker(
          label: field.label,
          value: dateValue,
          onChanged: (picked) {
            widget.onChanged(field.key, picked.toIso8601String());
          },
        );

      case FieldType.multiSelect:
        return AppMultiSelectChips(
          label: field.label,
          options: field.multiSelectOptions ?? const [],
          selected: (widget.value as List<String>?) ?? const [],
          onChanged: (updated) => widget.onChanged(field.key, updated),
        );

      case FieldType.triState:
        throw UnimplementedError('triState rendering added in Plan 05-02');
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
