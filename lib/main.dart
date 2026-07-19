import 'package:flutter/material.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    final pages = [

      const Center(
        child: Text(
          "Research Page\nComing in Part 2",
          textAlign: TextAlign.center,
        ),
      ),

      const Center(
        child: Text(
          "Saved Page\nComing in Part 4",
          textAlign: TextAlign.center,
        ),
      ),

      const Center(
        child: Text(
          "Export Page\nComing in Part 5",
          textAlign: TextAlign.center,
        ),
      ),

      const Center(
        child: Text(
          "Settings Page\nComing in Part 6",
          textAlign: TextAlign.center,
        ),
      ),

    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Vehicle Key Verifier"),
        centerTitle: true,
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: NavigationBar(

        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Research",
          ),

          NavigationDestination(
            icon: Icon(Icons.save),
            label: "Saved",
          ),

          NavigationDestination(
            icon: Icon(Icons.archive),
            label: "Export",
          ),

          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),

        ],
      ),
    );
  }
}
