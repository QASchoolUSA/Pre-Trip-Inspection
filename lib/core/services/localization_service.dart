import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing application localization
class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _autoDetectedKey = 'auto_detected_language';
  static const String _hasManualSelectionKey = 'has_manual_selection';
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English (default)
    Locale('ru', ''), // Russian
    Locale('uk', ''), // Ukrainian
    Locale('es', ''), // Spanish
  ];
  
  /// Get the current locale from preferences or system
  static Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final hasManualSelection = prefs.getBool(_hasManualSelectionKey) ?? false;
    
    if (hasManualSelection) {
      // User has manually selected a language, use it
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        return Locale(languageCode);
      }
    }
    
    // Check if we have an auto-detected language stored
    final autoDetectedLanguage = prefs.getString(_autoDetectedKey);
    if (autoDetectedLanguage != null) {
      return Locale(autoDetectedLanguage);
    }
    
    // First time launch - auto-detect and store
    final detectedLocale = _detectSystemLocale();
    await prefs.setString(_autoDetectedKey, detectedLocale.languageCode);
    return detectedLocale;
  }
  
  /// Detect system locale with fallback to English
  static Locale _detectSystemLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    
    // Check if system locale is supported
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }
    
    // Fallback to English if system locale is not supported
    return const Locale('en', '');
  }
  
  /// Save language preference (manual selection)
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    await prefs.setBool(_hasManualSelectionKey, true);
  }
  
  /// Reset to auto-detected language (remove manual selection)
  static Future<void> resetToAutoDetected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
    await prefs.setBool(_hasManualSelectionKey, false);
    
    // Re-detect system language
    final detectedLocale = _detectSystemLocale();
    await prefs.setString(_autoDetectedKey, detectedLocale.languageCode);
  }
  
  /// Check if current language is manually selected
  static Future<bool> isManuallySelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasManualSelectionKey) ?? false;
  }
  
  /// Get auto-detected language
  static Future<String?> getAutoDetectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_autoDetectedKey);
  }
  
  /// Get language name for display
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }
  
  /// Get language flag emoji
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      case 'uk':
        return '🇺🇦';
      case 'es':
        return '🇪🇸';
      default:
        return '🇺🇸';
    }
  }
  
  /// Check if locale is supported
  static bool isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
  
  /// Get locale resolution callback for MaterialApp
  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) {
      return const Locale('en', '');
    }
    
    // Try to find exact match
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    
    // Return default locale if no match found
    return const Locale('en', '');
  }
}