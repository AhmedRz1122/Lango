import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import 'translation_text_chunker.dart';

/// Online translation via DeepSeek (translation-only backend flow).
class OnlineTranslationService {
  final String? _baseUrlOverride;

  OnlineTranslationService({String? baseUrl}) : _baseUrlOverride = baseUrl;

  List<String> get _candidateUrls {
    final override = _baseUrlOverride;
    if (override != null) return [override];

    const fromEnv = String.fromEnvironment('GENKIT_URL');
    if (fromEnv.isNotEmpty) return [fromEnv];

    if (!kIsWeb && Platform.isAndroid) {
      return AppConstants.androidBackendUrls;
    }
    return [AppConstants.genkitBaseUrl];
  }

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    // One API call for short/medium text — much faster than per-sentence chunking.
    if (trimmed.length <= AppConstants.deepseekSingleRequestMaxChars) {
      return _translateChunk(trimmed, from: from, to: to);
    }

    final chunks = TranslationTextChunker.split(trimmed);
    if (chunks.length <= 1) {
      return _translateChunk(trimmed, from: from, to: to);
    }

    // Long text: translate chunks in parallel to reduce total wait time.
    final results = await Future.wait(
      chunks.map((chunk) => _translateChunk(chunk, from: from, to: to)),
    );
    return results.join(' ');
  }

  Future<String> _translateChunk(
    String chunk, {
    required String from,
    required String to,
  }) async {
    Object? lastError;

    for (final baseUrl in _candidateUrls) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/deepseekTranslateFlow'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'data': {
                  'text': chunk,
                  'sourceLang': from,
                  'targetLang': to,
                },
              }),
            )
            .timeout(
              const Duration(
                seconds: AppConstants.backendTranslateTimeoutSeconds,
              ),
            );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final result = json['result'] as Map<String, dynamic>?;
          final translated = result?['translatedText'] as String?;
          if (translated != null && translated.isNotEmpty) {
            return translated;
          }
        }

        lastError =
            Exception('DeepSeek backend responded with ${response.statusCode}');
      } catch (e) {
        lastError = e;
        debugPrint('Backend $baseUrl failed: $e');
      }
    }

    if (lastError case final Exception error) throw error;
    throw Exception(
      'Online translation unavailable. On a physical phone run:\n'
      'adb reverse tcp:3400 tcp:3400\n'
      'Then start backend: cd backend && npm run dev',
    );
  }

  Future<bool> isAvailable() async {
    for (final baseUrl in _candidateUrls) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/deepseekTranslateFlow'))
            .timeout(
              const Duration(
                seconds: AppConstants.backendConnectTimeoutSeconds,
              ),
            );
        if (response.statusCode < 500) return true;
      } catch (_) {}
    }
    return false;
  }
}
