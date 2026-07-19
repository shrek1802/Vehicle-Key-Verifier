import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/research_record.dart';
import '../repositories/research_repository.dart';
import 'research_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _repository = ResearchRepository.instance;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(ResearchRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete saved research?'),
        content: Text('${record.make} ${record.model} (${record.year}) will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      await _repository.delete(record.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved research deleted.')),
        );
      }
    }
  }

  void _openRecord(ResearchRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.make} ${record.model} (${record.year})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(record.jobType),
            const SizedBox(height: 12),
            ResearchResultsCard(result: record.result),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search saved research',
              hintText: 'Make, model, year or job type',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: _repository.changes,
            builder: (context, _, __) => FutureBuilder<List<ResearchRecord>>(
              future: _repository.getAll(query: _query),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Could not load saved research: ${snapshot.error}'),
                    ),
                  );
                }

                final records = snapshot.data ?? const <ResearchRecord>[];
                if (records.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmarks_outlined, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _query.isEmpty ? 'No saved research yet' : 'No matching research',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _query.isEmpty
                                ? 'Successful Gemini research is saved here automatically.'
                                : 'Try a different search term.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      child: ListTile(
                        onTap: () => _openRecord(record),
                        leading: CircleAvatar(child: Text(record.make.substring(0, 1))),
                        title: Text('${record.make} ${record.model}'),
                        subtitle: Text(
                          '${record.year} • ${record.jobType}\n${DateFormat('dd MMM yyyy, HH:mm').format(record.updatedAt.toLocal())}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: record.isFavourite
                                  ? 'Remove favourite'
                                  : 'Add favourite',
                              onPressed: () => _repository.setFavourite(
                                record,
                                !record.isFavourite,
                              ),
                              icon: Icon(
                                record.isFavourite ? Icons.star : Icons.star_border,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(record),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}