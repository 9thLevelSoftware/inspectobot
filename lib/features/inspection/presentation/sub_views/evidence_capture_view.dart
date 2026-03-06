import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

import '../../domain/inspection_wizard_state.dart';

/// Renders per-form progress summaries showing completion status and
/// missing requirements.
///
/// Pure [StatelessWidget] -- receives all data from the parent.
class EvidenceCaptureView extends StatelessWidget {
  const EvidenceCaptureView({
    super.key,
    required this.wizardState,
  });

  final InspectionWizardState wizardState;

  @override
  Widget build(BuildContext context) {
    final summaries = wizardState.buildFormSummaries();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Per-Form Summary',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppSpacing.spacingSm),
        if (summaries.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('No forms enabled'),
              subtitle: Text('Enable forms to see completion summaries.'),
            ),
          )
        else
          ...summaries.map((summary) {
            final missingText = summary.isComplete
                ? 'Complete'
                : 'Missing required: ${summary.missingRequirements.map((r) => r.label).join(', ')}';
            return Card(
              child: ListTile(
                title: Text(summary.form.label),
                subtitle: Text(missingText),
                trailing: summary.isComplete
                    ? Icon(Icons.check_circle, color: Palette.success)
                    : Icon(Icons.error_outline, color: Palette.warning),
              ),
            );
          }),
      ],
    );
  }
}
