import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/translation_mode.dart';
import '../models/translation_record.dart';
import 'offline_translation_service.dart';
import 'online_translation_service.dart';

class TranslationRepository {
  final OnlineTranslationService _onlineService;
  final OfflineTranslationService _offlineService;
  final Connectivity _connectivity;
  final Uuid _uuid = const Uuid();
  static const _historyKey = 'translation_history';

  TranslationRepository({
    OnlineTranslationService? onlineService,
    OfflineTranslationService? offlineService,
    Connectivity? connectivity,
  })  : _onlineService = onlineService ?? OnlineTranslationService(),
        _offlineService = offlineService ?? OfflineTranslationService(),
        _connectivity = connectivity ?? Connectivity();

  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<String> translate({
    required String text,
    required String from,
    required String to,
    TranslationMode mode = TranslationMode.auto,
  }) async {
    final isOnline = await hasConnectivity();
    final useOffline = mode == TranslationMode.offline ||
        (mode == TranslationMode.auto && !isOnline);

    if (useOffline) {
      return _offlineService.translate(text: text, from: from, to: to);
    }
    return _onlineService.translate(text: text, from: from, to: to);
  }

  Future<bool> isOfflineAvailable() => _offlineService.isAvailable();
  Future<bool> isOnlineAvailable() => _onlineService.isAvailable();

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

    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, record);
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
    return record;
  }

  Future<List<TranslationRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TranslationRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TranslationRecord>> getFavorites() async {
    final history = await getHistory();
    return history.where((r) => r.isFavorite).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final history = await getHistory();
    final index = history.indexWhere((r) => r.id == id);
    if (index == -1) return;

    history[index] = history[index].copyWith(
      isFavorite: !history[index].isFavorite,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
