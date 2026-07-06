import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

/// Offline translation via Tencent HY-MT1.5 model.
/// Routes through Genkit backend or direct Hy-MT service.
class OfflineTranslationService {
  final String _genkitUrl;
  final String _hyMtUrl;

  OfflineTranslationService({
    String? genkitUrl,
    String? hyMtUrl,
  })  : _genkitUrl = genkitUrl ?? AppConstants.genkitBaseUrl,
        _hyMtUrl = hyMtUrl ?? AppConstants.hyMtServiceUrl;

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return '';

    // Try Genkit Hy-MT flow first
    try {
      final response = await http
          .post(
            Uri.parse('$_genkitUrl/hyMtTranslateFlow'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'data': {
                'text': text,
                'sourceLang': from,
                'targetLang': to,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = json['result'] as Map<String, dynamic>?;
        if (result != null && result['translatedText'] != null) {
          return result['translatedText'] as String;
        }
      }
    } catch (_) {}

    // Fallback to direct Hy-MT Python service
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
        return json['translation'] as String? ?? '';
      }
    } catch (_) {}

    throw Exception(
      'Offline translation unavailable. Ensure HY-MT1.5 service is running.',
    );
  }

  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_genkitUrl/hyMtTranslateFlow'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode < 500;
    } catch (_) {
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
}
