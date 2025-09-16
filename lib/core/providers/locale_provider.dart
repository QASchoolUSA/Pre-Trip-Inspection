import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/localization_service.dart';

/// Provider for managing the current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Notifier for managing locale state
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en', '')) {
    _loadSavedLocale();
  }
  
  /// Load saved locale from preferences
  Future<void> _loadSavedLocale() async {
    final locale = await LocalizationService.getCurrentLocale();
    state = locale;
  }
  
  /// Change the current locale (manual selection)
  Future<void> setLocale(String languageCode) async {
    final newLocale = Locale(languageCode, '');
    
    // Validate that the locale is supported
    if (LocalizationService.isLocaleSupported(newLocale)) {
      state = newLocale;
      await LocalizationService.setLanguage(languageCode);
    }
  }
  
  /// Reset to auto-detected language
  Future<void> resetToAutoDetected() async {
    await LocalizationService.resetToAutoDetected();
    final locale = await LocalizationService.getCurrentLocale();
    state = locale;
  }
  
  /// Check if current language is manually selected
  Future<bool> isManuallySelected() async {
    return await LocalizationService.isManuallySelected();
  }
  
  /// Get auto-detected language code
  Future<String?> getAutoDetectedLanguage() async {
    return await LocalizationService.getAutoDetectedLanguage();
  }
  
  /// Get the current language code
  String get currentLanguageCode => state.languageCode;
  
  /// Get the current language name for display
  String get currentLanguageName => 
      LocalizationService.getLanguageName(state.languageCode);
  
  /// Get the current language flag
  String get currentLanguageFlag => 
      LocalizationService.getLanguageFlag(state.languageCode);
}