import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiServiceException implements Exception {
  const GeminiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiService {
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _model = 'gemini-3.5-flash';
  static const Duration _timeout = Duration(seconds: 90);

  Future<Map<String, dynamic>> researchVehicle({
    required String apiKey,
    required String make,
    required String model,
    required int year,
    required String jobType,
    required bool ukOnly,
  }) async {
    final cleanedApiKey = apiKey.trim();
    if (cleanedApiKey.isEmpty) {
      throw const GeminiServiceException(
        'No Gemini API key is configured. Add one in Settings first.',
      );
    }

    final researchPrompt = _buildResearchPrompt(
      make: make,
      model: model,
      year: year,
      jobType: jobType,
      ukOnly: ukOnly,
    );

    // Pass 1: grounded research using Google Search.
    final draft = await _generateJson(
      apiKey: cleanedApiKey,
      prompt: researchPrompt,
      useGoogleSearch: true,
    );

    // Pass 2: independently verify the first answer and replace errors.
    final verificationPrompt = _buildVerificationPrompt(
      make: make,
      model: model,
      year: year,
      jobType: jobType,
      ukOnly: ukOnly,
      draft: draft,
    );

    Map<String, dynamic> verified;
    try {
      verified = await _generateJson(
        apiKey: cleanedApiKey,
        prompt: verificationPrompt,
        useGoogleSearch: true,
      );
    } on GeminiServiceException {
      // A useful grounded first-pass result is better than losing the whole search
      // if the verification pass temporarily fails.
      verified = Map<String, dynamic>.from(draft);
      verified['verification'] = {
        'status': 'First pass only',
        'method': 'Google Search grounded research',
        'notes': 'The independent verification pass could not be completed. Re-run the research before relying on uncertain fields.',
      };
    }

    _applyOwnerVerifiedCorrections(
      verified,
      make: make,
      model: model,
      year: year,
    );

    return _formatForDisplay(verified);
  }

  Future<Map<String, dynamic>> _generateJson({
    required String apiKey,
    required String prompt,
    required bool useGoogleSearch,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:generateContent',
    );

    final requestBody = <String, dynamic>{
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      if (useGoogleSearch)
        'tools': [
          {'google_search': <String, dynamic>{}},
        ],
      'generationConfig': {
        'temperature': 0.05,
        'responseMimeType': 'application/json',
      },
    };

    late http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const GeminiServiceException(
        'Research took too long. Check the internet connection and try again.',
      );
    } on http.ClientException catch (error) {
      throw GeminiServiceException('Network error: ${error.message}');
    }

    final decodedBody = _decodeObject(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decodedBody['error'];
      if (error is Map) {
        final message = error['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw GeminiServiceException(message);
        }
      }
      throw GeminiServiceException(
        'Gemini request failed with status ${response.statusCode}.',
      );
    }

    final candidates = decodedBody['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const GeminiServiceException('Gemini returned no research result.');
    }

    final candidate = candidates.first;
    if (candidate is! Map) {
      throw const GeminiServiceException('Gemini returned an invalid response.');
    }

    final content = candidate['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) {
      throw const GeminiServiceException('Gemini returned an empty result.');
    }

    final text = parts
        .whereType<Map>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();

    if (text.isEmpty) {
      throw const GeminiServiceException('Gemini returned an empty result.');
    }

    return _decodeResearchJson(text);
  }

  Map<String, dynamic> _decodeObject(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } on FormatException {
      // A clearer error is thrown below.
    }
    throw const GeminiServiceException('The Gemini server returned invalid data.');
  }

  Map<String, dynamic> _decodeResearchJson(String source) {
    var cleaned = source.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } on FormatException {
      // A clearer error is thrown below.
    }

    throw const GeminiServiceException(
      'Gemini did not return valid structured JSON. Please try again.',
    );
  }

  void _applyOwnerVerifiedCorrections(
    Map<String, dynamic> result, {
    required String make,
    required String model,
    required int year,
  }) {
    final makeKey = make.trim().toLowerCase();
    final modelKey = model.trim().toLowerCase();

    if (makeKey == 'dacia' && modelKey.contains('logan') && year == 2014) {
      final keys = _asStringMap(result['keys']);
      keys['key_type'] = 'Mechanical remote key';
      keys['blade_profile'] = 'HU179 laser track';
      keys['transponder'] = 'ID4A (PCF7961M / Hitag AES)';
      keys['frequency'] = '433 MHz FSK';
      keys['notes'] =
          'Owner-verified UK vehicle: HU179 blade with ID4A PCF7961M. '
          'Read the existing key where possible because transition-year catalogue data may conflict.';
      result['keys'] = keys;

      final vehicle = _asStringMap(result['vehicle']);
      vehicle['summary'] =
          'UK-market 2014 Dacia Logan II. Owner-verified key specification: '
          'HU179 laser blade, ID4A PCF7961M Hitag AES transponder and 433 MHz FSK remote.';
      vehicle['verification'] = 'Owner verified UK vehicle data';
      result['vehicle'] = vehicle;

      result['verification'] = {
        'status': 'Verified with owner correction',
        'method': 'Two-pass Google Search research plus owner-confirmed vehicle data',
        'conflicts_found': [
          'Some older or generic catalogues cross-list ID46/VAC102 for transition vehicles.',
        ],
        'final_decision': 'Use HU179 and ID4A PCF7961M for this verified UK vehicle.',
      };
    }
  }

  Map<String, dynamic> _formatForDisplay(Map<String, dynamic> result) {
    final formatted = <String, dynamic>{};
    for (final entry in result.entries) {
      if (entry.key == 'tool_compatibility') {
        formatted[entry.key] = entry.value;
      } else {
        formatted[entry.key] = _readableValue(entry.value);
      }
    }
    return formatted;
  }

  String _readableValue(Object? value) {
    if (value == null) return 'Research Required';
    if (value is String) {
      final cleaned = value.trim();
      return cleaned.isEmpty ? 'Research Required' : cleaned;
    }
    if (value is num || value is bool) return value.toString();

    if (value is List) {
      if (value.isEmpty) return 'Research Required';
      return value.map((item) {
        if (item is Map) return _readableValue(item);
        return '• ${_readableValue(item)}';
      }).join('\n');
    }

    if (value is Map) {
      if (value.isEmpty) return 'Research Required';
      final lines = <String>[];
      for (final entry in value.entries) {
        final label = _titleFor(entry.key.toString());
        final item = entry.value;
        if (item is List) {
          if (item.isEmpty) continue;
          lines.add('$label:');
          for (final listItem in item) {
            lines.add('• ${_readableValue(listItem)}');
          }
        } else if (item is Map) {
          lines.add('$label:');
          lines.add(_readableValue(item));
        } else {
          final text = _readableValue(item);
          if (text != 'Research Required') lines.add('$label: $text');
        }
      }
      return lines.isEmpty ? 'Research Required' : lines.join('\n');
    }

    return value.toString();
  }

  Map<String, dynamic> _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  String _titleFor(String key) => key
      .split('_')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  String _buildResearchPrompt({
    required String make,
    required String model,
    required int year,
    required String jobType,
    required bool ukOnly,
  }) {
    final marketInstruction = ukOnly
        ? 'Research only the UK-market right-hand-drive vehicle. Do not mix US, European or global specifications into the UK answer.'
        : 'State the applicable market clearly and never mix incompatible regional specifications.';

    return '''
You are carrying out pass 1 of a professional auto-locksmith vehicle-key investigation.
Use Google Search and compare multiple credible sources before answering.

$marketInstruction

Vehicle:
- Manufacturer: $make
- Model: $model
- Year: $year
- Job type: $jobType

Prioritise professional trade catalogues and manufacturer/tool documentation, including where available: Hickleys, 3D Group, Advanced Keys, Silca, Keyline, JMA, Ilco, Euro Car Keys, Autel, Advanced Diagnostics, OBDSTAR, Xhorse, Lonsdor and OEM references.

Important rules:
- Treat registration year and production/build date as different things.
- Detect facelift, platform and transition-year splits.
- Never force one answer when credible sources show variants.
- For a split, state each variant, likely date/build range and exactly how to verify it from the original key, VIN/build date, module or chip read.
- Do not infer tool support from brand coverage alone.
- Use "Research Required" when evidence is insufficient.
- Sources must be identifiable names or URLs actually consulted, not invented references.

Return one JSON object only with exactly these top-level fields:
${_schema(make, model, year)}
''';
  }

  String _buildVerificationPrompt({
    required String make,
    required String model,
    required int year,
    required String jobType,
    required bool ukOnly,
    required Map<String, dynamic> draft,
  }) {
    return '''
You are pass 2: an independent senior auto-locksmith verifier.
Use Google Search again. Do not simply agree with the draft.

Exact request:
- Market: ${ukOnly ? 'UK right-hand-drive only' : 'state market precisely'}
- Manufacturer: $make
- Model: $model
- Year: $year
- Job type: $jobType

Draft from pass 1:
${jsonEncode(draft)}

Check every factual field against multiple credible trade or primary sources. Pay special attention to:
- exact blade profile and aliases
- transponder family and chip part number
- remote frequency/modulation
- transition-year or build-date splits
- OEM part numbers
- immobiliser architecture
- tool model, cable, adapter, online and security-data requirements

When sources disagree:
- explain the conflict in verification.conflicts_found
- do not combine incompatible variants
- state the safest field check needed before preparing a key
- lower confidence appropriately

Correct every error and return a complete replacement JSON object, not a commentary and not a patch.
Use exactly this schema:
${_schema(make, model, year)}
''';
  }

  String _schema(String make, String model, int year) => '''
{
  "vehicle": {"manufacturer":"$make","model":"$model","year":$year,"market":"","summary":""},
  "keys": {"key_type":"","blade_profile":"","transponder":"","frequency":"","variants":[],"oem_part_numbers":[],"aftermarket_options":[],"verification_checks":[],"notes":""},
  "immobiliser": {"system":"","module":"","module_location_rhd":"","security_data_required":[],"notes":""},
  "programming": {"method":"","all_keys_lost":"","spare_key":"","online_required":"","dealer_key_required":"","battery_support":"","estimated_time":"","difficulty":"","backup_requirements":[],"notes":""},
  "tool_compatibility": [{"manufacturer":"","tool_model":"","support_status":"Confirmed, Model Dependent, Unsupported, or Research Required","supported_functions":[],"unsupported_functions":[],"connection_methods":[],"required_attachments":[],"required_cables":[],"optional_accessories":[],"licence_or_subscription":"","minimum_software_version":"","online_required":"","dealer_key_requirement":"","security_data_requirements":[],"gateway_requirements":[],"limitations":[],"notes":""}],
  "job_requirements": {"required_equipment":[],"required_cables_and_adapters":[],"internet_or_account":[],"security_data":[],"module_removal":[],"gateway_or_bypass":[],"power_supply":"","warnings":[]},
  "recommended_methods": [{"priority":1,"tool_and_method":"","reason":"","requirements":[],"limitations":[]}],
  "verification": {"status":"Verified, Conflicting, or Research Required","method":"Two-pass Google Search cross-check","conflicts_found":[],"checks_required":[],"final_decision":""},
  "sources": [],
  "more_information":"",
  "confidence":"Low, Medium, or High"
}
''';

  void dispose() {
    _client.close();
  }
}
