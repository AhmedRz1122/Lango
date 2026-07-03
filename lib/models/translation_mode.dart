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
        return 'Cloud-powered translation';
      case TranslationMode.offline:
        return 'On-device translation';
      case TranslationMode.auto:
        return 'Switches based on connectivity';
    }
  }
}
