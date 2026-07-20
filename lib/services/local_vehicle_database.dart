import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vehicle_record.dart';

class LocalVehicleDatabase {
  LocalVehicleDatabase._();

  static final LocalVehicleDatabase instance = LocalVehicleDatabase._();

  List<VehicleRecord> _records = const [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString('assets/data/vag_uk_verified.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Vehicle database root must be a JSON list.');
    }

    _records = decoded
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .map(VehicleRecord.fromJson)
        .where((record) =>
            record.manufacturer.isNotEmpty && record.model.isNotEmpty)
        .toList(growable: false);

    _loaded = true;
  }

  List<String> get manufacturers {
    final values = _records
        .map((record) => record.manufacturer)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  List<String> modelsFor(String manufacturer) {
    final values = _records
        .where((record) => record.manufacturer == manufacturer)
        .map((record) => record.model)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  List<VehicleRecord> find({
    required String manufacturer,
    required String model,
    int? year,
  }) {
    final matches = _records.where((record) {
      if (record.manufacturer != manufacturer) return false;
      if (record.model != model) return false;
      if (year == null) return true;

      final start = record.startYear;
      final end = record.endYear;
      if (start != null && year < start) return false;
      if (end != null && year > end) return false;
      return true;
    }).toList();

    matches.sort((a, b) => (b.startYear ?? 0).compareTo(a.startYear ?? 0));
    return matches;
  }
}
