import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/language.dart';
import '../models/translation_mode.dart';
import '../models/translation_record.dart';
import '../services/translation_repository.dart';
import '../services/vosk_speech_service.dart';

enum TranslateState { idle, translating, success, error }

class TranslateViewModel extends ChangeNotifier {
  final TranslationRepository _repository;
  final VoskSpeechService _speechService;
  final FlutterTts _tts = FlutterTts();

  TranslateViewModel({
    TranslationRepository? repository,
    VoskSpeechService? speechService,
  })  : _repository = repository ?? TranslationRepository(),
        _speechService = speechService ?? VoskSpeechService();

  Language _sourceLang = Language.offlineSupported.firstWhere(
    (l) => l.code == 'en',
    orElse: () => Language.offlineSupported[1],
  );
  Language _targetLang = Language.offlineSupported.firstWhere(
    (l) => l.code == 'es',
    orElse: () => Language.offlineSupported[4],
  );
  String _sourceText = '';
  String _translatedText = '';
  TranslateState _state = TranslateState.idle;
  String? _errorMessage;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _showVoiceInput = false;
  bool _isSpeechLoading = false;
  TranslationMode _mode = TranslationMode.offline;
  List<TranslationRecord> _history = [];
  List<TranslationRecord> _favorites = [];

  Language get sourceLang => _sourceLang;
  Language get targetLang => _targetLang;
  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  TranslateState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get showVoiceInput => _showVoiceInput;
  bool get isSpeechLoading => _isSpeechLoading;
  TranslationMode get mode => _mode;
  List<TranslationRecord> get history => _history;
  List<TranslationRecord> get favorites => _favorites;
  VoskSpeechService get speechService => _speechService;

  List<Language> get availableLanguages => Language.forMode(_mode);

  bool get isVoiceInputSupported =>
      _mode != TranslationMode.online &&
      VoskSpeechService.isSupportedForLanguage(_sourceLang.code);

  Future<void> initialize() async {
    await loadHistory();
    _speechService.onResult.listen((text) {
      _sourceText = text;
      notifyListeners();
      translate();
    });
    _speechService.onPartial.listen((text) {
      _sourceText = text;
      notifyListeners();
    });
  }

  void _ensureLanguagesValidForMode() {
    final langs = availableLanguages;
    if (langs.isEmpty) return;

    if (!langs.any((l) => l.code == _sourceLang.code)) {
      _sourceLang = langs.first;
    }
    if (!langs.any((l) => l.code == _targetLang.code)) {
      _targetLang = langs.length > 1 ? langs[1] : langs.first;
    }
  }

  Future<void> _ensureSpeechReady() async {
    if (!isVoiceInputSupported) {
      _errorMessage =
          'Voice input is not available for ${_sourceLang.name}. Use keyboard instead.';
      notifyListeners();
      return;
    }

    if (_speechService.isInitialized &&
        _speechService.currentLangCode == _sourceLang.code) {
      return;
    }
    if (_speechService.isLoading) return;

    _isSpeechLoading = true;
    _errorMessage = null;
    notifyListeners();

    final ok = await _speechService.initializeForLanguage(_sourceLang.code);
    _isSpeechLoading = false;

    if (!ok) {
      _errorMessage = _speechService.lastError ??
          'Speech recognition is unavailable on this device.';
      // Keep floating mic visible so user can retry.
    }
    notifyListeners();
  }

  void setSourceLang(Language lang) {
    _sourceLang = lang;
    notifyListeners();
  }

  void setTargetLang(Language lang) {
    _targetLang = lang;
    notifyListeners();
  }

  void swapLanguages() {
    final tempLang = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = tempLang;

    if (_translatedText.isNotEmpty) {
      final tempText = _sourceText;
      _sourceText = _translatedText;
      _translatedText = tempText;
    }
    notifyListeners();
  }

  void setSourceText(String text) {
    _sourceText = text;
    notifyListeners();
  }

  void setMode(TranslationMode mode) {
    _mode = mode;
    _ensureLanguagesValidForMode();
    notifyListeners();
  }

  Future<void> translate() async {
    if (_sourceText.trim().isEmpty) return;

    _state = TranslateState.translating;
    _errorMessage = null;
    notifyListeners();

    try {
      final isOnline = await _repository.hasConnectivity();
      final useOffline = _mode == TranslationMode.offline ||
          (_mode == TranslationMode.auto && !isOnline);

      _translatedText = await _repository.translate(
        text: _sourceText,
        from: _sourceLang.code,
        to: _targetLang.code,
        mode: _mode,
      );

      await _repository.saveTranslation(
        sourceText: _sourceText,
        translatedText: _translatedText,
        sourceLang: _sourceLang.code,
        targetLang: _targetLang.code,
        isOffline: useOffline,
      );

      await loadHistory();
      _state = TranslateState.success;
    } catch (e) {
      _state = TranslateState.error;
      _errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('ClientException: ', '');
    }
    notifyListeners();
  }

  Future<void> showVoiceInputBar() async {
    _showVoiceInput = true;
    notifyListeners();
    await _ensureSpeechReady();
  }

  Future<void> hideVoiceInputBar() async {
    if (_isListening) {
      await _speechService.stopListening();
      _isListening = false;
    }
    _showVoiceInput = false;
    _errorMessage = null;
    notifyListeners();
  }

  void toggleVoiceInputBar() {
    if (_showVoiceInput) {
      hideVoiceInputBar();
    } else {
      showVoiceInputBar();
    }
  }

  Future<void> toggleListening() async {
    if (!_showVoiceInput) {
      showVoiceInputBar();
    }

    try {
      if (!_speechService.isInitialized) {
        await _ensureSpeechReady();
        if (!_speechService.isInitialized) {
          throw Exception(
            _speechService.lastError ?? 'Speech recognition not available',
          );
        }
      }

      if (_isListening) {
        await _speechService.stopListening();
        _isListening = false;
      } else {
        await _speechService.startListening(langCode: _sourceLang.code);
        _isListening = true;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isListening = false;
    }
    notifyListeners();
  }

  Future<void> speak(String text, String langCode) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();
    await _tts.setLanguage(langCode);
    await _tts.speak(text);
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _history = await _repository.getHistory();
    _favorites = await _repository.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    await loadHistory();
  }

  Future<void> deleteTranslation(String id) async {
    await _repository.deleteTranslation(id);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    await loadHistory();
  }

  void clearTexts() {
    _sourceText = '';
    _translatedText = '';
    _state = TranslateState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.dispose();
    _tts.stop();
    super.dispose();
  }
}
