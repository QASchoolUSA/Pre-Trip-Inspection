# pti_mobile_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Configuration

This project uses Firebase for push notifications. To configure Firebase:

1. Copy `.env.local.example` to `.env.local`
2. Update the environment variables with your Firebase configuration
3. For Vercel deployments, add the same environment variables in your Vercel project settings

See [FIREBASE_CONFIG.md](file:///Users/nikitakedrov/PTI-Mobile-App/pti_mobile_app/FIREBASE_CONFIG.md) for detailed instructions.

## Push Notifications

This app includes support for push notifications on both iOS and Android PWAs. 

Key features:
- Daily reminders until inspection completion
- Cross-platform support (iOS and Android)
- Easy testing through Settings page
- iOS-specific handling for PWA restrictions

For detailed setup and testing instructions, see [PUSH_NOTIFICATIONS.md](file:///Users/nikitakedrov/PTI-Mobile-App/pti_mobile_app/PUSH_NOTIFICATIONS.md).

To test notifications:
1. Open the app and navigate to Settings (gear icon in top right)
2. Enable "Daily PTI Reminder" and set a time
3. Use the "Send Test Notification" button to verify functionality
4. For advanced testing, use the notification-test.html page

The app will send daily reminders until the user completes an inspection, helping ensure compliance with pre-trip inspection requirements.