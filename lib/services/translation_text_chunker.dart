/// Splits input text into sentence-sized chunks for reliable on-device translation.
class TranslationTextChunker {
  TranslationTextChunker._();

  static final _sentenceBoundary = RegExp(r'(?<=[.!?؟。！？])\s+');

  /// Splits on sentence boundaries. Returns a single chunk when no boundary exists.
  static List<String> split(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return [];

    final parts = trimmed
        .split(_sentenceBoundary)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return parts.isEmpty ? [trimmed] : parts;
  }
}
