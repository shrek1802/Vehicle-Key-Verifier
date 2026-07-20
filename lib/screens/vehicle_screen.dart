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
            icon: Icon(Icons.info_outline),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.key),
            text: 'Keys',
          ),
          Tab(
            icon: Icon(Icons.memory),
            text: 'Programming',
          ),
          Tab(
            icon: Icon(Icons.location_on_outlined),
            text: 'Locations',
          ),
          Tab(
            icon: Icon(Icons.build_circle_outlined),
            text: 'Tools',
          ),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: const [
        Center(
          child: Text(
            'Overview Tab',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Center(
          child: Text(
            'Keys Tab',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Center(
          child: Text(
            'Programming Tab',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Center(
          child: Text(
            'Locations Tab',
            style: TextStyle(fontSize: 22),
          ),
        ),
        Center(
          child: Text(
            'Tools Tab',
            style: TextStyle(fontSize: 22),
          ),
        ),
      ],
    ),
  );
}
