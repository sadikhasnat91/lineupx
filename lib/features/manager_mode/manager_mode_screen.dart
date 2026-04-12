import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/player_model.dart';
import '../../data/models/team_settings_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/formation_preview_widget.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/smart_image.dart';
import 'manager_controller.dart';

class ManagerModeScreen extends StatelessWidget {
  const ManagerModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ManagerController>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: GradientAppBar(
        title: 'Manager Mode',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: ctrl.refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentGreen),
          );
        }

        if (ctrl.activeLineup.value == null) {
          return _EmptyState();
        }

        return RefreshIndicator(
          color: AppColors.accentGreen,
          backgroundColor: AppColors.bgCard,
          onRefresh: ctrl.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ManagerHeader(ctrl: ctrl),
              ),
              SliverToBoxAdapter(
                child: _StatsRow(ctrl: ctrl),
              ),
              SliverToBoxAdapter(
                child: _TacticsCard(ctrl: ctrl),
              ),
              SliverToBoxAdapter(
                child: _TopPerformers(ctrl: ctrl),
              ),
              SliverToBoxAdapter(
                child: _StartingElevenCard(ctrl: ctrl),
              ),
              SliverToBoxAdapter(
                child: _BenchCard(ctrl: ctrl),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      }),
    );
  }
}

