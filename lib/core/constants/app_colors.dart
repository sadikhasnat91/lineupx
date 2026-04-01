import 'package:flutter/material.dart';

/// Central color palette for LineupX.
/// All UI should reference these constants — never hardcode hex values.
class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color bgDeep = Color(0xFF070B14);
  static const Color bgDark = Color(0xFF0C1220);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardElevated = Color(0xFF1A2336);
  static const Color bgSurface = Color(0xFF1E2D40);

  // ── Pitch ───────────────────────────────────────────────────────────────────
  static const Color pitchDark = Color(0xFF0B2217);
  static const Color pitchMid = Color(0xFF0F2E1F);
  static const Color pitchLight = Color(0xFF154027);
  static const Color pitchLine = Color(0xFFFFFFFF);
  static const Color pitchLineFaint = Color(0x66FFFFFF);

  // ── Brand accents ───────────────────────────────────────────────────────────
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentGreenDim = Color(0xFF00C853);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentGoldDim = Color(0xFFFFB300);
  static const Color accentBlue = Color(0xFF448AFF);
  static const Color accentPurple = Color(0xFF7C4DFF);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);
  static const Color textOnAccent = Color(0xFF0A0E1A);

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ── Captain badges ──────────────────────────────────────────────────────────
  static const Color captainGold = Color(0xFFFFD700);
  static const Color viceCaptainSilver = Color(0xFFB0BEC5);

  // ── Position type colors ────────────────────────────────────────────────────
  static const Color posGK = Color(0xFFFF9800);
  static const Color posDEF = Color(0xFF2196F3);
  static const Color posMID = Color(0xFF4CAF50);
  static const Color posFWD = Color(0xFFF44336);

  // ── Border / dividers ───────────────────────────────────────────────────────
  static const Color border = Color(0xFF1E293B);
  static const Color borderBright = Color(0xFF334155);

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0C1220), Color(0xFF070B14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient pitchGradient = LinearGradient(
    colors: [Color(0xFF0B2217), Color(0xFF0F2E1F), Color(0xFF0B2217)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0C1220), Color(0xFF0F2E1F), Color(0xFF0C1220)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Helper: glass overlay
  static Color glass(double opacity) =>
      Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
}
