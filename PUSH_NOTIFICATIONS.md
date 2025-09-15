# Push Notifications Setup and Testing Guide

This guide explains how to set up and test push notifications for the PTI Mobile App PWA on both iOS and Android.

## Setup Instructions

### 1. Enable Notifications in the App

1. Open the PTI Mobile App
2. Navigate to Settings (using the gear icon in the top right of the Dashboard)
3. Toggle "Daily PTI Reminder" to ON
4. Set your preferred reminder time
5. Click "Send Test Notification" to verify setup

### 2. PWA Installation

#### For iOS:
1. Open the app in Safari
2. Tap the Share button (box with arrow)
3. Select "Add to Home Screen"
4. Open the app from the home screen icon

#### For Android:
1. Open the app in Chrome
2. Tap the three dots menu
3. Select "Add to Home Screen"
4. Open the app from the home screen icon

## Testing Push Notifications

### Method 1: Using the App Interface

1. Go to Settings page
2. Click "Send Test Notification" button
3. You should receive an immediate notification

### Method 2: Using Browser Console

1. Open the app in a browser
2. Open Developer Tools (F12)
3. Go to the Console tab
4. Run one of these commands:

For an immediate notification:
```javascript
navigator.serviceWorker.controller.postMessage({
  type: 'SHOW_NOTIFICATION',
  title: 'Test Notification',
  body: 'This is a test notification triggered from console',
  icon: '/icons/icon-192.png'
});
```

For a scheduled daily reminder:
```javascript
navigator.serviceWorker.controller.postMessage({
  type: 'SCHEDULE_DAILY_REMINDER',
  title: 'Console Test Reminder',
  body: 'This reminder was triggered from the browser console',
  hour: 10,
  minute: 30
});
```

### Method 3: Simulate Push Events (Chrome DevTools)

1. Open Chrome DevTools
2. Go to Application → Service Workers
3. Find your registered service worker
4. In the "Push" section, send a push message with custom data:

```json
{
  "title": "Push Test",
  "body": "This is a push notification test",
  "icon": "/icons/icon-192.png"
}
```

## iOS-Specific Considerations

iOS PWAs have specific requirements for notifications:

1. **User Interaction Required**: iOS requires user interaction before requesting notification permissions
2. **Persistent Notifications**: iOS notifications are more persistent and require explicit dismissal
3. **Service Worker Options**: The service worker is configured with iOS-specific options like `requireInteraction: true`

## Android-Specific Considerations

Android PWAs generally have fewer restrictions:

1. **Background Sync**: Better support for background sync and periodic notifications
2. **Notification Channels**: Support for notification channels and categories
3. **Badge Support**: Better badge support for unread notifications

## Troubleshooting

### No Notifications Received

1. Check that notifications are enabled in the Settings page
2. Verify browser notification permissions are granted
3. Ensure the PWA is installed and opened from the home screen
4. Check browser console for any errors

### iOS Notification Issues

1. Make sure you're opening the app from the home screen icon
2. Check that you've allowed notifications when prompted
3. iOS may delay notifications based on usage patterns

### Android Notification Issues

1. Check app permissions in device settings
2. Ensure battery optimization is not restricting the app
3. Verify that notifications are not blocked at the system level

## Daily Reminder Logic

The app is designed to send daily reminders until the user completes an inspection:

1. When enabled, a daily reminder is scheduled at the specified time
2. Notifications will continue to be sent daily until an inspection is completed
3. Users can disable notifications at any time through the Settings page

## Technical Implementation

### Notification Service
The notification service handles:
- Permission requests
- Notification display
- Scheduling logic
- iOS-specific handling

### Service Worker
The service worker handles:
- Background notification processing
- Push event handling
- Notification click handling
- Periodic sync for daily reminders

### IndexedDB Storage
Scheduled notifications are stored in IndexedDB for persistence across sessions.