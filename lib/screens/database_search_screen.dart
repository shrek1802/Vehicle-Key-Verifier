import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../services/local_vehicle_database.dart';
import 'research_screen.dart';

class DatabaseSearchScreen extends StatefulWidget {
  const DatabaseSearchScreen({required this.controller, super.key});

  final AppController controller;

  @override
  State<DatabaseSearchScreen> createState() => _DatabaseSearchScreenState();
}

class _DatabaseSearchScreenState extends State<DatabaseSearchScreen> {
  final _database = LocalVehicleDatabase.instance;
  final _yearController = TextEditingController();

  bool _loading = true;
  String? _make;
  String? _model;
  String? _error;
  List<String> _makes = const [];
  List<String> _models = const [];
  List<Map<String, dynamic>> _results = const [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _database.load();
      if (!mounted) return;
      setState(() {
        _makes = _database.manufacturers;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the offline database: $error';
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  int? _year() {
    final text = _yearController.text.trim();
    if (text.isEmpty) return null;
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 4) return int.tryParse(digits);
    if (digits.length != 2) return null;
    final age = int.tryParse(digits);
    if (age == null) return null;
    if (age >= 1 && age <= 49) return 2000 + age;
    if (age >= 51 && age <= 99) return 2000 + age - 50;
    return null;
  }

  void _search() {
    if (_make == null || _model == null) {
      setState(() => _error = 'Select a manufacturer and model first.');
      return;
    }
    final input = _yearController.text.trim();
    final year = _year();
    if (input.isNotEmpty && year == null) {
      setState(() => _error = 'Enter a full year or UK registration age, e.g. 2021 or 71.');
      return;
    }
    if (year != null) _yearController.text = year.toString();
    setState(() {
      _results = _database.find(manufacturer: _make!, model: _model!, year: year);
      _searched = true;
      _error = null;
    });
  }

  void _openAi() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('AI Research')),
          body: SafeArea(child: ResearchScreen(controller: widget.controller)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('UK Vehicle Search', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('Search the offline database first. Use AI only for rare, imported or unknown vehicles.'),
                const SizedBox(height: 20),
                DropdownMenu<String>(
                  expandedInsets: EdgeInsets.zero,
                  enabled: !_loading,
                  enableFilter: true,
                  enableSearch: true,
                  label: const Text('Manufacturer'),
                  hintText: _loading ? 'Loading database…' : 'Select manufacturer',
                  dropdownMenuEntries: _makes
                      .map((value) => DropdownMenuEntry(value: value, label: value))
                      .toList(),
                  onSelected: (value) {
                    setState(() {
                      _make = value;
                      _model = null;
                      _models = value == null ? const [] : _database.modelsFor(value);
                      _results = const [];
                      _searched = false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownMenu<String>(
                  key: ValueKey(_make),
                  expandedInsets: EdgeInsets.zero,
                  enabled: _make != null,
                  enableFilter: true,
                  enableSearch: true,
                  label: const Text('Model'),
                  hintText: _make == null ? 'Select manufacturer first' : 'Select model',
                  dropdownMenuEntries: _models
                      .map((value) => DropdownMenuEntry(value: value, label: value))
                      .toList(),
                  onSelected: (value) => setState(() {
                    _model = value;
                    _results = const [];
                    _searched = false;
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Year / UK Registration (optional)',
                    hintText: 'For example: 2021, 71 or AB71 CDE',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Database'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openAi,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI Research'),
                ),
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)),
          ),
        ],
        if (_searched && _results.isEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.manage_search, size: 42),
                  const SizedBox(height: 12),
                  Text('No verified record found', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text('This vehicle is not currently in the offline database.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _openAi,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Research with AI'),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._results.map((record) => _VehicleCard(record: record)),
        ],
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final title = '${record['Manufacturer'] ?? ''} ${record['Model'] ?? ''}'.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.verified_outlined),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${record['Generation'] ?? ''} • ${record['Start Year'] ?? ''}–${record['End Year'] ?? ''}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: record.entries
            .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: entry.value.toString()),
                    ])),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
