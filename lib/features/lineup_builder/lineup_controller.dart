import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/formation_model.dart';
import '../../data/models/lineup_model.dart';
import '../../data/models/player_model.dart';
import '../../data/models/team_settings_model.dart';
import '../../data/repositories/lineup_repository.dart';

class LineupController extends GetxController {
  final _repo = Get.find<LineupRepository>();

  late final LineupModel lineup;

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Reactive player slots: position_id → PlayerModel?
  final slots = <String, Rx<PlayerModel?>>{}.obs;

  // Bench (max 7)
  final bench = <PlayerModel>[].obs;

  // Captain / vice captain player ids
  final captainId = RxnString();
  final viceCaptainId = RxnString();

  // Team settings (reactive)
  final teamSettings = Rx<TeamSettingsModel>(TeamSettingsModel());

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args?['lineup'] != null) {
      // Restore existing lineup for editing
      lineup = (args!['lineup'] as LineupModel).deepCopy();
    } else {
      // New lineup from selected formation
      final formation = args?['formation'] as FormationModel?;
      if (formation == null) {
        log('[LineupController] No formation provided!');
        return;
      }
      lineup = LineupModel(
        id: const Uuid().v4(),
        name: '${formation.name} Lineup',
        formation: formation,
      );
    }

    // Populate reactive slots from the lineup model
    for (final pos in lineup.formation.positions) {
      slots[pos.id] = Rx<PlayerModel?>(lineup.playerSlots[pos.id]);
    }

    bench.value = List.from(lineup.benchPlayers);
    captainId.value = lineup.captainId;
    viceCaptainId.value = lineup.viceCaptainId;
    teamSettings.value = lineup.teamSettings;
  }

  // ── Slot operations ───────────────────────────────────────────────────────

  void assignPlayer(String positionId, PlayerModel player) {
    slots[positionId]?.value = player;
    lineup.playerSlots[positionId] = player;
  }

  void clearSlot(String positionId) {
    slots[positionId]?.value = null;
    lineup.playerSlots[positionId] = null;
  }

  PlayerModel? playerAt(String positionId) => slots[positionId]?.value;

  // ── Captain ───────────────────────────────────────────────────────────────

  void setCaptain(String playerId) {
    if (captainId.value == playerId) {
      captainId.value = null;
    } else {
      captainId.value = playerId;
      if (viceCaptainId.value == playerId) viceCaptainId.value = null;
    }
  }

  void setViceCaptain(String playerId) {
    if (viceCaptainId.value == playerId) {
      viceCaptainId.value = null;
    } else {
      viceCaptainId.value = playerId;
      if (captainId.value == playerId) captainId.value = null;
    }
  }

  // ── Bench ─────────────────────────────────────────────────────────────────

  void addBenchPlayer(PlayerModel player) {
    if (bench.length >= 7) {
      Get.snackbar('Max reached', 'Bench is full (7 players)',
          backgroundColor: const Color(0xFF111827),
          colorText: Colors.white);
      return;
    }
    if (bench.any((p) => p.id == player.id)) return;
    bench.add(player);
  }

  void removeBenchPlayer(PlayerModel player) => bench.remove(player);

  // ── Team settings ─────────────────────────────────────────────────────────

  void updateTeamSettings(TeamSettingsModel settings) {
    teamSettings.value = settings;
    lineup.teamSettings = settings;
  }

  // ── Save lineup ───────────────────────────────────────────────────────────

  Future<void> save() async {
    isSaving.value = true;
    try {
      lineup.captainId = captainId.value;
      lineup.viceCaptainId = viceCaptainId.value;
      lineup.benchPlayers = List.from(bench);
      lineup.teamSettings = teamSettings.value;
      lineup.updatedAt = DateTime.now();
      await _repo.save(lineup);
      Get.snackbar(
        'Saved!',
        'Lineup "${lineup.name}" saved',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF111827),
        colorText: const Color(0xFF00E676),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      log('[LineupController] save error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Derived stats ─────────────────────────────────────────────────────────

  int get filledCount =>
      slots.values.where((rx) => rx.value != null).length;

  double get avgRating {
    final players =
        slots.values.map((rx) => rx.value).whereType<PlayerModel>().toList();
    if (players.isEmpty) return 0;
    return players.map((p) => p.rating).reduce((a, b) => a + b) /
        players.length;
  }

  int get chemistry {
    // Simplified: chemistry = (filled / total) * 100
    final total = slots.length;
    if (total == 0) return 0;
    return ((filledCount / total) * 100).toInt();
  }
}
