import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/section_header.dart';
import 'package:inspectobot/features/inspection/domain/mold_form_data.dart';
import 'package:inspectobot/theme/theme.dart';

/// Mold Assessment wizard step 5: Remediation Recommendations.
///
/// Contains a [SwitchListTile] for the `remediationRecommended` branch flag,
/// a conditionally-visible multiline [TextFormField] for remediation details,
/// and an always-visible optional field for additional findings.
class MoldRemediationStep extends StatelessWidget {
  const MoldRemediationStep({
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
          const SectionHeader(title: 'Remediation Recommendations'),
          SizedBox(height: tokens.spacingSm),
          Text(
            'Provide remediation protocol recommendations based on '
            'assessment findings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Palette.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spacingMd),
          SwitchListTile(
            title: const Text('Remediation is recommended'),
            value: formData.remediationRecommended,
            onChanged: (value) {
              onChanged(formData.copyWith(remediationRecommended: value));
            },
          ),
          if (formData.remediationRecommended) ...[
            SizedBox(height: tokens.spacingMd),
            TextFormField(
              initialValue: formData.remediationRecommendations,
              decoration: const InputDecoration(
                labelText: 'Remediation Recommendations',
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 4,
              textInputAction: TextInputAction.newline,
              onChanged: (value) {
                onChanged(
                  formData.copyWith(remediationRecommendations: value),
                );
              },
            ),
          ],
          SizedBox(height: tokens.spacingLg),
          TextFormField(
            initialValue: formData.additionalFindings,
            decoration: const InputDecoration(
              labelText: 'Additional Findings (Optional)',
              alignLabelWithHint: true,
            ),
            maxLines: null,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            onChanged: (value) {
              onChanged(formData.copyWith(additionalFindings: value));
            },
          ),
        ],
      ),
    );
  }
}
