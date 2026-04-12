import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(size: size),
          ),

          // ── Main actions grid ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.0,
              children: [
                _ActionCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create\nLineup',
                  sublabel: 'Build your XI',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00BCD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: Colors.black87,
                  onTap: controller.createNewLineup,
                ),
                Obx(
                  () => _ActionCard(
                    icon: Icons.folder_open_rounded,
                    label: 'Saved\nLineups',
                    sublabel:
                        '${controller.savedCount.value} lineup${controller.savedCount.value == 1 ? '' : 's'}',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF448AFF), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: Colors.white,
                    onTap: controller.openSavedLineups,
                  ),
                ),
                _ActionCard(
                  icon: Icons.dashboard_rounded,
                  label: 'Manager\nMode',
                  sublabel: 'Full squad view',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: Colors.white,
                  onTap: controller.openManagerMode,
                ),
                _ActionCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Templates',
                  sublabel: 'Quick start',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: Colors.white,
                  onTap: controller.openTemplates,
                ),
                _ActionCard(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Quick\nMatch',
                  sublabel: 'Custom player count',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: Colors.white,
                  onTap: () => Get.toNamed(AppRoutes.quickMatch),
                ),
                _ActionCard(
                  icon: Icons.compare_arrows_rounded,
                  label: '11 vs 11',
                  sublabel: 'Set up two teams',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: Colors.white,
                  onTap: () => Get.toNamed(AppRoutes.versus),
                ),
                _ActionCard(
                  icon: Icons.schema_rounded,
                  label: 'Tactical\nBoard',
                  sublabel: 'Plan your tactics',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF00796B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: Colors.white,
                  onTap: controller.openTacticalBoard,
                ),
              ],
            ),
          ),

          // ── Features strip ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _FeatureStrip(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Hero header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final Size size;
  const _HeroHeader({required this.size});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.height * 0.35),
      child: IntrinsicHeight(
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F2E1F),
                    Color(0xFF0B2217),
                    AppColors.bgDeep,
                  ],
                  stops: [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Pitch line decoration
          Positioned.fill(
            child: CustomPaint(painter: _HeroPitchPainter()),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.paddingOf(context).top + 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sports_soccer_rounded,
                          size: 16, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'LineupX',
                        style: GoogleFonts.rajdhani(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _IconBtn(
                      icon: Icons.notifications_outlined,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Build Your',
                  style: GoogleFonts.rajdhani(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Dream XI',
                  style: GoogleFonts.rajdhani(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tactics • Squads • Football Manager',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Quick create CTA
                GestureDetector(
                  onTap: Get.find<HomeController>().createNewLineup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 18, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          'Create New Lineup',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
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

// ── Feature strip ─────────────────────────────────────────────────────────────

class _FeatureStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final items = [
      ('⚽', 'Formations', () => controller.createNewLineup()),
      ('🧩', 'Custom XI', () => Get.toNamed(AppRoutes.quickMatch)),
      ('📊', 'Tactics', () => controller.openManagerMode()),
      ('💾', 'Save & Share', () => controller.openSavedLineups()),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FEATURES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: GestureDetector(
                      onTap: item.$3,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Text(item.$1, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(
                              item.$2,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Action card ───────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white12,
        highlightColor: Colors.white10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon bubble
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Hero pitch painter ────────────────────────────────────────────────────────

class _HeroPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Center circle
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.55), size.width * 0.28, paint);

    // Some horizontal lines
    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(size.width * 0.5, y),
          Offset(size.width * 1.0, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
