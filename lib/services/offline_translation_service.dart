import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import 'mlkit_language_mapper.dart';
import 'on_device_translation_service.dart';

/// Offline translation:
/// - **Phone / release:** on-device ML Kit (fast, no server).
/// - **Debug:** ML Kit first; HY-MT Python dev server as fallback.
class OfflineTranslationService {
  final String? _hyMtUrlOverride;
  final OnDeviceTranslationService _onDevice;

  OfflineTranslationService({
    String? hyMtUrl,
    OnDeviceTranslationService? onDevice,
  })  : _hyMtUrlOverride = hyMtUrl,
        _onDevice = onDevice ?? OnDeviceTranslationService();

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return '';

    if (_canUseOnDevice(from, to)) {
      try {
        return await _onDevice.translate(text: text, from: from, to: to);
      } catch (e) {
        if (!kDebugMode) rethrow;
        debugPrint('ML Kit translation failed, trying HY-MT dev server: $e');
      }
    }

    if (kDebugMode) {
      return _translateViaHyMt(text: text, from: from, to: to);
    }

    throw Exception(
      'On-device translation is not available for this language pair. '
      'Connect to the internet and use Online mode.',
    );
  }

  bool _canUseOnDevice(String from, String to) =>
      MlKitLanguageMapper.isSupported(from) &&
      MlKitLanguageMapper.isSupported(to);

  String get _hyMtUrl => _hyMtUrlOverride ?? AppConstants.hyMtServiceUrl;

  Future<String> _translateViaHyMt({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_hyMtUrl/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': text,
              'source_lang': from,
              'target_lang': to,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final translation = json['translation'] as String?;
        if (translation != null && translation.isNotEmpty) {
          return translation;
        }
      }
    } catch (e) {
      debugPrint('HY-MT dev server failed: $e');
    }

    if (_canUseOnDevice(from, to)) {
      return _onDevice.translate(text: text, from: from, to: to);
    }

    throw Exception(
      'Offline translation unavailable for this language pair.',
    );
  }

  Future<bool> isAvailable() async {
    if (await _onDevice.isAvailable()) return true;

    if (!kDebugMode) return false;

    try {
      final response = await http
          .get(Uri.parse('$_hyMtUrl/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
