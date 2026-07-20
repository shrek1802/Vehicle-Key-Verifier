import 'dart:convert';

import 'package:flutter/services.dart';

class LocalVehicleDatabase {
  LocalVehicleDatabase._();

  static final LocalVehicleDatabase instance = LocalVehicleDatabase._();

  List<Map<String, dynamic>> _records = const [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/vag_uk_verified.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _records = decoded
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);
    _loaded = true;
  }

  List<String> get manufacturers {
    final values = _records
        .map((record) => record['Manufacturer']?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  List<String> modelsFor(String manufacturer) {
    final values = _records
        .where((record) => record['Manufacturer']?.toString() == manufacturer)
        .map((record) => record['Model']?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  List<Map<String, dynamic>> find({
    required String manufacturer,
    required String model,
    int? year,
  }) {
    final matches = _records.where((record) {
      if (record['Manufacturer']?.toString() != manufacturer) return false;
      if (record['Model']?.toString() != model) return false;
      if (year == null) return true;

      final start = _asInt(record['Start Year']);
      final end = _asInt(record['End Year']);
      if (start != null && year < start) return false;
      if (end != null && year > end) return false;
      return true;
    }).map(Map<String, dynamic>.from).toList();

    matches.sort((a, b) {
      final aStart = _asInt(a['Start Year']) ?? 0;
      final bStart = _asInt(b['Start Year']) ?? 0;
      return bStart.compareTo(aStart);
    });
    return matches;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
