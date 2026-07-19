import 'dart:convert';

class ResearchRecord {
  const ResearchRecord({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.jobType,
    required this.result,
    required this.createdAt,
    required this.updatedAt,
    this.isFavourite = false,
  });

  final int? id;
  final String make;
  final String model;
  final int year;
  final String jobType;
  final Map<String, dynamic> result;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavourite;

  ResearchRecord copyWith({
    int? id,
    String? make,
    String? model,
    int? year,
    String? jobType,
    Map<String, dynamic>? result,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavourite,
  }) {
    return ResearchRecord(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      jobType: jobType ?? this.jobType,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  Map<String, Object?> toDatabaseMap() {
    return {
      if (id != null) 'id': id,
      'make': make,
      'model': model,
      'year': year,
      'job_type': jobType,
      'result_json': jsonEncode(result),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favourite': isFavourite ? 1 : 0,
    };
  }

  factory ResearchRecord.fromDatabaseMap(Map<String, Object?> map) {
    return ResearchRecord(
      id: map['id'] as int?,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      jobType: map['job_type'] as String,
      result: Map<String, dynamic>.from(
        jsonDecode(map['result_json'] as String) as Map,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isFavourite: (map['is_favourite'] as int? ?? 0) == 1,
    );
  }
}