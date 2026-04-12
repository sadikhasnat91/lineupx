import 'package:flutter/material.dart';

/// Draws a football jersey (t-shirt) shape for the player slot.
class JerseyPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final bool isEmpty;

  const JerseyPainter({
    required this.fillColor,
    required this.borderColor,
    this.isEmpty = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _buildPath(w, h);

    // Shadow
    canvas.drawShadow(path, borderColor.withOpacity(0.4), 4, false);

    // Fill
    final fillPaint = Paint()
      ..color = isEmpty ? fillColor.withOpacity(0.15) : fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Stripe accent across chest
    if (!isEmpty) {
      final stripePath = Path();
      stripePath.moveTo(w * 0.15, h * 0.42);
      stripePath.lineTo(w * 0.85, h * 0.42);
      stripePath.lineTo(w * 0.85, h * 0.52);
      stripePath.lineTo(w * 0.15, h * 0.52);
      stripePath.close();
      final combined = Path.combine(PathOperation.intersect, path, stripePath);
      canvas.drawPath(combined, Paint()
        ..color = borderColor.withOpacity(0.18)
        ..style = PaintingStyle.fill);
    }

    // Border
    final borderPaint = Paint()
      ..color = isEmpty ? borderColor.withOpacity(0.45) : borderColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isEmpty ? 1.2 : 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    if (isEmpty) {
      borderPaint.shader = null;
      // dashed effect suggestion via intervals not needed, just draw
    }
    canvas.drawPath(path, borderPaint);
  }

  /// Builds the jersey path within [w x h].
  static Path buildPath(double w, double h) => _buildPath(w, h);

  static Path _buildPath(double w, double h) {
    final path = Path();
    // Left collar edge of V-neck
    path.moveTo(w * 0.30, 0);
    // Left shoulder to sleeve
    path.lineTo(w * 0.13, 0);
    path.lineTo(0, h * 0.12);
    path.lineTo(0, h * 0.42);
    // Left armpit
    path.lineTo(w * 0.22, h * 0.47);
    // Left body down
    path.lineTo(w * 0.10, h);
    // Bottom
    path.lineTo(w * 0.90, h);
    // Right body up
    path.lineTo(w * 0.78, h * 0.47);
    // Right armpit
    path.lineTo(w, h * 0.42);
    path.lineTo(w, h * 0.12);
    path.lineTo(w * 0.87, 0);
    // Right collar
    path.lineTo(w * 0.70, 0);
    // V-neck tip
    path.lineTo(w * 0.50, h * 0.20);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(JerseyPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.isEmpty != isEmpty;
}
