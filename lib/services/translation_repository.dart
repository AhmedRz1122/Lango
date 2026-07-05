import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/translation_record.dart';
import 'offline_translation_service.dart';
import 'translation_database.dart';

class TranslationRepository {
  final OfflineTranslationService _offlineService;
  final Connectivity _connectivity;
  final TranslationDatabase _database;
  final Uuid _uuid = const Uuid();

  TranslationRepository({
    OfflineTranslationService? offlineService,
    Connectivity? connectivity,
    TranslationDatabase? database,
  })  : _offlineService = offlineService ?? OfflineTranslationService(),
        _connectivity = connectivity ?? Connectivity(),
        _database = database ?? TranslationDatabase();

  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<String> translateOffline({
    required String text,
    required String from,
    required String to,
  }) {
    return _offlineService.translate(text: text, from: from, to: to);
  }

  Future<bool> isOfflineAvailable() => _offlineService.isAvailable();

  Future<TranslationRecord> saveTranslation({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
    required bool isOffline,
  }) async {
    final record = TranslationRecord(
      id: _uuid.v4(),
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLang: sourceLang,
      targetLang: targetLang,
      timestamp: DateTime.now(),
      isOffline: isOffline,
    );

    await _database.insert(record);
    return record;
  }

  Future<List<TranslationRecord>> getHistory() => _database.getAll();

  Future<List<TranslationRecord>> getFavorites() => _database.getFavorites();

  Future<void> toggleFavorite(String id) => _database.toggleFavorite(id);

  Future<void> deleteTranslation(String id) => _database.deleteById(id);

  Future<void> clearHistory() => _database.deleteAll();
}
