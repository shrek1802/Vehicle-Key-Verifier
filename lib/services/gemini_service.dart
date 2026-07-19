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
        'temperature': 0.2,
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

    return _decodeResearchJson(text);
  }

  Map<String, dynamic> _decodeObject(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
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
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      // A clearer error is thrown below.
    }

    throw const GeminiServiceException(
      'Gemini did not return valid structured JSON. Please try the research again.',
    );
  }

  String _buildPrompt({
    required String make,
    required String model,
    required int year,
    required String jobType,
    required bool ukOnly,
  }) {
    final marketInstruction = ukOnly
        ? 'Research the UK-market, right-hand-drive vehicle only. Exclude US-only systems and procedures.'
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
Do not claim that a tool, attachment, cable, licence or procedure is supported unless you are reasonably confident.
Clearly distinguish confirmed support, model-dependent support, unsupported functions and information that requires verification.
Research multiple professional locksmith tool brands, not only Autel or the user's own tools.
Keep safety and legality in mind and provide professional locksmith reference information only.

For tool compatibility, consider relevant current and legacy tools from manufacturers including:
Autel, Xhorse, OBDSTAR, Advanced Diagnostics/Smart Pro, Lonsdor, Abrites, KEYDIY, Auro/Otofix, TDB, Zed-Full, Tango, Orange5, VVDI, CGDI, Yanhua and other credible professional systems where applicable.
Do not include a tool merely because the brand generally covers the manufacturer.

For every compatible tool entry include:
- exact tool model
- support status: Confirmed, Model Dependent, Unsupported, or Research Required
- supported job functions
- programming path: OBD, Bench, EEPROM, MCU, BDM, Boot, or mixed
- every required attachment, programmer, adapter, cable, bypass lead or interface
- optional accessories
- online account, token, licence or subscription requirements
- minimum software version when reliably known
- whether a dealer key is required or can be generated
- PIN, CS, ISN, password or security data requirements
- SGW, SFD, CAN-FD or gateway requirements
- important limitations and cautions

Use exactly these top-level fields:
{
  "vehicle": {
    "manufacturer": "$make",
    "model": "$model",
    "year": $year,
    "market": "UK or Research Required",
    "summary": ""
  },
  "keys": {
    "key_type": "",
    "blade_profile": "",
    "transponder": "",
    "frequency": "",
    "oem_part_numbers": [],
    "aftermarket_options": [],
    "notes": ""
  },
  "immobiliser": {
    "system": "",
    "module": "",
    "module_location_rhd": "",
    "security_data_required": [],
    "notes": ""
  },
  "programming": {
    "method": "",
    "all_keys_lost": "",
    "spare_key": "",
    "online_required": "",
    "dealer_key_required": "",
    "battery_support": "",
    "estimated_time": "",
    "difficulty": "",
    "backup_requirements": [],
    "notes": ""
  },
  "tool_compatibility": [
    {
      "manufacturer": "",
      "tool_model": "",
      "support_status": "Confirmed, Model Dependent, Unsupported, or Research Required",
      "supported_functions": [],
      "unsupported_functions": [],
      "connection_methods": [],
      "required_attachments": [],
      "required_cables": [],
      "optional_accessories": [],
      "licence_or_subscription": "",
      "minimum_software_version": "",
      "online_required": "",
      "dealer_key_requirement": "",
      "security_data_requirements": [],
      "gateway_requirements": [],
      "limitations": [],
      "notes": ""
    }
  ],
  "job_requirements": {
    "required_equipment": [],
    "required_cables_and_adapters": [],
    "internet_or_account": [],
    "security_data": [],
    "module_removal": [],
    "gateway_or_bypass": [],
    "power_supply": "",
    "warnings": []
  },
  "recommended_methods": [
    {
      "priority": 1,
      "tool_and_method": "",
      "reason": "",
      "requirements": [],
      "limitations": []
    }
  ],
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
