import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

/// Simple notification service for web-based PTI Mobile App
/// Uses browser Notification API for web push notifications
class SimpleNotificationService {
  static final SimpleNotificationService _instance = 
      SimpleNotificationService._internal();
  
  factory SimpleNotificationService() => _instance;
  
  SimpleNotificationService._internal();

  /// Check if notifications are supported in the current environment
  bool get isSupported => kIsWeb && html.window.navigator.serviceWorker != null;

  /// Request permission to show notifications
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

  /// Show a notification immediately
  Future<void> showNotification({
    required String title,
    String? body,
    String? icon,
  }) async {
    if (!isSupported) return;
    
    try {
      // Create a notification using the browser Notification API
      // This is a simplified version - in a real app you would use more robust handling
      html.window.console.log('Showing notification: $title');
      
      // For web, we would typically communicate with the service worker
      // to show the notification
      if (html.window.navigator.serviceWorker?.controller != null) {
        html.window.navigator.serviceWorker!.controller!.postMessage({
          'type': 'SHOW_NOTIFICATION',
          'title': title,
          'body': body,
          'icon': icon ?? '/icons/icon-192.png',
        });
      }
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Schedule a daily reminder notification
  /// For web, this would typically be handled by the service worker
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
      if (html.window.navigator.serviceWorker?.controller != null) {
        html.window.navigator.serviceWorker!.controller!.postMessage({
          'type': 'SCHEDULE_DAILY_REMINDER',
          'title': notificationTitle,
          'body': notificationBody,
          'hour': time.hour,
          'minute': time.minute,
        });
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
      if (html.window.navigator.serviceWorker?.controller != null) {
        html.window.navigator.serviceWorker!.controller!.postMessage({
          'type': 'CANCEL_NOTIFICATIONS',
        });
      }
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }
}