// â”€â”€ Empty state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.sports_soccer_rounded,
                  size: 40, color: AppColors.accentGreen),
            ),
            const SizedBox(height: 20),
            Text(
              'No Lineup Found',
              style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save a lineup from the Lineup Builder\nto unlock Manager Mode.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.formationSelection),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Build Lineup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Manager header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ManagerHeader extends StatelessWidget {
  final ManagerController ctrl;
  const _ManagerHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final lineup = ctrl.activeLineup.value!;
    final settings = lineup.teamSettings;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [settings.primaryColor, settings.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: settings.primaryColor.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // pitch preview
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: FormationPreviewWidget(formation: lineup.formation),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SmartImage(
                        source: settings.logoPath,
                        fit: BoxFit.cover,
                        fallback: const Icon(Icons.shield_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        settings.teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lineup.formation.name,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  lineup.name,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _HeaderPill(
                      icon: Icons.emoji_events_outlined,
                      label: settings.matchType.label,
                    ),
                    if (settings.coachName.trim().isNotEmpty ||
                        settings.coachImagePath?.isNotEmpty == true)
                      _HeaderPill(
                        icon: Icons.person_outline_rounded,
                        label: settings.coachName.trim().isEmpty
                            ? 'Manager'
                            : settings.coachName,
                        imageSource: settings.coachImagePath,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.lineupBuilder,
              arguments: {'lineup': lineup},
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Stats row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StatsRow extends StatelessWidget {
  final ManagerController ctrl;
  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child: _MiniStat(
                  label: 'Players',
                  value: '${ctrl.filledSlots}/11',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.accentGreen)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStat(
                  label: 'Avg OVR',
                  value: ctrl.avgRating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  color: AppColors.accentGold)),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStat(
                  label: 'Chemistry',
                  value: '${ctrl.chemistryScore.toStringAsFixed(0)}%',
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF7C4DFF))),
          const SizedBox(width: 10),
          Expanded(
              child: _MiniStat(
                  label: 'Bench',
                  value: '${ctrl.benchCount}',
                  icon: Icons.event_seat_rounded,
                  color: const Color(0xFF00BCD4))),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// â”€â”€ Tactics card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? imageSource;

  const _HeaderPill({
    required this.icon,
    required this.label,
    this.imageSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
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
                fallback: Icon(icon, size: 12, color: Colors.white70),
              ),
            )
          else
            Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticsCard extends StatelessWidget {
  final ManagerController ctrl;
  const _TacticsCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final s = ctrl.activeLineup.value!.teamSettings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              title: 'Tactics',
              icon: Icons.tune_rounded,
              onAction: () => Get.toNamed(
                AppRoutes.teamCustomization,
                arguments: {
                  'controller': ctrl,
                  'teamSettings': s,
                },
              ),
              actionLabel: 'Edit',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TacticChip(
                    label: s.attackStyle.label, icon: s.attackStyle.icon),
                _TacticChip(
                    label: s.defensiveStyle.label,
                    icon: s.defensiveStyle.icon),
                _TacticChip(
                    label: s.defensiveLine.label,
                    icon: s.defensiveLine.icon),
                _TacticChip(
                    label: '${s.width.label} width', icon: s.width.icon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TacticChip extends StatelessWidget {
  final String label;
  final String icon;

  const _TacticChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '$icon  $label',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.accentGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// â”€â”€ Top performers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TopPerformers extends StatelessWidget {
  final ManagerController ctrl;
  const _TopPerformers({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final tops = ctrl.topPlayers;
    if (tops.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(
              title: 'Top Performers',
              icon: Icons.emoji_events_rounded,
            ),
            const SizedBox(height: 12),
            Row(
              children: tops.asMap().entries.map((e) {
                final rank = e.key;
                final player = e.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: rank < tops.length - 1 ? 8 : 0),
                    child: _TopPlayerTile(
                        player: player, rank: rank + 1),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopPlayerTile extends StatelessWidget {
  final PlayerModel player;
  final int rank;

  const _TopPlayerTile({required this.player, required this.rank});

  @override
  Widget build(BuildContext context) {
    final medalColors = [
      AppColors.accentGold,
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final medalColor = rank <= 3 ? medalColors[rank - 1] : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _PlayerAvatar(player: player, size: 42),
          const SizedBox(height: 6),
          Text(
            player.name.split(' ').last,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            player.positions.isNotEmpty ? player.positions.first : '',
            style: TextStyle(
                color: AppHelpers.positionColor(
                    player.positions.isNotEmpty
                        ? player.positions.first
                        : 'MID'),
                fontSize: 10,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              player.rating.toStringAsFixed(0),
              style: TextStyle(
                  color: medalColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Starting eleven card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StartingElevenCard extends StatelessWidget {
  final ManagerController ctrl;
  const _StartingElevenCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final lineup = ctrl.activeLineup.value!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(
              title: 'Starting XI',
              icon: Icons.format_list_numbered_rounded,
            ),
            const SizedBox(height: 12),
            if (lineup.teamSettings.coachName.trim().isNotEmpty ||
                lineup.teamSettings.coachImagePath?.isNotEmpty == true) ...[
              _CoachRow(settings: lineup.teamSettings),
              const Divider(color: AppColors.border, height: 18),
            ],
            ...lineup.formation.positions.map((pos) {
              final player = lineup.playerSlots[pos.id];
              final isCaptain = player != null && player.id == lineup.captainId;
              final isVc =
                  player != null && player.id == lineup.viceCaptainId;
              return _SquadRow(
                position: pos.label,
                player: player,
                isCaptain: isCaptain,
                isVc: isVc,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CoachRow extends StatelessWidget {
  final TeamSettingsModel settings;

  const _CoachRow({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgCardElevated,
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: SmartImage(
            source: settings.coachImagePath,
            fit: BoxFit.cover,
            fallback: const Icon(Icons.person, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings.coachName.trim().isEmpty ? 'Manager' : settings.coachName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Coach / Manager slot',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'MGR',
            style: TextStyle(
              color: AppColors.accentBlue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SquadRow extends StatelessWidget {
  final String position;
  final PlayerModel? player;
  final bool isCaptain;
  final bool isVc;

  const _SquadRow({
    required this.position,
    required this.player,
    this.isCaptain = false,
    this.isVc = false,
  });

  @override
  Widget build(BuildContext context) {
    final posColor = AppHelpers.positionColor(position);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // position label
          Container(
            width: 36,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: posColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              position,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: posColor,
                  fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          if (player != null) _PlayerAvatar(player: player!, size: 30),
          if (player != null) const SizedBox(width: 10),
          Expanded(
            child: player != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              player!.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCaptain)
                            _Badge(label: 'C', color: AppColors.accentGold),
                          if (isVc)
                            _Badge(
                                label: 'VC',
                                color: const Color(0xFFC0C0C0)),
                        ],
                      ),
                      Text(
                        player!.number > 0
                            ? '#${player!.number} • ${player!.club}'
                            : player!.club,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : const Text('â€” Empty slot â€”',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
          ),
          if (player != null)
            Text(
              player!.rating.toStringAsFixed(0),
              style: TextStyle(
                color: AppHelpers.ratingColor(player!.rating.toInt()),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
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
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// â”€â”€ Bench card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _BenchCard extends StatelessWidget {
  final ManagerController ctrl;
  const _BenchCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final benchPlayers = ctrl.bench;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              title: 'Bench (${benchPlayers.length}/7)',
              icon: Icons.event_seat_rounded,
            ),
            if (benchPlayers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text('No bench players assigned',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic)),
                ),
              )
            else
              const SizedBox(height: 12),
            ...benchPlayers.map((player) => _SquadRow(
                  position: player.positions.isNotEmpty
                      ? player.positions.first
                      : 'SUB',
                  player: player,
                )),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Shared widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CardHeader(
      {required this.title,
      required this.icon,
      this.actionLabel,
      this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentGreen, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final PlayerModel player;
  final double size;

  const _PlayerAvatar({required this.player, required this.size});

  @override
  Widget build(BuildContext context) {
    final initials = AppHelpers.initials(player.name);
    final posColor = player.positions.isNotEmpty
        ? AppHelpers.positionColor(player.positions.first)
        : AppColors.textMuted;

    if (player.imageUrl.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.network(
            player.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _InitialsAvatar(initials: initials, color: posColor, size: size),
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : _InitialsAvatar(initials: initials, color: posColor, size: size),
          ),
        ),
      );
    }
    return _InitialsAvatar(initials: initials, color: posColor, size: size);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  const _InitialsAvatar(
      {required this.initials, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: color.withOpacity(0.2)),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
