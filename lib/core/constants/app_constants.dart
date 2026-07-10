class AppConstants {
  AppConstants._();

  static const String appName = 'Lango';
  static const String appVersion = '1.0.0';
  static const String defaultUserName = 'Alex Morgan';
  static const String defaultUserEmail = 'alex.morgan@email.com';
  static const String taglinePart1 = 'Translate ';
  static const String taglineHighlight1 = 'anything.';
  static const String taglinePart2 = ' Understand ';
  static const String taglineHighlight2 = 'everything.';

  static const String genkitBaseUrl = 'http://localhost:3400';
  static const String hyMtServiceUrl = 'http://localhost:3401';

  /// Send one DeepSeek request when text is at or below this length (faster).
  static const int deepseekSingleRequestMaxChars = 1500;

  /// Backend URLs tried on Android (127.0.0.1 first — works with adb reverse on physical devices).
  static const List<String> androidBackendUrls = [
    'http://127.0.0.1:3400',
    'http://10.0.2.2:3400',
  ];

  static const int backendConnectTimeoutSeconds = 8;
  static const int backendTranslateTimeoutSeconds = 60;

  static const String appLogo = 'assets/images/Lango_logo.png';

  static const int maxTextLength = 5000;

  static const List<String> quickPhrases = [
    'Hello',
    'Thank you',
    'How are you?',
    'Goodbye',
    'Please',
    'Excuse me',
    'Where is...?',
    'How much?',
  ];
}
