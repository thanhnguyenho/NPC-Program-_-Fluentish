import 'dart:io' show Platform;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MlKitTranslator {
  static OnDeviceTranslator? _translator;
  static final _modelManager = OnDeviceTranslatorModelManager();
  
  static bool get isAvailable => Platform.isAndroid || Platform.isIOS;

  static Future<void> ensureModelsDownloaded() async {
    if (!isAvailable) return;
    final enReady = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    final viReady = await _modelManager.isModelDownloaded(TranslateLanguage.vietnamese.bcpCode);
    if (!enReady) await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    if (!viReady) await _modelManager.downloadModel(TranslateLanguage.vietnamese.bcpCode);
  }

  static Future<String> translate(String text, String sourceLang, String targetLang) async {
    if (!isAvailable) throw UnsupportedError('ML Kit only works on iOS/Android');
    
    final src = sourceLang == 'Vietnamese' ? TranslateLanguage.vietnamese : TranslateLanguage.english;
    final tgt = targetLang == 'Vietnamese' ? TranslateLanguage.vietnamese : TranslateLanguage.english;
    
    _translator?.close();
    _translator = OnDeviceTranslator(sourceLanguage: src, targetLanguage: tgt);
    return await _translator!.translateText(text);
  }

  static void dispose() {
    _translator?.close();
    _translator = null;
  }
}
