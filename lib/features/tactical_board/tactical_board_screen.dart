import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/player_repository.dart';
import '../lineup_builder/widgets/pitch_painter.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kTeamA = Color(0xFF00E676);
const _kTeamB = Color(0xFFFF5252);
const _kBall = Color(0xFFFFD700);

const _kPenColors = <Color>[
  Colors.white,
  Color(0xFFFFEB3B),
  Color(0xFF00E676),
  Color(0xFFFF5252),
  Color(0xFF448AFF),
  Color(0xFFE040FB),
];

// ── Enums ─────────────────────────────────────────────────────────────────────

enum _Tool { move, pass, run, draw, erase }

// ── Models ────────────────────────────────────────────────────────────────────

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool dashed;
  final bool arrow;

  const _Stroke({
    required this.points,
    required this.color,
    this.width = 2.5,
    this.dashed = false,
    this.arrow = false,
  });
}

class _Token {
  Offset pos; // fractional 0..1
  Color color;
  String label;
  String? imageUrl; // network image for logos/coaches

  _Token({
    required this.pos,
    required this.color,
    required this.label,
    this.imageUrl,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TacticalBoardScreen extends StatefulWidget {
  const TacticalBoardScreen({super.key});

  @override
  State<TacticalBoardScreen> createState() => _TacticalBoardScreenState();
}

class _TacticalBoardScreenState extends State<TacticalBoardScreen> {
  _Tool _tool = _Tool.move;
  Color _pen = Colors.white;

  final List<_Stroke> _strokes = [];
  List<Offset>? _active;
  int? _dragIdx;
  final List<_Token> _tokens = [];

  Size _pitchSz = Size.zero;

  // ── Team settings ───────────────────────────────────────────────────────
  String? _teamALogo;
  String? _teamBLogo;
  String? _coachAName;
  String? _coachAImage;
  String? _coachBName;
  String? _coachBImage;

  // Database cache
  List<PlayerModel> _allPlayers = [];
  List<_ClubEntry> _clubs = [];
  bool _dbLoaded = false;

  @override
  void initState() {
    super.initState();
    _resetTokens();
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    try {
      final repo = Get.find<PlayerRepository>();
      _allPlayers = await repo.getAll();
    } catch (_) {
      _allPlayers = [];
    }

    // Build unique club list with logos
    final seen = <String>{};
    final clubs = <_ClubEntry>[];
    for (final p in _allPlayers) {
      if (p.club.isNotEmpty && seen.add(p.club)) {
        clubs.add(_ClubEntry(name: p.club, logoUrl: p.clubLogoUrl));
      }
    }
    clubs.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _clubs = clubs;
      _dbLoaded = true;
    });
  }

  // ── Token setup ─────────────────────────────────────────────────────────

  void _resetTokens() {
    _tokens.clear();

    // Team A (bottom half) – 4‑3‑3
    for (final t in <(double, double, String)>[
      (0.50, 0.93, 'GK'),
      (0.15, 0.80, 'LB'),
      (0.38, 0.82, 'CB'),
      (0.62, 0.82, 'CB'),
      (0.85, 0.80, 'RB'),
      (0.25, 0.67, 'CM'),
      (0.50, 0.64, 'CM'),
      (0.75, 0.67, 'CM'),
      (0.20, 0.55, 'LW'),
      (0.50, 0.52, 'ST'),
      (0.80, 0.55, 'RW'),
    ]) {
      _tokens
          .add(_Token(pos: Offset(t.$1, t.$2), color: _kTeamA, label: t.$3));
    }

    // Team B (top half) – 4‑3‑3 mirror
    for (final t in <(double, double, String)>[
      (0.50, 0.07, 'GK'),
      (0.85, 0.20, 'LB'),
      (0.62, 0.18, 'CB'),
      (0.38, 0.18, 'CB'),
      (0.15, 0.20, 'RB'),
      (0.75, 0.33, 'CM'),
      (0.50, 0.36, 'CM'),
      (0.25, 0.33, 'CM'),
      (0.80, 0.45, 'LW'),
      (0.50, 0.48, 'ST'),
      (0.20, 0.45, 'RW'),
    ]) {
      _tokens
          .add(_Token(pos: Offset(t.$1, t.$2), color: _kTeamB, label: t.$3));
    }

    // Ball
    _tokens.add(
        _Token(pos: const Offset(0.50, 0.50), color: _kBall, label: '●'));

    // Re-add any active logos / coaches
    _syncSpecialTokens();
  }

  /// Ensures logo & coach tokens exist (or are updated) without duplicating.
  void _syncSpecialTokens() {
    _tokens.removeWhere((t) =>
        t.label == '🏠A' ||
        t.label == '🏠B' ||
        t.label == '🧑‍💼A' ||
        t.label == '🧑‍💼B');

    if (_teamALogo != null && _teamALogo!.isNotEmpty) {
      _tokens.add(_Token(
          pos: const Offset(0.92, 0.92),
          color: _kTeamA,
          label: '🏠A',
          imageUrl: _teamALogo));
    }
    if (_teamBLogo != null && _teamBLogo!.isNotEmpty) {
      _tokens.add(_Token(
          pos: const Offset(0.08, 0.08),
          color: _kTeamB,
          label: '🏠B',
          imageUrl: _teamBLogo));
    }
    if (_coachAImage != null && _coachAImage!.isNotEmpty) {
      _tokens.add(_Token(
          pos: const Offset(0.92, 0.72),
          color: _kTeamA,
          label: '🧑‍💼A',
          imageUrl: _coachAImage));
    }
    if (_coachBImage != null && _coachBImage!.isNotEmpty) {
      _tokens.add(_Token(
          pos: const Offset(0.08, 0.28),
          color: _kTeamB,
          label: '🧑‍💼B',
          imageUrl: _coachBImage));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  int? _hitToken(Offset abs) {
    double best = 30;
    int? idx;
    for (int i = 0; i < _tokens.length; i++) {
      final c = Offset(
          _tokens[i].pos.dx * _pitchSz.width,
          _tokens[i].pos.dy * _pitchSz.height);
      final d = (c - abs).distance;
      if (d < best) {
        best = d;
        idx = i;
      }
    }
    return idx;
  }

  Offset _clamp01(Offset o) =>
      Offset(o.dx.clamp(0.0, 1.0), o.dy.clamp(0.0, 1.0));

  // ── Gesture handling ────────────────────────────────────────────────────

  void _panStart(DragStartDetails d) {
    final p = d.localPosition;
    switch (_tool) {
      case _Tool.move:
        _dragIdx = _hitToken(p);
      case _Tool.pass:
      case _Tool.run:
        _active = [p, p];
      case _Tool.draw:
        _active = [p];
      case _Tool.erase:
        break;
    }
    setState(() {});
  }

  void _panUpdate(DragUpdateDetails d) {
    final p = d.localPosition;
    switch (_tool) {
      case _Tool.move:
        if (_dragIdx != null) {
          _tokens[_dragIdx!].pos = _clamp01(
            Offset(p.dx / _pitchSz.width, p.dy / _pitchSz.height),
          );
        }
      case _Tool.pass:
      case _Tool.run:
        if (_active != null) _active = [_active!.first, p];
      case _Tool.draw:
        _active?.add(p);
      case _Tool.erase:
        break;
    }
    setState(() {});
  }

  void _panEnd(DragEndDetails _) {
    if (_tool == _Tool.move) {
      _dragIdx = null;
    } else if (_active != null && _active!.length >= 2) {
      final dashed = _tool == _Tool.pass;
      final arrow = _tool == _Tool.pass || _tool == _Tool.run;
      _strokes.add(_Stroke(
        points: List.of(_active!),
        color: _pen,
        dashed: dashed,
        arrow: arrow,
      ));
    }
    _active = null;
    setState(() {});
  }

  void _tapUp(TapUpDetails d) {
    if (_tool != _Tool.erase) return;
    final p = d.localPosition;
    double best = 25;
    int? idx;
    for (int i = 0; i < _strokes.length; i++) {
      for (final pt in _strokes[i].points) {
        final dist = (pt - p).distance;
        if (dist < best) {
          best = dist;
          idx = i;
        }
      }
    }
    if (idx != null) setState(() => _strokes.removeAt(idx!));
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _undo() {
    if (_strokes.isNotEmpty) setState(() => _strokes.removeLast());
  }

  void _clearStrokes() => setState(() => _strokes.clear());

  void _resetAll() => setState(() {
        _strokes.clear();
        _teamALogo = null;
        _teamBLogo = null;
        _coachAName = null;
        _coachAImage = null;
        _coachBName = null;
        _coachBImage = null;
        _resetTokens();
      });

  // ── Team settings bottom sheet ──────────────────────────────────────────

  void _openTeamSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamSettingsSheet(
        clubs: _clubs,
        allPlayers: _allPlayers,
        teamALogo: _teamALogo,
        teamBLogo: _teamBLogo,
        coachAName: _coachAName,
        coachAImage: _coachAImage,
        coachBName: _coachBName,
        coachBImage: _coachBImage,
        onApply: ({
          String? teamALogo,
          String? teamBLogo,
          String? coachAName,
          String? coachAImage,
          String? coachBName,
          String? coachBImage,
        }) {
          setState(() {
            _teamALogo = teamALogo;
            _teamBLogo = teamBLogo;
            _coachAName = coachAName;
            _coachAImage = coachAImage;
            _coachBName = coachBName;
            _coachBImage = coachBImage;
            _syncSpecialTokens();
          });
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: const BackButton(color: AppColors.textSecondary),
        title: Text(
          'Tactical Board',
          style: GoogleFonts.rajdhani(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.groups_rounded, size: 20),
            color: AppColors.accentGreen,
            onPressed: _dbLoaded ? _openTeamSettings : null,
            tooltip: 'Team Settings',
          ),
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: _undo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.layers_clear_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: _clearStrokes,
            tooltip: 'Clear drawings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: _resetAll,
            tooltip: 'Reset all',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Info bar ────────────────────────────────────────────────────
          _buildInfoBar(),

          // ── Pitch area ──────────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(builder: (ctx, box) {
              _pitchSz = Size(box.maxWidth, box.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _panStart,
                onPanUpdate: _panUpdate,
                onPanEnd: _panEnd,
                onTapUp: _tapUp,
                child: Stack(
                  children: [
                    // Pitch + drawing painter
                    Positioned.fill(
                      child: CustomPaint(
                        size: _pitchSz,
                        painter: const PitchPainter(),
                        foregroundPainter: _BoardPainter(
                          tokens: _tokens,
                          strokes: _strokes,
                          activePoints: _active,
                          activeTool: _tool,
                          penColor: _pen,
                        ),
                      ),
                    ),
                    // Overlay image tokens (logos + coaches)
                    ..._buildImageOverlays(),
                  ],
                ),
              );
            }),
          ),

          // ── Toolbar ─────────────────────────────────────────────────────
          _buildToolbar(),
        ],
      ),
    );
  }

  // ── Info bar showing team logos & coach names ────────────────────────────

  Widget _buildInfoBar() {
    final hasInfo = _teamALogo != null ||
        _teamBLogo != null ||
        _coachAName != null ||
        _coachBName != null;
    if (!hasInfo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.bgCard,
      child: Row(
        children: [
          // Team A side
          if (_teamALogo != null && _teamALogo!.isNotEmpty)
            _netImg(_teamALogo!, 22),
          if (_coachAName != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _coachAName!,
                style: const TextStyle(
                    color: _kTeamA, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          Text('VS',
              style: GoogleFonts.rajdhani(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          // Team B side
          if (_coachBName != null) ...[
            Flexible(
              child: Text(
                _coachBName!,
                style: const TextStyle(
                    color: _kTeamB, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (_teamBLogo != null && _teamBLogo!.isNotEmpty)
            _netImg(_teamBLogo!, 22),
        ],
      ),
    );
  }

  Widget _netImg(String url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(url,
          width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image, size: size, color: AppColors.textMuted)),
    );
  }

  // ── Image overlays on pitch (logos + coaches as draggable images) ───────

  List<Widget> _buildImageOverlays() {
    if (_pitchSz == Size.zero) return [];
    final items = <Widget>[];
    final r = _pitchSz.width * 0.045;

    for (int i = 0; i < _tokens.length; i++) {
      final t = _tokens[i];
      if (t.imageUrl == null || t.imageUrl!.isEmpty) continue;
      final left = t.pos.dx * _pitchSz.width - r;
      final top = t.pos.dy * _pitchSz.height - r;

      items.add(Positioned(
        left: left,
        top: top,
        width: r * 2,
        height: r * 2,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: t.color, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                t.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: t.color.withOpacity(0.3),
                  child: Icon(
                    t.label.startsWith('🏠') ? Icons.shield : Icons.person,
                    color: Colors.white70,
                    size: r,
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return items;
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.paddingOf(context).bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Tool buttons ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolBtn(Icons.open_with_rounded, 'Move', _Tool.move),
              _toolBtn(Icons.north_east_rounded, 'Pass', _Tool.pass),
              _toolBtn(Icons.directions_run_rounded, 'Run', _Tool.run),
              _toolBtn(Icons.draw_rounded, 'Draw', _Tool.draw),
              _toolBtn(Icons.auto_fix_off_rounded, 'Erase', _Tool.erase),
            ],
          ),
          const SizedBox(height: 10),

          // ── Pen colors ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _kPenColors
                .map((c) => GestureDetector(
                      onTap: () => setState(() => _pen = c),
                      child: Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                _pen == c ? Colors.white : Colors.white24,
                            width: _pen == c ? 2.5 : 1,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, _Tool tool) {
    final active = _tool == tool;
    return GestureDetector(
      onTap: () => setState(() => _tool = tool),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accentGreen.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: active ? AppColors.accentGreen : AppColors.border),
            ),
            child: Icon(icon,
                size: 22,
                color:
                    active ? AppColors.accentGreen : AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppColors.accentGreen : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Club entry helper ─────────────────────────────────────────────────────────

class _ClubEntry {
  final String name;
  final String logoUrl;
  const _ClubEntry({required this.name, required this.logoUrl});
}

// ── Team settings bottom sheet ────────────────────────────────────────────────

class _TeamSettingsSheet extends StatefulWidget {
  final List<_ClubEntry> clubs;
  final List<PlayerModel> allPlayers;
  final String? teamALogo;
  final String? teamBLogo;
  final String? coachAName;
  final String? coachAImage;
  final String? coachBName;
  final String? coachBImage;
  final void Function({
    String? teamALogo,
    String? teamBLogo,
    String? coachAName,
    String? coachAImage,
    String? coachBName,
    String? coachBImage,
  }) onApply;

  const _TeamSettingsSheet({
    required this.clubs,
    required this.allPlayers,
    this.teamALogo,
    this.teamBLogo,
    this.coachAName,
    this.coachAImage,
    this.coachBName,
    this.coachBImage,
    required this.onApply,
  });

  @override
  State<_TeamSettingsSheet> createState() => _TeamSettingsSheetState();
}

class _TeamSettingsSheetState extends State<_TeamSettingsSheet> {
  late String? _aLogo = widget.teamALogo;
  late String? _bLogo = widget.teamBLogo;
  late String? _caName = widget.coachAName;
  late String? _caImg = widget.coachAImage;
  late String? _cbName = widget.coachBName;
  late String? _cbImg = widget.coachBImage;

  String _clubSearch = '';
  String _coachSearch = '';

  List<Map<String, String>> _coaches = [];

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/coaches.json');
      final List<dynamic> raw = json.decode(jsonStr);
      setState(() {
        _coaches = raw
            .map((e) => {
                  'name': e['name']?.toString() ?? '',
                  'country': e['country']?.toString() ?? '',
                  'image': e['image']?.toString() ?? '',
                })
            .where((c) => c['image']!.isNotEmpty)
            .toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('Team Settings',
                  style: GoogleFonts.rajdhani(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // ── Team A Club Logo ─────────────────────────────────
                    _sectionTitle('Team A — Club Logo', _kTeamA),
                    _clubPicker(
                      currentUrl: _aLogo,
                      onSelected: (url) =>
                          setState(() => _aLogo = url),
                      onClear: () => setState(() => _aLogo = null),
                    ),
                    const SizedBox(height: 8),

                    // ── Team A Coach ─────────────────────────────────────
                    _sectionTitle('Team A — Coach / Manager', _kTeamA),
                    _coachPicker(
                      currentName: _caName,
                      currentImg: _caImg,
                      onSelected: (name, img) =>
                          setState(() { _caName = name; _caImg = img; }),
                      onClear: () =>
                          setState(() { _caName = null; _caImg = null; }),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),

                    // ── Team B Club Logo ─────────────────────────────────
                    _sectionTitle('Team B — Club Logo', _kTeamB),
                    _clubPicker(
                      currentUrl: _bLogo,
                      onSelected: (url) =>
                          setState(() => _bLogo = url),
                      onClear: () => setState(() => _bLogo = null),
                    ),
                    const SizedBox(height: 8),

                    // ── Team B Coach ─────────────────────────────────────
                    _sectionTitle('Team B — Coach / Manager', _kTeamB),
                    _coachPicker(
                      currentName: _cbName,
                      currentImg: _cbImg,
                      onSelected: (name, img) =>
                          setState(() { _cbName = name; _cbImg = img; }),
                      onClear: () =>
                          setState(() { _cbName = null; _cbImg = null; }),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Apply button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, MediaQuery.paddingOf(context).bottom + 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      widget.onApply(
                        teamALogo: _aLogo,
                        teamBLogo: _bLogo,
                        coachAName: _caName,
                        coachAImage: _caImg,
                        coachBName: _cbName,
                        coachBImage: _cbImg,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Apply',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Section title ──────────────────────���────────────────────────────────

  Widget _sectionTitle(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 0.5)),
    );
  }

  // ── Club logo picker ────────────────────────────────────────────────────

  Widget _clubPicker({
    required String? currentUrl,
    required ValueChanged<String> onSelected,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentUrl != null && currentUrl.isNotEmpty)
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(currentUrl,
                    width: 36, height: 36, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 36,
                        color: AppColors.textMuted)),
              ),
              const SizedBox(width: 12),
              const Text('Selected',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                child: const Text('Remove',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ],
          ),
        const SizedBox(height: 6),
        _SearchField(
          hint: 'Search club...',
          onChanged: (q) => setState(() => _clubSearch = q),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: widget.clubs
                .where((c) => c.name
                    .toLowerCase()
                    .contains(_clubSearch.toLowerCase()))
                .take(30)
                .map((club) => _ClubChip(
                      club: club,
                      selected: currentUrl == club.logoUrl && club.logoUrl.isNotEmpty,
                      onTap: () {
                        if (club.logoUrl.isNotEmpty) onSelected(club.logoUrl);
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Coach picker (select a coach or player as coach image) ───────────────

  Widget _coachPicker({
    required String? currentName,
    required String? currentImg,
    required void Function(String name, String img) onSelected,
    required VoidCallback onClear,
  }) {
    final filteredCoaches = _coachSearch.isEmpty
        ? _coaches
        : _coaches
            .where((c) =>
                c['name']!.toLowerCase().contains(_coachSearch.toLowerCase()) ||
                c['country']!
                    .toLowerCase()
                    .contains(_coachSearch.toLowerCase()))
            .toList();

    final filteredPlayers = _coachSearch.length < 2
        ? <PlayerModel>[]
        : widget.allPlayers
            .where((p) =>
                p.imageUrl.isNotEmpty &&
                (p.name
                        .toLowerCase()
                        .contains(_coachSearch.toLowerCase()) ||
                    p.club
                        .toLowerCase()
                        .contains(_coachSearch.toLowerCase())))
            .take(20)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentName != null)
          Row(
            children: [
              if (currentImg != null && currentImg.isNotEmpty)
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(currentImg),
                  onBackgroundImageError: (_, __) {},
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(currentName,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Remove',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ],
          ),
        const SizedBox(height: 6),
        _SearchField(
          hint: 'Search coaches, players...',
          onChanged: (q) => setState(() => _coachSearch = q),
        ),
        const SizedBox(height: 6),

        // ── Coaches from database ──
        if (filteredCoaches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text('COACHES',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGreen,
                    letterSpacing: 1.2)),
          ),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filteredCoaches
                  .take(30)
                  .map((c) => _CoachDbCard(
                        name: c['name']!,
                        country: c['country']!,
                        imageUrl: c['image']!,
                        selected: currentName == c['name'],
                        onTap: () =>
                            onSelected(c['name']!, c['image']!),
                      ))
                  .toList(),
            ),
          ),
        ],

        // ── Players fallback ──
        if (filteredPlayers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 6, bottom: 4),
            child: Text('FROM PLAYERS',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2)),
          ),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filteredPlayers
                  .map((p) => _CoachCard(
                        player: p,
                        selected: currentName == p.name,
                        onTap: () =>
                            onSelected(p.name, p.imageUrl),
                      ))
                  .toList(),
            ),
          ),
        ],

        if (filteredCoaches.isEmpty && filteredPlayers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
                _coachSearch.isEmpty
                    ? 'Loading coaches...'
                    : _coachSearch.length < 2
                        ? 'Type 2+ chars to search players too'
                        : 'No results found',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
          ),
      ],
    );
  }
}

// ── Reusable search field ─────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        filled: true,
        fillColor: AppColors.bgDark,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
      ),
    );
  }
}

// ── Club chip widget ──────────────────────────────────────────────────────────

class _ClubChip extends StatelessWidget {
  final _ClubEntry club;
  final bool selected;
  final VoidCallback onTap;

  const _ClubChip(
      {required this.club, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withOpacity(0.15)
              : AppColors.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.accentGreen : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (club.logoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(club.logoUrl,
                    width: 36, height: 36, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.shield, size: 36, color: AppColors.textMuted)),
              )
            else
              const Icon(Icons.shield, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 4),
            Text(
              club.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: selected ? AppColors.accentGreen : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coach card widget ─────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  final PlayerModel player;
  final bool selected;
  final VoidCallback onTap;

  const _CoachCard(
      {required this.player, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withOpacity(0.15)
              : AppColors.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.accentGreen : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(player.imageUrl),
              onBackgroundImageError: (_, __) {},
              backgroundColor: AppColors.bgSurface,
            ),
            const SizedBox(height: 4),
            Text(
              player.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: selected ? AppColors.accentGreen : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              player.club,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 8, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coach database card widget ────────────────────────────────────────────────

class _CoachDbCard extends StatelessWidget {
  final String name;
  final String country;
  final String imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _CoachDbCard({
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withOpacity(0.15)
              : AppColors.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.accentGreen : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) {},
              backgroundColor: AppColors.bgSurface,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: selected ? AppColors.accentGreen : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              country,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Board painter (strokes + tokens) ──────────────────────────────────────────

class _BoardPainter extends CustomPainter {
  final List<_Token> tokens;
  final List<_Stroke> strokes;
  final List<Offset>? activePoints;
  final _Tool activeTool;
  final Color penColor;

  _BoardPainter({
    required this.tokens,
    required this.strokes,
    this.activePoints,
    required this.activeTool,
    required this.penColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Completed strokes ──────────────────────────────────────────────────
    for (final s in strokes) {
      _drawStroke(canvas, s);
    }

    // ── Active stroke preview ────────────────────────────────────────────���─
    if (activePoints != null && activePoints!.length >= 2) {
      _drawStroke(canvas, _Stroke(
        points: activePoints!,
        color: penColor.withOpacity(0.6),
        dashed: activeTool == _Tool.pass,
        arrow: activeTool == _Tool.pass || activeTool == _Tool.run,
      ));
    }

    // ── Tokens (only draw non-image ones via painter) ──────────────────────
    for (final t in tokens) {
      if (t.imageUrl != null && t.imageUrl!.isNotEmpty) continue;
      _drawToken(canvas, size, t);
    }
  }

  // ── Stroke rendering ────────────────────────────────────────────────────

  void _drawStroke(Canvas canvas, _Stroke s) {
    if (s.points.length < 2) return;

    final paint = Paint()
      ..color = s.color
      ..strokeWidth = s.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
    for (int i = 1; i < s.points.length; i++) {
      path.lineTo(s.points[i].dx, s.points[i].dy);
    }

    if (s.dashed) {
      _drawDashed(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    if (s.arrow) {
      _drawArrow(
          canvas, s.points[s.points.length - 2], s.points.last, s.color);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final seg = m.extractPath(d, min(d + 8, m.length));
        canvas.drawPath(seg, paint);
        d += 14;
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const len = 14.0;
    final p1 = Offset(
        to.dx - len * cos(angle - 0.45), to.dy - len * sin(angle - 0.45));
    final p2 = Offset(
        to.dx - len * cos(angle + 0.45), to.dy - len * sin(angle + 0.45));
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  // ── Token rendering ─────────────────────────────────────────────────────

  void _drawToken(Canvas canvas, Size size, _Token t) {
    final c =
        Offset(t.pos.dx * size.width, t.pos.dy * size.height);
    final r = size.width * 0.034;

    // Shadow
    canvas.drawCircle(
        c + const Offset(0, 2), r, Paint()..color = Colors.black38);

    // Fill
    canvas.drawCircle(c, r, Paint()..color = t.color);

    // Border ring
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.white.withOpacity(0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);

    // Label
    final isBall = t.label == '●';
    final tp = TextPainter(
      text: TextSpan(
        text: t.label,
        style: TextStyle(
          color: isBall ? Colors.black87 : Colors.white,
          fontSize: isBall ? r * 1.2 : r * 0.78,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}
