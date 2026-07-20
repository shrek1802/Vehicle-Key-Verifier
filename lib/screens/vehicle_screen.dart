import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../widgets/app_card.dart';
import '../widgets/app_header.dart';
import '../widgets/info_tile.dart';
import '../widgets/status_chip.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({required this.record, super.key});
  final Map<String, dynamic> record;

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <Tab>[
    Tab(icon: Icon(Icons.info_outline_rounded), text: 'Overview'),
    Tab(icon: Icon(Icons.key_rounded), text: 'Programming'),
    Tab(icon: Icon(Icons.place_outlined), text: 'Locations'),
    Tab(icon: Icon(Icons.build_outlined), text: 'Tools'),
    Tab(icon: Icon(Icons.notes_rounded), text: 'Notes'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _value(List<String> keys, {String fallback = 'Not recorded'}) {
    for (final key in keys) {
      final raw = widget.record[key];
      if (raw != null && raw.toString().trim().isNotEmpty) {
        return raw.toString().trim();
      }
    }
    return fallback;
  }

  String _years() {
    final start = _value(const ['Start Year', 'StartYear'], fallback: '');
    final end = _value(const ['End Year', 'EndYear'], fallback: '');
    if (start.isEmpty && end.isEmpty) return 'Not recorded';
    if (start.isEmpty) return 'Up to $end';
    if (end.isEmpty || end.toLowerCase() == 'present') return '$start–Present';
    return '$start–$end';
  }

  @override
  Widget build(BuildContext context) {
    final make = _value(const ['Manufacturer', 'Make'], fallback: 'Vehicle');
    final model = _value(const ['Model'], fallback: '');
    final generation = _value(const ['Generation', 'Platform'], fallback: '');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: AppHeader(
                compact: true,
                icon: Icons.directions_car_filled,
                title: '$make $model'.trim(),
                subtitle: [generation, _years()]
                    .where((item) => item.isNotEmpty && item != 'Not recorded')
                    .join(' • '),
                trailing: IconButton.filledTonal(
                  tooltip: 'Close vehicle',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
            _WorkshopSummary(value: _value),
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.fieldRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(
                  color: AppColors.navigationSelected,
                  borderRadius: AppSpacing.fieldRadius,
                ),
                labelColor: AppColors.primaryLight,
                unselectedLabelColor: AppColors.navigationUnselected,
                labelStyle: AppText.label,
                tabs: _tabs,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(record: widget.record, value: _value, years: _years()),
                  _ProgrammingTab(value: _value),
                  _LocationsTab(value: _value),
                  _ToolsTab(value: _value),
                  _NotesTab(value: _value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopSummary extends StatelessWidget {
  const _WorkshopSummary({required this.value});
  final String Function(List<String>, {String fallback}) value;

  @override
  Widget build(BuildContext context) {
    final addKey = value(const ['Add Key', 'Add Key Method', 'Programming Method']);
    final akl = value(const ['All Keys Lost', 'AKL', 'AKL Method']);
    final sgw = value(const ['SGW', 'Security Gateway', 'Gateway']);
    final online = value(const ['Online', 'Online Required', 'Server']);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _CapabilityChip(label: 'Add key', value: addKey, icon: Icons.key_rounded),
          AppSpacing.gapRowSM,
          _CapabilityChip(label: 'AKL', value: akl, icon: Icons.key_off_outlined),
          AppSpacing.gapRowSM,
          _CapabilityChip(label: 'SGW', value: sgw, icon: Icons.shield_outlined),
          AppSpacing.gapRowSM,
          _CapabilityChip(label: 'Online', value: online, icon: Icons.cloud_outlined),
        ],
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label: $value',
      child: StatusChip(
        label: label.toUpperCase(),
        status: _stateFor(value),
        icon: icon,
      ),
    );
  }
}

AppStatus _stateFor(String value) {
  final text = value.trim().toLowerCase();
  if (text.isEmpty || text == 'not recorded' || text == 'unknown' || text == 'n/a') {
    return AppStatus.unknown;
  }
  if (text.contains('not supported') || text == 'no' || text.contains('unavailable')) {
    return AppStatus.unsupported;
  }
  if (text.contains('warning') || text.contains('bench') || text.contains('remove')) {
    return AppStatus.warning;
  }
  return AppStatus.supported;
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.record, required this.value, required this.years});
  final Map<String, dynamic> record;
  final String Function(List<String>, {String fallback}) value;
  final String years;

  @override
  Widget build(BuildContext context) {
    return _TabList(children: [
      AppCard(
        title: 'Verified vehicle record',
        subtitle: 'Offline UK database information',
        leading: const Icon(Icons.verified_rounded, color: AppColors.verifiedLight),
        trailing: const StatusChip.verified(),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('Manufacturer', value(const ['Manufacturer', 'Make']), Icons.factory_outlined),
          _Info('Model', value(const ['Model']), Icons.directions_car_outlined),
          _Info('Generation / platform', value(const ['Generation', 'Platform']), Icons.account_tree_outlined),
          _Info('Production years', years, Icons.calendar_month_outlined),
          _Info('UK market', value(const ['Market', 'Region'], fallback: 'United Kingdom / RHD'), Icons.flag_outlined),
        ]),
      ),
      AppCard(
        title: 'Key specification',
        leading: const Icon(Icons.key_rounded, color: AppColors.primaryLight),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('Key type', value(const ['Key Type', 'KeyType', 'Key']), Icons.key_outlined),
          _Info('Blade / profile', value(const ['Blade', 'Blade Profile', 'Key Blade']), Icons.content_cut_rounded),
          _Info('Transponder', value(const ['Transponder', 'Chip', 'Chip Type']), Icons.memory_rounded),
          _Info('Remote frequency', value(const ['Frequency', 'Remote Frequency']), Icons.settings_remote_outlined),
          _Info('Keyless / proximity', value(const ['Keyless', 'Proximity', 'Smart Key']), Icons.sensors_outlined),
        ]),
      ),
      _ExtraFieldsCard(record: record),
    ]);
  }
}

