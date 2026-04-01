import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/formation_model.dart';
import '../../data/repositories/formation_repository.dart';
import '../../routes/app_routes.dart';

class FormationController extends GetxController {
  final _repo = Get.find<FormationRepository>();

  final formations = <FormationModel>[].obs;
  final selected = Rxn<FormationModel>();

  @override
  void onInit() {
    super.onInit();
    formations.value = _repo.getAll();
  }

  void select(FormationModel f) => selected.value = f;

  void confirmSelection() {
    if (selected.value == null) return;
    Get.toNamed(AppRoutes.lineupBuilder,
        arguments: {'formation': selected.value});
  }

  void openCustomBuilder() {
    Get.toNamed(AppRoutes.customFormation);
  }

  Future<void> deleteCustomFormation(String id) async {
    await _repo.deleteCustom(id);
    formations.value = _repo.getAll();
  }

  /// Called from CustomFormationScreen when a custom formation is saved.
  Future<void> saveCustomFormation(FormationModel f) async {
    final toSave = f.isCustom
        ? f
        : f.copyWith(
            id: const Uuid().v4(),
            isCustom: true,
          );
    await _repo.saveCustom(toSave);
    formations.value = _repo.getAll();
  }
}
