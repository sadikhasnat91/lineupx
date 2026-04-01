import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/models/formation_model.dart';

/// Mini formation viewer shown on formation selection cards.
class FormationPreviewWidget extends StatelessWidget {
  final FormationModel formation;
  final double width;
  final double height;
  final Color? dotColor;

  const FormationPreviewWidget({
    super.key,
    required this.formation,
    this.width = 80,
    this.height = 110,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _FormationPreviewPainter(
          positions: formation.positions,
          dotColor: dotColor,
        ),
      ),
    );
  }
}

class _FormationPreviewPainter extends CustomPainter {
  final List<FormationPosition> positions;
  final Color? dotColor;

  const _FormationPreviewPainter({required this.positions, this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Pitch background
    final pitchPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.pitchDark, AppColors.pitchMid],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)),
      pitchPaint,
    );

    // Pitch lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final padX = size.width * 0.04;
    final padY = size.height * 0.03;

    // Outer rect
    canvas.drawRect(
        Rect.fromLTWH(padX, padY, size.width - padX * 2, size.height - padY * 2),
        linePaint);

    // Centre line
    canvas.drawLine(
      Offset(padX, size.height / 2),
      Offset(size.width - padX, size.height / 2),
      linePaint,
    );

    // Centre circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.14,
      linePaint,
    );

    // Player dots
    final colors = {
      PositionType.gk: AppColors.posGK,
      PositionType.def: AppColors.posDEF,
      PositionType.mid: AppColors.posMID,
      PositionType.fwd: AppColors.posFWD,
    };

    for (final pos in positions) {
      final cx = pos.dx * size.width;
      final cy = pos.dy * size.height;
      final color = dotColor ?? colors[pos.positionType] ?? AppColors.accentGreen;

      // Glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(cx, cy), 5, glowPaint);

      // Dot
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(cx, cy), 3.2, dotPaint);

      // Outline
      final outlinePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(Offset(cx, cy), 3.2, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FormationPreviewPainter old) =>
      old.positions != positions;
}
