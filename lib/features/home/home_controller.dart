import 'package:get/get.dart';
import '../../data/repositories/lineup_repository.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final _repo = Get.find<LineupRepository>();

  final savedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCount();
  }

  void _loadCount() {
    savedCount.value = _repo.getAll().length;
  }

  void createNewLineup() {
    Get.toNamed(AppRoutes.formationSelection);
  }

  void openSavedLineups() {
    Get.toNamed(AppRoutes.savedLineups);
  }

  void openManagerMode() {
    Get.toNamed(AppRoutes.managerMode);
  }

  void openTemplates() {
    // Quick-start: go directly to formation selection
    Get.toNamed(AppRoutes.formationSelection);
  }

  void openTacticalBoard() {
    Get.toNamed(AppRoutes.tacticalBoard);
  }
}
