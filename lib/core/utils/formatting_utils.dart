import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for locale-specific formatting
class FormattingUtils {
  /// Format date according to locale
  static String formatDate(DateTime date, Locale locale) {
    final formatter = DateFormat.yMMMd(locale.toString());
    return formatter.format(date);
  }
  
  /// Format date and time according to locale
  static String formatDateTime(DateTime dateTime, Locale locale) {
    final formatter = DateFormat.yMMMd(locale.toString()).add_jm();
    return formatter.format(dateTime);
  }
  
  /// Format time according to locale
  static String formatTime(DateTime time, Locale locale) {
    final formatter = DateFormat.jm(locale.toString());
    return formatter.format(time);
  }
  
  /// Format short date (e.g., 12/31/2023)
  static String formatShortDate(DateTime date, Locale locale) {
    final formatter = DateFormat.yMd(locale.toString());
    return formatter.format(date);
  }
  
  /// Format long date (e.g., December 31, 2023)
  static String formatLongDate(DateTime date, Locale locale) {
    final formatter = DateFormat.yMMMMd(locale.toString());
    return formatter.format(date);
  }
  
  /// Format number according to locale
  static String formatNumber(num number, Locale locale) {
    final formatter = NumberFormat('#,##0', locale.toString());
    return formatter.format(number);
  }
  
  /// Format decimal number according to locale
  static String formatDecimal(double number, Locale locale, {int decimalDigits = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalDigits}', locale.toString());
    return formatter.format(number);
  }
  
  /// Format percentage according to locale
  static String formatPercentage(double percentage, Locale locale, {int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern(locale.toString());
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(percentage / 100);
  }
  
  /// Format currency according to locale
  static String formatCurrency(double amount, Locale locale, {String? currencySymbol}) {
    String symbol = currencySymbol ?? _getCurrencySymbol(locale);
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: symbol,
    );
    return formatter.format(amount);
  }
  
  /// Format compact number (e.g., 1K, 1M)
  static String formatCompactNumber(num number, Locale locale) {
    final formatter = NumberFormat.compact(locale: locale.toString());
    return formatter.format(number);
  }
  
  /// Get currency symbol based on locale
  static String _getCurrencySymbol(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '\$'; // USD
      case 'ru':
        return '₽'; // Russian Ruble
      case 'uk':
        return '₴'; // Ukrainian Hryvnia
      case 'es':
        return '€'; // Euro (assuming European Spanish)
      default:
        return '\$';
    }
  }
  
  /// Format file size
  static String formatFileSize(int bytes, Locale locale) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final size = bytes / (1 << (i * 10));
    
    return '${formatDecimal(size, locale, decimalDigits: i == 0 ? 0 : 1)} ${suffixes[i]}';
  }
  
  /// Format duration in a human-readable way
  static String formatDuration(Duration duration, Locale locale) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return formatDate(dateTime, locale);
    } else if (difference.inDays > 0) {
      return _getRelativeTimeString(difference.inDays, 'day', locale);
    } else if (difference.inHours > 0) {
      return _getRelativeTimeString(difference.inHours, 'hour', locale);
    } else if (difference.inMinutes > 0) {
      return _getRelativeTimeString(difference.inMinutes, 'minute', locale);
    } else {
      return _getJustNowString(locale);
    }
  }
  
  /// Get relative time string based on locale
  static String _getRelativeTimeString(int value, String unit, Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        final unitRu = _getUnitInRussian(unit, value);
        return '$value $unitRu назад';
      case 'uk':
        final unitUk = _getUnitInUkrainian(unit, value);
        return '$value $unitUk тому';
      case 'es':
        final unitEs = _getUnitInSpanish(unit, value);
        return 'hace $value $unitEs';
      default:
        final unitEn = value == 1 ? unit : '${unit}s';
        return '$value $unitEn ago';
    }
  }
  
  /// Get "just now" string based on locale
  static String _getJustNowString(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'только что';
      case 'uk':
        return 'щойно';
      case 'es':
        return 'ahora mismo';
      default:
        return 'just now';
    }
  }
  
  /// Get unit in Russian with proper declension
  static String _getUnitInRussian(String unit, int value) {
    switch (unit) {
      case 'day':
        if (value % 10 == 1 && value % 100 != 11) return 'день';
        if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'дня';
        return 'дней';
      case 'hour':
        if (value % 10 == 1 && value % 100 != 11) return 'час';
        if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'часа';
        return 'часов';
      case 'minute':
        if (value % 10 == 1 && value % 100 != 11) return 'минута';
        if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'минуты';
        return 'минут';
      default:
        return unit;
    }
  }
  
  /// Get unit in Ukrainian with proper declension
  static String _getUnitInUkrainian(String unit, int value) {
    switch (unit) {
      case 'day':
        if (value % 10 == 1 && value % 100 != 11) return 'день';
        if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'дні';
        return 'днів';
      case 'hour':
        if (value % 10 == 1 && value % 100 != 11) return 'година';
        if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'години';
        return 'годин';
      case 'minute':
        if (value % 10 == 1 && value % 100 != 11) return 'хвилина';
        if ([2, 3, 4].contains(value % 10) && ![12, 13, 14].contains(value % 100)) return 'хвилини';
        return 'хвилин';
      default:
        return unit;
    }
  }
  
  /// Get unit in Spanish with proper form
  static String _getUnitInSpanish(String unit, int value) {
    switch (unit) {
      case 'day':
        return value == 1 ? 'día' : 'días';
      case 'hour':
        return value == 1 ? 'hora' : 'horas';
      case 'minute':
        return value == 1 ? 'minuto' : 'minutos';
      default:
        return unit;
    }
  }
}