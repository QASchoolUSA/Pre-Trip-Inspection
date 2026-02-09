import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/simple_notification_service.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/app_providers.dart';
import '../../widgets/language_switcher.dart';
import '../../../generated/l10n/app_localizations.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      final hour = prefs.getInt('reminder_hour') ?? 8;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);

    // If notifications are enabled, schedule the daily reminder
    if (_notificationsEnabled) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.scheduleDailyReminder(time: _reminderTime);
    } else {
      // If notifications are disabled, cancel all scheduled notifications
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelAllNotifications();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _saveSettings();
    }
  }

  Future<void> _testNotification() async {
    final l10n = AppLocalizations.of(context)!;
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.showNotification(
      title: l10n.testNotification,
      body: l10n.testNotificationBody,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.testNotificationSent),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Settings Section
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Language Switcher
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    const Icon(Icons.language, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.language,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.selectPreferredLanguage,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const LanguageSwitcher(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            Text(
              l10n.notificationSettings,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            
            // Daily Reminder Toggle
            SwitchListTile(
              title: Text(l10n.dailyPTIReminder),
              subtitle: Text(l10n.dailyReminderDescription),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
              secondary: const Icon(Icons.notifications),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Reminder Time
            ListTile(
              title: Text(l10n.reminderTime),
              subtitle: Text(
                '${_reminderTime.format(context)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
              enabled: _notificationsEnabled,
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Test Notification Button
            ElevatedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.notifications_active),
              label: Text(l10n.sendTestNotification),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            

            
            // Notification Preview
            if (_notificationsEnabled)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.preview,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        l10n.dailyPTIReminder,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l10n.timeToPerformInspection,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        l10n.scheduledFor(_reminderTime.format(context)),
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Instructions for PWA
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pwaNotificationInstructions,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      l10n.forIOSPWA,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      l10n.addAppToHomeScreen,
                    ),
                    Text(
                      l10n.openFromHomeScreen,
                    ),
                    Text(
                      l10n.allowNotificationsWhenPrompted,
                    ),
                    Text(
                      l10n.notificationsAppearDaily,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      l10n.forAndroidPWA,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      l10n.addToHomeScreenFromBrowser,
                    ),
                    Text(
                      l10n.openAppFromHomeScreen,
                    ),
                    Text(
                      l10n.grantNotificationPermissions,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}