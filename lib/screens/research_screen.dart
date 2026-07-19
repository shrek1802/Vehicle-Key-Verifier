import 'dart:convert';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../services/gemini_service.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({
    required this.controller,
    super.key,
  });

  final AppController controller;

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _geminiService = GeminiService();

  static const _makes = [
    'Audi',
    'BMW',
    'Citroen',
    'Dacia',
    'Fiat',
    'Ford',
    'Honda',
    'Hyundai',
    'Kia',
    'Land Rover',
    'Mercedes-Benz',
    'MINI',
    'Nissan',
    'Peugeot',
    'Renault',
    'SEAT',
    'Skoda',
    'Toyota',
    'Vauxhall',
    'Volkswagen',
    'Volvo',
  ];

  static const _jobTypes = [
    'Spare Key',
    'All Keys Lost',
    'Module Replacement',
    'EEPROM',
  ];

  String? _selectedMake;
  String _jobType = _jobTypes.first;
  bool _isResearching = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _geminiService.dispose();
    super.dispose();
  }

  Future<void> _researchVehicle() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!widget.controller.hasGeminiApiKey) {
      setState(() {
        _errorMessage = 'Add your Gemini API key in Settings before researching.';
        _result = null;
      });
      return;
    }

    final year = int.parse(_yearController.text.trim());

    setState(() {
      _isResearching = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _geminiService.researchVehicle(
        apiKey: widget.controller.geminiApiKey,
        make: _selectedMake!,
        model: _modelController.text.trim(),
        year: year,
        jobType: _jobType,
        ukOnly: widget.controller.ukOnly,
      );

      if (!mounted) return;
      setState(() => _result = result);
    } on GeminiServiceException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unexpected error: $error');
    } finally {
      if (mounted) {
        setState(() => _isResearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedMake,
                    decoration: const InputDecoration(
                      labelText: 'Manufacturer',
                      border: OutlineInputBorder(),
                    ),
                    items: _makes
                        .map(
                          (make) => DropdownMenuItem(
                            value: make,
                            child: Text(make),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null
                        ? 'Select a manufacturer.'
                        : null,
                    onChanged: _isResearching
                        ? null
                        : (value) => setState(() => _selectedMake = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    enabled: !_isResearching,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'For example: Transit Custom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a model.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    enabled: !_isResearching,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'For example: 2021',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final year = int.tryParse(value?.trim() ?? '');
                      final maximumYear = DateTime.now().year + 1;
                      if (year == null) return 'Enter a valid year.';
                      if (year < 1980 || year > maximumYear) {
                        return 'Enter a year from 1980 to $maximumYear.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _jobType,
                    decoration: const InputDecoration(
                      labelText: 'Job Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _jobTypes
                        .map(
                          (job) => DropdownMenuItem(
                            value: job,
                            child: Text(job),
                          ),
                        )
                        .toList(),
                    onChanged: _isResearching
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _jobType = value);
                            }
                          },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isResearching ? null : _researchVehicle,
                      icon: _isResearching
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isResearching ? 'Researching…' : 'Research Vehicle',
                      ),
                    ),
                  ),
                  if (!widget.controller.hasGeminiApiKey) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gemini API key required. Add it on the Settings tab.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 16),
          _ResultsCard(result: _result!),
        ],
      ],
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    const preferredOrder = [
      'vehicle',
      'keys',
      'immobiliser',
      'programming',
      'tools',
      'confidence',
      'sources',
      'more_information',
    ];

    final keys = <String>[
      ...preferredOrder.where(result.containsKey),
      ...result.keys.where((key) => !preferredOrder.contains(key)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined),
                const SizedBox(width: 10),
                Text(
                  'Research Result',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...keys.map(
              (key) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 16),
                initiallyExpanded: key == 'vehicle' || key == 'keys',
                title: Text(_titleFor(key)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(_formatValue(result[key])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleFor(String key) {
    return key
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static String _formatValue(Object? value) {
    if (value == null) return 'Research Required';
    if (value is String) return value.isEmpty ? 'Research Required' : value;
    if (value is List && value.isEmpty) return 'Research Required';
    if (value is Map && value.isEmpty) return 'Research Required';

    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }

    return value.toString();
  }
}
