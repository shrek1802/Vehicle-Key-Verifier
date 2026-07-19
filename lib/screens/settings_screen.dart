import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool showOnlyUkVehicles = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text('Gemini API key'),
                subtitle: const Text('Not configured'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key storage will be added next.')),
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                value: darkMode,
                onChanged: (value) => setState(() => darkMode = value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.flag_outlined),
                title: const Text('UK vehicles only'),
                subtitle: const Text('Use UK registration years and RHD research defaults.'),
                value: showOnlyUkVehicles,
                onChanged: (value) => setState(() => showOnlyUkVehicles = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Vehicle Key Verifier'),
            subtitle: Text('Version 0.1.0'),
          ),
        ),
      ],
    );
  }
}
