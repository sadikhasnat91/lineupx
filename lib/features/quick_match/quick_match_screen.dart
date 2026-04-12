import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/player_model.dart';
import '../../features/lineup_builder/widgets/jersey_painter.dart';
import '../../widgets/gradient_app_bar.dart';
import '../player_selection/player_selection_sheet.dart';

/// Quick Match — user picks how many players and assigns names freely.
class QuickMatchScreen extends StatefulWidget {
  const QuickMatchScreen({super.key});

  @override
  State<QuickMatchScreen> createState() => _QuickMatchScreenState();
}

class _QuickMatchScreenState extends State<QuickMatchScreen> {
  int _playerCount = 11;
  final List<PlayerModel?> _players = List.filled(11, null, growable: true);
  final _teamNameCtrl = TextEditingController(text: 'My Team');

  static const _presets = [5, 6, 7, 8, 9, 10, 11];

  void _setCount(int count) {
    setState(() {
      _playerCount = count;
      while (_players.length < count) _players.add(null);
      while (_players.length > count) _players.removeLast();
    });
  }

  @override
  void dispose() {
    _teamNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: GradientAppBar(title: 'Quick Match Setup'),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildGrid()),
          _buildBottom(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.bgDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team name
          TextField(
            controller: _teamNameCtrl,
            style: GoogleFonts.rajdhani(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Team name...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              isDense: true,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.edit_rounded,
                  color: AppColors.textMuted, size: 16),
            ),
          ),
          const SizedBox(height: 10),
          // Player count presets
          Text(
            'PLAYERS',
            style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.textMuted, letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: _presets.map((n) {
              final selected = n == _playerCount;
              return GestureDetector(
                onTap: () => _setCount(n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentGreen
                        : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.accentGreen
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.black87 : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: _playerCount,
      itemBuilder: (context, index) {
        final player = _players[index];
        return GestureDetector(
          onTap: () => _openSlotOptions(index),
          onLongPress: player != null
              ? () => setState(() => _players[index] = null)
              : null,
          child: _SlotCard(index: index, player: player),
        );
      },
    );
  }

  Widget _buildBottom() {
    final filled = _players.where((p) => p != null).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$filled / $_playerCount',
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.accentGreen,
                ),
              ),
              const Text('Players set',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: filled < _playerCount ? _autoFillRemaining : null,
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
              label: const Text('Auto-fill Empty Slots'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSlotOptions(int index) {
    final player = _players[index];
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
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              player != null ? player.name : 'Player ${index + 1}',
              style: GoogleFonts.rajdhani(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            // Browse DB
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
                      positionLabel: 'ALL',
                      onPlayerSelected: (p) {
                        setState(() => _players[index] = p);
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
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Type name
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _typeCustomName(index);
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Type Player Name'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                  side: const BorderSide(color: AppColors.accentBlue),
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
                    setState(() => _players[index] = null);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.person_remove_outlined, size: 18),
                  label: const Text('Remove Player'),
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

  void _typeCustomName(int index) {
    final ctrl = TextEditingController(
        text: _players[index]?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Player ${index + 1}',
          style: GoogleFonts.rajdhani(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: ctrl,
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
              setState(() {
                _players[index] = PlayerModel.custom(name: name);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
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

  void _autoFillRemaining() {
    setState(() {
      for (int i = 0; i < _players.length; i++) {
        if (_players[i] == null) {
          _players[i] = PlayerModel.custom(name: 'Player ${i + 1}');
        }
      }
    });
    Get.snackbar('Done', 'Empty slots filled with placeholder names',
        backgroundColor: AppColors.bgCard,
        colorText: AppColors.accentGreen,
        duration: const Duration(seconds: 2));
  }
}

class _SlotCard extends StatelessWidget {
  final int index;
  final PlayerModel? player;
  const _SlotCard({required this.index, required this.player});

  @override
  Widget build(BuildContext context) {
    final isEmpty = player == null;
    final borderColor = isEmpty
        ? AppColors.border
        : AppHelpers.ratingColor(player!.rating);
    final fillColor = isEmpty
        ? AppColors.bgCard
        : AppHelpers.avatarBgColor(player!.rating);

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
                  borderColor: borderColor,
                  isEmpty: isEmpty,
                ),
                child: const SizedBox.expand(),
              ),
              if (isEmpty)
                Positioned(
                  top: 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Icon(Icons.add_rounded,
                          size: 16,
                          color: AppColors.textMuted.withOpacity(0.6)),
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Positioned(
                  top: 16,
                  child: Text(
                    '${player!.rating}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: borderColor,
                      shadows: [
                        Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 28,
          child: Text(
            isEmpty ? '– – –' : player!.name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
