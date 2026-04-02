import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'data/services/firebase_service.dart';
import 'data/services/hive_service.dart';
import 'data/repositories/player_repository.dart';
import 'data/repositories/lineup_repository.dart';
import 'data/repositories/formation_repository.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF070B14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive (local storage) – always available
  await HiveService.init();

  // Firebase – gracefully handle missing google-services.json
  try {
    await Firebase.initializeApp();
    log('[Main] Firebase initialized');
  } catch (e) {
    log('[Main] Firebase init skipped: $e');
  }

  // Register global singletons
  Get.put<HiveService>(HiveService());
  Get.put<FirebaseService>(FirebaseService());
  Get.put<PlayerRepository>(PlayerRepository());
  Get.put<LineupRepository>(LineupRepository());
  Get.put<FormationRepository>(FormationRepository());

  // Preload bundled player data
  await PlayerSampleData.load();

  runApp(const LineupXApp());
}

class LineupXApp extends StatelessWidget {
  const LineupXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LineupX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
