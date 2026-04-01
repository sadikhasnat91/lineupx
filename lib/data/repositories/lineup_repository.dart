import 'package:get/get.dart';
import '../models/lineup_model.dart';
import '../services/hive_service.dart';

/// Thin repository over [HiveService] for lineup CRUD.
class LineupRepository {
  final HiveService _hive = Get.find<HiveService>();

  Future<void> save(LineupModel lineup) => _hive.saveLineup(lineup);

  Future<void> delete(String id) => _hive.deleteLineup(id);

  List<LineupModel> getAll() => _hive.getAllLineups();

  LineupModel? getById(String id) => _hive.getLineup(id);
}
