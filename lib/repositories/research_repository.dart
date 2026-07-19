import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/research_record.dart';

class ResearchRepository {
  ResearchRepository._();

  static final ResearchRepository instance = ResearchRepository._();

  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<ResearchRecord> save(ResearchRecord record) async {
    final database = await AppDatabase.instance.database;
    final id = await database.insert(
      'research_records',
      record.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    changes.value++;
    return record.copyWith(id: id);
  }

  Future<List<ResearchRecord>> getAll({String query = ''}) async {
    final database = await AppDatabase.instance.database;
    final cleaned = query.trim();
    final rows = await database.query(
      'research_records',
      where: cleaned.isEmpty
          ? null
          : 'make LIKE ? OR model LIKE ? OR CAST(year AS TEXT) LIKE ? OR job_type LIKE ?',
      whereArgs: cleaned.isEmpty ? null : List.filled(4, '%$cleaned%'),
      orderBy: 'is_favourite DESC, updated_at DESC',
    );
    return rows.map(ResearchRecord.fromDatabaseMap).toList();
  }

  Future<void> delete(int id) async {
    final database = await AppDatabase.instance.database;
    await database.delete('research_records', where: 'id = ?', whereArgs: [id]);
    changes.value++;
  }

  Future<void> setFavourite(ResearchRecord record, bool value) async {
    if (record.id == null) return;
    final database = await AppDatabase.instance.database;
    await database.update(
      'research_records',
      {
        'is_favourite': value ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
    changes.value++;
  }
}