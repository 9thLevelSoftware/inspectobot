import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A progress indicator that displays the current wizard step and completion
/// percentage as a labelled linear progress bar.
///
/// Styling is derived from the app theme -- no hardcoded values.
class WizardProgressIndicator extends StatelessWidget {
  const WizardProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.completionPercent,
  });

  /// The 1-based index of the current step.
  final int currentStep;

  /// Total number of wizard steps.
  final int totalSteps;

  /// Overall completion percentage (0-100).
  final int completionPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: theme.textTheme.titleSmall,
            ),
            Text(
              '$completionPercent%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingXs),
        ClipRRect(
          borderRadius: AppRadii.sm,
          child: LinearProgressIndicator(
            value: completionPercent / 100,
            minHeight: AppSpacing.spacingSm,
          ),
        ),
      ],
    );
  }
}
