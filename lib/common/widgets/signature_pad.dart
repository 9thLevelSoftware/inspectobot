import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:inspectobot/theme/theme.dart';

/// Controller that exposes the signature pad's point data to the parent.
///
/// Use [points] to read the current strokes and [clear] to reset.  Attach a
/// listener via [addListener] to be notified when the drawing state changes
/// (e.g. to toggle a "Clear" button).
class SignaturePadController extends ChangeNotifier {
  final List<Offset> _points = [];

  /// The current drawn points.
  List<Offset> get points => List.unmodifiable(_points);

  /// Whether any strokes have been drawn.
  bool get isEmpty => _points.isEmpty;

  /// Whether strokes exist.
  bool get isNotEmpty => _points.isNotEmpty;

  void _addPoint(Offset point) {
    _points.add(point);
    notifyListeners();
  }

  /// Remove all drawn strokes.
  void clear() {
    _points.clear();
    notifyListeners();
  }
}

/// A reusable signature capture widget that renders user-drawn strokes on a
/// canvas.
///
/// All drawing state lives inside the widget, driven by a
/// [SignaturePadController].  The parent never needs to [setState] during
/// drawing — only the pad's own [CustomPaint] repaints, keeping the rest of
/// the widget tree stable.
///
/// All visual defaults are derived from the current theme -- no hardcoded
/// colors, spacing, or radii.
class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 200,
    this.strokeWidth = 3.0,
    this.strokeColor,
    this.backgroundColor,
    this.hintText,
    this.borderColor,
    this.semanticLabel,
    this.enabled = true,
  });

  /// Controller that owns the drawn points.
  final SignaturePadController controller;

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
  int? _activePointer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Only rebuilds this widget — parent is unaffected.
    setState(() {});
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
          child: Listener(
            onPointerDown: widget.enabled
                ? (event) {
                    _activePointer ??= event.pointer;
                    if (event.pointer == _activePointer) {
                      widget.controller._addPoint(event.localPosition);
                    }
                  }
                : null,
            onPointerMove: widget.enabled
                ? (event) {
                    if (event.pointer == _activePointer) {
                      widget.controller._addPoint(event.localPosition);
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
            child: RawGestureDetector(
              gestures: <Type, GestureRecognizerFactory>{
                if (widget.enabled)
                  _ArenaClaimer: GestureRecognizerFactoryWithHandlers<
                      _ArenaClaimer>(
                    _ArenaClaimer.new,
                    (_ArenaClaimer instance) {
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
                    points: widget.controller._points,
                    color: effectiveStrokeColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                  child: widget.controller.isEmpty
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
/// scrollable from claiming the drag.
class _ArenaClaimer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
