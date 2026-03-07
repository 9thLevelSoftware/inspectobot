import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A reusable signature capture widget that renders user-drawn strokes on a
/// canvas.
///
/// Drawing is handled via [Listener] (raw pointer events, no gesture arena
/// dependency). A separate [RawGestureDetector] with an eager recognizer wins
/// the gesture arena immediately on pointer-down so the parent [ListView]
/// cannot steal the drag for scrolling.
///
/// All visual defaults are derived from the current theme -- no hardcoded
/// colors, spacing, or radii.
class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    required this.points,
    required this.onPointsChanged,
    this.height = 200,
    this.strokeWidth = 3.0,
    this.strokeColor,
    this.backgroundColor,
    this.hintText,
    this.borderColor,
    this.semanticLabel,
    this.enabled = true,
  });

  /// The list of [Offset] points representing the current signature strokes.
  final List<Offset> points;

  /// Called whenever the user draws, with the updated point list.
  final ValueChanged<List<Offset>> onPointsChanged;

  /// Height of the drawing area.
  final double height;

  /// Stroke width for drawn lines.
  final double strokeWidth;

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

  /// When `false`, gesture callbacks are disabled.
  final bool enabled;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  // Track the active pointer so we only respond to a single finger.
  int? _activePointer;

  void _addPoint(Offset localPosition) {
    widget.onPointsChanged([...widget.points, localPosition]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveStrokeColor = widget.strokeColor ?? colorScheme.onSurface;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final effectiveBorderColor = widget.borderColor ?? colorScheme.outline;

    return Semantics(
      label: widget.semanticLabel ?? 'Signature capture area',
      child: ClipRRect(
        borderRadius: AppRadii.md,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            border: Border.all(color: effectiveBorderColor),
            borderRadius: AppRadii.md,
          ),
          // Listener captures raw pointer events for drawing — bypasses the
          // gesture arena entirely so it never loses events to the parent
          // scrollable.
          child: Listener(
            onPointerDown: widget.enabled
                ? (event) {
                    _activePointer ??= event.pointer;
                    if (event.pointer == _activePointer) {
                      _addPoint(event.localPosition);
                    }
                  }
                : null,
            onPointerMove: widget.enabled
                ? (event) {
                    if (event.pointer == _activePointer) {
                      _addPoint(event.localPosition);
                    }
                  }
                : null,
            onPointerUp: widget.enabled
                ? (event) {
                    if (event.pointer == _activePointer) {
                      _activePointer = null;
                    }
                  }
                : null,
            onPointerCancel: widget.enabled
                ? (event) {
                    if (event.pointer == _activePointer) {
                      _activePointer = null;
                    }
                  }
                : null,
            // RawGestureDetector's ONLY job: eagerly win the gesture arena so
            // the parent ListView's scroll recognizer is rejected.  Drawing
            // itself is handled entirely by the Listener above.
            child: RawGestureDetector(
              gestures: <Type, GestureRecognizerFactory>{
                if (widget.enabled)
                  _ArenaClaimer: GestureRecognizerFactoryWithHandlers<
                      _ArenaClaimer>(
                    _ArenaClaimer.new,
                    (_ArenaClaimer instance) {
                      // No-op callbacks — we only need the arena claim.
                      instance.onStart = (_) {};
                    },
                  ),
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: widget.height,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SignaturePainter(
                    points: widget.points,
                    color: effectiveStrokeColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                  child: widget.points.isEmpty
                      ? Center(
                          child: Text(
                            widget.hintText ?? 'Draw your signature here',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Immediately wins the gesture arena on pointer-down, preventing any parent
/// scrollable from claiming the drag.  Does no actual work — drawing is
/// handled separately by a [Listener].
class _ArenaClaimer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
