import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/general_inspection_form_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// General Inspection wizard scope step: Scope and Purpose.
///
/// Provides a single multiline [TextFormField] for describing the scope,
/// limitations, and purpose of the general home inspection.
class GeneralInspectionScopeStep extends StatelessWidget {
  const GeneralInspectionScopeStep({
    super.key,
    required this.formData,
    required this.onChanged,
  });

  final GeneralInspectionFormData formData;
  final ValueChanged<GeneralInspectionFormData> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Scope and Purpose'),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Describe the scope, limitations, and purpose of this inspection.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingMd),
          TextFormField(
            initialValue: formData.scopeAndPurpose,
            decoration: const InputDecoration(
              labelText: 'Scope and Purpose',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 6,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(scopeAndPurpose: value));
            },
          ),
        ],
      ),
    );
  }
}
