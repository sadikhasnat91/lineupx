import 'package:get/get.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/home_controller.dart';
import '../features/formation/formation_selection_screen.dart';
import '../features/formation/formation_controller.dart';
import '../features/formation/custom_formation_screen.dart';
import '../features/lineup_builder/lineup_builder_screen.dart';
import '../features/lineup_builder/lineup_controller.dart';
import '../features/saved_lineups/saved_lineups_screen.dart';
import '../features/saved_lineups/saved_lineups_controller.dart';
import '../features/customization/team_customization_screen.dart';
import '../features/customization/customization_controller.dart';
import '../features/manager_mode/manager_mode_screen.dart';
import '../features/manager_mode/manager_controller.dart';
import '../features/quick_match/quick_match_screen.dart';
import '../features/versus/versus_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.formationSelection,
      page: () => const FormationSelectionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FormationController>(() => FormationController());
      }),
    ),
    GetPage(
      name: AppRoutes.customFormation,
      page: () => const CustomFormationScreen(),
    ),
    GetPage(
      name: AppRoutes.lineupBuilder,
      page: () => const LineupBuilderScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LineupController>(() => LineupController());
      }),
    ),
    GetPage(
      name: AppRoutes.savedLineups,
      page: () => const SavedLineupsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SavedLineupsController>(() => SavedLineupsController());
      }),
    ),
    GetPage(
      name: AppRoutes.teamCustomization,
      page: () => const TeamCustomizationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomizationController>(() => CustomizationController());
      }),
    ),
    GetPage(
      name: AppRoutes.managerMode,
      page: () => const ManagerModeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ManagerController>(() => ManagerController());
      }),
    ),
    GetPage(
      name: AppRoutes.quickMatch,
      page: () => const QuickMatchScreen(),
    ),
    GetPage(
      name: AppRoutes.versus,
      page: () => const VersusScreen(),
    ),
  ];
}
