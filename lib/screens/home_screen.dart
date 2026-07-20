import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/app_card.dart';
import '../controllers/app_controller.dart';
import 'database_search_screen.dart';
import 'export_screen.dart';
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
    DatabaseSearchScreen(controller: widget.controller),
    const SavedScreen(),
    const ExportScreen(),
    SettingsScreen(controller: widget.controller),
  ];

  static const titles = [
    'Vehicle Search',
    'Saved Data',
    'Export',
    'Settings',
  ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Column(
        children: [

      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: AppHeader(
          title: titles[currentIndex],
          subtitle: 'Vehicle Key Verifier',
          trailing: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.lock_outline),
            ),
          ),
        ),
      ),

      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ),
    ],
  ),
),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
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
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: 'Export',
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
