import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// Mold Assessment wizard step 2: Visual Observations.
///
/// Provides a single multiline [TextFormField] for documenting visual
/// observations of potential mold growth, water damage, and related conditions.
class MoldObservationsStep extends StatelessWidget {
  const MoldObservationsStep({
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
          const SectionHeader(title: 'Visual Observations'),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Document all visual observations of potential mold growth, '
            'water damage, staining, or other moisture-related conditions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingMd),
          TextFormField(
            initialValue: formData.visualObservations,
            decoration: const InputDecoration(
              labelText: 'Visual Observations',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 6,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(visualObservations: value));
            },
          ),
        ],
      ),
    );
  }
}
