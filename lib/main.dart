import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/simple_notification_service.dart';
import 'core/services/localization_service.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/locale_provider.dart';
import 'core/navigation/app_router.dart';
import 'presentation/providers/app_providers.dart';
import 'generated/l10n/app_localizations.dart';
import 'data/datasources/database_service.dart';
import 'presentation/widgets/trip_assistant_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for web
  await Hive.initFlutter();
  
  // Initialize database service (registers adapters and opens boxes)
  await DatabaseService.instance.initialize();
  
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
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      localeResolutionCallback: LocalizationService.localeResolutionCallback,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      builder: (context, child) {
        final currentUser = ref.watch(currentUserProvider);
        final isLoggedIn = currentUser != null;
        return Stack(
          children: [
            if (child != null) child,
            if (isLoggedIn) const TripAssistantButton(),
          ],
        );
      },
    );
  }
}
