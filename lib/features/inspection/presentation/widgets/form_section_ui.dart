import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/repeating_group_card.dart';
import 'package:inspectobot/common/widgets/section_card.dart';
import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/form_section_definition.dart';
import 'package:inspectobot/theme/theme.dart';

import 'form_field_input.dart';

/// Renders a complete [FormSectionDefinition] as a scrollable form section.
///
/// Includes the section header, optional branch flag toggles, and all visible
/// fields based on the current [branchContext].
class FormSectionUI extends StatelessWidget {
  const FormSectionUI({
    super.key,
    required this.section,
    required this.formValues,
    required this.branchContext,
    required this.onFieldChanged,
    required this.onBranchFlagChanged,
  });

  final FormSectionDefinition section;
  final Map<String, dynamic> formValues;
  final Map<String, dynamic> branchContext;
  final void Function(String key, dynamic value) onFieldChanged;
  final void Function(String key, bool value) onBranchFlagChanged;

  /// Converts a snake_case or camelCase key to Title Case label.
  static String _humanizeKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    // Only standalone fields — FieldGroup and RepeatingFieldGroup fields
    // are rendered separately below.
    final standaloneFields = section.fieldDefinitions
        .where((f) => f.isVisible(branchContext))
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: section.title),
            if (section.description != null)
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.spacingLg,
                  bottom: tokens.spacingSm,
                ),
                child: Text(
                  section.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (section.branchFlagKeys.isNotEmpty)
              SectionCard(
                child: Column(
                  children: section.branchFlagKeys.map((key) {
                    return SwitchListTile(
                      title: Text(_humanizeKey(key)),
                      value: branchContext[key] == true,
                      onChanged: (v) => onBranchFlagChanged(key, v),
                    );
                  }).toList(),
                ),
              ),
            // Standalone field definitions
            ...standaloneFields.map((field) {
              return Padding(
                padding: EdgeInsets.only(top: tokens.spacingMd),
                child: FormFieldInput(
                  field: field,
                  value: formValues[field.key],
                  onChanged: onFieldChanged,
                ),
              );
            }),
            // Field groups (trigger + conditional dependents)
            ...section.fieldGroups.expand((group) {
              final groupFields = group.visibleFields(formValues);
              return groupFields.map((field) {
                return Padding(
                  padding: EdgeInsets.only(top: tokens.spacingMd),
                  child: FormFieldInput(
                    key: ValueKey('fg_${group.groupKey}_${field.key}'),
                    field: field,
                    value: formValues[field.key],
                    onChanged: onFieldChanged,
                  ),
                );
              });
            }),
            // Repeating field groups (N iterations of template fields)
            ...section.repeatingFieldGroups.expand((rg) {
              return List.generate(rg.repetitions, (i) {
                final label = rg.repetitionLabel?.call(i + 1) ?? rg.label;
                return Padding(
                  padding: EdgeInsets.only(top: tokens.spacingMd),
                  child: RepeatingGroupCard(
                    label: label,
                    index: i + 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rg.fieldTemplate.map((templateField) {
                        final concreteKey = rg.fieldKey(i, templateField.key);
                        return Padding(
                          padding: EdgeInsets.only(top: tokens.spacingSm),
                          child: FormFieldInput(
                            key: ValueKey('rg_${rg.groupKey}_$concreteKey'),
                            field: templateField,
                            value: formValues[concreteKey],
                            onChanged: (_, value) =>
                                onFieldChanged(concreteKey, value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              });
            }),
          ],
        ),
      ),
    );
  }
}
