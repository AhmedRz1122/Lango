enum TranslationMode {
  online,
  offline,
  auto,
}

extension TranslationModeExtension on TranslationMode {
  String get label {
    switch (this) {
      case TranslationMode.online:
        return 'Online';
      case TranslationMode.offline:
        return 'Offline';
      case TranslationMode.auto:
        return 'Auto';
    }
  }

  String get description {
    switch (this) {
      case TranslationMode.online:
        return 'Google Translate in browser';
      case TranslationMode.offline:
        return 'On-device translation';
      case TranslationMode.auto:
        return 'Offline when no internet';
    }
  }
}
