import 'package:get/get.dart';
import '../../data/models/lineup_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/team_settings_model.dart';
import '../../data/repositories/lineup_repository.dart';

class ManagerController extends GetxController {
  final LineupRepository _lineupRepo = Get.find();

  final Rx<LineupModel?> activeLineup = Rx<LineupModel?>(null);
  final RxBool isLoading = true.obs;

  // ── computed stats ────────────────────────────────────────────────────────
  double get avgRating {
    final l = activeLineup.value;
    if (l == null) return 0.0;
    final players = l.playerSlots.values
        .whereType<PlayerModel>()
        .toList();
    if (players.isEmpty) return 0.0;
    return players.fold(0.0, (s, p) => s + p.rating) / players.length;
  }

  int get filledSlots {
    final l = activeLineup.value;
    if (l == null) return 0;
    return l.playerSlots.values.whereType<PlayerModel>().length;
  }

  int get benchCount => activeLineup.value?.benchPlayers.length ?? 0;

  String get formationLabel =>
      activeLineup.value?.formation.name ?? '—';

  double get chemistryScore {
    final filled = filledSlots;
    if (filled == 0) return 0.0;
    // Simple chemistry: based on % filled + bench coverage (max 7)
    final pitch = (filled / 11).clamp(0.0, 1.0);
    final bench = (benchCount / 7).clamp(0.0, 1.0);
    return (pitch * 0.7 + bench * 0.3) * 100;
  }

  Map<String, int> get positionBreakdown {
    final l = activeLineup.value;
    if (l == null) return {};
    final breakdown = <String, int>{};
    for (final entry in l.playerSlots.entries) {
      final player = entry.value;
      if (player == null) continue;
      final formationPosition = l.formation.positions
          .where((p) => p.id == entry.key)
          .firstOrNull;
      if (formationPosition == null) continue;
      final type = formationPosition.positionType.name.toUpperCase();
      breakdown[type] = (breakdown[type] ?? 0) + 1;
    }
    return breakdown;
  }

  List<PlayerModel> get startingEleven {
    final l = activeLineup.value;
    if (l == null) return [];
    return l.playerSlots.values.whereType<PlayerModel>().toList();
  }

  List<PlayerModel> get bench => activeLineup.value?.benchPlayers ?? [];

  PlayerModel? get captain {
    final l = activeLineup.value;
    if (l == null || l.captainId == null) return null;
    return l.playerSlots.values
        .whereType<PlayerModel>()
        .where((p) => p.id == l.captainId)
        .firstOrNull;
  }

  PlayerModel? get viceCaptain {
    final l = activeLineup.value;
    if (l == null || l.viceCaptainId == null) return null;
    return l.playerSlots.values
        .whereType<PlayerModel>()
        .where((p) => p.id == l.viceCaptainId)
        .firstOrNull;
  }

  // ── top performers ────────────────────────────────────────────────────────
  List<PlayerModel> get topPlayers {
    final players = startingEleven;
    final sorted = List<PlayerModel>.from(players)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(3).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadMostRecentLineup();
  }

  Future<void> _loadMostRecentLineup() async {
    isLoading.value = true;
    try {
      final lineups = _lineupRepo.getAll();
      if (lineups.isNotEmpty) {
        // sort by updatedAt descending
        lineups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        activeLineup.value = lineups.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => _loadMostRecentLineup();

  /// Switch active lineup from saved lineup id
  Future<void> switchLineup(String id) async {
    final l = await _lineupRepo.getById(id);
    if (l != null) activeLineup.value = l;
  }

  // ── tactical summary label ────────────────────────────────────────────────
  String get tacticsSummary {
    final s = activeLineup.value?.teamSettings;
    if (s == null) return 'No tactics set';
    return '${s.attackStyle.label} · ${s.defensiveStyle.label} · ${s.width.label} width';
  }
}
