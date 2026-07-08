import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vosk_flutter_service/vosk_flutter.dart';

import '../models/vosk_language_config.dart';

class VoskSpeechService {
  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;
  StreamSubscription<String>? _partialSub;
  StreamSubscription<String>? _resultSub;

  final _partialController = StreamController<String>.broadcast();
  final _resultController = StreamController<String>.broadcast();
  bool _isListening = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;
  String? _currentLangCode;

  static const _channel = MethodChannel('vosk_flutter');

  Stream<String> get onPartial => _partialController.stream;
  Stream<String> get onResult => _resultController.stream;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String? get currentLangCode => _currentLangCode;

  static bool isSupportedForLanguage(String langCode) =>
      VoskLanguageConfig.isSupported(langCode);

  Future<bool> initialize({String langCode = 'en'}) =>
      initializeForLanguage(langCode);

  Future<bool> initializeForLanguage(String langCode) async {
    final config = VoskLanguageConfig.forLanguage(langCode);
    if (config == null) {
      _lastError =
          'Voice input is not available for this language. Use keyboard instead.';
      return false;
    }

    if (_isInitialized &&
        _currentLangCode == langCode &&
        _speechService != null) {
      return true;
    }
    if (_isLoading) return false;

    _isLoading = true;
    _lastError = null;

    try {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        _lastError = 'Microphone permission is required for voice input.';
        return false;
      }

      // Native SpeechService is a singleton — always clear leftovers
      // (hot restart / previous screen can leave it alive).
      await _forceDestroyNativeSpeechService();
      await _resetResources();

      final modelPath = await _loadModel(config);
      debugPrint('Vosk loading model from: $modelPath');

      _model = await _vosk.createModel(modelPath);
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );
      _speechService = await _initSpeechServiceWithRetry(_recognizer!);

      await _partialSub?.cancel();
      await _resultSub?.cancel();

      _partialSub = _speechService!.onPartial().listen((partial) {
        final text = _extractText(partial);
        if (text.isNotEmpty) _partialController.add(text);
      });

      _resultSub = _speechService!.onResult().listen((result) {
        final text = _extractText(result);
        if (text.isNotEmpty) _resultController.add(text);
      });

      _currentLangCode = langCode;
      _isInitialized = true;
      _lastError = null;
      return true;
    } catch (e, stack) {
      debugPrint('Vosk initialization failed: $e\n$stack');
      _lastError = _friendlyError(e);
      await _forceDestroyNativeSpeechService();
      await _resetResources();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<SpeechService> _initSpeechServiceWithRetry(Recognizer recognizer) async {
    try {
      return await _vosk.initSpeechService(recognizer);
    } on PlatformException catch (e) {
      if (e.code == 'INITIALIZE_FAIL' &&
          (e.message?.contains('already exist') == true ||
              e.message?.contains('already initialized') == true)) {
        debugPrint('Stale SpeechService found — destroying and retrying');
        await _forceDestroyNativeSpeechService();
        return _vosk.initSpeechService(recognizer);
      }
      rethrow;
    }
  }

  /// Clears the Android/iOS singleton SpeechService even if Dart lost the handle.
  Future<void> _forceDestroyNativeSpeechService() async {
    try {
      await _speechService?.dispose();
    } catch (e) {
      debugPrint('Dart SpeechService.dispose failed: $e');
    }
    _speechService = null;

    try {
      await _channel.invokeMethod<void>('speechService.destroy');
    } catch (_) {
      // Already destroyed or never created — fine.
    }
  }

  Future<String> _loadModel(VoskLanguageConfig config) async {
    final assetPath = config.assetPath;
    if (assetPath != null) {
      try {
        await rootBundle.load(assetPath);
        return ModelLoader().loadFromAssets(assetPath);
      } catch (e) {
        debugPrint('Vosk asset missing ($e), trying network/cache...');
      }
    }

    try {
      return await ModelLoader().loadFromNetwork(config.downloadUrl);
    } catch (e) {
      debugPrint('Vosk network load failed: $e');
      rethrow;
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Microphone') || msg.contains('PERMISSION')) {
      return 'Microphone permission is required for voice input.';
    }
    if (msg.contains('already exist') || msg.contains('already initialized')) {
      return 'Speech engine was busy. Please tap the mic again.';
    }
    if (msg.contains('Socket') ||
        msg.contains('Failed host lookup') ||
        msg.contains('network')) {
      return 'Could not download the speech model. Check your internet and try again.';
    }
    return 'Speech model could not be loaded. Tap the mic again to retry.';
  }

  String _extractText(String raw) {
    final jsonStr = raw.trim();
    if (jsonStr.isEmpty) return '';

    try {
      if (jsonStr.startsWith('{')) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final partial = map['partial'];
        final text = map['text'];
        if (partial is String && partial.isNotEmpty) return partial;
        if (text is String && text.isNotEmpty) return text;
      }
    } catch (_) {}

    final partialMatch = RegExp(
      r'''["']?partial["']?\s*[:=]\s*["']([^"']+)["']''',
    ).firstMatch(jsonStr);
    if (partialMatch != null) return partialMatch.group(1)!.trim();

    final textMatch = RegExp(
      r'''["']?text["']?\s*[:=]\s*["']([^"']+)["']''',
    ).firstMatch(jsonStr);
    if (textMatch != null) return textMatch.group(1)!.trim();

    return jsonStr
        .replaceAll(RegExp(r'[{}"\s]'), '')
        .replaceAll('partial:', '')
        .replaceAll('text:', '');
  }

  Future<void> startListening({String? langCode}) async {
    final code = langCode ?? _currentLangCode ?? 'en';
    if (!_isInitialized ||
        _currentLangCode != code ||
        _speechService == null) {
      final ok = await initializeForLanguage(code);
      if (!ok) {
        throw Exception(_lastError ?? 'Speech recognition not available');
      }
    }
    if (_isListening) return;

    final started = await _speechService?.start();
    if (started != true) {
      throw Exception('Could not start microphone. Please try again.');
    }
    _isListening = true;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    try {
      await _speechService?.stop();
    } catch (e) {
      debugPrint('stopListening failed: $e');
    }
    _isListening = false;
  }

  Future<void> _resetResources() async {
    await _partialSub?.cancel();
    await _resultSub?.cancel();
    _partialSub = null;
    _resultSub = null;

    try {
      await _speechService?.stop();
    } catch (_) {}
    try {
      await _speechService?.dispose();
    } catch (_) {}

    try {
      await _recognizer?.dispose();
    } catch (_) {}
    try {
      _model?.dispose();
    } catch (_) {}

    _speechService = null;
    _recognizer = null;
    _model = null;
    _isInitialized = false;
    _isListening = false;
    _currentLangCode = null;
  }

  Future<void> resetModel() async {
    await _forceDestroyNativeSpeechService();
    await _resetResources();
  }

  Future<void> dispose() async {
    await _forceDestroyNativeSpeechService();
    await _resetResources();
    if (!_partialController.isClosed) await _partialController.close();
    if (!_resultController.isClosed) await _resultController.close();
  }
}
