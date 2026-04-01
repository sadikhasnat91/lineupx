import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/lineup_model.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/formation_preview_widget.dart';
import 'saved_lineups_controller.dart';

class SavedLineupsScreen extends StatelessWidget {
  const SavedLineupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SavedLineupsController>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: const GradientAppBar(title: 'Saved Lineups'),
      body: Obx(() {
        if (controller.lineups.isEmpty) {
          return _EmptyState();
        }
        return RefreshIndicator(
          onRefresh: () async => controller.load(),
          color: AppColors.accentGreen,
          backgroundColor: AppColors.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: controller.lineups.length,
            itemBuilder: (_, i) => _LineupCard(
              lineup: controller.lineups[i],
              onTap: () => controller.openLineup(controller.lineups[i]),
              onDelete: () => _confirmDelete(context, controller,
                  controller.lineups[i]),
            ),
          ),
        );
      }),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SavedLineupsController controller,
    LineupModel lineup,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Lineup?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove "${lineup.name}" permanently?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.delete(lineup);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Saved lineup card ─────────────────────────────────────────────────────────

class _LineupCard extends StatelessWidget {
  final LineupModel lineup;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LineupCard({
    required this.lineup,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final avgRating = lineup.averageRating;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Top section: info + formation preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formation mini preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FormationPreviewWidget(
                      formation: lineup.formation,
                      width: 72,
                      height: 96,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lineup.name,
                          style: GoogleFonts.rajdhani(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            _Badge(
                              label: lineup.formation.name,
                              color: AppColors.accentGreen,
                            ),
                            const SizedBox(width: 6),
                            if (lineup.formation.isCustom)
                              _Badge(
                                  label: 'CUSTOM',
                                  color: AppColors.accentGold),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _StatMini(
                              value: '${lineup.filledSlots}/11',
                              label: 'Players',
                              color: lineup.isComplete
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 16),
                            if (avgRating > 0)
                              _StatMini(
                                value: avgRating.toStringAsFixed(1),
                                label: 'OVR',
                                color: AppHelpers.ratingColor(
                                    avgRating.toInt()),
                              ),
                            const SizedBox(width: 16),
                            if (lineup.benchPlayers.isNotEmpty)
                              _StatMini(
                                value:
                                    '${lineup.benchPlayers.length}',
                                label: 'Bench',
                                color: AppColors.accentBlue,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Updated ${AppHelpers.formatDate(lineup.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action bar
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.edit_rounded,
                          size: 15, color: AppColors.accentGreen),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                            color: AppColors.accentGreen, fontSize: 12),
                      ),
                    ),
                  ),
                  Container(
                      width: 1, height: 24, color: AppColors.border),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 15, color: AppColors.error),
                      label: const Text(
                        'Delete',
                        style: TextStyle(
                            color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatMini(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 72,
            color: AppColors.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved lineups yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create and save your first lineup\nto see it here.',
            style: TextStyle(
                fontSize: 13, color: AppColors.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Create Lineup'),
          ),
        ],
      ),
    );
  }
}
