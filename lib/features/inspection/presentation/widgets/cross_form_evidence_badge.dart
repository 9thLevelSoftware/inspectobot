import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

import '../../domain/form_type.dart';

/// Displays a subtle informational badge indicating which other forms
/// benefit from capturing a particular evidence photo.
///
/// Renders "Also satisfies: [Form A], [Form B]" with form abbreviations.
/// Returns [SizedBox.shrink] when [sharedForms] is empty (invisible).
///
/// Designed to sit below requirement info inside an [EvidenceRequirementCard].
class CrossFormEvidenceBadge extends StatelessWidget {
  const CrossFormEvidenceBadge({
    super.key,
    required this.sharedForms,
  });

  /// The other forms (excluding the current one) that also accept this
  /// evidence category.
  final Set<FormType> sharedForms;

  @override
  Widget build(BuildContext context) {
    if (sharedForms.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final abbreviations = sharedForms
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final label =
        'Also satisfies: ${abbreviations.map((f) => f.abbreviation).join(', ')}';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.spacingXs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.link,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.spacingXs),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
