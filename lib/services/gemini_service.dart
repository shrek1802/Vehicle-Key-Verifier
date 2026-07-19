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
Do not claim that a tool or procedure is supported unless you are reasonably confident.
Keep safety and legality in mind and provide professional locksmith reference information only.

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
    "notes": ""
  },
  "immobiliser": {
    "system": "",
    "module": "",
    "notes": ""
  },
  "programming": {
    "method": "",
    "all_keys_lost": "",
    "spare_key": "",
    "online_required": "",
    "notes": ""
  },
  "tools": [],
  "sources": [],
  "more_information": "",
  "confidence": "Low, Medium, or High"
}
''';
  }

  void dispose() {
    _client.close();
  }
}
