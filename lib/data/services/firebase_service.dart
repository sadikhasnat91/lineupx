import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      return PlayerSampleData.filterByPositions(positions);
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
      return PlayerSampleData.search(q);
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
      return PlayerSampleData.all;
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
  static String _img(String id) => 'https://i.pravatar.cc/200?u=$id';

  static final List<PlayerModel> all = [
    // ── Goalkeepers ──────────────────────────────────────────────────────────
    _p('alisson', 'Alisson Becker', 'Liverpool', 'Brazil',
        _img('alisson'), 1, ['GK'], 90, 31, 'Right'),
    _p('courtois', 'Thibaut Courtois', 'Real Madrid', 'Belgium',
        _img('courtois'), 1, ['GK'], 90, 32, 'Right'),
    _p('terstegen', 'Marc-André ter Stegen', 'Barcelona', 'Germany',
        _img('terstegen'), 1, ['GK'], 88, 32, 'Right'),
    _p('ederson', 'Ederson', 'Manchester City', 'Brazil',
        _img('ederson'), 31, ['GK'], 88, 30, 'Right'),
    _p('onana', 'André Onana', 'Manchester United', 'Cameroon',
        _img('onana'), 24, ['GK'], 85, 28, 'Right'),

    // ── Defenders ────────────────────────────────────────────────────────────
    _p('vandijk', 'Virgil van Dijk', 'Liverpool', 'Netherlands',
        _img('vandijk'), 4, ['CB'], 90, 33, 'Right'),
    _p('rubendias', 'Rúben Dias', 'Manchester City', 'Portugal',
        _img('rubendias'), 3, ['CB'], 89, 27, 'Right'),
    _p('saliba', 'William Saliba', 'Arsenal', 'France',
        _img('saliba'), 12, ['CB'], 87, 23, 'Right'),
    _p('hakimi', 'Achraf Hakimi', 'PSG', 'Morocco',
        _img('hakimi'), 2, ['RB', 'RWB'], 87, 25, 'Right'),
    _p('theohernandez', 'Theo Hernandez', 'AC Milan', 'France',
        _img('theohernandez'), 19, ['LB', 'LWB'], 86, 26, 'Left'),
    _p('carvajal', 'Dani Carvajal', 'Real Madrid', 'Spain',
        _img('carvajal'), 2, ['RB'], 85, 32, 'Right'),
    _p('alba', 'Jordi Alba', 'Inter Miami', 'Spain',
        _img('alba'), 18, ['LB'], 82, 35, 'Left'),
    _p('militao', 'Eder Militão', 'Real Madrid', 'Brazil',
        _img('militao'), 3, ['CB', 'RB'], 86, 26, 'Right'),
    _p('tapsoba', 'Edmond Tapsoba', 'Bayer Leverkusen', 'Burkina Faso',
        _img('tapsoba'), 5, ['CB'], 83, 25, 'Right'),

    // ── Midfielders ──────────────────────────────────────────────────────────
    _p('rodri', 'Rodri', 'Manchester City', 'Spain',
        _img('rodri'), 16, ['CDM', 'CM'], 92, 28, 'Right'),
    _p('debruyne', 'Kevin De Bruyne', 'Manchester City', 'Belgium',
        _img('debruyne'), 17, ['CM', 'CAM'], 91, 33, 'Right'),
    _p('modric', 'Luka Modrić', 'Real Madrid', 'Croatia',
        _img('modric'), 10, ['CM', 'CAM'], 88, 38, 'Right'),
    _p('bellingham', 'Jude Bellingham', 'Real Madrid', 'England',
        _img('bellingham'), 5, ['CM', 'CAM'], 91, 21, 'Right'),
    _p('pedri', 'Pedri', 'Barcelona', 'Spain',
        _img('pedri'), 8, ['CM', 'CAM'], 88, 22, 'Right'),
    _p('brunofernandes', 'Bruno Fernandes', 'Manchester United', 'Portugal',
        _img('brunofernandes'), 8, ['CAM', 'CM'], 88, 29, 'Right'),
    _p('tonali', 'Sandro Tonali', 'Newcastle', 'Italy',
        _img('tonali'), 8, ['CM', 'CDM'], 85, 24, 'Right'),
    _p('kroos', 'Toni Kroos', 'Real Madrid', 'Germany',
        _img('kroos'), 8, ['CM'], 87, 34, 'Right'),
    _p('camavinga', 'Eduardo Camavinga', 'Real Madrid', 'France',
        _img('camavinga'), 12, ['CM', 'CDM'], 85, 21, 'Left'),

    // ── Forwards ─────────────────────────────────────────────────────────────
    _p('messi', 'Lionel Messi', 'Inter Miami', 'Argentina',
        _img('messi'), 10, ['RW', 'CAM', 'ST'], 94, 37, 'Left'),
    _p('ronaldo', 'Cristiano Ronaldo', 'Al Nassr', 'Portugal',
        _img('ronaldo'), 7, ['ST', 'LW'], 92, 39, 'Right'),
    _p('mbappe', 'Kylian Mbappé', 'Real Madrid', 'France',
        _img('mbappe'), 9, ['ST', 'LW', 'RW'], 93, 26, 'Right'),
    _p('haaland', 'Erling Haaland', 'Manchester City', 'Norway',
        _img('haaland'), 9, ['ST'], 93, 24, 'Left'),
    _p('neymar', 'Neymar Jr', 'Al Hilal', 'Brazil',
        _img('neymar'), 10, ['LW', 'RW', 'CAM'], 88, 32, 'Right'),
    _p('salah', 'Mohamed Salah', 'Liverpool', 'Egypt',
        _img('salah'), 11, ['RW', 'ST'], 91, 32, 'Left'),
    _p('vinicius', 'Vinicius Jr', 'Real Madrid', 'Brazil',
        _img('vinicius'), 7, ['LW', 'ST'], 92, 24, 'Right'),
    _p('yamal', 'Lamine Yamal', 'Barcelona', 'Spain',
        _img('yamal'), 19, ['RW', 'LW', 'CAM'], 87, 17, 'Right'),
    _p('kane', 'Harry Kane', 'Bayern Munich', 'England',
        _img('kane'), 9, ['ST', 'CF'], 90, 30, 'Right'),
    _p('lewandowski', 'Robert Lewandowski', 'Barcelona', 'Poland',
        _img('lewandowski'), 9, ['ST', 'CF'], 89, 36, 'Right'),
    _p('lautaro', 'Lautaro Martínez', 'Inter Milan', 'Argentina',
        _img('lautaro'), 10, ['ST', 'CF'], 89, 26, 'Right'),
    _p('osimhen', 'Victor Osimhen', 'Galatasaray', 'Nigeria',
        _img('osimhen'), 9, ['ST'], 88, 25, 'Right'),
    _p('rashford', 'Marcus Rashford', 'Manchester United', 'England',
        _img('rashford'), 10, ['LW', 'ST'], 83, 26, 'Right'),
    _p('dembele', 'Ousmane Dembélé', 'PSG', 'France',
        _img('dembele'), 10, ['RW', 'LW'], 86, 27, 'Right'),
    _p('leao', 'Rafael Leão', 'AC Milan', 'Portugal',
        _img('leao'), 10, ['LW', 'ST'], 87, 24, 'Left'),
    _p('saka', 'Bukayo Saka', 'Arsenal', 'England',
        _img('saka'), 7, ['RW', 'LW'], 88, 22, 'Left'),
  ];

  static PlayerModel _p(
    String id,
    String name,
    String club,
    String country,
    String imageUrl,
    int number,
    List<String> positions,
    int rating,
    int age,
    String foot,
  ) =>
      PlayerModel(
        id: id,
        name: name,
        club: club,
        country: country,
        imageUrl: imageUrl,
        number: number,
        positions: positions,
        rating: rating,
        age: age,
        preferredFoot: foot,
      );

  static List<PlayerModel> filterByPositions(List<String> positions) {
    if (positions.isEmpty) return all;
    return all
        .where((p) => p.positions.any((pos) => positions.contains(pos)))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  static List<PlayerModel> search(String q) {
    final lower = q.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.club.toLowerCase().contains(lower))
        .toList();
  }
}
