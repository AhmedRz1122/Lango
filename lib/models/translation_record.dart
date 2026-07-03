class TranslationRecord {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  final bool isFavorite;
  final bool isOffline;

  const TranslationRecord({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    this.isFavorite = false,
    this.isOffline = false,
  });

  TranslationRecord copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    DateTime? timestamp,
    bool? isFavorite,
    bool? isOffline,
  }) {
    return TranslationRecord(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
        'isOffline': isOffline,
      };

  factory TranslationRecord.fromJson(Map<String, dynamic> json) {
    return TranslationRecord(
      id: json['id'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLang: json['sourceLang'] as String,
      targetLang: json['targetLang'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isOffline: json['isOffline'] as bool? ?? false,
    );
  }
}
