import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'mlkit_language_mapper.dart';

/// On-device offline translation for production (Google Play) builds.
/// Uses ML Kit — no development server required.
class OnDeviceTranslationService {
  OnDeviceTranslator? _translator;
  String? _pairKey;

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    if (text.trim().isEmpty) return '';

    if (!MlKitLanguageMapper.isSupported(from) ||
        !MlKitLanguageMapper.isSupported(to)) {
      throw Exception(
        'This language is not available for on-device translation. '
        'Use Online Translation instead.',
      );
    }

    final source = MlKitLanguageMapper.toMlKit(from);
    final target = MlKitLanguageMapper.toMlKit(to);
    final key = '${source.bcpCode}|${target.bcpCode}';

    if (_translator == null || _pairKey != key) {
      await _translator?.close();
      _pairKey = key;
      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );
    }

    await _ensureModel(source);
    await _ensureModel(target);

    return _translator!.translateText(text);
  }

  Future<void> _ensureModel(TranslateLanguage language) async {
    final modelManager = OnDeviceTranslatorModelManager();
    final code = language.bcpCode;
    if (!await modelManager.isModelDownloaded(code)) {
      await modelManager.downloadModel(code, isWifiRequired: false);
    }
  }

  Future<bool> isAvailable() async => true;

  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
    _pairKey = null;
  }
}
