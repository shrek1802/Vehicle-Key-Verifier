import 'package:flutter/material.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Information'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline_rounded),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.key_rounded),
              text: 'Programming',
            ),
            Tab(
              icon: Icon(Icons.place_outlined),
              text: 'Locations',
            ),
            Tab(
              icon: Icon(Icons.build_outlined),
              text: 'Tools',
            ),
            Tab(
              icon: Icon(Icons.notes_rounded),
              text: 'Notes',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _VehicleTabPlaceholder(
            icon: Icons.info_outline_rounded,
            title: 'Overview',
            message: 'Vehicle overview information will appear here.',
          ),
          _VehicleTabPlaceholder(
            icon: Icons.key_rounded,
            title: 'Programming',
            message: 'Key programming procedures will appear here.',
          ),
          _VehicleTabPlaceholder(
            icon: Icons.place_outlined,
            title: 'Locations',
            message: 'OBD, immobiliser and module locations will appear here.',
          ),
          _VehicleTabPlaceholder(
            icon: Icons.build_outlined,
            title: 'Tool Support',
            message: 'Supported locksmith tools will appear here.',
          ),
          _VehicleTabPlaceholder(
            icon: Icons.notes_rounded,
            title: 'Notes',
            message: 'Vehicle notes and warnings will appear here.',
          ),
        ],
      ),
    );
  }
}

class _VehicleTabPlaceholder extends StatelessWidget {
  const _VehicleTabPlaceholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
