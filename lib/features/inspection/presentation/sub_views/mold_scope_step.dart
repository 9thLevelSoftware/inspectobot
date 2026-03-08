import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// Mold Assessment wizard step 1: Scope of Assessment.
///
/// Provides a single multiline [TextFormField] for describing the scope and
/// limitations of the mold assessment.
class MoldScopeStep extends StatelessWidget {
  const MoldScopeStep({
    super.key,
    required this.formData,
    required this.onChanged,
  });

  final MoldFormData formData;
  final ValueChanged<MoldFormData> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Scope of Assessment'),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Describe the scope and limitations of this mold assessment, '
            'including areas inspected and inspection methodology.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingMd),
          TextFormField(
            initialValue: formData.scopeOfAssessment,
            decoration: const InputDecoration(
              labelText: 'Scope of Assessment',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 6,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(scopeOfAssessment: value));
            },
          ),
        ],
      ),
    );
  }
}
