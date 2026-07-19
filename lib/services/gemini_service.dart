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
  static const Duration _timeout = Duration(seconds: 60);

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

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:generateContent',
    );

    final prompt = _buildPrompt(
      make: make,
      model: model,
      year: year,
      jobType: jobType,
      ukOnly: ukOnly,
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
      'generationConfig': {
        'temperature': 0.1,
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
              'x-goog-api-key': cleanedApiKey,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const GeminiServiceException(
        'Gemini took too long to respond. Check the internet connection and try again.',
      );
    } on http.ClientException catch (error) {
      throw GeminiServiceException('Network error: ${error.message}');
    }

    final decodedBody = _decodeObject(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decodedBody['error'];
      if (error is Map<String, dynamic>) {
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
      final feedback = decodedBody['promptFeedback'];
      throw GeminiServiceException(
        feedback is Map<String, dynamic> && feedback['blockReason'] != null
            ? 'Gemini blocked the request: ${feedback['blockReason']}'
            : 'Gemini returned no research result.',
      );
    }

    final firstCandidate = candidates.first;
    if (firstCandidate is! Map<String, dynamic>) {
      throw const GeminiServiceException('Gemini returned an invalid response.');
    }

    final content = firstCandidate['content'];
    if (content is! Map<String, dynamic>) {
      throw const GeminiServiceException('Gemini returned no readable content.');
    }

    final parts = content['parts'];
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

    final result = _decodeResearchJson(text);
    _applyVerifiedCorrections(result, make: make, model: model, year: year);
    return _formatForDisplay(result);
  }

  Map<String, dynamic> _decodeObject(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) return decoded;
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
    } on FormatException {
      // A clearer error is thrown below.
    }

    throw const GeminiServiceException(
      'Gemini did not return valid structured JSON. Please try the research again.',
    );
  }

  void _applyVerifiedCorrections(
    Map<String, dynamic> result, {
    required String make,
    required String model,
    required int year,
  }) {
    final makeKey = make.trim().toLowerCase();
    final modelKey = model.trim().toLowerCase();

    // Owner-verified UK vehicle data. Verified data always overrides AI output.
    if (makeKey == 'dacia' &&
        modelKey.contains('logan') &&
        year == 2014) {
      final keys = _asStringMap(result['keys']);
      keys['transponder'] = 'ID4A (PCF7961M / Hitag AES)';
      keys['frequency'] = '433 MHz';
      keys['notes'] =
          'Verified UK specification: 2014 Dacia Logan uses ID4A (PCF7961M). '
          'Do not substitute ID46 without confirming the original key.';
      result['keys'] = keys;

      final vehicle = _asStringMap(result['vehicle']);
      vehicle['verification'] = 'Owner verified UK vehicle data';
      result['vehicle'] = vehicle;
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

  String _readableValue(Object? value, {int depth = 0}) {
    if (value == null) return 'Research Required';
    if (value is String) {
      final cleaned = value.trim();
      return cleaned.isEmpty ? 'Research Required' : cleaned;
    }
    if (value is num || value is bool) return value.toString();

    if (value is List) {
      if (value.isEmpty) return 'Research Required';
      return value.map((item) {
        if (item is Map) {
          return _readableValue(item, depth: depth + 1);
        }
        return '• ${_readableValue(item, depth: depth + 1)}';
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
            lines.add('• ${_readableValue(listItem, depth: depth + 1)}');
          }
        } else if (item is Map) {
          lines.add('$label:');
          lines.add(_readableValue(item, depth: depth + 1));
        } else {
          final text = _readableValue(item, depth: depth + 1);
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

  String _buildPrompt({
    required String make,
    required String model,
    required int year,
    required String jobType,
    required bool ukOnly,
  }) {
    final marketInstruction = ukOnly
        ? '''Research the UK-market right-hand-drive vehicle only.
Do not mix European, US or global specifications into the UK answer.
Return the single most likely UK specification for the exact year requested.
Only mention an alternative transponder, key or immobiliser when reliable evidence shows both were genuinely supplied in UK vehicles for that exact model year.
Do not use vague phrases such as "ID46 or ID4A" merely because a model changed around that period.'''
        : 'State the applicable market clearly and do not mix incompatible regional specifications.';

    return '''
You are a careful professional vehicle-key research assistant for an auto locksmith.

$marketInstruction

Vehicle request:
- Manufacturer: $make
- Model: $model
- Year: $year
- Job type: $jobType

Return one JSON object only. Do not use Markdown and do not add text outside the JSON.
Never guess. When reliable information is unavailable, write "Research Required".
Prioritise exact UK model-year data over generic manufacturer coverage.
Do not claim that a tool, attachment, cable, licence or procedure is supported unless you are reasonably confident.
Clearly distinguish confirmed support, model-dependent support, unsupported functions and information that requires verification.
Research multiple professional locksmith tool brands, not only Autel or the user's own tools.
Keep safety and legality in mind and provide professional locksmith reference information only.

For tool compatibility, consider relevant current and legacy tools from manufacturers including:
Autel, Xhorse, OBDSTAR, Advanced Diagnostics/Smart Pro, Lonsdor, Abrites, KEYDIY, Auro/Otofix, TDB, Zed-Full, Tango, Orange5, VVDI, CGDI, Yanhua and other credible professional systems where applicable.
Do not include a tool merely because the brand generally covers the manufacturer.

Use exactly these top-level fields:
{
  "vehicle": {"manufacturer":"$make","model":"$model","year":$year,"market":"UK or Research Required","summary":""},
  "keys": {"key_type":"","blade_profile":"","transponder":"","frequency":"","oem_part_numbers":[],"aftermarket_options":[],"notes":""},
  "immobiliser": {"system":"","module":"","module_location_rhd":"","security_data_required":[],"notes":""},
  "programming": {"method":"","all_keys_lost":"","spare_key":"","online_required":"","dealer_key_required":"","battery_support":"","estimated_time":"","difficulty":"","backup_requirements":[],"notes":""},
  "tool_compatibility": [{"manufacturer":"","tool_model":"","support_status":"Confirmed, Model Dependent, Unsupported, or Research Required","supported_functions":[],"unsupported_functions":[],"connection_methods":[],"required_attachments":[],"required_cables":[],"optional_accessories":[],"licence_or_subscription":"","minimum_software_version":"","online_required":"","dealer_key_requirement":"","security_data_requirements":[],"gateway_requirements":[],"limitations":[],"notes":""}],
  "job_requirements": {"required_equipment":[],"required_cables_and_adapters":[],"internet_or_account":[],"security_data":[],"module_removal":[],"gateway_or_bypass":[],"power_supply":"","warnings":[]},
  "recommended_methods": [{"priority":1,"tool_and_method":"","reason":"","requirements":[],"limitations":[]}],
  "sources": [],
  "more_information": "",
  "confidence": "Low, Medium, or High"
}

Return several tool entries when credible alternatives exist. If support cannot be verified, use Research Required instead of inventing compatibility.
''';
  }

  void dispose() {
    _client.close();
  }
}
