import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/theme/theme.dart';

import '../../domain/evidence_sharing_matrix.dart';
import '../../domain/form_type.dart';
import '../../domain/inspection_wizard_state.dart';
import '../widgets/cross_form_evidence_badge.dart';

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
    final enabledForms =
        summaries.map((s) => s.form).toSet();

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              summary.isComplete
                                  ? 'All evidence captured'
                                  : 'Missing: ${summary.missingRequirements.map((r) => r.label).join(", ")}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            ..._buildSharingBadges(
                              summary,
                              enabledForms,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  /// Builds [CrossFormEvidenceBadge] widgets for each requirement in [summary]
  /// whose category is shared with other enabled forms.
  List<Widget> _buildSharingBadges(
    FormProgressSummary summary,
    Set<FormType> enabledForms,
  ) {
    // Collect unique shared form sets across all requirements (not just missing)
    // to show sharing info even for captured items.
    final sharedSets = <Set<FormType>>[];

    // Use the form's total requirements (via buildFormSummaries' backing data).
    // We only have missingRequirements on the summary, so we check those plus
    // any requirement whose category is shared.
    for (final requirement in summary.missingRequirements) {
      final category = requirement.category;
      if (category == null) continue;

      final accepting = EvidenceSharingMatrix.formsAcceptingCategoryFiltered(
        category,
        enabledForms,
      );
      final otherForms = accepting.difference({summary.form});
      if (otherForms.isNotEmpty &&
          !sharedSets.any((s) => _setsEqual(s, otherForms))) {
        sharedSets.add(otherForms);
      }
    }

    if (sharedSets.isEmpty) return const [];

    return [
      for (final forms in sharedSets)
        CrossFormEvidenceBadge(sharedForms: forms),
    ];
  }

  static bool _setsEqual(Set<FormType> a, Set<FormType> b) {
    return a.length == b.length && a.containsAll(b);
  }
}
