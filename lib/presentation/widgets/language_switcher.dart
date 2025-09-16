import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/localization_service.dart';
import '../../generated/l10n/app_localizations.dart';

/// A widget that allows users to switch between supported languages
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocalizationService.getLanguageFlag(currentLocale.languageCode),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 4),
          Text(
            LocalizationService.getLanguageName(currentLocale.languageCode),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      tooltip: l10n.language,
      onSelected: (String value) async {
        if (value == 'auto') {
          await localeNotifier.resetToAutoDetected();
        } else {
          await localeNotifier.setLocale(value);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          // Auto-detect option
          PopupMenuItem<String>(
            value: 'auto',
            child: FutureBuilder<bool>(
              future: localeNotifier.isManuallySelected(),
              builder: (context, snapshot) {
                final isManual = snapshot.data ?? false;
                
                return Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: !isManual ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Auto-detect',
                        style: TextStyle(
                          fontWeight: !isManual ? FontWeight.bold : FontWeight.normal,
                          color: !isManual ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                    ),
                    if (!isManual)
                      Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                );
              },
            ),
          ),
          const PopupMenuDivider(),
          // Language options
          ...LocalizationService.supportedLocales.map((Locale locale) {
            return PopupMenuItem<String>(
              value: locale.languageCode,
              child: FutureBuilder<bool>(
                future: localeNotifier.isManuallySelected(),
                builder: (context, snapshot) {
                  final isManual = snapshot.data ?? false;
                  final isSelected = isManual && locale.languageCode == currentLocale.languageCode;
                  
                  return Row(
                    children: [
                      Text(
                        LocalizationService.getLanguageFlag(locale.languageCode),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          LocalizationService.getLanguageName(locale.languageCode),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
        ];
      },
    );
  }
}

/// A compact version of the language switcher for smaller spaces
class CompactLanguageSwitcher extends ConsumerWidget {
  const CompactLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocalizationService.getLanguageFlag(currentLocale.languageCode),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      tooltip: l10n.language,
      onSelected: (String languageCode) {
        localeNotifier.setLocale(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return LocalizationService.supportedLocales.map((Locale locale) {
          final isSelected = locale.languageCode == currentLocale.languageCode;
          
          return PopupMenuItem<String>(
            value: locale.languageCode,
            child: Row(
              children: [
                Text(
                  LocalizationService.getLanguageFlag(locale.languageCode),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  locale.languageCode.toUpperCase(),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}