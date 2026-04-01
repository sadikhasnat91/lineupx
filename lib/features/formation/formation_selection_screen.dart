import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/formation_model.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/formation_preview_widget.dart';
import 'formation_controller.dart';

class FormationSelectionScreen extends StatelessWidget {
  const FormationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FormationController>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: const GradientAppBar(title: 'Select Formation'),
      body: Column(
        children: [
          // Description
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Choose your tactical setup. Swipe or scroll to explore all formations.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Formation grid
          Expanded(
            child: Obx(
              () => GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount:
                    controller.formations.length + 1, // +1 for custom
                itemBuilder: (context, index) {
                  if (index == controller.formations.length) {
                    return _CustomFormationCard(
                      onTap: controller.openCustomBuilder,
                    );
                  }
                  final f = controller.formations[index];
                  return Obx(
                    () => _FormationCard(
                      formation: f,
                      isSelected:
                          controller.selected.value?.id == f.id,
                      onTap: () => controller.select(f),
                      onDelete: f.isCustom
                          ? () => controller
                              .deleteCustomFormation(f.id)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),

          // Confirm button
          Obx(() => AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: controller.selected.value != null
                    ? Offset.zero
                    : const Offset(0, 1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      controller.selected.value != null ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.accentGreen.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: controller.confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Use ${controller.selected.value?.name ?? ''} →',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Formation card ────────────────────────────────────────────────────────────

class _FormationCard extends StatelessWidget {
  final FormationModel formation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _FormationCard({
    required this.formation,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGreen.withOpacity(0.08)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGreen
                : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formation name + custom badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formation.name,
                          style: GoogleFonts.rajdhani(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.accentGreen
                                : AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (formation.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CUSTOM',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formation.description,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Mini pitch preview
                  Expanded(
                    child: Center(
                      child: FormationPreviewWidget(
                        formation: formation,
                        width: double.infinity,
                        height: double.infinity,
                        dotColor:
                            isSelected ? AppColors.accentGreen : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Player count
                  Text(
                    '${formation.positions.length} players',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? AppColors.accentGreen
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Selected check
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 14, color: Colors.black87),
                ),
              ),

            // Delete for custom
            if (formation.isCustom && onDelete != null)
              Positioned(
                top: 8,
                right: isSelected ? 38 : 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 13, color: AppColors.error),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Custom formation card ─────────────────────────────────────────────────────

class _CustomFormationCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CustomFormationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.accentGold.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_rounded,
                  size: 28, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'Custom',
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Build your own\nformation',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
