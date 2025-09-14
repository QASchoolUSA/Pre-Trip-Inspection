import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/simple_notification_service.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            
            // Daily Reminder Toggle
            SwitchListTile(
              title: const Text('Daily PTI Reminder'),
              subtitle: const Text('Receive a daily reminder to perform your Pre-Trip Inspection'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
              secondary: const Icon(Icons.notifications),
            ),
            
            const SizedBox(height: AppConstants.mediumPadding),
            
            // Reminder Time
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(
                '${_reminderTime.format(context)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
              enabled: _notificationsEnabled,
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Notification Preview
            if (_notificationsEnabled)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      const Text(
                        'Daily PTI Reminder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Time to perform your Pre-Trip Inspection',
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Scheduled for ${_reminderTime.format(context)}',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                        ),
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