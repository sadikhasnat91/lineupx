import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/player_model.dart';
import '../../data/models/team_settings_model.dart';
import '../../data/repositories/player_repository.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/smart_image.dart';
import 'customization_controller.dart';

class TeamCustomizationScreen extends StatelessWidget {
  const TeamCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomizationController>();
    final nameController = TextEditingController(
      text: controller.settings.value.teamName,
    );
    final coachController = TextEditingController(
      text: controller.settings.value.coachName,
    );

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: GradientAppBar(
        title: 'Customize Team',
        actions: [
          TextButton(
            onPressed: controller.saveAndReturn,
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Team preview card ────────────────────────────────────────
            _TeamPreview(settings: controller.settings.value),

            const SizedBox(height: 24),

            // ── Team name ────────────────────────────────────────────────
            _SectionLabel('Team Identity'),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              onChanged: controller.updateTeamName,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Team name',
                prefixIcon: Icon(Icons.shield_outlined,
                    color: AppColors.textMuted, size: 18),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: coachController,
              onChanged: controller.updateCoachName,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Coach / manager name',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppColors.textMuted, size: 18),
              ),
            ),

            const SizedBox(height: 16),

            // ── Image pickers ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickLogo(controller),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_outlined,
                              color: AppColors.textMuted, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            controller.settings.value.logoPath?.isNotEmpty == true
                                ? 'Change Logo'
                                : 'Choose Logo',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickCoachImage(controller),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_2_outlined,
                              color: AppColors.textMuted, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            controller.settings.value.coachImagePath?.isNotEmpty == true
                                ? 'Change Photo'
                                : 'Coach Photo',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Colors ────────────────────────────────────────────────────
            _SectionLabel('Team Colors'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ColorPicker(
                    label: 'Primary',
                    color: controller.settings.value.primaryColor,
                    onChanged: controller.updatePrimaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ColorPicker(
                    label: 'Secondary',
                    color: controller.settings.value.secondaryColor,
                    onChanged: controller.updateSecondaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Tactics ───────────────────────────────────────────────────
            _SectionLabel('Tactical Settings'),
            const SizedBox(height: 14),

            _TacticRow(
              label: 'Match Type',
              icon: Icons.emoji_events_outlined,
              options: MatchType.values.map((e) => e.label).toList(),
              selectedIndex: controller.settings.value.matchType.index,
              onChanged: (i) => controller.updateMatchType(MatchType.values[i]),
            ),

            const SizedBox(height: 14),

            _TacticRow(
              label: 'Attack Style',
              icon: Icons.sports_soccer_rounded,
              options: AttackStyle.values.map((e) => e.label).toList(),
              selectedIndex:
                  controller.settings.value.attackStyle.index,
              onChanged: (i) =>
                  controller.updateAttackStyle(AttackStyle.values[i]),
            ),

            const SizedBox(height: 14),

            _TacticRow(
              label: 'Defensive Style',
              icon: Icons.shield_rounded,
              options: DefensiveStyle.values.map((e) => e.label).toList(),
              selectedIndex:
                  controller.settings.value.defensiveStyle.index,
              onChanged: (i) => controller
                  .updateDefStyle(DefensiveStyle.values[i]),
            ),

            const SizedBox(height: 14),

            _TacticRow(
              label: 'Defensive Line',
              icon: Icons.height_rounded,
              options: DefensiveLine.values.map((e) => e.label).toList(),
              selectedIndex:
                  controller.settings.value.defensiveLine.index,
              onChanged: (i) => controller
                  .updateDefLine(DefensiveLine.values[i]),
            ),

            const SizedBox(height: 14),

            _TacticRow(
              label: 'Width',
              icon: Icons.open_in_full_rounded,
              options: PitchWidth.values.map((e) => e.label).toList(),
              selectedIndex: controller.settings.value.width.index,
              onChanged: (i) =>
                  controller.updateWidth(PitchWidth.values[i]),
            ),

            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: controller.saveAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Save & Apply',
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLogo(CustomizationController controller) async {
    final ctx = Get.context;
    if (ctx == null) return;

    final source = await showModalBottomSheet<String>(
      context: ctx,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SourcePickerSheet(
        title: 'Choose Logo Source',
        option1Label: 'From Gallery',
        option1Icon: Icons.photo_library_outlined,
        option2Label: 'From Club Database',
        option2Icon: Icons.shield_outlined,
      ),
    );
    if (source == null) return;

    if (source == 'gallery') {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (file != null) {
        final bytes = await file.readAsBytes();
        controller.updateLogoPath(
          'data:image/*;base64,${base64Encode(bytes)}',
        );
      }
    } else if (source == 'database') {
      if (!ctx.mounted) return;
      final url = await showModalBottomSheet<String>(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _ClubLogoPicker(),
      );
      if (url != null && url.isNotEmpty) {
        controller.updateLogoPath(url);
      }
    }
  }

  Future<void> _pickCoachImage(CustomizationController controller) async {
    final ctx = Get.context;
    if (ctx == null) return;

    final source = await showModalBottomSheet<String>(
      context: ctx,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SourcePickerSheet(
        title: 'Choose Coach Photo Source',
        option1Label: 'From Gallery',
        option1Icon: Icons.photo_library_outlined,
        option2Label: 'From Player Database',
        option2Icon: Icons.person_search_rounded,
      ),
    );
    if (source == null) return;

    if (source == 'gallery') {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (file != null) {
        final bytes = await file.readAsBytes();
        controller.updateCoachImagePath(
          'data:image/*;base64,${base64Encode(bytes)}',
        );
      }
    } else if (source == 'database') {
      if (!ctx.mounted) return;
      final result = await showModalBottomSheet<_CoachPickResult>(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _CoachImagePicker(),
      );
      if (result != null) {
        controller.updateCoachImagePath(result.imageUrl);
        if (result.name.isNotEmpty) {
          controller.updateCoachName(result.name);
        }
      }
    }
  }
}

// ── Team preview card ─────────────────────────────────────────────────────────

class _TeamPreview extends StatelessWidget {
  final TeamSettingsModel settings;
  const _TeamPreview({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [settings.primaryColor, settings.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: settings.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SmartImage(
                  source: settings.logoPath,
                  fit: BoxFit.cover,
                  fallback: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (settings.coachName.trim().isNotEmpty)
                        _PreviewPill(
                          icon: Icons.person_outline_rounded,
                          label: settings.coachName,
                        ),
                      _PreviewPill(
                        icon: Icons.emoji_events_outlined,
                        label: settings.matchType.label,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (settings.coachImagePath?.isNotEmpty == true)
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
                clipBehavior: Clip.antiAlias,
                child: SmartImage(
                  source: settings.coachImagePath,
                  fit: BoxFit.cover,
                  fallback: const Icon(Icons.person, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PreviewPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
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

// ── Color picker ──────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final String label;
  final Color color;
  final void Function(Color) onChanged;

  const _ColorPicker(
      {required this.label,
      required this.color,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    Color _current = color;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pick $label Color',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ColorPicker(
              pickerColor: color,
              onColorChanged: (c) => _current = c,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.5,
            ),
            ElevatedButton(
              onPressed: () {
                onChanged(_current);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black87,
                minimumSize: const Size(double.infinity, 46),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tactic row ────────────────────────────────────────────────────────────────

class _TacticRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final int selectedIndex;
  final void Function(int) onChanged;

  const _TacticRow({
    required this.label,
    required this.icon,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isSelected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i < options.length - 1 ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGreen.withOpacity(0.15)
                        : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentGreen
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    opt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.accentGreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// ── Source picker (gallery vs database) ───────────────────────────────────────

class _SourcePickerSheet extends StatelessWidget {
  final String title;
  final String option1Label;
  final IconData option1Icon;
  final String option2Label;
  final IconData option2Icon;

  const _SourcePickerSheet({
    required this.title,
    required this.option1Label,
    required this.option1Icon,
    required this.option2Label,
    required this.option2Icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.paddingOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _SourceOption(
            icon: option1Icon,
            label: option1Label,
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          const SizedBox(height: 10),
          _SourceOption(
            icon: option2Icon,
            label: option2Label,
            onTap: () => Navigator.pop(context, 'database'),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentGreen, size: 22),
              const SizedBox(width: 14),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Club logo picker from database ────────────────────────────────────────────

class _ClubLogoPicker extends StatefulWidget {
  const _ClubLogoPicker();

  @override
  State<_ClubLogoPicker> createState() => _ClubLogoPickerState();
}

class _ClubLogoPickerState extends State<_ClubLogoPicker> {
  List<_ClubInfo> _clubs = [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = Get.find<PlayerRepository>();
      final players = await repo.getAll();
      final seen = <String>{};
      final clubs = <_ClubInfo>[];
      for (final p in players) {
        if (p.club.isNotEmpty &&
            p.clubLogoUrl.isNotEmpty &&
            seen.add(p.club)) {
          clubs.add(_ClubInfo(name: p.club, logoUrl: p.clubLogoUrl));
        }
      }
      clubs.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _clubs = clubs;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<_ClubInfo> get _filtered => _query.isEmpty
      ? _clubs
      : _clubs
          .where(
              (c) => c.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();

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
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text('Select Club Logo',
                  style: GoogleFonts.rajdhani(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search club...',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.bgDark,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accentGreen))
                    : GridView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final club = _filtered[i];
                          return GestureDetector(
                            onTap: () => Navigator.pop(context, club.logoUrl),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(club.logoUrl,
                                        width: 38,
                                        height: 38,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.shield,
                                                size: 38,
                                                color: AppColors.textMuted)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    club.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClubInfo {
  final String name;
  final String logoUrl;
  const _ClubInfo({required this.name, required this.logoUrl});
}

// ── Coach image picker from database ──────────────────────────────────────────

class _CoachPickResult {
  final String name;
  final String imageUrl;
  const _CoachPickResult({required this.name, required this.imageUrl});
}

class _CoachImagePicker extends StatefulWidget {
  const _CoachImagePicker();

  @override
  State<_CoachImagePicker> createState() => _CoachImagePickerState();
}

class _CoachImagePickerState extends State<_CoachImagePicker> {
  List<PlayerModel> _players = [];
  List<Map<String, String>> _coaches = [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Load dedicated coaches
      final jsonStr = await rootBundle.loadString('assets/data/coaches.json');
      final List<dynamic> raw = json.decode(jsonStr);
      _coaches = raw
          .map((e) => {
                'name': e['name']?.toString() ?? '',
                'country': e['country']?.toString() ?? '',
                'image': e['image']?.toString() ?? '',
              })
          .where((c) => c['image']!.isNotEmpty)
          .toList();

      // Load players with images as fallback
      final repo = Get.find<PlayerRepository>();
      final all = await repo.getAll();
      _players = all.where((p) => p.imageUrl.isNotEmpty).toList();
      _players.sort((a, b) => b.rating.compareTo(a.rating));
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<Map<String, String>> get _filteredCoaches => _query.isEmpty
      ? _coaches
      : _coaches
          .where((c) =>
              c['name']!.toLowerCase().contains(_query.toLowerCase()) ||
              c['country']!.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  List<PlayerModel> get _filteredPlayers => _query.length < 2
      ? []
      : _players
          .where((p) =>
              p.name.toLowerCase().contains(_query.toLowerCase()) ||
              p.club.toLowerCase().contains(_query.toLowerCase()))
          .take(40)
          .toList();

  @override
  Widget build(BuildContext context) {
    final coaches = _filteredCoaches;
    final players = _filteredPlayers;

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
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Text('Select Coach / Manager',
                  style: GoogleFonts.rajdhani(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                    'Choose from real coaches or search any player',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search coaches, players, clubs...',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.bgDark,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accentGreen))
                    : ListView(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          // ── Coaches section ──
                          if (coaches.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 4, bottom: 6),
                              child: Text('COACHES & MANAGERS',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentGreen,
                                      letterSpacing: 1.5)),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: coaches.length,
                              itemBuilder: (_, i) {
                                final c = coaches[i];
                                return GestureDetector(
                                  onTap: () => Navigator.pop(
                                      context,
                                      _CoachPickResult(
                                          name: c['name']!,
                                          imageUrl: c['image']!)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDark,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.border),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              NetworkImage(c['image']!),
                                          onBackgroundImageError:
                                              (_, __) {},
                                          backgroundColor:
                                              AppColors.bgSurface,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          c['name']!,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color:
                                                  AppColors.textPrimary,
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                        Text(
                                          c['country']!,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 8,
                                              color:
                                                  AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],

                          // ── Players section ──
                          if (players.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 14, bottom: 6),
                              child: Text('FROM PLAYERS',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1.5)),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: players.length,
                              itemBuilder: (_, i) {
                                final p = players[i];
                                return GestureDetector(
                                  onTap: () => Navigator.pop(
                                      context,
                                      _CoachPickResult(
                                          name: p.name,
                                          imageUrl: p.imageUrl)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDark,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.border),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              NetworkImage(p.imageUrl),
                                          onBackgroundImageError:
                                              (_, __) {},
                                          backgroundColor:
                                              AppColors.bgSurface,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          p.name,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color:
                                                  AppColors.textPrimary,
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                        Text(
                                          p.club,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 8,
                                              color:
                                                  AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],

                          // Empty state
                          if (coaches.isEmpty && players.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                    _query.isEmpty
                                        ? 'No coaches found'
                                        : _query.length < 2
                                            ? 'Type 2+ chars to search players too'
                                            : 'No results found',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13)),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
