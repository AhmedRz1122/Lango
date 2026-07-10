import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/translation_mode.dart';
import '../services/translation_repository.dart';

class AppViewModel extends ChangeNotifier {
  final TranslationRepository _repository;

  AppViewModel({TranslationRepository? repository})
      : _repository = repository ?? TranslationRepository();

  bool _hasSeenOnboarding = false;
  int _currentNavIndex = 0;
  TranslationMode _translationMode = TranslationMode.offline;
  bool _isOnline = true;
  bool _offlineAvailable = false;
  String _userName = AppConstants.defaultUserName;
  String _userEmail = AppConstants.defaultUserEmail;

  bool get hasSeenOnboarding => _hasSeenOnboarding;
  int get currentNavIndex => _currentNavIndex;
  TranslationMode get translationMode => _translationMode;
  bool get isOnline => _isOnline;
  bool get offlineAvailable => _offlineAvailable;
  String get userName => _userName;
  String get userEmail => _userEmail;

  Future<void> initialize() async {
    _isOnline = await _repository.hasConnectivity();
    _offlineAvailable = await _repository.isOfflineAvailable();
    final profile = await _repository.loadUserProfile();
    _userName = profile.$1;
    _userEmail = profile.$2;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void setTranslationMode(TranslationMode mode) {
    _translationMode = mode;
    notifyListeners();
  }

  Future<void> refreshConnectivity() async {
    _isOnline = await _repository.hasConnectivity();
    _offlineAvailable = await _repository.isOfflineAvailable();
    notifyListeners();
  }
}
