import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// A layout widget that anchors primary actions to the bottom of the viewport
/// (thumb zone) for improved field usability.
///
/// The [body] fills the available space above and scrolls independently, while
/// [stickyBottom] stays pinned at the bottom within the thumb-reachable area.
class ReachZoneScaffold extends StatelessWidget {
  const ReachZoneScaffold({
    super.key,
    required this.body,
    required this.stickyBottom,
    this.bottomPadding,
    this.showDivider = true,
  });

  /// Scrollable content area that fills available space above the sticky zone.
  final Widget body;

  /// Widget pinned to the bottom of the viewport (thumb zone).
  final Widget stickyBottom;

  /// Padding around [stickyBottom]. Defaults to [AppEdgeInsets.pagePadding].
  final EdgeInsetsGeometry? bottomPadding;

  /// Whether to show a divider between [body] and [stickyBottom].
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: body),
        if (showDivider) const Divider(height: 1),
        Padding(
          padding: bottomPadding ?? AppEdgeInsets.pagePadding,
          child: SafeArea(
            top: false,
            child: stickyBottom,
          ),
        ),
      ],
    );
  }
}
