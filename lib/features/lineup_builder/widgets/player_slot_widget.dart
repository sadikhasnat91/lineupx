import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/player_model.dart';
import 'jersey_painter.dart';

/// A single player slot widget on the pitch.
/// Shows an empty "tap to fill" state or the assigned player — jersey shaped.
class PlayerSlotWidget extends StatelessWidget {
  final String positionId;
  final String positionLabel;
  final PlayerModel? player;
  final bool isCaptain;
  final bool isViceCaptain;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const PlayerSlotWidget({
    super.key,
    required this.positionId,
    required this.positionLabel,
    required this.player,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.onTap,
    this.onLongPress,
  });

  static const double _w = 54.0;
  static const double _h = 60.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: _w + 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _buildJersey(),
                if (isCaptain)
                  const Positioned(
                    top: -4,
                    right: 0,
                    child: _CaptainBadge(label: 'C', color: AppColors.captainGold),
                  ),
                if (isViceCaptain)
                  const Positioned(
                    top: -4,
                    right: 0,
                    child: _CaptainBadge(label: 'V', color: AppColors.viceCaptainSilver),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildJersey() {
    final posColor = AppHelpers.positionColor(positionLabel);

    if (player == null) {
      return SizedBox(
        width: _w,
        height: _h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(_w, _h),
              painter: JerseyPainter(
                fillColor: AppColors.bgDark,
                borderColor: posColor,
                isEmpty: true,
              ),
            ),
            Positioned(
              top: _h * 0.28,
              child: Column(
                children: [
                  Icon(Icons.add_rounded, size: 13, color: posColor.withOpacity(0.8)),
                  Text(
                    positionLabel,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: posColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final ratingColor = AppHelpers.ratingColor(player!.rating);
    final jerseyFill = AppHelpers.avatarBgColor(player!.rating);

    return SizedBox(
      width: _w,
      height: _h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(_w, _h),
            painter: JerseyPainter(
              fillColor: jerseyFill,
              borderColor: ratingColor,
            ),
          ),
          Positioned(
            top: _h * 0.22,
            child: Text(
              '${player!.rating}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: ratingColor,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.6), blurRadius: 4),
                ],
              ),
            ),
          ),
          if (player!.number > 0)
            Positioned(
              top: _h * 0.56,
              child: Text(
                '#${player!.number}',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    if (player == null) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxWidth: 72),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.88),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Text(
        player!.name,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.15,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}

class _CaptainBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CaptainBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }
}
