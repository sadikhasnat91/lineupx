import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import '../data/models/player_model.dart';

/// Rich player card shown in the player selection list.
class PlayerCardWidget extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback? onTap;
  final bool isSelected;

  const PlayerCardWidget({
    super.key,
    required this.player,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGreen.withOpacity(0.12)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              _PlayerAvatar(player: player),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          player.club,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          ' Â· ',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          player.country,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Positions row
                    Wrap(
                      spacing: 4,
                      children: player.positions
                          .take(3)
                          .map(
                            (pos) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppHelpers.positionColor(pos)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pos,
                                style: TextStyle(
                                  color: AppHelpers.positionColor(pos),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Rating
              Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppHelpers.ratingColor(player.rating)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppHelpers.ratingColor(player.rating)
                            .withOpacity(0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      player.rating.toString(),
                      style: TextStyle(
                        color: AppHelpers.ratingColor(player.rating),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${player.number}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accentGreen,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular avatar with fallback initials.
class _PlayerAvatar extends StatelessWidget {
  final PlayerModel player;

  const _PlayerAvatar({required this.player});

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_size / 2.5),
        child: player.imageUrl.isNotEmpty
            ? Image.network(
                player.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _initials(),
              )
            : _initials(),
      ),
    );
  }

  Widget _initials() {
    return Container(
      color: AppHelpers.avatarBgColor(player.rating),
      alignment: Alignment.center,
      child: Text(
        AppHelpers.initials(player.name),
        style: TextStyle(
          color: AppHelpers.ratingColor(player.rating),
          fontSize: _size * 0.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
