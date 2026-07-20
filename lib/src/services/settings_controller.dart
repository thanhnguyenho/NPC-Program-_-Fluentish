import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AppTextSize {
  small,
  medium,
  large;

  String get label => switch (this) {
        AppTextSize.small => 'Small',
        AppTextSize.medium => 'Medium',
        AppTextSize.large => 'Large',
      };

  double get scale => switch (this) {
        AppTextSize.small => 0.9,
        AppTextSize.medium => 1.0,
        AppTextSize.large => 1.1,
      };
}

class SettingsController extends ChangeNotifier {
  SettingsController._();

  static final SettingsController instance = SettingsController._();

  static const _defaults = <String, Object>{
    'sourceLanguage': 'English',
    'targetLanguage': 'Vietnamese',
    'autoDetectLocation': true,
    'pushNotifications': false,
    'friendUpdates': false,
    'nearbyRecommendation': true,
    'themeMode': 'light',
    'textSize': 'medium',
  };

  String _sourceLanguage = _defaults['sourceLanguage']! as String;
  String _targetLanguage = _defaults['targetLanguage']! as String;
  bool _autoDetectLocation = _defaults['autoDetectLocation']! as bool;
  bool _pushNotifications = _defaults['pushNotifications']! as bool;
  bool _friendUpdates = _defaults['friendUpdates']! as bool;
  bool _nearbyRecommendation = _defaults['nearbyRecommendation']! as bool;
  ThemeMode _themeMode = ThemeMode.light;
  AppTextSize _textSize = AppTextSize.medium;
  StreamSubscription<User?>? _authSubscription;
  bool _initialized = false;

  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  bool get autoDetectLocation => _autoDetectLocation;
  bool get pushNotifications => _pushNotifications;
  bool get friendUpdates => _friendUpdates;
  bool get nearbyRecommendation => _nearbyRecommendation;
  ThemeMode get themeMode => _themeMode;
  AppTextSize get textSize => _textSize;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFor(FirebaseAuth.instance.currentUser);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (user) => unawaited(_loadFor(user)),
        );
  }

  Future<void> _loadFor(User? user) async {
    _apply(_defaults);
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final saved = snapshot.data()?['settings'];
        if (saved is Map) {
          _apply(Map<String, dynamic>.from(saved));
        }
      } catch (_) {
        // Firestore's local cache may be unavailable on first launch. Defaults
        // remain usable and the next setting change will retry persistence.
      }
    }
    notifyListeners();
  }

  void _apply(Map<String, dynamic> values) {
    _sourceLanguage = values['sourceLanguage'] as String? ?? 'English';
    _targetLanguage = values['targetLanguage'] as String? ?? 'Vietnamese';
    _autoDetectLocation = values['autoDetectLocation'] as bool? ?? true;
    _pushNotifications = values['pushNotifications'] as bool? ?? false;
    _friendUpdates =
        _pushNotifications && (values['friendUpdates'] as bool? ?? false);
    _nearbyRecommendation = values['nearbyRecommendation'] as bool? ?? true;
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == values['themeMode'],
      orElse: () => ThemeMode.light,
    );
    _textSize = AppTextSize.values.firstWhere(
      (size) => size.name == values['textSize'],
      orElse: () => AppTextSize.medium,
    );
  }

  Map<String, Object> get _data => {
        'sourceLanguage': _sourceLanguage,
        'targetLanguage': _targetLanguage,
        'autoDetectLocation': _autoDetectLocation,
        'pushNotifications': _pushNotifications,
        'friendUpdates': _friendUpdates,
        'nearbyRecommendation': _nearbyRecommendation,
        'themeMode': _themeMode.name,
        'textSize': _textSize.name,
      };

  Future<void> _persist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'settings': _data},
        SetOptions(merge: true),
      );
    } catch (_) {
      // The setting is still applied for this session. Firestore will be
      // retried on the user's next change when connectivity is restored.
    }
  }

  Future<void> setSourceLanguage(String value) async {
    if (_sourceLanguage == value) return;
    _sourceLanguage = value;
    if (_targetLanguage == value) {
      _targetLanguage = value == 'English' ? 'Vietnamese' : 'English';
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setTargetLanguage(String value) async {
    if (_targetLanguage == value) return;
    _targetLanguage = value;
    if (_sourceLanguage == value) {
      _sourceLanguage = value == 'English' ? 'Vietnamese' : 'English';
    }
    notifyListeners();
    await _persist();
  }

  Future<void> setLanguagePair(String source, String target) async {
    if (_sourceLanguage == source && _targetLanguage == target) return;
    _sourceLanguage = source;
    _targetLanguage = target;
    notifyListeners();
    await _persist();
  }

  Future<void> setAutoDetectLocation(bool value) async {
    if (_autoDetectLocation == value) return;
    _autoDetectLocation = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setPushNotifications(bool value) async {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setFriendUpdates(bool value) async {
    if (_friendUpdates == value) return;
    _friendUpdates = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setNearbyRecommendation(bool value) async {
    if (_nearbyRecommendation == value) return;
    _nearbyRecommendation = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setTextSize(AppTextSize value) async {
    if (_textSize == value) return;
    _textSize = value;
    notifyListeners();
    await _persist();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
