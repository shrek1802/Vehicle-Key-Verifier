import 'package:flutter/material.dart';

import 'controllers/app_controller.dart';
import 'screens/home_screen.dart';
import 'services/app_settings_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AppController(AppSettingsService());
  await controller.initialise();

  runApp(VehicleKeyVerifierApp(controller: controller));
}

class VehicleKeyVerifierApp extends StatelessWidget {
  const VehicleKeyVerifierApp({
    required this.controller,
    super.key,
  });

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Vehicle Key Verifier',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomeScreen(controller: controller),
        );
      },
    );
  }
}