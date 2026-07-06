import 'package:translator/translator.dart';

/// Seamless online translation service.
/// Uses cloud translation without exposing provider branding in the UI.
class OnlineTranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return '';

    final result = await _translator.translate(
      text,
      from: from,
      to: to,
    );
    return result.text;
  }

  Future<bool> isAvailable() async {
    try {
      await _translator.translate('test', from: 'en', to: 'es');
      return true;
    } catch (_) {
      return false;
    }
  }
}
