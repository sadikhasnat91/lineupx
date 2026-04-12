import 'package:flutter/material.dart';

// ── Tactic enums ─────────────────────────────────────────────────────────────

enum AttackStyle { possession, counter, longBall }

enum DefensiveStyle { press, balanced, deepBlock }

enum DefensiveLine { high, medium, low }

enum PitchWidth { narrow, balanced, wide }

enum MatchType {
  classic,
  semiFinal,
  firstLeg,
  secondLeg,
  quarterFinal,
  finalMatch,
}

// ── Model ───────────────────────────────────────────────────────────────────

class TeamSettingsModel {
  String teamName;
  String? logoPath; // asset path, data uri, or remote image url
  String coachName;
  String? coachImagePath;
  Color primaryColor;
  Color secondaryColor;
  AttackStyle attackStyle;
  DefensiveStyle defensiveStyle;
  DefensiveLine defensiveLine;
  PitchWidth width;
  MatchType matchType;

  TeamSettingsModel({
    this.teamName = 'My Team',
    this.logoPath,
    this.coachName = '',
    this.coachImagePath,
    this.primaryColor = const Color(0xFF00E676),
    this.secondaryColor = const Color(0xFF0A0E1A),
    this.attackStyle = AttackStyle.possession,
    this.defensiveStyle = DefensiveStyle.balanced,
    this.defensiveLine = DefensiveLine.medium,
    this.width = PitchWidth.balanced,
    this.matchType = MatchType.classic,
  });

  factory TeamSettingsModel.fromJson(Map<String, dynamic> json) =>
      TeamSettingsModel(
        teamName: json['teamName'] as String? ?? 'My Team',
        logoPath: json['logoPath'] as String?,
        coachName: json['coachName'] as String? ?? '',
        coachImagePath: json['coachImagePath'] as String?,
        primaryColor: Color(json['primaryColor'] as int? ?? 0xFF00E676),
        secondaryColor: Color(json['secondaryColor'] as int? ?? 0xFF0A0E1A),
        attackStyle: AttackStyle.values.firstWhere(
          (e) => e.name == json['attackStyle'],
          orElse: () => AttackStyle.possession,
        ),
        defensiveStyle: DefensiveStyle.values.firstWhere(
          (e) => e.name == json['defensiveStyle'],
          orElse: () => DefensiveStyle.balanced,
        ),
        defensiveLine: DefensiveLine.values.firstWhere(
          (e) => e.name == json['defensiveLine'],
          orElse: () => DefensiveLine.medium,
        ),
        width: PitchWidth.values.firstWhere(
          (e) => e.name == json['width'],
          orElse: () => PitchWidth.balanced,
        ),
        matchType: MatchType.values.firstWhere(
          (e) => e.name == json['matchType'],
          orElse: () => MatchType.classic,
        ),
      );

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'logoPath': logoPath,
        'coachName': coachName,
        'coachImagePath': coachImagePath,
        'primaryColor': primaryColor.value,
        'secondaryColor': secondaryColor.value,
        'attackStyle': attackStyle.name,
        'defensiveStyle': defensiveStyle.name,
        'defensiveLine': defensiveLine.name,
        'width': width.name,
        'matchType': matchType.name,
      };

  TeamSettingsModel copyWith({
    String? teamName,
    String? logoPath,
    String? coachName,
    String? coachImagePath,
    Color? primaryColor,
    Color? secondaryColor,
    AttackStyle? attackStyle,
    DefensiveStyle? defensiveStyle,
    DefensiveLine? defensiveLine,
    PitchWidth? width,
    MatchType? matchType,
  }) =>
      TeamSettingsModel(
        teamName: teamName ?? this.teamName,
        logoPath: logoPath ?? this.logoPath,
        coachName: coachName ?? this.coachName,
        coachImagePath: coachImagePath ?? this.coachImagePath,
        primaryColor: primaryColor ?? this.primaryColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        attackStyle: attackStyle ?? this.attackStyle,
        defensiveStyle: defensiveStyle ?? this.defensiveStyle,
        defensiveLine: defensiveLine ?? this.defensiveLine,
        width: width ?? this.width,
        matchType: matchType ?? this.matchType,
      );
}

// ── Display helpers ───────────────────────────────────────────────────────────

extension AttackStyleExt on AttackStyle {
  String get label {
    switch (this) {
      case AttackStyle.possession:
        return 'Possession';
      case AttackStyle.counter:
        return 'Counter';
      case AttackStyle.longBall:
        return 'Long Ball';
    }
  }

  String get icon {
    switch (this) {
      case AttackStyle.possession:
        return '🔄';
      case AttackStyle.counter:
        return '⚡';
      case AttackStyle.longBall:
        return '🎯';
    }
  }
}

extension DefensiveStyleExt on DefensiveStyle {
  String get label {
    switch (this) {
      case DefensiveStyle.press:
        return 'High Press';
      case DefensiveStyle.balanced:
        return 'Balanced';
      case DefensiveStyle.deepBlock:
        return 'Deep Block';
    }
  }

  String get icon {
    switch (this) {
      case DefensiveStyle.press:
        return '🛡️';
      case DefensiveStyle.balanced:
        return '⚖️';
      case DefensiveStyle.deepBlock:
        return '🧱';
    }
  }
}

extension MatchTypeExt on MatchType {
  String get label {
    switch (this) {
      case MatchType.classic:
        return 'Classic';
      case MatchType.semiFinal:
        return 'Semi Final';
      case MatchType.firstLeg:
        return '1st Leg';
      case MatchType.secondLeg:
        return '2nd Leg';
      case MatchType.quarterFinal:
        return 'Quarter Final';
      case MatchType.finalMatch:
        return 'Final';
    }
  }

  String get icon {
    switch (this) {
      case MatchType.classic:
        return '⚽';
      case MatchType.semiFinal:
        return '🥈';
      case MatchType.firstLeg:
        return '1️⃣';
      case MatchType.secondLeg:
        return '2️⃣';
      case MatchType.quarterFinal:
        return '🏟️';
      case MatchType.finalMatch:
        return '🏆';
    }
  }
}

extension DefensiveLineExt on DefensiveLine {
  String get label {
    switch (this) {
      case DefensiveLine.high:
        return 'High';
      case DefensiveLine.medium:
        return 'Medium';
      case DefensiveLine.low:
        return 'Low';
    }
  }

  String get icon {
    switch (this) {
      case DefensiveLine.high:
        return '⬆️';
      case DefensiveLine.medium:
        return '➡️';
      case DefensiveLine.low:
        return '⬇️';
    }
  }
}

extension PitchWidthExt on PitchWidth {
  String get label {
    switch (this) {
      case PitchWidth.narrow:
        return 'Narrow';
      case PitchWidth.balanced:
        return 'Balanced';
      case PitchWidth.wide:
        return 'Wide';
    }
  }

  String get icon {
    switch (this) {
      case PitchWidth.narrow:
        return '↔️';
      case PitchWidth.balanced:
        return '⬌';
      case PitchWidth.wide:
        return '↕️';
    }
  }
}
