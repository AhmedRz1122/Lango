import 'translation_mode.dart';
import 'deepseek_languages.dart';

class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });

  /// 38 languages for on-device offline translation (HY-MT / ML Kit).
  static const List<Language> offlineSupported = [
    Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
    Language(code: 'en', name: 'English', flag: '🇬🇧'),
    Language(code: 'fr', name: 'French', flag: '🇫🇷'),
    Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    Language(code: 'tr', name: 'Turkish', flag: '🇹🇷'),
    Language(code: 'ru', name: 'Russian', flag: '🇷🇺'),
    Language(code: 'ar', name: 'Arabic', flag: '🇸🇦'),
    Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    Language(code: 'th', name: 'Thai', flag: '🇹🇭'),
    Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
    Language(code: 'de', name: 'German', flag: '🇩🇪'),
    Language(code: 'vi', name: 'Vietnamese', flag: '🇻🇳'),
    Language(code: 'ms', name: 'Malay', flag: '🇲🇾'),
    Language(code: 'id', name: 'Indonesian', flag: '🇮🇩'),
    Language(code: 'tl', name: 'Filipino', flag: '🇵🇭'),
    Language(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
    Language(code: 'zh-Hant', name: 'Traditional Chinese', flag: '🇹🇼'),
    Language(code: 'pl', name: 'Polish', flag: '🇵🇱'),
    Language(code: 'cs', name: 'Czech', flag: '🇨🇿'),
    Language(code: 'nl', name: 'Dutch', flag: '🇳🇱'),
    Language(code: 'km', name: 'Khmer', flag: '🇰🇭'),
    Language(code: 'my', name: 'Burmese', flag: '🇲🇲'),
    Language(code: 'fa', name: 'Persian', flag: '🇮🇷'),
    Language(code: 'gu', name: 'Gujarati', flag: '🇮🇳'),
    Language(code: 'ur', name: 'Urdu', flag: '🇵🇰'),
    Language(code: 'te', name: 'Telugu', flag: '🇮🇳'),
    Language(code: 'mr', name: 'Marathi', flag: '🇮🇳'),
    Language(code: 'he', name: 'Hebrew', flag: '🇮🇱'),
    Language(code: 'bn', name: 'Bengali', flag: '🇧🇩'),
    Language(code: 'ta', name: 'Tamil', flag: '🇮🇳'),
    Language(code: 'uk', name: 'Ukrainian', flag: '🇺🇦'),
    Language(code: 'bo', name: 'Tibetan', flag: '🏔️'),
    Language(code: 'kk', name: 'Kazakh', flag: '🇰🇿'),
    Language(code: 'mn', name: 'Mongolian', flag: '🇲🇳'),
    Language(code: 'ug', name: 'Uyghur', flag: '🇨🇳'),
    Language(code: 'yue', name: 'Cantonese', flag: '🇭🇰'),
  ];

  /// Alias for offline list (backward compatibility).
  static const List<Language> supported = offlineSupported;

  /// ~100 languages for DeepSeek online translation.
  static List<Language> get deepseekSupported => DeepSeekLanguages.all;

  static List<Language> forMode(TranslationMode mode) {
    if (mode == TranslationMode.online) return deepseekSupported;
    return offlineSupported;
  }

  static Language? fromCode(String code, {TranslationMode? mode}) {
    if (mode != null) return _findInList(forMode(mode), code);
    return _findInList(offlineSupported, code) ??
        _findInList(deepseekSupported, code);
  }

  static Language? _findInList(List<Language> list, String code) {
    try {
      return list.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }
}