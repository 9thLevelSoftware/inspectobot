import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// The completion status shown by a [StatusCard].
enum StatusType {
  /// Task is complete -- shows a green check-circle icon.
  complete,

  /// Task is incomplete -- shows a warning-amber icon.
  incomplete,

  /// Task has an error -- shows an error icon in the theme error color.
  error,

  /// No status indicator.
  none,
}

/// A themed card with a [ListTile] that displays a status icon.
///
/// Inherits visual properties from [CardTheme] and [ListTileTheme].
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.title,
    this.subtitle,
    this.status = StatusType.none,
    this.trailing,
    this.onTap,
  });

  /// Primary text displayed in the list tile.
  final String title;

  /// Optional secondary text below [title].
  final String? subtitle;

  /// Determines the trailing status icon when [trailing] is null.
  final StatusType status;

  /// Custom trailing widget. When provided, overrides the [status] icon.
  final Widget? trailing;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ?? _iconForStatus(context, tokens),
        onTap: onTap,
      ),
    );
  }

  Widget? _iconForStatus(BuildContext context, AppTokens tokens) {
    return switch (status) {
      StatusType.complete =>
        Icon(Icons.check_circle, color: tokens.success),
      StatusType.incomplete =>
        Icon(Icons.warning_amber, color: tokens.warning),
      StatusType.error =>
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
      StatusType.none => null,
    };
  }
}
