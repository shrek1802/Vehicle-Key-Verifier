class VehicleRecord {
  VehicleRecord._(this._fields, this.extraFields);

  factory VehicleRecord.fromJson(Map<String, dynamic> json) {
    String pick(List<String> aliases, {String fallback = ''}) {
      for (final alias in aliases) {
        final value = json[alias];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return fallback;
    }

    final fields = <String, String>{
      'Manufacturer': pick(const ['Manufacturer', 'Make']),
      'Model': pick(const ['Model']),
      'Generation': pick(const ['Generation', 'Platform']),
      'Platform': pick(const ['Platform', 'Generation']),
      'Start Year': pick(const ['Start Year', 'StartYear']),
      'End Year': pick(const ['End Year', 'EndYear']),
      'Body Type': pick(const ['Body Type', 'BodyType']),
      'Market': pick(const ['Market'], fallback: 'UK'),
      'Drive Side': pick(const ['Drive Side', 'DriveSide'], fallback: 'RHD'),
      'Key Type': pick(const ['Key Type', 'KeyType', 'Key']),
      'Blade': pick(const ['Blade', 'Blade Profile', 'Key Blade']),
      'Transponder': pick(const ['Transponder', 'Chip', 'Chip Type']),
      'Frequency': pick(const ['Frequency', 'Remote Frequency']),
      'Keyless': pick(const ['Keyless', 'Proximity', 'Prox']),
      'Immobiliser': pick(const ['Immobiliser', 'Immobiliser System', 'Immo System']),
      'Add Key': pick(const ['Add Key', 'Add Key Method', 'Programming Method']),
      'All Keys Lost': pick(const ['All Keys Lost', 'AKL', 'AKL Method']),
      'OBD': pick(const ['OBD', 'OBD Programming', 'Via OBD']),
      'EEPROM / Bench': pick(const ['EEPROM / Bench', 'EEPROM', 'Bench Work', 'Module Work']),
      'Working Key Required': pick(const ['Working Key Required', 'Working Key']),
      'PIN / Security Data': pick(const ['PIN / Security Data', 'PIN', 'Security Data']),
      'Bypass Cable': pick(const ['Bypass Cable', 'Cable', 'Adapter']),
      'SGW': pick(const ['SGW', 'Security Gateway', 'Gateway']),
      'Online': pick(const ['Online', 'Online Required', 'Server']),
      'Programming Warning': pick(const ['Programming Warning', 'Warning', 'Important']),
      'OBD Location': pick(const ['OBD Location', 'OBD Port Location']),
      'Immobiliser Location': pick(const ['Immobiliser Location', 'BCM Location', 'Immo Location']),
      'SGW Location': pick(const ['SGW Location', 'Gateway Location']),
      'ELV Location': pick(const ['ELV Location', 'ESL Location', 'Steering Lock']),
      'KESSY Location': pick(const ['KESSY Location', 'Keyless Module Location']),
      'Emergency Start': pick(const ['Emergency Start', 'Backup Start Location', 'Key Recognition Point']),
      'Tools': pick(const ['Tools', 'Supported Tools', 'Programmers']),
      'Lishi': pick(const ['Lishi', 'Lishi Tool', 'Pick']),
      'Cutter': pick(const ['Cutter', 'Cutting Machine', 'Key Cutting']),
      'Battery Support': pick(const ['Battery Support', 'Power Supply', 'Voltage Support']),
      'Notes': pick(const ['Notes']),
      'Tips': pick(const ['Tips']),
      'Common Faults': pick(const ['Common Faults', 'Known Issues', 'Common Issues']),
      'Source': pick(const ['Source', 'Sources']),
      'Last Verified': pick(const ['Last Verified', 'Verified Date', 'Updated']),
      'Status': pick(const ['Status'], fallback: 'Partially verified'),
    };

    const knownAliases = <String>{
      'Manufacturer', 'Make', 'Model', 'Generation', 'Platform', 'Start Year',
      'StartYear', 'End Year', 'EndYear', 'Body Type', 'BodyType', 'Market',
      'Drive Side', 'DriveSide', 'Key Type', 'KeyType', 'Key', 'Blade',
      'Blade Profile', 'Key Blade', 'Transponder', 'Chip', 'Chip Type',
      'Frequency', 'Remote Frequency', 'Keyless', 'Proximity', 'Prox',
      'Immobiliser', 'Immobiliser System', 'Immo System', 'Add Key',
      'Add Key Method', 'Programming Method', 'All Keys Lost', 'AKL',
      'AKL Method', 'OBD', 'OBD Programming', 'Via OBD', 'EEPROM / Bench',
      'EEPROM', 'Bench Work', 'Module Work', 'Working Key Required',
      'Working Key', 'PIN / Security Data', 'PIN', 'Security Data',
      'Bypass Cable', 'Cable', 'Adapter', 'SGW', 'Security Gateway', 'Gateway',
      'Online', 'Online Required', 'Server', 'Programming Warning', 'Warning',
      'Important', 'OBD Location', 'OBD Port Location', 'Immobiliser Location',
      'BCM Location', 'Immo Location', 'SGW Location', 'Gateway Location',
      'ELV Location', 'ESL Location', 'Steering Lock', 'KESSY Location',
      'Keyless Module Location', 'Emergency Start', 'Backup Start Location',
      'Key Recognition Point', 'Tools', 'Supported Tools', 'Programmers',
      'Lishi', 'Lishi Tool', 'Pick', 'Cutter', 'Cutting Machine', 'Key Cutting',
      'Battery Support', 'Power Supply', 'Voltage Support', 'Notes', 'Tips',
      'Common Faults', 'Known Issues', 'Common Issues', 'Source', 'Sources',
      'Last Verified', 'Verified Date', 'Updated', 'Status',
    };

    final extras = <String, dynamic>{};
    for (final entry in json.entries) {
      if (!knownAliases.contains(entry.key) &&
          entry.value != null &&
          entry.value.toString().trim().isNotEmpty) {
        extras[entry.key] = entry.value;
      }
    }

    return VehicleRecord._(fields, extras);
  }

  final Map<String, String> _fields;
  final Map<String, dynamic> extraFields;

  String get manufacturer => _fields['Manufacturer'] ?? '';
  String get model => _fields['Model'] ?? '';
  String get generation => _fields['Generation'] ?? '';
  int? get startYear => int.tryParse(_fields['Start Year'] ?? '');
  int? get endYear => int.tryParse(_fields['End Year'] ?? '');

  String value(String key, {String fallback = ''}) {
    final value = _fields[key]?.trim() ?? '';
    return value.isEmpty ? fallback : value;
  }

  Map<String, dynamic> toCanonicalMap() {
    return <String, dynamic>{
      ..._fields,
      ...extraFields,
    };
  }
}
