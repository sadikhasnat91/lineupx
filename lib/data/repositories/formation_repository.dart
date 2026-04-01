import 'package:get/get.dart';
import '../models/formation_model.dart';
import '../services/hive_service.dart';
import '../../core/constants/formation_data.dart';

/// Repository that merges preset formations with user-created custom ones.
class FormationRepository {
  final HiveService _hive = Get.find<HiveService>();

  List<FormationModel> getAll() {
    return [...FormationData.all, ..._hive.getCustomFormations()];
  }

  Future<void> saveCustom(FormationModel f) => _hive.saveCustomFormation(f);

  Future<void> deleteCustom(String id) => _hive.deleteCustomFormation(id);
}
