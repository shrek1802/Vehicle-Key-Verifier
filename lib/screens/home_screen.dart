import 'package:flutter/material.dart';
import 'research_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  final List<Widget> pages = const [

    ResearchScreen(),

    Center(
      child: Text(
        "Saved Data\nComing Soon",
        textAlign: TextAlign.center,
      ),
    ),

    Center(
      child: Text(
        "Export\nComing Soon",
        textAlign: TextAlign.center,
      ),
    ),

    Center(
      child: Text(
        "Settings\nComing Soon",
        textAlign: TextAlign.center,
      ),
    ),

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Vehicle Key Verifier"),
        centerTitle: true,
      ),

      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(

        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Research",
          ),

          NavigationDestination(
            icon: Icon(Icons.bookmark),
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
