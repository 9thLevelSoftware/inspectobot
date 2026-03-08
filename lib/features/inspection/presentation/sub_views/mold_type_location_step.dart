import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// Mold Assessment wizard step 4: Mold Type & Location.
///
/// Provides a single multiline [TextFormField] for documenting the types of
/// mold observed and their specific locations within the property.
class MoldTypeLocationStep extends StatelessWidget {
  const MoldTypeLocationStep({
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
          const SectionHeader(title: 'Mold Type & Location'),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Document the type(s) of mold observed and their specific '
            'locations within the property.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingMd),
          TextFormField(
            initialValue: formData.moldTypeLocation,
            decoration: const InputDecoration(
              labelText: 'Mold Type & Location',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 6,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(moldTypeLocation: value));
            },
          ),
        ],
      ),
    );
  }
}
