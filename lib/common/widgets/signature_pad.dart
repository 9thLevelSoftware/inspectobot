import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import 'package:inspectobot/theme/theme.dart';

/// Re-export [SignatureController] so callers only need to import widgets.dart.
export 'package:signature/signature.dart' show SignatureController;

/// A themed signature capture widget backed by the `signature` package.
///
/// All visual defaults are derived from the current theme -- no hardcoded
/// colors, spacing, or radii.
class SignaturePad extends StatelessWidget {
  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 200,
    this.strokeColor,
    this.backgroundColor,
    this.hintText,
    this.borderColor,
    this.semanticLabel,
    this.enabled = true,
  });

  /// Controller from the `signature` package that owns the drawn points.
  final SignatureController controller;

  /// Height of the drawing area.
  final double height;

  /// Stroke color. Defaults to [ColorScheme.onSurface].
  final Color? strokeColor;

  /// Canvas background color. Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? backgroundColor;

  /// Hint text shown when the canvas is empty.
  final String? hintText;

  /// Border color. Defaults to [ColorScheme.outline].
  final Color? borderColor;

  /// Accessibility label for the signature area.
  final String? semanticLabel;

  /// When `false`, drawing is disabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;

    return Semantics(
      label: semanticLabel ?? 'Signature capture area',
      child: ClipRRect(
        borderRadius: AppRadii.md,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            border: Border.all(color: effectiveBorderColor),
            borderRadius: AppRadii.md,
          ),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                Signature(
                  controller: controller,
                  backgroundColor: effectiveBackgroundColor,
                ),
                if (!enabled)
                  Positioned.fill(
                    child: AbsorbPointer(
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                // Hint text overlay when empty.
                ValueListenableBuilder<bool>(
                  valueListenable: _EmptyNotifier(controller),
                  builder: (context, isEmpty, _) {
                    if (!isEmpty) return const SizedBox.shrink();
                    return Center(
                      child: IgnorePointer(
                        child: Text(
                          hintText ?? 'Draw your signature here',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A [ValueNotifier] that mirrors [SignatureController.isEmpty].
class _EmptyNotifier extends ValueNotifier<bool> {
  _EmptyNotifier(this._controller) : super(_controller.isEmpty) {
    _controller.addListener(_sync);
  }

  final SignatureController _controller;

  void _sync() {
    value = _controller.isEmpty;
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    super.dispose();
  }
}
