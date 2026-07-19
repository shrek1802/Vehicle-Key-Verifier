import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VehicleKeyVerifierApp());
}

class VehicleKeyVerifierApp extends StatelessWidget {
  const VehicleKeyVerifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Key Verifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF005A9C),
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}