class _ProgrammingTab extends StatelessWidget {
  const _ProgrammingTab({required this.value});
  final String Function(List<String>, {String fallback}) value;

  @override
  Widget build(BuildContext context) {
    final warning = value(const ['Programming Warning', 'Warning', 'Important'], fallback: '');
    return _TabList(children: [
      AppCard(
        title: 'Immobiliser and programming',
        leading: const Icon(Icons.security_rounded, color: AppColors.primaryLight),
        trailing: const StatusChip.information(),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('Immobiliser system', value(const ['Immobiliser', 'Immobiliser System', 'Immo System']), Icons.shield_outlined),
          _Info('Add key method', value(const ['Add Key', 'Add Key Method', 'Programming Method']), Icons.add_circle_outline_rounded),
          _Info('All keys lost method', value(const ['All Keys Lost', 'AKL', 'AKL Method']), Icons.key_off_outlined),
          _Info('OBD programming', value(const ['OBD', 'OBD Programming', 'Via OBD']), Icons.cable_rounded),
          _Info('PIN / security data', value(const ['PIN', 'Security Code', 'PIN Required']), Icons.pin_outlined),
          _Info('Module work', value(const ['Module Work', 'EEPROM', 'Bench Method']), Icons.memory_outlined),
        ]),
      ),
      AppCard(
        title: 'Security requirements',
        leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primaryLight),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('Bypass cable / adaptor', value(const ['Bypass Cable', 'Cable', 'Adapter']), Icons.electrical_services_outlined),
          _Info('Security gateway', value(const ['SGW', 'Security Gateway', 'Gateway']), Icons.lock_outline_rounded),
          _Info('Online / server required', value(const ['Online', 'Online Required', 'Server']), Icons.cloud_outlined),
          _Info('Working keys required', value(const ['Working Keys', 'Keys Required', 'Existing Key']), Icons.vpn_key_outlined),
        ]),
      ),
      if (warning.isNotEmpty)
        AppCard(
          backgroundColor: AppColors.warningBackground,
          borderColor: AppColors.warning,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            AppSpacing.gapRowMD,
            Expanded(child: Text(warning, style: AppText.warning)),
          ]),
        ),
    ]);
  }
}

