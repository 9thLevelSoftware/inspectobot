import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final subtitleText = resumeStep != null
        ? '$address\nResume at step ${resumeStep! + 1}'
        : address;

    return Card(
      child: ListTile(
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
    );
  }
}
