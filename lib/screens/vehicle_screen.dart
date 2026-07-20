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
              text: 'Programming',
            ),
            Tab(
              icon: Icon(Icons.place),
              text: 'Locations',
            ),
            Tab(
              icon: Icon(Icons.build),
              text: 'Tools',
            ),
            Tab(
              icon: Icon(Icons.notes),
              text: 'Notes',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(
            child: Text('Overview'),
          ),
          Center(
            child: Text('Programming'),
          ),
          Center(
            child: Text('Locations'),
          ),
          Center(
            child: Text('Tools'),
          ),
          Center(
            child: Text('Notes'),
          ),
        ],
      ),
    );
  }
}