class _LocationsTab extends StatelessWidget {
  const _LocationsTab({required this.value});
  final String Function(List<String>, {String fallback}) value;

  @override
  Widget build(BuildContext context) {
    return _TabList(children: [
      AppCard(
        backgroundColor: AppColors.infoBackground,
        borderColor: AppColors.info,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.flag_outlined, color: AppColors.info),
          AppSpacing.gapRowMD,
          Expanded(
            child: Text(
              'Locations are for UK right-hand-drive vehicles. Confirm trim and model-year differences before dismantling.',
              style: AppText.bodySecondary,
            ),
          ),
        ]),
      ),
      AppCard(
        title: 'UK / RHD locations',
        leading: const Icon(Icons.place_outlined, color: AppColors.primaryLight),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('OBD port', value(const ['OBD Location', 'OBD Port Location']), Icons.settings_input_component_outlined),
          _Info('Immobiliser / BCM', value(const ['Immobiliser Location', 'BCM Location', 'Immo Location']), Icons.memory_outlined),
          _Info('Security gateway', value(const ['SGW Location', 'Gateway Location']), Icons.shield_outlined),
          _Info('ELV / ESL', value(const ['ELV Location', 'ESL Location', 'Steering Lock']), Icons.directions_car_filled_outlined),
          _Info('KESSY / keyless module', value(const ['KESSY Location', 'Keyless Module Location']), Icons.sensors_outlined),
          _Info('Emergency start point', value(const ['Emergency Start', 'Backup Start Location', 'Key Recognition Point']), Icons.emergency_outlined),
        ]),
      ),
    ]);
  }
}

class _ToolsTab extends StatelessWidget {
  const _ToolsTab({required this.value});
  final String Function(List<String>, {String fallback}) value;

  List<String> _splitTools(String raw) {
    if (raw == 'Not recorded') return const [];
    return raw
        .split(RegExp(r'[,;|\n]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final rawTools = value(const ['Tools', 'Supported Tools', 'Programmers']);
    final tools = _splitTools(rawTools);

    return _TabList(children: [
      AppCard(
        title: 'Programming tool support',
        subtitle: tools.isEmpty ? 'No verified tool list recorded yet' : 'Recorded compatible equipment',
        leading: const Icon(Icons.precision_manufacturing_outlined, color: AppColors.primaryLight),
        showDivider: true,
        child: tools.isEmpty
            ? const StatusChip.unknown(label: 'TOOL SUPPORT UNKNOWN')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tool in tools)
                    StatusChip.supported(label: tool.toUpperCase()),
                ],
              ),
      ),
      AppCard(
        title: 'Workshop equipment',
        leading: const Icon(Icons.build_outlined, color: AppColors.primaryLight),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('Lishi / picking tool', value(const ['Lishi', 'Lishi Tool', 'Pick']), Icons.lock_open_outlined),
          _Info('Key cutting', value(const ['Cutter', 'Cutting Machine', 'Key Cutting']), Icons.content_cut_rounded),
          _Info('Battery support', value(const ['Battery Support', 'Power Supply', 'Voltage Support']), Icons.battery_charging_full_rounded),
          _Info('Required cable / adaptor', value(const ['Bypass Cable', 'Cable', 'Adapter']), Icons.cable_rounded),
        ]),
      ),
    ]);
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.value});
  final String Function(List<String>, {String fallback}) value;

  @override
  Widget build(BuildContext context) {
    final source = value(const ['Source', 'Sources']);
    return _TabList(children: [
      AppCard(
        title: 'Technician notes',
        leading: const Icon(Icons.notes_rounded, color: AppColors.primaryLight),
        showDivider: true,
        child: _InfoGroup(items: [
          _Info('Notes', value(const ['Notes']), Icons.description_outlined),
          _Info('Tips', value(const ['Tips']), Icons.lightbulb_outline_rounded),
          _Info('Important', value(const ['Important', 'Warning']), Icons.warning_amber_rounded),
          _Info('Common faults', value(const ['Common Faults', 'Known Issues']), Icons.report_problem_outlined),
        ]),
      ),
      AppCard(
        title: 'Record information',
        leading: const Icon(Icons.fact_check_outlined, color: AppColors.verifiedLight),
        showDivider: true,
        child: Column(children: [
          InfoTile(
            label: 'Source',
            value: source,
            icon: Icons.source_outlined,
            copyable: source != 'Not recorded',
            onTap: source == 'Not recorded'
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: source));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Source copied')),
                    );
                  },
          ),
          const Divider(color: AppColors.divider),
          InfoTile(
            label: 'Last verified',
            value: value(const ['Last Verified', 'Verified Date', 'Updated']),
            icon: Icons.event_available_outlined,
          ),
          const Divider(color: AppColors.divider),
          InfoTile(
            label: 'Record status',
            value: value(const ['Status'], fallback: 'Verified database record'),
            icon: Icons.verified_user_outlined,
          ),
        ]),
      ),
    ]);
  }
}

