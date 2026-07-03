import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vosk_flutter_service/vosk_flutter.dart';
import '../core/constants/app_constants.dart';

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

  Stream<String> get onPartial => _partialController.stream;
  Stream<String> get onResult => _resultController.stream;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (_isLoading) return false;

    _isLoading = true;
    _lastError = null;

    try {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        _lastError = 'Microphone permission is required for voice input.';
        return false;
      }

      final modelPath = await _loadModel();
      _model = await _vosk.createModel(modelPath);
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );
      _speechService = await _vosk.initSpeechService(_recognizer!);

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

      _isInitialized = true;
      return true;
    } catch (e, stack) {
      debugPrint('Vosk initialization failed: $e\n$stack');
      _lastError = 'Speech model could not be loaded. Check your internet connection and try again.';
      await _resetResources();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<String> _loadModel() async {
    try {
      await rootBundle.load(AppConstants.voskModelAsset);
      return ModelLoader().loadFromAssets(AppConstants.voskModelAsset);
    } catch (_) {
      debugPrint('Vosk asset missing, downloading model from network...');
      return ModelLoader().loadFromNetwork(AppConstants.voskModelUrl);
    }
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

    return jsonStr.replaceAll(RegExp(r'[{}"\s]'), '').replaceAll('partial:', '').replaceAll('text:', '');
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      final ok = await initialize();
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
    await _speechService?.stop();
    _isListening = false;
  }

  Future<void> _resetResources() async {
    await _partialSub?.cancel();
    await _resultSub?.cancel();
    _partialSub = null;
    _resultSub = null;
    await _speechService?.dispose();
    _recognizer?.dispose();
    _model?.dispose();
    _speechService = null;
    _recognizer = null;
    _model = null;
    _isInitialized = false;
    _isListening = false;
  }

  Future<void> dispose() async {
    await _resetResources();
    if (!_partialController.isClosed) await _partialController.close();
    if (!_resultController.isClosed) await _resultController.close();
  }
}
