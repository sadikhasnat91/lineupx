import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/player_model.dart';

/// Thin wrapper around Firestore for player data.
/// Falls back to [PlayerSampleData] when Firebase is unavailable.
class FirebaseService {
  FirebaseFirestore? _dbInstance;

  FirebaseFirestore get _db {
    _dbInstance ??= FirebaseFirestore.instance;
    return _dbInstance!;
  }

  // ── Players ──────────────────────────────────────────────────────────────────

  /// Fetch players whose `positions` array contains at least one of [positions].
  /// Firestore `array-contains-any` supports up to 10 values.
  Future<List<PlayerModel>> getPlayersByPositions(
      List<String> positions) async {
    try {
      final chunks = _chunk(positions, 10);
      final results = <PlayerModel>[];
      for (final chunk in chunks) {
        final snap = await _db
            .collection('players')
            .where('positions', arrayContainsAny: chunk)
            .orderBy('rating', descending: true)
            .get();
        results.addAll(snap.docs.map(PlayerModel.fromFirestore));
      }
      // de-duplicate
      final seen = <String>{};
      return results.where((p) => seen.add(p.id)).toList();
    } catch (e) {
      log('[FirebaseService] getPlayersByPositions error: $e');
      return await PlayerSampleData.filterByPositions(positions);
    }
  }

  /// Search players by name (prefix match via Firestore range query).
  Future<List<PlayerModel>> searchPlayers(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim();
    final end = q.substring(0, q.length - 1) +
        String.fromCharCode(q.codeUnitAt(q.length - 1) + 1);
    try {
      final snap = await _db
          .collection('players')
          .orderBy('name')
          .startAt([q])
          .endAt([end])
          .limit(30)
          .get();
      return snap.docs.map(PlayerModel.fromFirestore).toList();
    } catch (e) {
      log('[FirebaseService] searchPlayers error: $e');
      return await PlayerSampleData.search(q);
    }
  }

  /// Get all players (used when seeding / not filtering by position).
  Future<List<PlayerModel>> getAllPlayers({int limit = 100}) async {
    try {
      final snap = await _db
          .collection('players')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(PlayerModel.fromFirestore).toList();
    } catch (e) {
      log('[FirebaseService] getAllPlayers error: $e');
      return await PlayerSampleData.load();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final result = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      result.add(list.sublist(i, (i + size).clamp(0, list.length)));
    }
    return result;
  }
}

// ──────────────────────────────────────────────────────────────��──────────────
// Bundled sample player data (fallback when Firebase is not configured)
// ─────────────────────────────────────────────────────────────────────────────

class PlayerSampleData {
  static List<PlayerModel>? _cache;

  static Future<List<PlayerModel>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/players.json');
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    _cache = list
        .map((e) => PlayerModel.fromAssetJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return _cache!;
  }

  static List<PlayerModel> get all => _cache ?? [];

  static Future<List<PlayerModel>> filterByPositions(List<String> positions) async {
    final data = await load();
    if (positions.isEmpty) return data;
    return data
        .where((p) => p.positions.any((pos) => positions.contains(pos)))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  static Future<List<PlayerModel>> search(String q) async {
    final data = await load();
    final lower = q.toLowerCase();
    return data
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.club.toLowerCase().contains(lower))
        .toList();
  }

}
