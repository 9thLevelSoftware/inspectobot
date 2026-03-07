import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// A reusable signature capture widget that renders user-drawn strokes on a
/// canvas.
///
/// Uses a [StatefulWidget] to own a single [PanGestureRecognizer] instance that
/// survives parent rebuilds, preventing the parent [ListView] from stealing
/// the drag mid-stroke.
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
  late final _EagerPanGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = _EagerPanGestureRecognizer()
      ..onStart = _onPanStart
      ..onUpdate = _onPanUpdate;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;
    widget.onPointsChanged([...widget.points, details.localPosition]);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    widget.onPointsChanged([...widget.points, details.localPosition]);
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
          child: RawGestureDetector(
            gestures: <Type, GestureRecognizerFactory>{
              _EagerPanGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      _EagerPanGestureRecognizer>(
                () => _recognizer,
                (_EagerPanGestureRecognizer instance) {
                  instance
                    ..onStart = _onPanStart
                    ..onUpdate = _onPanUpdate;
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
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : null,
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

/// A [PanGestureRecognizer] that immediately claims victory in the gesture
/// arena, preventing parent scrollables from stealing the drag.
class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
