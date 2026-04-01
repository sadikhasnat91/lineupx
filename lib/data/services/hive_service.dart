import 'dart:convert';
import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/lineup_model.dart';
import '../models/formation_model.dart';

/// Local persistence layer using Hive.
/// Everything is serialised as JSON strings to avoid code-gen adapters.
class HiveService {
  static const _lineupBoxName = 'lineups_v1';
  static const _formationBoxName = 'custom_formations_v1';
  static const _settingsBoxName = 'settings_v1';
  static const _cacheBoxName = 'player_cache_v1';

  // ── Init ─────────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(_lineupBoxName),
      Hive.openBox<String>(_formationBoxName),
      Hive.openBox<String>(_settingsBoxName),
      Hive.openBox<String>(_cacheBoxName),
    ]);
    log('[HiveService] Initialized');
  }

  // ── Lineups ──────────────────────────────────────────────────────────────────

  Box<String> get _lineupBox => Hive.box<String>(_lineupBoxName);

  Future<void> saveLineup(LineupModel lineup) async {
    await _lineupBox.put(lineup.id, jsonEncode(lineup.toJson()));
    log('[HiveService] Saved lineup: ${lineup.id}');
  }

  Future<void> deleteLineup(String id) async {
    await _lineupBox.delete(id);
  }

  List<LineupModel> getAllLineups() {
    return _lineupBox.values.map((raw) {
      try {
        return LineupModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        log('[HiveService] Failed to parse lineup: $e');
        return null;
      }
    }).whereType<LineupModel>().toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  LineupModel? getLineup(String id) {
    final raw = _lineupBox.get(id);
    if (raw == null) return null;
    try {
      return LineupModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      log('[HiveService] Failed to parse lineup $id: $e');
      return null;
    }
  }

  // ── Custom Formations ────────────────────────────────────────────────────────

  Box<String> get _formBox => Hive.box<String>(_formationBoxName);

  Future<void> saveCustomFormation(FormationModel f) async {
    await _formBox.put(f.id, jsonEncode(f.toJson()));
  }

  Future<void> deleteCustomFormation(String id) async {
    await _formBox.delete(id);
  }

  List<FormationModel> getCustomFormations() {
    return _formBox.values.map((raw) {
      try {
        return FormationModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<FormationModel>().toList();
  }

  // ── Settings / misc ──────────────────────────────────────────────────────────

  Box<String> get _settingsBox => Hive.box<String>(_settingsBoxName);

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, jsonEncode(value));
  }

  T? getSetting<T>(String key) {
    final raw = _settingsBox.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T?;
    } catch (_) {
      return null;
    }
  }
}
