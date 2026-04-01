import 'formation_model.dart';
import 'player_model.dart';
import 'team_settings_model.dart';

/// A complete saved lineup.
class LineupModel {
  final String id;
  String name;
  FormationModel formation;

  /// Map of position-slot id → assigned player (null = empty).
  Map<String, PlayerModel?> playerSlots;

  /// Up to 7 bench players.
  List<PlayerModel> benchPlayers;

  String? captainId; // player id
  String? viceCaptainId;

  TeamSettingsModel teamSettings;
  DateTime createdAt;
  DateTime updatedAt;

  LineupModel({
    required this.id,
    required this.name,
    required this.formation,
    Map<String, PlayerModel?>? playerSlots,
    List<PlayerModel>? benchPlayers,
    this.captainId,
    this.viceCaptainId,
    TeamSettingsModel? teamSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : playerSlots = playerSlots ??
            {for (final p in formation.positions) p.id: null},
        benchPlayers = benchPlayers ?? [],
        teamSettings = teamSettings ?? TeamSettingsModel(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ── Derived helpers ──────────────────────────────────────────────────────────

  int get filledSlots =>
      playerSlots.values.where((p) => p != null).length;

  bool get isComplete => filledSlots == formation.positions.length;

  double get averageRating {
    final players = playerSlots.values.whereType<PlayerModel>().toList();
    if (players.isEmpty) return 0;
    return players.map((p) => p.rating).reduce((a, b) => a + b) /
        players.length;
  }

  // ── JSON serialisation ────────────────────────────────────────────────────────

  factory LineupModel.fromJson(Map<String, dynamic> json) {
    final formation =
        FormationModel.fromJson(json['formation'] as Map<String, dynamic>);

    final rawSlots = json['playerSlots'] as Map<String, dynamic>? ?? {};
    final slots = <String, PlayerModel?>{};
    for (final pos in formation.positions) {
      final rawPlayer = rawSlots[pos.id];
      slots[pos.id] =
          rawPlayer != null ? PlayerModel.fromJson(rawPlayer as Map<String, dynamic>) : null;
    }

    return LineupModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      formation: formation,
      playerSlots: slots,
      benchPlayers: (json['benchPlayers'] as List? ?? [])
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      captainId: json['captainId'] as String?,
      viceCaptainId: json['viceCaptainId'] as String?,
      teamSettings: json['teamSettings'] != null
          ? TeamSettingsModel.fromJson(
              json['teamSettings'] as Map<String, dynamic>)
          : TeamSettingsModel(),
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'formation': formation.toJson(),
        'playerSlots': {
          for (final e in playerSlots.entries)
            e.key: e.value?.toJson(),
        },
        'benchPlayers': benchPlayers.map((p) => p.toJson()).toList(),
        'captainId': captainId,
        'viceCaptainId': viceCaptainId,
        'teamSettings': teamSettings.toJson(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  LineupModel deepCopy() => LineupModel.fromJson(toJson());
}
