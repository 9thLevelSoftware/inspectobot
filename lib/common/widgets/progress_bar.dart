import 'package:flutter/material.dart';

/// A progress indicator that supports both linear and circular modes.
///
/// All styling is inherited from [ProgressIndicatorThemeData] in the app theme
/// -- no hardcoded colors.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    this.value,
    this.isCircular = false,
    this.size,
  });

  /// Progress value between 0.0 and 1.0. When null, shows indeterminate.
  final double? value;

  /// Whether to render as a circular indicator instead of linear.
  final bool isCircular;

  /// Optional size constraint (width & height for circular, height for linear).
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (isCircular) {
      final indicator = CircularProgressIndicator(value: value);
      if (size != null) {
        return SizedBox(
          width: size,
          height: size,
          child: indicator,
        );
      }
      return indicator;
    }

    final indicator = LinearProgressIndicator(value: value);
    if (size != null) {
      return SizedBox(
        height: size,
        child: indicator,
      );
    }
    return indicator;
  }
}
