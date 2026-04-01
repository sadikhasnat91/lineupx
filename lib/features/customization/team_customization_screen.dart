import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/team_settings_model.dart';
import '../../widgets/gradient_app_bar.dart';
import 'customization_controller.dart';

class TeamCustomizationScreen extends StatelessWidget {
  const TeamCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomizationController>();
    final nameController = TextEditingController(
      text: controller.settings.value.teamName,
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

            const SizedBox(height: 16),

            // ── Logo picker ───────────────────────────────────────────────
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
                            controller.settings.value.logoPath != null
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
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      controller.updateLogoPath(file.path);
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: settings.logoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(settings.logoPath!,
                        fit: BoxFit.cover))
                : const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Text(
            settings.teamName,
            style: GoogleFonts.rajdhani(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
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
