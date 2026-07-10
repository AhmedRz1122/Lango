/// Maps Lango language codes to Vosk speech-recognition models.
/// Models are downloaded on demand from https://alphacephei.com/vosk/models
class VoskLanguageConfig {
  final String langCode;
  final String modelZipName;
  final String? assetPath;

  const VoskLanguageConfig({
    required this.langCode,
    required this.modelZipName,
    this.assetPath,
  });

  static const _baseUrl = 'https://alphacephei.com/vosk/models';

  String get downloadUrl => '$_baseUrl/$modelZipName';

  /// Vosk-supported languages that overlap with HY-MT.
  /// Chinese variants share the Mandarin small model.
  static const List<VoskLanguageConfig> _configs = [
    VoskLanguageConfig(
      langCode: 'en',
      modelZipName: 'vosk-model-small-en-us-0.15.zip',
    ),
    VoskLanguageConfig(
      langCode: 'de',
      modelZipName: 'vosk-model-de-0.21.zip',
    ),
    VoskLanguageConfig(
      langCode: 'es',
      modelZipName: 'vosk-model-small-es-0.42.zip',
    ),
    VoskLanguageConfig(
      langCode: 'pt',
      modelZipName: 'vosk-model-small-pt-0.3.zip',
    ),
    VoskLanguageConfig(
      langCode: 'zh',
      modelZipName: 'vosk-model-small-cn-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'zh-Hant',
      modelZipName: 'vosk-model-small-cn-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'yue',
      modelZipName: 'vosk-model-small-cn-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'ru',
      modelZipName: 'vosk-model-small-ru-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'tr',
      modelZipName: 'vosk-model-small-tr-0.3.zip',
    ),
    VoskLanguageConfig(
      langCode: 'vi',
      modelZipName: 'vosk-model-small-vn-0.4.zip',
    ),
    VoskLanguageConfig(
      langCode: 'it',
      modelZipName: 'vosk-model-small-it-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'nl',
      modelZipName: 'vosk-model-small-nl-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'ar',
      modelZipName: 'vosk-model-ar-mgb2-0.4.zip',
    ),
    VoskLanguageConfig(
      langCode: 'fa',
      modelZipName: 'vosk-model-fa-0.5.zip',
    ),
    VoskLanguageConfig(
      langCode: 'tl',
      modelZipName: 'vosk-model-tl-ph-generic-0.6.zip',
    ),
    VoskLanguageConfig(
      langCode: 'uk',
      modelZipName: 'vosk-model-uk-v3.zip',
    ),
    VoskLanguageConfig(
      langCode: 'kk',
      modelZipName: 'vosk-model-kk-0.15.zip',
    ),
    VoskLanguageConfig(
      langCode: 'ja',
      modelZipName: 'vosk-model-ja-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'hi',
      modelZipName: 'vosk-model-hi-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'cs',
      modelZipName: 'vosk-model-cs-0.4.zip',
    ),
    VoskLanguageConfig(
      langCode: 'pl',
      modelZipName: 'vosk-model-pl-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'fr',
      modelZipName: 'vosk-model-fr-0.22.zip',
    ),
    VoskLanguageConfig(
      langCode: 'id',
      modelZipName: 'vosk-model-small-id-0.4.zip',
    ),
  ];

  static final Map<String, VoskLanguageConfig> _byCode = {
    for (final c in _configs) c.langCode: c,
  };

  static VoskLanguageConfig? forLanguage(String code) => _byCode[code];

  static bool isSupported(String code) => _byCode.containsKey(code);

  static List<String> get supportedLanguageCodes =>
      _configs.map((c) => c.langCode).toSet().toList();
}
