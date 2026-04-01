import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/lineup_model.dart';
import '../../data/repositories/lineup_repository.dart';
import '../../routes/app_routes.dart';

class SavedLineupsController extends GetxController {
  final _repo = Get.find<LineupRepository>();

  final lineups = <LineupModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void load() {
    lineups.value = _repo.getAll();
  }

  Future<void> delete(LineupModel lineup) async {
    await _repo.delete(lineup.id);
    load();
    Get.snackbar(
      'Deleted',
      '"${lineup.name}" removed',
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFFF44336),
      duration: const Duration(seconds: 2),
    );
  }

  void openLineup(LineupModel lineup) {
    Get.toNamed(
      AppRoutes.lineupBuilder,
      arguments: {'lineup': lineup},
    );
  }
}
