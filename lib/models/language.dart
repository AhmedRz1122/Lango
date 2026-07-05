class Language {
  final String code;
  final String name;
  final String flag;
  /// Google Translate code when it differs from the HY-MT code.
  final String? onlineCode;

  const Language({
    required this.code,
    required this.name,
    required this.flag,
    this.onlineCode,
  });

  String get effectiveOnlineCode => onlineCode ?? code;

  /// All languages supported by Tencent HY-MT1.5 (33 languages + 5 dialects).
  static const List<Language> supported = [
    Language(code: 'ar', name: 'Arabic', flag: '🇸🇦'),
    Language(code: 'bn', name: 'Bengali', flag: '🇧🇩'),
    Language(code: 'my', name: 'Burmese', flag: '🇲🇲'),
    Language(code: 'yue', name: 'Cantonese', flag: '🇭🇰'),
    Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
    Language(code: 'cs', name: 'Czech', flag: '🇨🇿'),
    Language(code: 'nl', name: 'Dutch', flag: '🇳🇱'),
    Language(code: 'en', name: 'English', flag: '🇬🇧'),
    Language(code: 'tl', name: 'Filipino', flag: '🇵🇭', onlineCode: 'fil'),
    Language(code: 'fr', name: 'French', flag: '🇫🇷'),
    Language(code: 'de', name: 'German', flag: '🇩🇪'),
    Language(code: 'gu', name: 'Gujarati', flag: '🇮🇳'),
    Language(code: 'he', name: 'Hebrew', flag: '🇮🇱'),
    Language(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
    Language(code: 'id', name: 'Indonesian', flag: '🇮🇩'),
    Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
    Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    Language(code: 'kk', name: 'Kazakh', flag: '🇰🇿'),
    Language(code: 'km', name: 'Khmer', flag: '🇰🇭'),
    Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    Language(code: 'ms', name: 'Malay', flag: '🇲🇾'),
    Language(code: 'mr', name: 'Marathi', flag: '🇮🇳'),
    Language(code: 'mn', name: 'Mongolian', flag: '🇲🇳'),
    Language(code: 'fa', name: 'Persian', flag: '🇮🇷'),
    Language(code: 'pl', name: 'Polish', flag: '🇵🇱'),
    Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    Language(code: 'ru', name: 'Russian', flag: '🇷🇺'),
    Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    Language(code: 'ta', name: 'Tamil', flag: '🇮🇳'),
    Language(code: 'te', name: 'Telugu', flag: '🇮🇳'),
    Language(code: 'th', name: 'Thai', flag: '🇹🇭'),
    Language(code: 'bo', name: 'Tibetan', flag: '🏔️'),
    Language(
      code: 'zh-Hant',
      name: 'Traditional Chinese',
      flag: '🇹🇼',
      onlineCode: 'zh-TW',
    ),
    Language(code: 'tr', name: 'Turkish', flag: '🇹🇷'),
    Language(code: 'uk', name: 'Ukrainian', flag: '🇺🇦'),
    Language(code: 'ur', name: 'Urdu', flag: '🇵🇰'),
    Language(code: 'ug', name: 'Uyghur', flag: '🇨🇳'),
    Language(code: 'vi', name: 'Vietnamese', flag: '🇻🇳'),
  ];

  /// Full English names used in HY-MT prompts (XX<=>XX, excluding ZH<=>XX).
  static const Map<String, String> hyMtEnglishNames = {
    'zh': 'Chinese',
    'en': 'English',
    'fr': 'French',
    'pt': 'Portuguese',
    'es': 'Spanish',
    'ja': 'Japanese',
    'tr': 'Turkish',
    'ru': 'Russian',
    'ar': 'Arabic',
    'ko': 'Korean',
    'th': 'Thai',
    'it': 'Italian',
    'de': 'German',
    'vi': 'Vietnamese',
    'ms': 'Malay',
    'id': 'Indonesian',
    'tl': 'Filipino',
    'hi': 'Hindi',
    'zh-Hant': 'Traditional Chinese',
    'pl': 'Polish',
    'cs': 'Czech',
    'nl': 'Dutch',
    'km': 'Khmer',
    'my': 'Burmese',
    'fa': 'Persian',
    'gu': 'Gujarati',
    'ur': 'Urdu',
    'te': 'Telugu',
    'mr': 'Marathi',
    'he': 'Hebrew',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'uk': 'Ukrainian',
    'bo': 'Tibetan',
    'kk': 'Kazakh',
    'mn': 'Mongolian',
    'ug': 'Uyghur',
    'yue': 'Cantonese',
  };

  /// Full Chinese names used in HY-MT prompts (ZH<=>XX).
  static const Map<String, String> hyMtChineseNames = {
    'zh': '中文',
    'en': '英语',
    'fr': '法语',
    'pt': '葡萄牙语',
    'es': '西班牙语',
    'ja': '日语',
    'tr': '土耳其语',
    'ru': '俄语',
    'ar': '阿拉伯语',
    'ko': '韩语',
    'th': '泰语',
    'it': '意大利语',
    'de': '德语',
    'vi': '越南语',
    'ms': '马来语',
    'id': '印尼语',
    'tl': '菲律宾语',
    'hi': '印地语',
    'zh-Hant': '繁体中文',
    'pl': '波兰语',
    'cs': '捷克语',
    'nl': '荷兰语',
    'km': '高棉语',
    'my': '缅甸语',
    'fa': '波斯语',
    'gu': '古吉拉特语',
    'ur': '乌尔都语',
    'te': '泰卢固语',
    'mr': '马拉地语',
    'he': '希伯来语',
    'bn': '孟加拉语',
    'ta': '泰米尔语',
    'uk': '乌克兰语',
    'bo': '藏语',
    'kk': '哈萨克语',
    'mn': '蒙古语',
    'ug': '维吾尔语',
    'yue': '粤语',
  };

  static const Set<String> chineseVariants = {'zh', 'zh-Hant', 'yue'};

  String get hyMtEnglishName => hyMtEnglishNames[code] ?? name;
  String get hyMtChineseName => hyMtChineseNames[code] ?? name;

  static bool usesChinesePrompt(String sourceCode, String targetCode) {
    return chineseVariants.contains(sourceCode) ||
        chineseVariants.contains(targetCode);
  }

  static Language? fromCode(String code) {
    try {
      return supported.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }
}
