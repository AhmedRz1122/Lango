import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

/// Genkit AI integration for enhanced translation features.
class GenkitAiService {
  final String baseUrl;

  GenkitAiService({String? baseUrl})
      : baseUrl = baseUrl ?? AppConstants.genkitBaseUrl;

  Future<String> explainTranslation({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/explainTranslationFlow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {
          'sourceText': sourceText,
          'translatedText': translatedText,
          'sourceLang': sourceLang,
          'targetLang': targetLang,
        },
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['result'] as Map<String, dynamic>?;
      return result?['explanation'] as String? ?? 'No explanation available.';
    }
    throw Exception('AI explanation unavailable');
  }

  Future<String> contextualTranslate({
    required String text,
    required String from,
    required String to,
    String? context,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contextualTranslateFlow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {
          'text': text,
          'sourceLang': from,
          'targetLang': to,
          'context': context,
        },
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['result'] as Map<String, dynamic>?;
      return result?['translatedText'] as String? ?? text;
    }
    throw Exception('Contextual translation unavailable');
  }

  Future<List<String>> suggestPhrases({
    required String targetLang,
    String? topic,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/suggestPhrasesFlow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {
          'targetLang': targetLang,
          'topic': topic ?? 'travel',
        },
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['result'] as Map<String, dynamic>?;
      final phrases = result?['phrases'] as List<dynamic>?;
      return phrases?.cast<String>() ?? [];
    }
    return [];
  }

  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
