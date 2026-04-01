import 'package:get/get.dart';
import '../models/player_model.dart';
import '../services/firebase_service.dart';
import '../../core/constants/formation_data.dart';

/// Provides players from Firestore with in-memory position caching.
class PlayerRepository {
  final FirebaseService _service = Get.find<FirebaseService>();

  // Position-keyed cache to avoid repeated Firestore reads within a session.
  final Map<String, List<PlayerModel>> _positionCache = {};

  Future<List<PlayerModel>> getForPosition(String positionLabel) async {
    if (_positionCache.containsKey(positionLabel)) {
      return _positionCache[positionLabel]!;
    }
    final positions = FormationData.firestorePositionsFor(positionLabel);
    final players = await _service.getPlayersByPositions(positions);
    _positionCache[positionLabel] = players;
    return players;
  }

  Future<List<PlayerModel>> search(String query) =>
      _service.searchPlayers(query);

  Future<List<PlayerModel>> getAll() => _service.getAllPlayers();

  void clearCache() => _positionCache.clear();
}
