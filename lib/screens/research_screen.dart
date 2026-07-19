import 'dart:convert';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/research_record.dart';
import '../repositories/research_repository.dart';
import '../services/gemini_service.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({required this.controller, super.key});

  final AppController controller;

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _geminiService = GeminiService();
  final _repository = ResearchRepository.instance;

  static const _makes = [
    'Audi', 'BMW', 'Citroen', 'Dacia', 'Fiat', 'Ford', 'Honda', 'Hyundai',
    'Kia', 'Land Rover', 'Mercedes-Benz', 'MINI', 'Nissan', 'Peugeot',
    'Renault', 'SEAT', 'Skoda', 'Toyota', 'Vauxhall', 'Volkswagen', 'Volvo',
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

  int? _normaliseUkYear(String input) {
    final digits = input.toUpperCase().replaceAll(RegExp(r'[^0-9]'), '');
    final maximumYear = DateTime.now().year + 1;

    if (digits.length == 4) {
      final year = int.tryParse(digits);
      if (year != null && year >= 1980 && year <= maximumYear) return year;
      return null;
    }

    if (digits.length != 2) return null;
    final ageIdentifier = int.tryParse(digits);
    if (ageIdentifier == null) return null;

    int? year;
    if (ageIdentifier >= 1 && ageIdentifier <= 49) {
      year = 2000 + ageIdentifier;
    } else if (ageIdentifier >= 51 && ageIdentifier <= 99) {
      year = 2000 + ageIdentifier - 50;
    }

    if (year == null || year < 1980 || year > maximumYear) return null;
    return year;
  }

  Future<void> _researchVehicle() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!widget.controller.hasGeminiApiKey) {
      setState(() {
        _errorMessage = 'Add your Gemini API key in Settings before researching.';
        _result = null;
      });
      return;
    }

    final year = _normaliseUkYear(_yearController.text.trim())!;
    _yearController.text = year.toString();

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

      final now = DateTime.now();
      await _repository.save(
        ResearchRecord(
          make: _selectedMake!,
          model: _modelController.text.trim(),
          year: year,
          jobType: _jobType,
          result: result,
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (!mounted) return;
      setState(() => _result = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Research saved to Saved Data.')),
      );
    } on GeminiServiceException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unexpected error: $error');
    } finally {
      if (mounted) setState(() => _isResearching = false);
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
                    initialValue: _selectedMake,
                    decoration: const InputDecoration(
                      labelText: 'Manufacturer',
                      border: OutlineInputBorder(),
                    ),
                    items: _makes
                        .map((make) => DropdownMenuItem(value: make, child: Text(make)))
                        .toList(),
                    validator: (value) => value == null ? 'Select a manufacturer.' : null,
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
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Year / UK Registration',
                      hintText: 'For example: 2021, 71 or AB71 CDE',
                      helperText: 'UK registration ages are converted automatically.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final year = _normaliseUkYear(value?.trim() ?? '');
                      if (year == null) {
                        return 'Enter a full year or UK registration age, e.g. 2021 or 71.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _jobType,
                    decoration: const InputDecoration(
                      labelText: 'Job Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _jobTypes
                        .map((job) => DropdownMenuItem(value: job, child: Text(job)))
                        .toList(),
                    onChanged: _isResearching
                        ? null
                        : (value) {
                            if (value != null) setState(() => _jobType = value);
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
                      label: Text(_isResearching ? 'Researching…' : 'Research Vehicle'),
                    ),
                  ),
                  if (!widget.controller.hasGeminiApiKey) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Gemini API key required. Add it on the Settings tab.'),
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
              child: Text(_errorMessage!),
            ),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 16),
          ResearchResultsCard(result: _result!),
        ],
      ],
    );
  }
}

