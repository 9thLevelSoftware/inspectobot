import 'package:flutter/material.dart';

import 'package:inspectobot/common/widgets/widgets.dart';
import 'package:inspectobot/theme/theme.dart';

import '../../domain/evidence_requirement.dart';
import '../../domain/form_type.dart';
import '../widgets/cross_form_evidence_badge.dart';

/// A reusable card displaying a single evidence requirement with its capture
/// status and an action button.
///
/// - Captured: trailing [StatusBadge] with 'Complete'.
/// - Missing: trailing [StatusBadge] 'Missing' with action button below.
///
/// Optionally displays a [CrossFormEvidenceBadge] when [sharedForms] is
/// provided and non-empty, indicating other forms that also benefit from
/// capturing this evidence.
class EvidenceRequirementCard extends StatelessWidget {
  const EvidenceRequirementCard({
    super.key,
    required this.requirement,
    required this.isCaptured,
    this.onCapture,
    this.sharedForms,
  });

  /// The evidence requirement to display.
  final EvidenceRequirement requirement;

  /// Whether this requirement has already been captured.
  final bool isCaptured;

  /// Called when the user taps the Capture/Upload button.
  /// When `null`, the button is disabled.
  final VoidCallback? onCapture;

  /// Other forms that also accept this evidence category.
  /// When non-null and non-empty, a [CrossFormEvidenceBadge] is rendered
  /// below the requirement description.
  final Set<FormType>? sharedForms;

  @override
  Widget build(BuildContext context) {
    final actionLabel = requirement.mediaType == EvidenceMediaType.document
        ? 'Upload'
        : 'Capture';

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppSpacing.thumbZoneTapTarget,
      ),
      child: Card(
        child: Padding(
          padding: AppEdgeInsets.cardPaddingCompact,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(requirement.label,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.spacingXs),
                    Text(
                      isCaptured ? 'Captured' : 'Missing required item',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (sharedForms != null && sharedForms!.isNotEmpty)
                      CrossFormEvidenceBadge(sharedForms: sharedForms!),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spacingSm),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: isCaptured ? 'Complete' : 'Missing',
                    type: isCaptured
                        ? StatusBadgeType.success
                        : StatusBadgeType.warning,
                    highContrast: true,
                  ),
                  if (!isCaptured) ...[
                    const SizedBox(height: AppSpacing.spacingSm),
                    OutlinedButton(
                      onPressed: onCapture,
                      child: Text(actionLabel),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
