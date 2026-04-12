import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/formation_data.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/formation_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/team_settings_model.dart';
import '../../features/lineup_builder/widgets/jersey_painter.dart';
import '../../features/lineup_builder/widgets/pitch_painter.dart';
import '../../widgets/gradient_app_bar.dart';
import '../player_selection/player_selection_sheet.dart';

/// 11 vs 11 on a single football pitch — each team picks its own formation.
class VersusScreen extends StatefulWidget {
  const VersusScreen({super.key});

  @override
  State<VersusScreen> createState() => _VersusScreenState();
}

class _VersusScreenState extends State<VersusScreen> {
  final _team1Name = TextEditingController(text: 'Team A');
  final _team2Name = TextEditingController(text: 'Team B');
  final _team1Coach = TextEditingController();
  final _team2Coach = TextEditingController();

  MatchType _matchType = MatchType.classic;
  FormationModel _team1Formation = FormationData.f433;
  FormationModel _team2Formation = FormationData.f442;

  // Keyed by position-id from formation
  final Map<String, PlayerModel?> _team1Slots = {};
  final Map<String, PlayerModel?> _team2Slots = {};

  @override
  void initState() {
    super.initState();
    _resetSlots(_team1Slots, _team1Formation);
    _resetSlots(_team2Slots, _team2Formation);
  }

  void _resetSlots(Map<String, PlayerModel?> slots, FormationModel f) {
    slots.clear();
    for (final p in f.positions) {
      slots[p.id] = null;
    }
  }

  void _changeFormation(bool isTeam1, FormationModel f) {
    setState(() {
      if (isTeam1) {
        _team1Formation = f;
        _resetSlots(_team1Slots, f);
      } else {
        _team2Formation = f;
        _resetSlots(_team2Slots, f);
      }
    });
  }

