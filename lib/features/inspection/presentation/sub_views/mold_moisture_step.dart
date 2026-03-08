import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// Mold Assessment wizard step 3: Moisture Sources.
///
/// Provides a multiline [TextFormField] for documenting moisture sources and a
/// [SwitchListTile] toggle for the `airSamplesTaken` branch flag.
class MoldMoistureStep extends StatelessWidget {
  const MoldMoistureStep({
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
          const SectionHeader(title: 'Moisture Sources'),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Identify and document all potential moisture sources, including '
            'plumbing leaks, HVAC issues, roof leaks, and condensation.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingMd),
          TextFormField(
            initialValue: formData.moistureSources,
            decoration: const InputDecoration(
              labelText: 'Moisture Sources',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 6,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(moistureSources: value));
            },
          ),
          SizedBox(height: tokens.spacingLg),
          SwitchListTile(
            title: const Text(
              'Air samples were collected during this assessment',
            ),
            value: formData.airSamplesTaken,
            onChanged: (value) {
              onChanged(formData.copyWith(airSamplesTaken: value));
            },
          ),
        ],
      ),
    );
  }
}
