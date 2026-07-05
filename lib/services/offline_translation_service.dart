import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import 'on_device_translation_service.dart';

/// Offline translation:
/// - **Release (Play Store):** on-device via ML Kit — no server needed.
/// - **Debug:** tries Genkit (HY-MT), falls back to on-device ML Kit.
class OfflineTranslationService {
  final String? _genkitUrlOverride;
  final OnDeviceTranslationService _onDevice;

  OfflineTranslationService({
    String? genkitUrl,
    OnDeviceTranslationService? onDevice,
  })  : _genkitUrlOverride = genkitUrl,
        _onDevice = onDevice ?? OnDeviceTranslationService();

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return '';

    if (kReleaseMode) {
      return _onDevice.translate(text: text, from: from, to: to);
    }

    try {
      return await _translateViaGenkit(text: text, from: from, to: to);
    } catch (_) {
      return _onDevice.translate(text: text, from: from, to: to);
    }
  }

  List<String> get _genkitCandidateUrls {
    if (_genkitUrlOverride != null) return [_genkitUrlOverride];

    const fromEnv = String.fromEnvironment('GENKIT_URL');
    if (fromEnv.isNotEmpty) return [fromEnv];

    if (!kIsWeb && Platform.isAndroid) {
      return ['http://10.0.2.2:3400', 'http://127.0.0.1:3400'];
    }
    return [AppConstants.genkitBaseUrl];
  }

  Future<String> _translateViaGenkit({
    required String text,
    required String from,
    required String to,
  }) async {
    Object? lastError;

    for (final baseUrl in _genkitCandidateUrls) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/hyMtTranslateFlow'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'data': {
                  'text': text,
                  'sourceLang': from,
                  'targetLang': to,
                },
              }),
            )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final result = json['result'] as Map<String, dynamic>?;
          final translated = result?['translatedText'] as String?;
          if (translated != null && translated.isNotEmpty) {
            return translated;
          }
        }

        lastError = Exception('Genkit responded with ${response.statusCode}');
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ??
        Exception(
          'Genkit unavailable. Run: cd backend && npm run dev',
        );
  }

  Future<bool> isAvailable() async {
    if (kReleaseMode) return _onDevice.isAvailable();

    for (final baseUrl in _genkitCandidateUrls) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/hyMtTranslateFlow'))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode < 500) return true;
      } catch (_) {}
    }

    return _onDevice.isAvailable();
  }
}
