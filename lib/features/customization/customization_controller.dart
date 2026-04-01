import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/team_settings_model.dart';

class CustomizationController extends GetxController {
  final settings = Rx<TeamSettingsModel>(TeamSettingsModel());

  @override
  void onInit() {
    super.onInit();
    // Load from LineupController if passed via arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final lineupCtrl = args['controller'];
      if (lineupCtrl != null) {
        settings.value = (lineupCtrl as dynamic).teamSettings.value
            as TeamSettingsModel;
      }
    }
  }

  void updateTeamName(String name) {
    settings.value = settings.value.copyWith(teamName: name);
  }

  void updateLogoPath(String? path) {
    settings.value = settings.value.copyWith(logoPath: path);
  }

  void updatePrimaryColor(Color color) {
    settings.value = settings.value.copyWith(primaryColor: color);
  }

  void updateSecondaryColor(Color color) {
    settings.value = settings.value.copyWith(secondaryColor: color);
  }

  void updateAttackStyle(AttackStyle style) {
    settings.value = settings.value.copyWith(attackStyle: style);
  }

  void updateDefStyle(DefensiveStyle style) {
    settings.value = settings.value.copyWith(defensiveStyle: style);
  }

  void updateDefLine(DefensiveLine line) {
    settings.value = settings.value.copyWith(defensiveLine: line);
  }

  void updateWidth(PitchWidth width) {
    settings.value = settings.value.copyWith(width: width);
  }

  void saveAndReturn() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final lineupCtrl = args['controller'];
      if (lineupCtrl != null) {
        (lineupCtrl as dynamic)
            .updateTeamSettings(settings.value);
      }
    }
    Get.back();
    Get.snackbar(
      'Saved',
      'Team settings updated',
      backgroundColor: const Color(0xFF111827),
      colorText: const Color(0xFF00E676),
      duration: const Duration(seconds: 2),
    );
  }
}
