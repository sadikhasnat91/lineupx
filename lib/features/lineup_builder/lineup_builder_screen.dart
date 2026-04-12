import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' if (dart.library.html) 'dart:io';
import 'dart:typed_data';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/player_model.dart';
import '../../data/models/team_settings_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/smart_image.dart';
import '../player_selection/player_selection_sheet.dart';
import 'lineup_controller.dart';
import 'widgets/pitch_painter.dart';
import 'widgets/player_slot_widget.dart';

class LineupBuilderScreen extends StatelessWidget {
  const LineupBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LineupController>();
    final screenshotController = ScreenshotController();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: GradientAppBar(
        title: controller.lineup.teamSettings.teamName,
        actions: [
          // Customize team
          IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () => Get.toNamed(
              AppRoutes.teamCustomization,
              arguments: {
                'controller': controller,
                'teamSettings': controller.teamSettings.value,
              },
            ),
          ),
          // Export
          IconButton(
            icon: const Icon(Icons.ios_share_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () => _export(screenshotController),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats bar ──────────────────────────────────────────────────
          _StatsBar(controller: controller),

          // ── Pitch + player slots ───────────────────────────────────────
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: _PitchArea(controller: controller),
            ),
          ),

          // ── Bench ──────────────────────────────────────────────────────
          _BenchSection(controller: controller),

          // ── Bottom actions ─────────────────────────────────────────────
          _BottomBar(controller: controller),
        ],
      ),
    );
  }

  Future<void> _export(ScreenshotController sc) async {
    try {
      final Uint8List? bytes = await sc.capture(pixelRatio: 2.5);
      if (bytes == null) return;

      if (kIsWeb) {
        // On web, use in-memory XFile (share_plus handles web download fallback)
        await Share.shareXFiles(
          [XFile.fromData(bytes, name: 'lineupx_export.png', mimeType: 'image/png')],
          text: 'Built with LineupX – Dream XI Builder',
        );
      } else {
        final dir = Directory.systemTemp;
        final file =
            await File('${dir.path}/lineupx_export.png').writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: 'Built with LineupX – Dream XI Builder',
        );
      }
    } catch (e) {
      Get.snackbar('Export failed', e.toString(),
          backgroundColor: AppColors.bgCard,
          colorText: AppColors.textPrimary);
    }
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final LineupController controller;
  const _StatsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() {
        final settings = controller.teamSettings.value;
        final showMeta = settings.coachName.trim().isNotEmpty ||
            settings.matchType != MatchType.classic ||
            (settings.logoPath?.isNotEmpty == true) ||
            (settings.coachImagePath?.isNotEmpty == true);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label:
                      '${controller.filledCount}/${controller.lineup.formation.positions.length}',
                  sublabel: 'Players',
                  color: AppColors.accentGreen,
                ),
                _StatChip(
                  label: controller.avgRating > 0
                      ? controller.avgRating.toStringAsFixed(1)
                      : '–',
                  sublabel: 'Avg OVR',
                  color: AppHelpers.ratingColor(controller.avgRating.toInt()),
                ),
                _StatChip(
                  label: '${controller.chemistry}%',
                  sublabel: 'Chemistry',
                  color: controller.chemistry >= 80
                      ? AppColors.success
                      : AppColors.warning,
                ),
                Text(
                  controller.lineup.formation.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentGreen,
                  ),
                ),
              ],
            ),
            if (showMeta) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (settings.logoPath?.isNotEmpty == true)
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SmartImage(
                        source: settings.logoPath,
                        fit: BoxFit.cover,
                        fallback: const Icon(Icons.shield_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          icon: Icons.emoji_events_outlined,
                          label: settings.matchType.label,
                        ),
                        if (settings.coachName.trim().isNotEmpty)
                          _MetaChip(
                            icon: Icons.person_outline_rounded,
                            label: settings.coachName,
                            imageSource: settings.coachImagePath,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? imageSource;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.imageSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageSource?.isNotEmpty == true)
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 5),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: SmartImage(
                source: imageSource,
                fit: BoxFit.cover,
                fallback: Icon(icon, size: 12, color: AppColors.textMuted),
              ),
            )
          else
            Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  const _StatChip(
      {required this.label,
      required this.sublabel,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color)),
        Text(sublabel,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

// ── Pitch area ────────────────────────────────────────────────────────────────

class _PitchArea extends StatelessWidget {
  final LineupController controller;
  const _PitchArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final pitchW = constraints.maxWidth;
      final pitchH = constraints.maxHeight;

      return Stack(
        children: [
          // Pitch painter
          Positioned.fill(
            child: CustomPaint(painter: const PitchPainter()),
          ),

          // Player slots
          ...controller.lineup.formation.positions
              .map((pos) => Obx(() {
                    final player =
                        controller.slots[pos.id]?.value;
                    final isCaptain =
                        player != null &&
                            controller.captainId.value ==
                                player.id;
                    final isVC =
                        player != null &&
                            controller.viceCaptainId.value ==
                                player.id;

                    final slotW = 64.0;
                    final slotH = player != null ? 80.0 : 68.0;
                    final left =
                        pos.dx * pitchW - slotW / 2;
                    final top =
                        pos.dy * pitchH - slotH / 2;

                    return Positioned(
                      left: left.clamp(0, pitchW - slotW),
                      top: top.clamp(0, pitchH - slotH),
                      child: PlayerSlotWidget(
                        positionId: pos.id,
                        positionLabel: pos.label,
                        player: player,
                        isCaptain: isCaptain,
                        isViceCaptain: isVC,
                        onTap: () => _openPlayerSelection(
                            context, controller, pos.id, pos.label),
                        onLongPress: player != null
                            ? () => _showSlotOptions(
                                context, controller, pos.id, player)
                            : null,
                      ),
                    );
                  })),
        ],
      );
    });
  }

  void _openPlayerSelection(
    BuildContext context,
    LineupController controller,
    String positionId,
    String positionLabel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Player',
              style: GoogleFonts.rajdhani(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              positionLabel,
              style: TextStyle(
                fontSize: 12,
                color: AppHelpers.positionColor(positionLabel),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Browse database
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PlayerSelectionSheet(
                      positionLabel: positionLabel,
                      onPlayerSelected: (player) {
                        controller.assignPlayer(positionId, player);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Browse Players Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Type custom name
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _typeCustomName(context, controller, positionId, positionLabel);
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Type Player Name'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                  side: const BorderSide(color: AppColors.accentBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _typeCustomName(
    BuildContext context,
    LineupController controller,
    String positionId,
    String positionLabel,
  ) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enter Player Name',
          style: GoogleFonts.rajdhani(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Sadik, Ashfaq...',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accentGreen),
            ),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              Navigator.pop(context);
              controller.assignPlayer(
                positionId,
                PlayerModel.custom(name: v.trim(), position: positionLabel),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              controller.assignPlayer(
                positionId,
                PlayerModel.custom(name: name, position: positionLabel),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editJerseyNumberDialog(
    BuildContext context,
    LineupController controller,
    String positionId,
    PlayerModel player,
  ) {
    final numberCtrl = TextEditingController(
      text: player.number > 0 ? player.number.toString() : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Jersey Number',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: numberCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Optional e.g. 7, 10, 99',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accentGreen),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final raw = numberCtrl.text.trim();
              final parsed = int.tryParse(raw) ?? 0;
              controller.updatePlayerNumber(positionId, parsed);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.black87,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSlotOptions(
    BuildContext context,
    LineupController controller,
    String positionId,
    PlayerModel player,
  ) {
    final isCaptain = controller.captainId.value == player.id;
    final isVC = controller.viceCaptainId.value == player.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Player name
            Text(
              player.name,
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${player.club} · ${player.country}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),

            _OptionRow(
              icon: Icons.star_rounded,
              label: isCaptain ? 'Remove Captain' : 'Set as Captain',
              color: AppColors.accentGold,
              onTap: () {
                controller.setCaptain(player.id);
                Navigator.pop(context);
              },
            ),
            _OptionRow(
              icon: Icons.star_half_rounded,
              label:
                  isVC ? 'Remove Vice Captain' : 'Set as Vice Captain',
              color: AppColors.viceCaptainSilver,
              onTap: () {
                controller.setViceCaptain(player.id);
                Navigator.pop(context);
              },
            ),
            _OptionRow(
              icon: Icons.swap_horiz_rounded,
              label: 'Change Player',
              color: AppColors.accentBlue,
              onTap: () {
                Navigator.pop(context);
                _openPlayerSelection(context, controller, positionId,
                    player.primaryPosition);
              },
            ),
            _OptionRow(
              icon: Icons.numbers_rounded,
              label: 'Edit Jersey Number',
              color: AppColors.accentGreen,
              onTap: () {
                Navigator.pop(context);
                _editJerseyNumberDialog(context, controller, positionId, player);
              },
            ),
            _OptionRow(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Move to Bench',
              color: AppColors.accentGreen,
              onTap: () {
                controller.addBenchPlayer(player);
                controller.clearSlot(positionId);
                Navigator.pop(context);
              },
            ),
            _OptionRow(
              icon: Icons.person_remove_outlined,
              label: 'Remove from Lineup',
              color: AppColors.error,
              onTap: () {
                controller.clearSlot(positionId);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionRow(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14)),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Bench section ─────────────────────────────────────────────────────────────

class _BenchSection extends StatelessWidget {
  final LineupController controller;
  const _BenchSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'BENCH',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                      '${controller.bench.length}/7',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 68,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                children: [
                  // Add bench player
                  GestureDetector(
                    onTap: () => _openBenchSelection(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      margin:
                          const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(
                          color: AppColors.accentGreen.withOpacity(0.4),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.accentGreen, size: 20),
                    ),
                  ),

                  // Bench players
                  ...controller.bench.map((player) => GestureDetector(
                        onLongPress: () =>
                            controller.removeBenchPlayer(player),
                        child: _BenchPlayerChip(player: player),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openBenchSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerSelectionSheet(
        positionLabel: 'ALL',
        onPlayerSelected: (player) {
          controller.addBenchPlayer(player);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _BenchPlayerChip extends StatelessWidget {
  final PlayerModel player;
  const _BenchPlayerChip({required this.player});

  @override
  Widget build(BuildContext context) {
    final color = AppHelpers.ratingColor(player.rating);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppHelpers.avatarBgColor(player.rating),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${player.rating}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            player.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final LineupController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.save,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87),
                        )
                      : const Icon(Icons.save_rounded, size: 16),
                  label: Text(
                    controller.isSaving.value
                        ? 'Saving...'
                        : 'Save Lineup',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
