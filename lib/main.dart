import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/simple_notification_service.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for web
  await Hive.initFlutter();
  
  // Initialize notification service
  await SimpleNotificationService().requestPermission();
  
  runApp(
    const ProviderScope(
      child: PTIMobileApp(),
    ),
  );
}

class PTIMobileApp extends ConsumerWidget {
  const PTIMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashPage(),
    );
  }
}
