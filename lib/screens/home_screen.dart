import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../widgets/app_header.dart';
import 'database_search_screen.dart';
import 'research_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    super.key,
  });

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    DatabaseSearchScreen(
      controller: widget.controller,
    ),
    const SavedScreen(),
    ResearchScreen(
      controller: widget.controller,
    ),
    SettingsScreen(
      controller: widget.controller,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: AppHeader(
                title: 'Vehicle Key Verifier',
                subtitle: 'Professional UK Edition',
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Research',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
