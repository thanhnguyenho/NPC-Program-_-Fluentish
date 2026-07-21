import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MlKitTranslator {
  static OnDeviceTranslator? _translator;
  static TranslateLanguage? _currentSrc;
  static TranslateLanguage? _currentTgt;
  static final _modelManager = OnDeviceTranslatorModelManager();
  static bool _modelsReady = false;

  static bool get isAvailable => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> ensureModelsDownloaded() async {
    if (!isAvailable) return;
    try {
      final enReady = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
      final viReady = await _modelManager.isModelDownloaded(TranslateLanguage.vietnamese.bcpCode);
      if (!enReady) await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
      if (!viReady) await _modelManager.downloadModel(TranslateLanguage.vietnamese.bcpCode);
      _modelsReady = true;
    } catch (e) {
      debugPrint('🟡 [ML KIT MODEL DOWNLOAD ERROR] $e');
    }
  }

  static Future<String> translate(String text, String sourceLang, String targetLang) async {
    if (!isAvailable || text.trim().isEmpty) return '';

    try {
      final src = sourceLang.toLowerCase() == 'vietnamese' ? TranslateLanguage.vietnamese : TranslateLanguage.english;
      final tgt = targetLang.toLowerCase() == 'vietnamese' ? TranslateLanguage.vietnamese : TranslateLanguage.english;

      if (_translator == null || _currentSrc != src || _currentTgt != tgt) {
        _translator?.close();
        _currentSrc = src;
        _currentTgt = tgt;
        _translator = OnDeviceTranslator(sourceLanguage: src, targetLanguage: tgt);
      }

      if (!_modelsReady) {
        // Trigger non-blocking check
        ensureModelsDownloaded();
      }

      final res = await _translator!.translateText(text);
      if (res.isNotEmpty && res.toLowerCase() != text.trim().toLowerCase()) {
        return res.trim();
      }
    } catch (e) {
      debugPrint('🟡 [ML KIT TRANSLATE FAILED] $e');
    }
    return '';
  }

  static void dispose() {
    _translator?.close();
    _translator = null;
  }
}
