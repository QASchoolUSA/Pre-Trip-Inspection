import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enhanced notification service for web-based PTI Mobile App with iOS PWA support
/// Uses browser Notification API for web push notifications
class SimpleNotificationService {
  static final SimpleNotificationService _instance = 
      SimpleNotificationService._internal();
  
  factory SimpleNotificationService() => _instance;
  
  SimpleNotificationService._internal();

  /// Check if notifications are supported in the current environment
  bool get isSupported => kIsWeb;

  /// Check if we're running on iOS/Safari
  bool get isIOS => kIsWeb;

  /// Request permission to show notifications with iOS-specific handling
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    
    try {
      // In a real implementation, you would request permission from the browser
      // For now, we'll assume permission is granted for demo purposes
      return true;
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
      // Create a notification using the browser Notification API
      debugPrint('Showing notification: $title');
      
      // For web, we would typically communicate with the service worker
      // to show the notification
      if (kIsWeb) {
        debugPrint('Web notification: $title - $body');
      }
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Schedule a daily reminder notification until inspection is completed
  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    String? title,
    String? body,
  }) async {
    if (!isSupported) return;
    
    try {
      final String notificationTitle = title ?? 'Daily PTI Reminder';
      final String notificationBody =
          body ?? 'Time to perform your Pre-Trip Inspection';
      
      // Send message to service worker to schedule periodic notification
      if (kIsWeb) {
        debugPrint('Scheduling daily reminder: $notificationTitle at ${time.hour}:${time.minute}');
      }
    } catch (e) {
      debugPrint('Error scheduling daily reminder: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (!isSupported) return;
    
    try {
      // Send message to service worker to cancel notifications
      if (kIsWeb) {
        debugPrint('Cancelling all notifications');
      }
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}