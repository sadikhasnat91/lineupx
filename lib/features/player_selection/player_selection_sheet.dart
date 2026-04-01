import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/player_model.dart';
import '../../widgets/player_card_widget.dart';
import 'player_selection_controller.dart';

class PlayerSelectionSheet extends StatelessWidget {
  final String positionLabel;
  final void Function(PlayerModel) onPlayerSelected;

  const PlayerSelectionSheet({
    super.key,
    required this.positionLabel,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Create controller scoped to this bottom sheet
    final controller = Get.put(
      PlayerSelectionController(positionLabel: positionLabel),
      tag: positionLabel + DateTime.now().millisecondsSinceEpoch.toString(),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ──────────────────────────────────────────────
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Player',
                          style: GoogleFonts.rajdhani(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (positionLabel != 'ALL')
                          Text(
                            AppHelpers.positionFullName(positionLabel),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppHelpers.positionColor(positionLabel),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Clear filters
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Search bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => controller.searchQuery.value = v,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search players, clubs...',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 18),
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Filter chips ─────────────────────────────────────────
              _FilterChipsRow(controller: controller),

              const SizedBox(height: 8),

              // ── Player list ──────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _ShimmerList();
                  }
                  if (controller.filtered.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_rounded,
                              size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text('No players found',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 15)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.filtered.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (_, i) => PlayerCardWidget(
                      player: controller.filtered[i],
                      onTap: () {
                        onPlayerSelected(controller.filtered[i]);
                        controller.onClose();
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  final PlayerSelectionController controller;
  const _FilterChipsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Rating filter
              _ratingChip(controller, 0, 'All Ratings'),
              _ratingChip(controller, 80, '80+'),
              _ratingChip(controller, 85, '85+'),
              _ratingChip(controller, 90, '90+'),
              const SizedBox(width: 8),
              // Club filter
              if (controller.clubs.isNotEmpty)
                _FilterDropdown(
                  value: controller.selectedClub.value.isEmpty
                      ? null
                      : controller.selectedClub.value,
                  hint: 'Club',
                  items: controller.clubs,
                  onChanged: (v) =>
                      controller.selectedClub.value = v ?? '',
                ),
              const SizedBox(width: 8),
              // Country filter
              if (controller.countries.isNotEmpty)
                _FilterDropdown(
                  value: controller.selectedCountry.value.isEmpty
                      ? null
                      : controller.selectedCountry.value,
                  hint: 'Country',
                  items: controller.countries,
                  onChanged: (v) =>
                      controller.selectedCountry.value = v ?? '',
                ),
              const SizedBox(width: 8),
              // Sort
              _SortChip(controller: controller),
            ],
          )),
    );
  }

  Widget _ratingChip(
      PlayerSelectionController c, int rating, String label) {
    return Obx(() {
      final isSelected = c.minRating.value == rating;
      return GestureDetector(
        onTap: () => c.minRating.value = rating,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 6),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentGreen
                : AppColors.bgCardElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected
                    ? AppColors.accentGreen
                    : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.black87
                  : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: value != null
            ? AppColors.accentBlue.withOpacity(0.15)
            : AppColors.bgCardElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value != null ? AppColors.accentBlue : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
          dropdownColor: AppColors.bgCard,
          isDense: true,
          iconSize: 14,
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.textMuted),
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 11),
          items: [
            DropdownMenuItem(value: null, child: Text('All $hint')),
            ...items.map((s) => DropdownMenuItem(value: s, child: Text(s))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final PlayerSelectionController controller;
  const _SortChip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => controller.sortDesc.value = !controller.sortDesc.value,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCardElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.sortDesc.value
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Rating',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ));
  }
}

// ── Shimmer loading ───────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCardElevated,
      highlightColor: AppColors.bgSurface,
      child: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemBuilder: (_, __) => Container(
          height: 76,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
