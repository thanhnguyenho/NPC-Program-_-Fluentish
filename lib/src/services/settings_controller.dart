import 'package:flutter/material.dart';

enum AppTextSize {
  small,
  medium,
  large;

  String get label {
    switch (this) {
      case AppTextSize.small:
        return 'Small';
      case AppTextSize.medium:
        return 'Medium';
      case AppTextSize.large:
        return 'Large';
    }
  }

  double get scale {
    switch (this) {
      case AppTextSize.small:
        return 0.9;
      case AppTextSize.medium:
        return 1.0;
      case AppTextSize.large:
        return 1.1;
    }
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController._();

  static final SettingsController instance = SettingsController._();

  String _sourceLanguage = 'English';
  String _targetLanguage = 'Vietnamese';
  bool _autoDetectLocation = true;
  bool _pushNotifications = true;
  bool _friendUpdates = true;
  bool _nearbyRecommendation = true;
  ThemeMode _themeMode = ThemeMode.light;
  AppTextSize _textSize = AppTextSize.medium;

  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  bool get autoDetectLocation => _autoDetectLocation;
  bool get pushNotifications => _pushNotifications;
  bool get friendUpdates => _friendUpdates;
  bool get nearbyRecommendation => _nearbyRecommendation;
  ThemeMode get themeMode => _themeMode;
  AppTextSize get textSize => _textSize;

  Future<void> setSourceLanguage(String value) async {
    if (_sourceLanguage == value) return;
    _sourceLanguage = value;
    notifyListeners();
  }

  Future<void> setTargetLanguage(String value) async {
    if (_targetLanguage == value) return;
    _targetLanguage = value;
    notifyListeners();
  }

  Future<void> setAutoDetectLocation(bool value) async {
    if (_autoDetectLocation == value) return;
    _autoDetectLocation = value;
    notifyListeners();
  }

  Future<void> setPushNotifications(bool value) async {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
  }

  void setFriendUpdates(bool value) {
    if (_friendUpdates == value) return;
    _friendUpdates = value;
    notifyListeners();
  }

  void setNearbyRecommendation(bool value) {
    if (_nearbyRecommendation == value) return;
    _nearbyRecommendation = value;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
  }

  Future<void> setTextSize(AppTextSize value) async {
    if (_textSize == value) return;
    _textSize = value;
    notifyListeners();
  }
}
