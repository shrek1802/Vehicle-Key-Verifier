import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/research_record.dart';

class ExportCancelledException implements Exception {
  const ExportCancelledException();
}

class ExportService {
  const ExportService();

  Future<String> exportZip(
    List<ResearchRecord> records, {
    String label = 'research',
  }) async {
    if (records.isEmpty) {
      throw StateError('There are no records to export.');
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'vehicle_key_verifier_${_slug(label)}_$timestamp.zip';
    final archive = Archive();

    final exportManifest = <String, dynamic>{
      'format': 'vehicle-key-verifier-export',
      'format_version': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'record_count': records.length,
      'records': records.map(_manifestEntry).toList(),
    };

    _addJson(archive, 'export_manifest.json', exportManifest);

    for (final record in records) {
      _addRecord(archive, record);
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw StateError('The ZIP archive could not be created.');
    }

    final bytes = Uint8List.fromList(encoded);
    String? selectedPath;

    try {
      selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save locksmith research export',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
    } catch (_) {
      selectedPath = null;
    }

    if (selectedPath != null && selectedPath.trim().isNotEmpty) {
      try {
        final output = File(selectedPath);
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes, flush: true);
        return output.path;
      } catch (_) {
        // Some Android document providers return a URI rather than a writable
        // dart:io path. Fall back to the app documents folder below.
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final output = File(p.join(directory.path, fileName));
    await output.writeAsBytes(bytes, flush: true);
    return output.path;
  }

  void _addRecord(Archive archive, ResearchRecord record) {
    final make = _slug(record.make);
    final model = _slug(record.model);
    final recordName = '${record.year}_${_slug(record.jobType)}_${record.id ?? 'local'}';
    final root = 'database/vehicles/$make/$model/research/$recordName';
    final result = record.result;

    final recordMetadata = <String, dynamic>{
      'id': record.id,
      'make': record.make,
      'model': record.model,
      'year': record.year,
      'job_type': record.jobType,
      'is_favourite': record.isFavourite,
      'created_at': record.createdAt.toUtc().toIso8601String(),
      'updated_at': record.updatedAt.toUtc().toIso8601String(),
      'result': result,
    };

    _addJson(archive, '$root/research_record.json', recordMetadata);
    _addJson(archive, '$root/manifest.json', {
      'manufacturer': record.make,
      'model': record.model,
      'year': record.year,
      'job_type': record.jobType,
      'market': _section(result, 'vehicle')['market'] ?? 'Research Required',
      'confidence': result['confidence'] ?? 'Research Required',
      'source_app': 'Vehicle Key Verifier',
      'researched_at': record.createdAt.toUtc().toIso8601String(),
      'updated_at': record.updatedAt.toUtc().toIso8601String(),
    });
    _addJson(archive, '$root/models.json', {
      'vehicle': result['vehicle'] ?? {},
      'keys': result['keys'] ?? {},
    });
    _addJson(archive, '$root/procedures.json', {
      'job_type': record.jobType,
      'programming': result['programming'] ?? {},
      'recommended_methods': result['recommended_methods'] ?? [],
      'job_requirements': result['job_requirements'] ?? {},
    });
    _addJson(archive, '$root/modules.json', {
      'immobiliser': result['immobiliser'] ?? {},
    });
    _addJson(archive, '$root/service_functions.json', {
      'tool_compatibility': result['tool_compatibility'] ?? result['tools'] ?? [],
    });
    _addJson(archive, '$root/notes.json', {
      'more_information': result['more_information'] ?? '',
      'sources': result['sources'] ?? [],
      'confidence': result['confidence'] ?? 'Research Required',
    });
  }

  Map<String, dynamic> _manifestEntry(ResearchRecord record) => {
        'id': record.id,
        'make': record.make,
        'model': record.model,
        'year': record.year,
        'job_type': record.jobType,
        'favourite': record.isFavourite,
        'updated_at': record.updatedAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _section(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  void _addJson(Archive archive, String path, Object value) {
    final text = const JsonEncoder.withIndent('  ').convert(value);
    final bytes = utf8.encode(text);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  String _slug(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return cleaned.isEmpty ? 'unknown' : cleaned;
  }
}
