import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

import '../../domain/evidence_requirement.dart';

/// A reusable card displaying a single evidence requirement with its capture
/// status and an action button.
///
/// Matches the UI output of the original `FormChecklistPage` monolith:
/// - Captured: trailing green check icon, subtitle "Captured".
/// - Missing: trailing Capture/Upload button, subtitle "Missing required item".
class EvidenceRequirementCard extends StatelessWidget {
  const EvidenceRequirementCard({
    super.key,
    required this.requirement,
    required this.isCaptured,
    this.onCapture,
  });

  /// The evidence requirement to display.
  final EvidenceRequirement requirement;

  /// Whether this requirement has already been captured.
  final bool isCaptured;

  /// Called when the user taps the Capture/Upload button.
  /// When `null`, the button is disabled.
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(requirement.label),
        subtitle: Text(isCaptured ? 'Captured' : 'Missing required item'),
        trailing: isCaptured
            ? const Icon(Icons.check_circle, color: Palette.success)
            : OutlinedButton(
                onPressed: onCapture,
                child: Text(
                  requirement.mediaType == EvidenceMediaType.document
                      ? 'Upload'
                      : 'Capture',
                ),
              ),
      ),
    );
  }
}
