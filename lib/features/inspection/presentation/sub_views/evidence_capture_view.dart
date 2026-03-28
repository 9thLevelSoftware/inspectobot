import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/theme/theme.dart';

import '../../domain/evidence_sharing_matrix.dart';
import '../../domain/form_type.dart';
import '../../domain/inspection_wizard_state.dart';
import '../widgets/cross_form_evidence_badge.dart';

/// Renders per-form progress summaries showing completion status and
/// missing requirements, or an empty state when no evidence is captured.
///
/// Pure [StatelessWidget] -- receives all data from the parent.
class EvidenceCaptureView extends StatelessWidget {
  const EvidenceCaptureView({
    super.key,
    required this.wizardState,
    this.onCapturePhoto,
    this.onSelectFromGallery,
  });

  final InspectionWizardState wizardState;
  final VoidCallback? onCapturePhoto;
  final VoidCallback? onSelectFromGallery;

  @override
  Widget build(BuildContext context) {
    final summaries = wizardState.buildFormSummaries();
    final enabledForms = summaries.map((s) => s.form).toSet();

    // Show empty state when no forms are enabled
    if (enabledForms.isEmpty) {
      return _buildNoFormsState(context);
    }

    // Check if any evidence has been captured by looking at completion
    // A form has captured evidence if total > missing (some requirements satisfied)
    final hasAnyCapturedEvidence = summaries.any(
      (s) => s.totalRequirements > s.missingRequirements.length,
    );

    // Show empty state when forms are enabled but no evidence captured yet
    if (!hasAnyCapturedEvidence) {
      return _buildEmptyEvidenceState(context);
    }

    return SingleChildScrollView(
      padding: AppEdgeInsets.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Evidence Summary', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.spacingLg),
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

  /// Builds the empty state when no forms are enabled.
  Widget _buildNoFormsState(BuildContext context) {
    return EmptyState(
      icon: Icons.folder_off_outlined,
      message: 'No inspection forms enabled.',
      actionLabel: 'Go to Setup',
      onAction: () {
        // Navigate back to enable forms
        Navigator.of(context).maybePop();
      },
    );
  }

  /// Builds the empty state when forms are enabled but no evidence captured.
  Widget _buildEmptyEvidenceState(BuildContext context) {
    final tokens = context.appTokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: AppEdgeInsets.pagePadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: tokens.spacingLg),
            Text(
              'No evidence captured yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacingSm),
            Text(
              'Start capturing photos to document your inspection requirements.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacingXl),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Capture Photo',
                icon: Icons.camera_alt,
                isThumbZone: true,
                onPressed: onCapturePhoto,
              ),
            ),
            SizedBox(height: tokens.spacingMd),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Select from Gallery',
                variant: AppButtonVariant.outlined,
                icon: Icons.photo_library,
                isThumbZone: true,
                onPressed: onSelectFromGallery,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds [CrossFormEvidenceBadge] widgets for each requirement in [summary]
  /// whose category is shared with other enabled forms.
  List<Widget> _buildSharingBadges(
    FormProgressSummary summary,
    Set<FormType> enabledForms,
  ) {
    // Collect unique shared form sets across missing requirements only —
    // badges disappear once a requirement is captured since it's no longer
    // actionable. This keeps the UI focused on what the inspector still needs.
    final sharedSets = <Set<FormType>>[];

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
