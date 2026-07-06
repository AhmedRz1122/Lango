import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'mlkit_language_mapper.dart';
import 'translation_text_chunker.dart';

/// Fast on-device offline translation via Google ML Kit.
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
        'This language pair is not available for on-device translation. '
        'Try Online mode or choose a supported language.',
      );
    }

    final chunks = TranslationTextChunker.split(text);
    if (chunks.isEmpty) return '';

    final results = <String>[];
    for (final chunk in chunks) {
      results.add(await _translateChunk(chunk, from: from, to: to));
    }
    return results.join(' ');
  }

  Future<String> _translateChunk(
    String chunk, {
    required String from,
    required String to,
  }) async {
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

    return _translator!.translateText(chunk);
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
