import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppHelpers {
  AppHelpers._();

  /// Position label → accent color.
  static Color positionColor(String label) {
    if (label == 'GK') return AppColors.posGK;
    const defLabels = {'LB', 'RB', 'CB', 'LWB', 'RWB', 'SW'};
    const midLabels = {'CDM', 'CM', 'DM', 'CAM', 'AM', 'LM', 'RM'};
    if (defLabels.contains(label)) return AppColors.posDEF;
    if (midLabels.contains(label)) return AppColors.posMID;
    return AppColors.posFWD;
  }

  /// Display full position name.
  static String positionFullName(String label) {
    const map = {
      'GK': 'Goalkeeper',
      'LB': 'Left Back',
      'RB': 'Right Back',
      'CB': 'Centre Back',
      'LWB': 'Left Wing-Back',
      'RWB': 'Right Wing-Back',
      'SW': 'Sweeper',
      'CDM': 'Def. Midfielder',
      'DM': 'Def. Midfielder',
      'CM': 'Central Midfielder',
      'CAM': 'Attacking Mid',
      'AM': 'Attacking Mid',
      'LM': 'Left Midfielder',
      'RM': 'Right Midfielder',
      'LW': 'Left Winger',
      'RW': 'Right Winger',
      'CF': 'Centre Forward',
      'ST': 'Striker',
    };
    return map[label] ?? label;
  }

  /// Clamp rating 0-99 and convert to display string.
  static String ratingLabel(int rating) => rating.clamp(0, 99).toString();

  /// Rating → color (green = high, amber = mid, red = low).
  static Color ratingColor(int rating) {
    if (rating >= 85) return AppColors.accentGreen;
    if (rating >= 75) return AppColors.warning;
    if (rating >= 65) return AppColors.accentGold;
    return AppColors.error;
  }

  /// Truncate long player names for slot labels.
  static String shortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts.first;
    // e.g. "Kylian Mbappé" → "Mbappé"
    return parts.last;
  }

  /// Initials from a player name (for avatar fallback).
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  /// Map a rating 0-99 to a colour for avatar background.
  static Color avatarBgColor(int rating) {
    if (rating >= 90) return const Color(0xFF1A3A2A);
    if (rating >= 85) return const Color(0xFF1A2E3A);
    if (rating >= 75) return const Color(0xFF2D1B4E);
    return const Color(0xFF2A1A1A);
  }

  /// Show a snackbar.
  static void showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Format DateTime to readable string.
  static String formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
