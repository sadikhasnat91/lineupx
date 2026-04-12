import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// The main football pitch painter for the lineup builder.
class PitchPainter extends CustomPainter {
  const PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Grass stripes ──────────────────────────────────────────────────────
    const stripeCount = 10;
    for (int i = 0; i < stripeCount; i++) {
      final y1 = h * i / stripeCount;
      final y2 = h * (i + 1) / stripeCount;
      final paint = Paint()
        ..color = i.isEven
            ? AppColors.pitchDark
            : AppColors.pitchMid
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, y1, w, y2 - y1), paint);
    }

    // ── Field boundary ─────────────────────────────────────────────────────
    final line = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final padX = w * 0.04;
    final padY = h * 0.02;

    canvas.drawRect(
        Rect.fromLTWH(padX, padY, w - padX * 2, h - padY * 2), line);

    // ── Centre line ────────────────────────────────────────────────────────
    final midY = h / 2;
    canvas.drawLine(Offset(padX, midY), Offset(w - padX, midY), line);

    // ── Centre circle ──────────────────────────────────────────────────────
    canvas.drawCircle(Offset(w / 2, midY), w * 0.13, line);

    // Centre spot
    final spotPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, midY), 2.5, spotPaint);

    // ── Top penalty box ────────────────────────────────────────────────────
    canvas.drawRect(
        Rect.fromLTWH(
            w * 0.22, padY, w * 0.56, h * 0.18),
        line);

    // Top goal box
    canvas.drawRect(
        Rect.fromLTWH(
            w * 0.35, padY, w * 0.30, h * 0.08),
        line);

    // Top penalty spot
    canvas.drawCircle(Offset(w / 2, padY + h * 0.125), 2, spotPaint);

    // Top penalty arc (clipped to only show portion outside the box)
    final topArcRect = Rect.fromCenter(
        center: Offset(w / 2, padY + h * 0.125),
        width: w * 0.28,
        height: w * 0.28);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, padY + h * 0.18, w, h));
    canvas.drawArc(topArcRect, 0.35, 2.44, false, line);
    canvas.restore();

    // ── Bottom penalty box ─────────────────────────────────────────────────
    canvas.drawRect(
        Rect.fromLTWH(
            w * 0.22, h - padY - h * 0.18, w * 0.56, h * 0.18),
        line);

    // Bottom goal box
    canvas.drawRect(
        Rect.fromLTWH(
            w * 0.35, h - padY - h * 0.08, w * 0.30, h * 0.08),
        line);

    // Bottom penalty spot
    canvas.drawCircle(
        Offset(w / 2, h - padY - h * 0.125), 2, spotPaint);

    // Bottom penalty arc (clipped to only show portion outside the box)
    final botArcRect = Rect.fromCenter(
        center: Offset(w / 2, h - padY - h * 0.125),
        width: w * 0.28,
        height: w * 0.28);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h - padY - h * 0.18));
    canvas.drawArc(botArcRect, 3.49, 2.44, false, line);
    canvas.restore();

    // ── Corner arcs ───────────────────────────────────────────────────────
    final cornerR = w * 0.04;
    // Top-left
    canvas.drawArc(
        Rect.fromLTWH(padX - cornerR, padY - cornerR, cornerR * 2, cornerR * 2),
        0, 1.58, false, line);
    // Top-right
    canvas.drawArc(
        Rect.fromLTWH(w - padX - cornerR, padY - cornerR, cornerR * 2, cornerR * 2),
        1.58, 1.58, false, line);
    // Bottom-left
    canvas.drawArc(
        Rect.fromLTWH(padX - cornerR, h - padY - cornerR, cornerR * 2, cornerR * 2),
        4.71, 1.58, false, line);
    // Bottom-right
    canvas.drawArc(
        Rect.fromLTWH(w - padX - cornerR, h - padY - cornerR, cornerR * 2, cornerR * 2),
        3.14, 1.58, false, line);

    // ── Goal areas at top & bottom ────────────────────────────────────────
    final goalW = w * 0.28;
    final goalH = h * 0.025;
    final goalPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Top goal
    canvas.drawRect(
        Rect.fromLTWH((w - goalW) / 2, padY - 1, goalW, goalH),
        goalPaint);
    // Bottom goal
    canvas.drawRect(
        Rect.fromLTWH((w - goalW) / 2, h - padY - goalH + 1, goalW, goalH),
        goalPaint);
  }

  @override
  bool shouldRepaint(covariant PitchPainter old) => false;
}
