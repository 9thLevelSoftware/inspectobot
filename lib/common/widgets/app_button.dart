import 'package:flutter/material.dart';

/// Variants for [AppButton].
enum AppButtonVariant { filled, outlined, text, icon }

/// A reusable button widget that maps to Material 3 button types with loading
/// state support.
///
/// All styling is inherited from the app theme -- no hardcoded colors or text
/// styles.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final effectiveLabel = isLoading ? (loadingLabel ?? label) : label;

    // Icon-only variant
    if (variant == AppButtonVariant.icon && icon != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: IconButton(
          icon: Icon(icon),
          onPressed: effectiveOnPressed,
        ),
      );
    }

    final loadingIndicator = isLoading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null;

    final textWidget = Text(effectiveLabel);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: _buildButton(
        effectiveOnPressed,
        textWidget,
        loadingIndicator,
      ),
    );
  }

  Widget _buildButton(
    VoidCallback? onPressed,
    Text textWidget,
    Widget? loadingIndicator,
  ) {
    // When we have an icon (non-icon variant) or a loading indicator, use the
    // .icon() constructor to show icon + label side-by-side.
    final effectiveIcon = loadingIndicator ?? (icon != null ? Icon(icon) : null);

    switch (variant) {
      case AppButtonVariant.filled:
        if (effectiveIcon != null) {
          return FilledButton.icon(
            onPressed: onPressed,
            icon: effectiveIcon,
            label: textWidget,
          );
        }
        return FilledButton(
          onPressed: onPressed,
          child: textWidget,
        );

      case AppButtonVariant.outlined:
        if (effectiveIcon != null) {
          return OutlinedButton.icon(
            onPressed: onPressed,
            icon: effectiveIcon,
            label: textWidget,
          );
        }
        return OutlinedButton(
          onPressed: onPressed,
          child: textWidget,
        );

      case AppButtonVariant.text:
        if (effectiveIcon != null) {
          return TextButton.icon(
            onPressed: onPressed,
            icon: effectiveIcon,
            label: textWidget,
          );
        }
        return TextButton(
          onPressed: onPressed,
          child: textWidget,
        );

      case AppButtonVariant.icon:
        // Handled above in build(); this is a fallback for icon == null.
        return FilledButton(
          onPressed: onPressed,
          child: textWidget,
        );
    }
  }
}
