class AppConstants {
  AppConstants._();

  static const String appName = 'Lango';
  static const String taglinePart1 = 'Translate ';
  static const String taglineHighlight1 = 'anything.';
  static const String taglinePart2 = ' Understand ';
  static const String taglineHighlight2 = 'everything.';

  static const String genkitBaseUrl = 'http://localhost:3400';

  static const String appLogo = 'assets/images/Lango_logo.png';

  static const int maxTextLength = 5000;
  static const String voskModelAsset = 'assets/models/vosk-model-small-en-us-0.15.zip';
  static const String voskModelUrl =
      'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip';

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