class ResearchResultsCard extends StatelessWidget {
  const ResearchResultsCard({required this.result, super.key});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final tools = _asMapList(result['tool_compatibility']);
    const preferredOrder = [
      'vehicle',
      'keys',
      'immobiliser',
      'programming',
      'job_requirements',
      'recommended_methods',
      'confidence',
      'sources',
      'more_information',
    ];
    final keys = <String>[
      ...preferredOrder.where(result.containsKey),
      ...result.keys.where(
        (key) => !preferredOrder.contains(key) && key != 'tool_compatibility',
      ),
    ];

    return Column(
      children: [
        if (tools.isNotEmpty) ...[
          ToolCompatibilitySection(tools: tools),
          const SizedBox(height: 16),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fact_check_outlined),
                    const SizedBox(width: 10),
                    Text('Research Result', style: Theme.of(context).textTheme.titleLarge),
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
        ),
      ],
    );
  }

  static List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList();
  }

  static String _titleFor(String key) => key
      .split('_')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

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

class ToolCompatibilitySection extends StatelessWidget {
  const ToolCompatibilitySection({required this.tools, super.key});

  final List<Map<String, dynamic>> tools;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tool Compatibility',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Compatible programmers, required attachments, cables and limitations.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...tools.map((tool) => _ToolCard(tool: tool)),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final Map<String, dynamic> tool;

  @override
  Widget build(BuildContext context) {
    final status = _text('support_status');
    final manufacturer = _text('manufacturer');
    final model = _text('tool_model');
    final supported = _strings('supported_functions');
    final unsupported = _strings('unsupported_functions');
    final connections = _strings('connection_methods');
    final attachments = _strings('required_attachments');
    final cables = _strings('required_cables');
    final optional = _strings('optional_accessories');
    final security = _strings('security_data_requirements');
    final gateway = _strings('gateway_requirements');
    final limitations = _strings('limitations');

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(_statusIcon(status)),
        title: Text(
          [manufacturer, model].where((value) => value.isNotEmpty).join(' '),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(status.isEmpty ? 'Research Required' : status),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (supported.isNotEmpty) _DetailGroup(title: 'Supported functions', values: supported),
          if (unsupported.isNotEmpty) _DetailGroup(title: 'Unsupported functions', values: unsupported),
          if (connections.isNotEmpty) _DetailGroup(title: 'Connection methods', values: connections),
          if (attachments.isNotEmpty) _DetailGroup(title: 'Required attachments', values: attachments),
          if (cables.isNotEmpty) _DetailGroup(title: 'Required cables', values: cables),
          if (optional.isNotEmpty) _DetailGroup(title: 'Optional accessories', values: optional),
          _SingleDetail(title: 'Licence or subscription', value: _text('licence_or_subscription')),
          _SingleDetail(title: 'Minimum software version', value: _text('minimum_software_version')),
          _SingleDetail(title: 'Online required', value: _text('online_required')),
          _SingleDetail(title: 'Dealer key requirement', value: _text('dealer_key_requirement')),
          if (security.isNotEmpty) _DetailGroup(title: 'Security data', values: security),
          if (gateway.isNotEmpty) _DetailGroup(title: 'Gateway requirements', values: gateway),
          if (limitations.isNotEmpty) _DetailGroup(title: 'Limitations and cautions', values: limitations),
          _SingleDetail(title: 'Notes', value: _text('notes')),
        ],
      ),
    );
  }

  String _text(String key) {
    final value = tool[key];
    return value == null ? '' : value.toString().trim();
  }

  List<String> _strings(String key) {
    final value = tool[key];
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty && item != 'Research Required')
        .toList();
  }

  IconData _statusIcon(String status) {
    final value = status.toLowerCase();
    if (value.contains('confirmed')) return Icons.check_circle_outline;
    if (value.contains('unsupported')) return Icons.cancel_outlined;
    if (value.contains('dependent')) return Icons.warning_amber_rounded;
    return Icons.help_outline;
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            ...values.map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• $value'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleDetail extends StatelessWidget {
  const _SingleDetail({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty || value == 'Research Required') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: value),
            ],
          ),
        ),
      ),
    );
  }
}
