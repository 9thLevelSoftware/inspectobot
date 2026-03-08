import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

import '../../domain/form_type.dart';

/// Short abbreviation labels for each [FormType], used in cross-form
/// evidence sharing badges.
extension FormTypeAbbreviation on FormType {
  /// Two-to-four character abbreviation for compact display.
  String get abbreviation {
    switch (this) {
      case FormType.fourPoint:
        return '4PT';
      case FormType.roofCondition:
        return 'ROOF';
      case FormType.windMitigation:
        return 'WIND';
      case FormType.wdo:
        return 'WDO';
      case FormType.sinkholeInspection:
        return 'SINK';
      case FormType.moldAssessment:
        return 'MOLD';
      case FormType.generalInspection:
        return 'GEN';
    }
  }
}

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
