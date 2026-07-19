import 'package:flutter/material.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Export Research',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a Companion-compatible ZIP containing verified vehicle records.',
        ),
        const SizedBox(height: 20),
        _ExportOption(
          icon: Icons.check_box_outlined,
          title: 'Export Selected',
          subtitle: 'Export only records you select.',
          onTap: () => _showNotReady(context),
        ),
        _ExportOption(
          icon: Icons.fiber_new_outlined,
          title: 'Export New',
          subtitle: 'Export records not previously exported.',
          onTap: () => _showNotReady(context),
        ),
        _ExportOption(
          icon: Icons.update_outlined,
          title: 'Export Updated',
          subtitle: 'Export records changed since the previous export.',
          onTap: () => _showNotReady(context),
        ),
        _ExportOption(
          icon: Icons.verified_outlined,
          title: 'Export Verified',
          subtitle: 'Export all records marked as verified.',
          onTap: () => _showNotReady(context),
        ),
        _ExportOption(
          icon: Icons.archive_outlined,
          title: 'Export Everything',
          subtitle: 'Export the complete local research database.',
          onTap: () => _showNotReady(context),
        ),
      ],
    );
  }

  static void _showNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ZIP export will be connected in the export stage.')),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