  @override
  void dispose() {
    _team1Name.dispose();
    _team2Name.dispose();
    _team1Coach.dispose();
    _team2Coach.dispose();
    super.dispose();
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: GradientAppBar(
        title: '11 vs 11 · ${_matchType.label}',
        actions: [
          PopupMenuButton<MatchType>(
            tooltip: 'Match type',
            color: AppColors.bgCard,
            icon: const Icon(Icons.emoji_events_outlined,
                color: AppColors.textSecondary),
            onSelected: (value) => setState(() => _matchType = value),
            itemBuilder: (_) => MatchType.values
                .map(
                  (type) => PopupMenuItem<MatchType>(
                    value: type,
                    child: Text(
                      type.label,
                      style: TextStyle(
                        color: type == _matchType
                            ? AppColors.accentGreen
                            : AppColors.textPrimary,
                        fontWeight: type == _matchType
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTeamBar(isTeam1: true),
          Expanded(child: _buildPitch()),
          _buildTeamBar(isTeam1: false),
          _buildStatsBar(),
        ],
      ),
    );
  }

  // ── team bar (name + formation picker + count) ───────────────────────────

  Widget _buildTeamBar({required bool isTeam1}) {
    final ctrl = isTeam1 ? _team1Name : _team2Name;
    final coachCtrl = isTeam1 ? _team1Coach : _team2Coach;
    final formation = isTeam1 ? _team1Formation : _team2Formation;
    final color = isTeam1 ? AppColors.accentGreen : AppColors.accentBlue;
    final slots = isTeam1 ? _team1Slots : _team2Slots;
    final filled = slots.values.where((p) => p != null).length;

    return Container(
      color: AppColors.bgDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Team name…',
                    hintStyle: TextStyle(color: color.withOpacity(0.4)),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              _formationPicker(isTeam1, formation, color),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$filled/11',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          // Coach name row
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 12,
                  color: color.withOpacity(0.5)),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: coachCtrl,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.7),
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Coach name…',
                    hintStyle: TextStyle(
                        color: color.withOpacity(0.25), fontSize: 10),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formationPicker(
      bool isTeam1, FormationModel current, Color color) {
    return PopupMenuButton<FormationModel>(
      offset: const Offset(0, 36),
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (f) => _changeFormation(isTeam1, f),
      itemBuilder: (_) => FormationData.all
          .map((f) => PopupMenuItem(
                value: f,
                child: Text(
                  f.name,
                  style: TextStyle(
                    color:
                        f.id == current.id ? color : AppColors.textPrimary,
                    fontWeight:
                        f.id == current.id ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.name,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  // ── football pitch with both teams ───────────────────────────────────────

  Widget _buildPitch() {
    return LayoutBuilder(builder: (context, constraints) {
      final pitchW = constraints.maxWidth;
      final pitchH = constraints.maxHeight;

      const slotW = 48.0;
      const slotH = 62.0;

      final children = <Widget>[
        // pitch background
        Positioned.fill(
            child: CustomPaint(painter: const PitchPainter())),

        // VS badge at the centre circle
        Positioned(
          left: pitchW / 2 - 22,
          top: pitchH / 2 - 14,
          child: Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.bgDark.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              'VS',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ];

      // ── Team A (top half — own goal at top, attackers near centre) ──
      for (final pos in _team1Formation.positions) {
        final player = _team1Slots[pos.id];
        // dy 0.89 (GK) → near top,  dy 0.14 (ST) → near centre
        final x = pos.dx * pitchW - slotW / 2;
        final y = (1.0 - pos.dy) * (pitchH * 0.47) + pitchH * 0.01;
        children.add(_positionedSlot(
          x: x,
          y: y,
          minY: 2,
          maxY: pitchH * 0.48 - slotH,
          pitchW: pitchW,
          slotW: slotW,
          player: player,
          posLabel: pos.label,
          accent: AppColors.accentGreen,
          onTap: () =>
              _openOptions(_team1Slots, pos.id, pos.label, AppColors.accentGreen),
          onLongPress: player != null
              ? () => setState(() => _team1Slots[pos.id] = null)
              : null,
        ));
      }

      // ── Team B (bottom half — own goal at bottom, attackers near centre) ──
      for (final pos in _team2Formation.positions) {
        final player = _team2Slots[pos.id];
        // mirror horizontally so formations face each other
        final x = (1.0 - pos.dx) * pitchW - slotW / 2;
        final y = pitchH * 0.53 + pos.dy * (pitchH * 0.47) - pitchH * 0.01;
        children.add(_positionedSlot(
          x: x,
          y: y,
          minY: pitchH * 0.52,
          maxY: pitchH - slotH - 2,
          pitchW: pitchW,
          slotW: slotW,
          player: player,
          posLabel: pos.label,
          accent: AppColors.accentBlue,
          onTap: () =>
              _openOptions(_team2Slots, pos.id, pos.label, AppColors.accentBlue),
          onLongPress: player != null
              ? () => setState(() => _team2Slots[pos.id] = null)
              : null,
        ));
      }

      return ClipRect(child: Stack(children: children));
    });
  }

  Widget _positionedSlot({
    required double x,
    required double y,
    required double minY,
    required double maxY,
    required double pitchW,
    required double slotW,
    required PlayerModel? player,
    required String posLabel,
    required Color accent,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Positioned(
      left: x.clamp(2.0, pitchW - slotW - 2),
      top: y.clamp(minY, maxY),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 48,
          height: 62,
          child: _PitchSlot(
            player: player,
            posLabel: posLabel,
            accentColor: accent,
          ),
        ),
      ),
    );
  }

  // ── stats bar ────────────────────────────────────────────────────────────

  Widget _buildStatsBar() {
    final t1Avg = _avgRating(_team1Slots);
    final t2Avg = _avgRating(_team2Slots);
    final t1Filled = _team1Slots.values.where((p) => p != null).length;
    final t2Filled = _team2Slots.values.where((p) => p != null).length;

    return Container(
      color: AppColors.bgDark,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Text(
            '${_team1Name.text.isEmpty ? 'Team A' : _team1Name.text}  '
            '$t1Filled/11 · ${t1Avg > 0 ? t1Avg.toStringAsFixed(1) : '–'} OVR',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.accentGreen),
          ),
          const Spacer(),
          Text(
            '${t2Avg > 0 ? t2Avg.toStringAsFixed(1) : '–'} OVR · '
            '$t2Filled/11  '
            '${_team2Name.text.isEmpty ? 'Team B' : _team2Name.text}',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue),
          ),
        ],
      ),
    );
  }

  double _avgRating(Map<String, PlayerModel?> slots) {
    final filled = slots.values.whereType<PlayerModel>().toList();
    if (filled.isEmpty) return 0;
    return filled.fold<int>(0, (s, p) => s + p.rating) / filled.length;
  }

  // ── slot interaction sheets ──────────────────────────────────────────────

  void _openOptions(
    Map<String, PlayerModel?> slots,
    String posId,
    String posLabel,
    Color accent,
  ) {
    final player = slots[posId];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            Text(
              player != null ? player.name : posLabel,
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
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
                      positionLabel: posLabel,
                      onPlayerSelected: (p) {
                        setState(() => slots[posId] = p);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Browse Players Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Type custom name
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _typeCustomName(slots, posId, accent);
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Type Player Name'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (player != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => slots[posId] = null);
                    Navigator.pop(context);
                  },
                  icon:
                      const Icon(Icons.person_remove_outlined, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _typeCustomName(
      Map<String, PlayerModel?> slots, String posId, Color accent) {
    final ctrl =
        TextEditingController(text: slots[posId]?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          posId.toUpperCase(),
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Sadik, Ashfaq…',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: accent),
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
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              setState(() => slots[posId] = PlayerModel.custom(name: name));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Compact pitch slot (jersey + label) ──────────────────────────────────────

class _PitchSlot extends StatelessWidget {
  final PlayerModel? player;
  final String posLabel;
  final Color accentColor;

  const _PitchSlot({
    required this.player,
    required this.posLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = player == null;
    final borderColor = isEmpty
        ? accentColor.withOpacity(0.5)
        : AppHelpers.ratingColor(player!.rating);
    final fillColor =
        isEmpty ? AppColors.bgCard : AppHelpers.avatarBgColor(player!.rating);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: JerseyPainter(
                  fillColor: fillColor,
                  borderColor: isEmpty ? accentColor : borderColor,
                  isEmpty: isEmpty,
                ),
                child: const SizedBox.expand(),
              ),
              if (isEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    Icon(Icons.add_rounded,
                        size: 11, color: accentColor.withOpacity(0.7)),
                    Text(
                      posLabel,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${player!.rating}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: borderColor,
                      shadows: [
                        Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Container(
          constraints: const BoxConstraints(maxWidth: 54),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: isEmpty
              ? null
              : BoxDecoration(
                  color: AppColors.bgDark.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: AppColors.border.withOpacity(0.4)),
                ),
          child: Text(
            isEmpty ? '' : player!.name,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