class _ExtraFieldsCard extends StatelessWidget {
  const _ExtraFieldsCard({required this.record});
  final Map<String, dynamic> record;

  static const known = <String>{
    'Manufacturer', 'Make', 'Model', 'Generation', 'Platform', 'Start Year',
    'StartYear', 'End Year', 'EndYear', 'Key Type', 'KeyType', 'Key', 'Blade',
    'Blade Profile', 'Key Blade', 'Transponder', 'Chip', 'Chip Type',
    'Frequency', 'Remote Frequency', 'Keyless', 'Proximity', 'Smart Key',
    'Immobiliser', 'Immobiliser System', 'Immo System', 'Add Key',
    'Add Key Method', 'Programming Method', 'All Keys Lost', 'AKL',
    'AKL Method', 'OBD', 'OBD Programming', 'Via OBD', 'PIN',
    'Security Code', 'PIN Required', 'Module Work', 'EEPROM', 'Bench Method',
    'Working Keys', 'Keys Required', 'Existing Key', 'Bypass Cable', 'Cable',
    'Adapter', 'SGW', 'Security Gateway', 'Gateway', 'Online',
    'Online Required', 'Server', 'Programming Warning', 'Warning', 'Important',
    'OBD Location', 'OBD Port Location', 'Immobiliser Location', 'BCM Location',
    'Immo Location', 'SGW Location', 'Gateway Location', 'ELV Location',
    'ESL Location', 'Steering Lock', 'KESSY Location',
    'Keyless Module Location', 'Emergency Start', 'Backup Start Location',
    'Key Recognition Point', 'Tools', 'Supported Tools', 'Programmers', 'Lishi',
    'Lishi Tool', 'Pick', 'Cutter', 'Cutting Machine', 'Key Cutting',
    'Battery Support', 'Power Supply', 'Voltage Support', 'Notes', 'Tips',
    'Common Faults', 'Known Issues', 'Source', 'Sources', 'Last Verified',
    'Verified Date', 'Updated', 'Status', 'Market', 'Region',
  };

  @override
  Widget build(BuildContext context) {
    final extras = record.entries
        .where((entry) =>
            !known.contains(entry.key) &&
            entry.value != null &&
            entry.value.toString().trim().isNotEmpty)
        .toList();
    if (extras.isEmpty) return const SizedBox.shrink();

    return AppCard(
      title: 'Additional database fields',
      leading: const Icon(Icons.list_alt_rounded, color: AppColors.primaryLight),
      showDivider: true,
      child: _InfoGroup(items: [
        for (final entry in extras)
          _Info(entry.key, entry.value.toString(), Icons.chevron_right_rounded),
      ]),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.items});
  final List<_Info> items;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var index = 0; index < items.length; index++) ...[
        InfoTile(label: items[index].label, value: items[index].value, icon: items[index].icon),
        if (index < items.length - 1) const Divider(color: AppColors.divider),
      ],
    ]);
  }
}

class _Info {
  const _Info(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _TabList extends StatelessWidget {
  const _TabList({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
      itemCount: children.length,
      separatorBuilder: (_, __) => AppSpacing.gapLG,
      itemBuilder: (_, index) => children[index],
    );
  }
}
