import 'package:flutter/material.dart';

import 'package:inspectobot/features/inspection/domain/inspection_wizard_state.dart';
import 'package:inspectobot/theme/theme.dart';

import 'app_button.dart';

/// A composite card widget for displaying inspection summaries in a list.
///
/// Composes [AppButton] for the resume action and inherits all visual
/// properties from the app's [CardTheme] — no hardcoded colors, spacing,
/// or text styles.
class InspectionCard extends StatelessWidget {
  const InspectionCard({
    super.key,
    required this.clientName,
    required this.address,
    this.resumeLabel,
    this.resumeStep,
    this.onResume,
    this.onTap,
    this.formSummaries,
  });

  /// The client name displayed as the card title.
  final String clientName;

  /// The inspection address displayed in the subtitle.
  final String address;

  /// Custom label for the resume button. Defaults to `'Resume'`.
  final String? resumeLabel;

  /// The step index to resume from. When non-null, the subtitle includes
  /// a "Resume at step N" line (1-indexed).
  final int? resumeStep;

  /// Callback for the resume button. When non-null, renders an [AppButton]
  /// in the trailing position.
  final VoidCallback? onResume;

  /// Callback when the card itself is tapped.
  final VoidCallback? onTap;

  /// Optional per-form completion summaries. When provided, colored chips
  /// showing abbreviation and percentage are rendered below the subtitle.
  final List<FormProgressSummary>? formSummaries;

  @override
  Widget build(BuildContext context) {
    final subtitleText = resumeStep != null
        ? '$address\nResume at step ${resumeStep! + 1}'
        : address;

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(clientName),
            subtitle: Text(subtitleText),
            isThreeLine: resumeStep != null,
            trailing: onResume != null
                ? AppButton(
                    label: resumeLabel ?? 'Resume',
                    onPressed: onResume,
                    variant: AppButtonVariant.filled,
                  )
                : null,
            onTap: onTap,
          ),
          if (formSummaries != null && formSummaries!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.spacingLg,
                right: AppSpacing.spacingLg,
                bottom: AppSpacing.spacingSm,
              ),
              child: FormProgressChips(summaries: formSummaries!),
            ),
        ],
      ),
    );
  }
}

/// Renders a [Wrap] of colored chips showing per-form completion progress.
///
/// Used by both [InspectionCard] and the dashboard's inspection list card.
class FormProgressChips extends StatelessWidget {
  const FormProgressChips({
    super.key,
    required this.summaries,
  });

  final List<FormProgressSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Wrap(
      spacing: AppSpacing.spacingXs,
      runSpacing: AppSpacing.spacingXs,
      children: [
        for (final summary in summaries)
          _ProgressChip(
            label: '${summary.abbreviation}: ${summary.percentComplete}%',
            color: _chipColor(summary.percentComplete, tokens),
          ),
      ],
    );
  }

  Color _chipColor(int percent, AppTokens tokens) {
    if (percent >= 100) return tokens.success;
    if (percent >= 50) return tokens.warning;
    return Palette.error;
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingSm,
        vertical: AppSpacing.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: AppRadii.sm,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
