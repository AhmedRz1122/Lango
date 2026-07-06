class Language {
  final String code;
  final String name;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
  });

  static const List<Language> supported = [
    Language(code: 'en', name: 'English', flag: '🇬🇧'),
    Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    Language(code: 'fr', name: 'French', flag: '🇫🇷'),
    Language(code: 'de', name: 'German', flag: '🇩🇪'),
    Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
    Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    Language(code: 'ru', name: 'Russian', flag: '🇷🇺'),
    Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
    Language(code: 'ar', name: 'Arabic', flag: '🇸🇦'),
    Language(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
    Language(code: 'tr', name: 'Turkish', flag: '🇹🇷'),
    Language(code: 'nl', name: 'Dutch', flag: '🇳🇱'),
    Language(code: 'pl', name: 'Polish', flag: '🇵🇱'),
    Language(code: 'vi', name: 'Vietnamese', flag: '🇻🇳'),
    Language(code: 'th', name: 'Thai', flag: '🇹🇭'),
    Language(code: 'id', name: 'Indonesian', flag: '🇮🇩'),
    Language(code: 'uk', name: 'Ukrainian', flag: '🇺🇦'),
    Language(code: 'cs', name: 'Czech', flag: '🇨🇿'),
  ];

  static Language? fromCode(String code) {
    try {
      return supported.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }
}
