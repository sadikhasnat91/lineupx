import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/player_model.dart';

/// A single player slot widget on the pitch.
/// Shows an empty "tap to fill" state or the assigned player.
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

  static const double _size = 58.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: _size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar / empty
                _buildAvatar(),

                // Captain badge
                if (isCaptain)
                  const Positioned(
                    top: -5,
                    right: -5,
                    child: _CaptainBadge(label: 'C', color: AppColors.captainGold),
                  ),

                if (isViceCaptain)
                  const Positioned(
                    top: -5,
                    right: -5,
                    child: _CaptainBadge(
                        label: 'V', color: AppColors.viceCaptainSilver),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Name label
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final posColor = AppHelpers.positionColor(positionLabel);

    if (player == null) {
      // Empty slot
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgDark.withOpacity(0.85),
          border: Border.all(
            color: posColor.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: posColor.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16, color: posColor.withOpacity(0.8)),
            const SizedBox(height: 1),
            Text(
              positionLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: posColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    // Filled slot
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppHelpers.avatarBgColor(player!.rating),
        border: Border.all(
          color: AppHelpers.ratingColor(player!.rating).withOpacity(0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppHelpers.ratingColor(player!.rating).withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: player!.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: player!.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _initialsWidget(),
                errorWidget: (_, __, ___) => _initialsWidget(),
              )
            : _initialsWidget(),
      ),
    );
  }

  Widget _initialsWidget() {
    return Container(
      color: AppHelpers.avatarBgColor(player?.rating ?? 70),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppHelpers.initials(player?.name ?? positionLabel),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppHelpers.ratingColor(player?.rating ?? 70),
            ),
          ),
          if (player != null)
            Text(
              player!.rating.toString(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppHelpers.ratingColor(player!.rating).withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    if (player == null) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Text(
        AppHelpers.shortName(player!.name),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }
}
