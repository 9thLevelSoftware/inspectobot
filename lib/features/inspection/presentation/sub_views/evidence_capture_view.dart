import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
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

    return SingleChildScrollView(
      padding: AppEdgeInsets.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Evidence Summary', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.spacingLg),
          if (summaries.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('No forms enabled'),
                subtitle: Text('Enable forms to see completion summaries.'),
              ),
            )
          else
            SectionGroup(
              children: summaries
                  .map((summary) => SectionCard(
                        density: SectionCardDensity.compact,
                        leadingBadge: StatusBadge(
                          label: summary.isComplete
                              ? 'Complete'
                              : '${summary.missingRequirements.length} missing',
                          type: summary.isComplete
                              ? StatusBadgeType.success
                              : StatusBadgeType.warning,
                          highContrast: true,
                        ),
                        title: summary.form.label,
                        child: Text(
                          summary.isComplete
                              ? 'All evidence captured'
                              : 'Missing: ${summary.missingRequirements.map((r) => r.label).join(", ")}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
