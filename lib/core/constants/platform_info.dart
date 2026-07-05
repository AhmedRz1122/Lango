import '../../models/language.dart';

/// Platform capability details shown in the About section.
class PlatformInfo {
  PlatformInfo._();

  /// Google Translate officially supports 133 languages.
  static const int googleTranslateLanguageCount = 133;

  /// Speech-to-text model bundled with the app (English).
  static const List<String> speechToTextLanguages = ['English'];

  static List<String> get offlineTranslationLanguages =>
      Language.supported.map((l) => l.name).toList();

  static int get offlineLanguageCount => Language.supported.length;

  /// Languages available for on-device offline translation (Play Store builds).
  static int get onDeviceLanguageCount =>
      Language.supported.where((l) => _onDeviceSupported.contains(l.code)).length;

  static const _onDeviceSupported = {
    'ar', 'bn', 'cs', 'de', 'en', 'es', 'fa', 'fr', 'gu', 'he', 'hi', 'id',
    'it', 'ja', 'ko', 'mr', 'ms', 'nl', 'pl', 'pt', 'ru', 'ta', 'te', 'th',
    'tl', 'tr', 'uk', 'ur', 'vi', 'zh', 'zh-Hant',
  };
}
