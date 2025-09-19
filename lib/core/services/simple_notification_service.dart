import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;

/// Enhanced notification service for web-based PTI Mobile App with iOS PWA support
/// Uses browser Notification API for web push notifications
class SimpleNotificationService {
  static final SimpleNotificationService _instance = 
      SimpleNotificationService._internal();
  
  factory SimpleNotificationService() => _instance;

  SimpleNotificationService._internal();

  /// Check if notifications are supported in the current environment
  bool get isSupported => kIsWeb && html.Notification.supported;

  /// Check if we're running on iOS/Safari
  bool get isIOS => kIsWeb && html.window.navigator.userAgent.contains('Safari') && 
                   !html.window.navigator.userAgent.contains('Chrome');

  /// Request permission to show notifications with iOS-specific handling
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    
    try {
      if (kIsWeb) {
        final permission = await html.Notification.requestPermission();
        debugPrint('Notification permission status: $permission');
        return permission == 'granted';
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Show a notification immediately with iOS-specific options
  Future<void> showNotification({
    required String title,
    String? body,
    String? icon,
  }) async {
    if (!isSupported) return;
    
    try {
      debugPrint('Showing notification: $title');
      
      if (kIsWeb) {
        // Check if service worker is available and active
        if (html.window.navigator.serviceWorker != null) {
          final registration = await html.window.navigator.serviceWorker!.ready;
          if (registration.active != null) {
            // Send message to service worker to show notification
            registration.active!.postMessage({
              'type': 'SHOW_NOTIFICATION',
              'title': title,
              'body': body ?? '',
              'icon': icon ?? '/icons/icon-192.png',
            });
            debugPrint('Notification message sent to service worker');
          } else {
            debugPrint('Service worker not active');
          }
        } else {
          debugPrint('Service worker not available');
        }
      }
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Schedule a daily reminder notification at the specified time
  Future<void> scheduleDailyReminder({
    TimeOfDay? time,
    String? title,
    String? body,
    int? hour,
    int? minute,
    bool requireInteraction = false,
  }) async {
    if (!isSupported) return;
    
    try {
      final String notificationTitle = title ?? 'Daily PTI Reminder';
      final String notificationBody = body ?? 'It\'s time for your PTI!';
      final int reminderHour = hour ?? time?.hour ?? 9;
      final int reminderMinute = minute ?? time?.minute ?? 0;
      
      debugPrint('Scheduling daily reminder: $notificationTitle at $reminderHour:$reminderMinute');
      
      if (kIsWeb) {
        // Check if service worker is available and active
        if (html.window.navigator.serviceWorker != null) {
          final registration = await html.window.navigator.serviceWorker!.ready;
          if (registration.active != null) {
            // Send message to service worker to schedule daily reminder
            registration.active!.postMessage({
              'type': 'SCHEDULE_DAILY_REMINDER',
              'title': notificationTitle,
              'body': notificationBody,
              'hour': reminderHour,
              'minute': reminderMinute,
              'requireInteraction': requireInteraction,
            });
            debugPrint('Daily reminder scheduled via service worker');
          } else {
            debugPrint('Service worker not active');
          }
        } else {
          debugPrint('Service worker not available');
        }
      }
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (!isSupported) return;
    
    try {
      debugPrint('Cancelling all notifications');
      
      if (kIsWeb) {
        // Check if service worker is available and active
        if (html.window.navigator.serviceWorker != null) {
          final registration = await html.window.navigator.serviceWorker!.ready;
          if (registration.active != null) {
            // Send message to service worker to cancel notifications
            registration.active!.postMessage({
              'type': 'CANCEL_NOTIFICATIONS',
            });
            debugPrint('Cancel message sent to service worker');
          } else {
            debugPrint('Service worker not active');
          }
        } else {
          debugPrint('Service worker not available');
        }
      }
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}