import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A section header with a title and optional trailing widget.
///
/// Uses [AppEdgeInsets.sectionGap] for top spacing and
/// [AppTokens.sectionHeader] for the title text style.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Padding(
      padding: AppEdgeInsets.sectionGap,
      child: trailing != null
          ? Row(
              children: [
                Text(title, style: tokens.sectionHeader),
                const Spacer(),
                trailing!,
              ],
            )
          : Text(title, style: tokens.sectionHeader),
    );
  }
}
