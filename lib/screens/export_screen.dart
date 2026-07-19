import 'package:flutter/material.dart';

import '../models/research_record.dart';
import '../repositories/research_repository.dart';
import '../services/export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _repository = ResearchRepository.instance;
  final _exportService = const ExportService();
  bool _isExporting = false;

  Future<void> _exportAll() async {
    final records = await _repository.getAll();
    await _runExport(records, label: 'all');
  }

  Future<void> _exportFavourites() async {
    final records = (await _repository.getAll())
        .where((record) => record.isFavourite)
        .toList();
    await _runExport(records, label: 'favourites');
  }

  Future<void> _exportSelected() async {
    final records = await _repository.getAll();
    if (!mounted) return;

    if (records.isEmpty) {
      _showMessage('There is no saved research to export.');
      return;
    }

    final selected = <int>{};
    final chosen = await showDialog<List<ResearchRecord>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select research to export'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final key = record.id ?? -(index + 1);
                return CheckboxListTile(
                  value: selected.contains(key),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text('${record.make} ${record.model}'),
                  subtitle: Text('${record.year} • ${record.jobType}'),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        selected.add(key);
                      } else {
                        selected.remove(key);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      final chosenRecords = <ResearchRecord>[];
                      for (var index = 0; index < records.length; index++) {
                        final record = records[index];
                        final key = record.id ?? -(index + 1);
                        if (selected.contains(key)) chosenRecords.add(record);
                      }
                      Navigator.pop(dialogContext, chosenRecords);
                    },
              child: Text('Export ${selected.length}'),
            ),
          ],
        ),
      ),
    );

    if (chosen != null && chosen.isNotEmpty) {
      await _runExport(chosen, label: 'selected');
    }
  }

  Future<void> _runExport(
    List<ResearchRecord> records, {
    required String label,
  }) async {
    if (records.isEmpty) {
      _showMessage('There are no matching records to export.');
      return;
    }

    setState(() => _isExporting = true);
    try {
      final path = await _exportService.exportZip(records, label: label);
      if (!mounted) return;
      _showMessage(
        'Exported ${records.length} record${records.length == 1 ? '' : 's'} successfully.\n$path',
        duration: const Duration(seconds: 8),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Export failed: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _repository.changes,
      builder: (context, _, __) => FutureBuilder<List<ResearchRecord>>(
        future: _repository.getAll(),
        builder: (context, snapshot) {
          final records = snapshot.data ?? const <ResearchRecord>[];
          final favouriteCount = records.where((record) => record.isFavourite).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Export Research',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a Companion-compatible ZIP containing the complete structured Gemini research, tool compatibility, attachments, cables and source information.',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.storage_outlined, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${records.length} saved record${records.length == 1 ? '' : 's'}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text('$favouriteCount marked as favourite'),
                          ],
                        ),
                      ),
                      if (_isExporting)
                        const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ExportOption(
                icon: Icons.check_box_outlined,
                title: 'Export Selected',
                subtitle: 'Choose individual saved vehicle research records.',
                enabled: !_isExporting && records.isNotEmpty,
                onTap: _exportSelected,
              ),
              _ExportOption(
                icon: Icons.star_outline,
                title: 'Export Favourites',
                subtitle: 'Export all records currently marked as favourites.',
                enabled: !_isExporting && favouriteCount > 0,
                onTap: _exportFavourites,
              ),
              _ExportOption(
                icon: Icons.archive_outlined,
                title: 'Export Everything',
                subtitle: 'Export the complete local research database.',
                enabled: !_isExporting && records.isNotEmpty,
                onTap: _exportAll,
              ),
              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ZIP contents',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Master export manifest'),
                      Text('• Full original research record'),
                      Text('• Vehicle and key data'),
                      Text('• Programming procedures and requirements'),
                      Text('• Immobiliser and module information'),
                      Text('• Compatible tools, attachments and cables'),
                      Text('• Sources, confidence and research notes'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
