import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Maps Lango HY-MT language codes to ML Kit on-device language IDs.
class MlKitLanguageMapper {
  MlKitLanguageMapper._();

  static const _unsupported = {
    'bo', // Tibetan
    'kk', // Kazakh
    'km', // Khmer
    'mn', // Mongolian
    'my', // Burmese
    'ug', // Uyghur
    'yue', // Cantonese
  };

  static bool isSupported(String code) => !_unsupported.contains(code);

  static TranslateLanguage toMlKit(String code) {
    switch (code) {
      case 'en':
        return TranslateLanguage.english;
      case 'es':
        return TranslateLanguage.spanish;
      case 'fr':
        return TranslateLanguage.french;
      case 'de':
        return TranslateLanguage.german;
      case 'it':
        return TranslateLanguage.italian;
      case 'pt':
        return TranslateLanguage.portuguese;
      case 'ru':
        return TranslateLanguage.russian;
      case 'ja':
        return TranslateLanguage.japanese;
      case 'ko':
        return TranslateLanguage.korean;
      case 'zh':
        return TranslateLanguage.chinese;
      case 'zh-Hant':
        return TranslateLanguage.chinese;
      case 'ar':
        return TranslateLanguage.arabic;
      case 'hi':
        return TranslateLanguage.hindi;
      case 'tr':
        return TranslateLanguage.turkish;
      case 'nl':
        return TranslateLanguage.dutch;
      case 'pl':
        return TranslateLanguage.polish;
      case 'vi':
        return TranslateLanguage.vietnamese;
      case 'th':
        return TranslateLanguage.thai;
      case 'id':
        return TranslateLanguage.indonesian;
      case 'uk':
        return TranslateLanguage.ukrainian;
      case 'cs':
        return TranslateLanguage.czech;
      case 'ms':
        return TranslateLanguage.malay;
      case 'tl':
        return TranslateLanguage.tagalog;
      case 'fa':
        return TranslateLanguage.persian;
      case 'gu':
        return TranslateLanguage.gujarati;
      case 'ur':
        return TranslateLanguage.urdu;
      case 'te':
        return TranslateLanguage.telugu;
      case 'mr':
        return TranslateLanguage.marathi;
      case 'he':
        return TranslateLanguage.hebrew;
      case 'bn':
        return TranslateLanguage.bengali;
      case 'ta':
        return TranslateLanguage.tamil;
      default:
        throw UnsupportedError('Language not supported on-device: $code');
    }
  }
}
