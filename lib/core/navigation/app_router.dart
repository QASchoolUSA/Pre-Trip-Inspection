import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/vehicle/vehicle_selection_page.dart';
import '../../presentation/pages/inspection/inspection_page.dart';
import '../../presentation/pages/inspection/inspection_details_page.dart';
import '../../presentation/pages/inspection/defect_reporting_page.dart';
import '../../presentation/pages/signature/signature_page.dart';
import '../../presentation/pages/report/report_preview_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/help/help_page.dart';
import '../../presentation/pages/sync/offline_sync_page.dart';

import '../../core/constants/app_constants.dart';
import '../../presentation/providers/app_providers.dart';
import '../../generated/l10n/app_localizations.dart';

/// App router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      // Check if user is authenticated
      final isAuthenticated = currentUser != null;
      final isOnAuthPages = state.matchedLocation.startsWith('/login');
      
      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isOnAuthPages && state.matchedLocation != RouteNames.splash) {
        return RouteNames.login;
      }
      
      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isOnAuthPages) {
        return RouteNames.dashboard;
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash route
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Authentication routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Main app routes
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      
      GoRoute(
        path: RouteNames.vehicleSelection,
        name: 'vehicle-selection',
        builder: (context, state) => const VehicleSelectionPage(),
      ),
      
      GoRoute(
        path: RouteNames.inspection,
        name: 'inspection',
        builder: (context, state) {
          final inspectionId = state.extra as String?;
          return InspectionPage(inspectionId: inspectionId);
        },
      ),
      
      GoRoute(
        path: RouteNames.inspectionDetails,
        name: 'inspection-details',
        builder: (context, state) {
          final inspectionId = state.pathParameters['id']!;
          return InspectionDetailsPage(inspectionId: inspectionId);
        },
      ),
      
      GoRoute(
        path: RouteNames.defectReporting,
        name: 'defect-reporting',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          if (params == null || 
              params['inspectionId'] == null || 
              params['itemId'] == null) {
            // Handle missing parameters by redirecting to dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteNames.dashboard);
            });
            return const SizedBox.shrink();
          }
          return DefectReportingPage(
            inspectionId: params['inspectionId'],
            itemId: params['itemId'],
          );
        },
      ),
      
      GoRoute(
        path: RouteNames.signature,
        name: 'signature',
        builder: (context, state) {
          final inspectionId = state.extra as String?;
          if (inspectionId == null) {
            // Handle missing inspection ID by redirecting to dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteNames.dashboard);
            });
            return const SizedBox.shrink();
          }
          return SignaturePage(inspectionId: inspectionId);
        },
      ),
      
      GoRoute(
        path: RouteNames.reportPreview,
        name: 'report-preview',
        builder: (context, state) {
          final inspectionId = state.extra as String?;
          if (inspectionId == null) {
            // Handle missing inspection ID by redirecting to dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteNames.dashboard);
            });
            return const SizedBox.shrink();
          }
          return ReportPreviewPage(inspectionId: inspectionId);
        },
      ),
      
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      GoRoute(
        path: RouteNames.help,
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),
      
      GoRoute(
        path: RouteNames.offlineSync,
        name: 'offline-sync',
        builder: (context, state) => const OfflineSyncPage(),
      ),
    ],
    
    errorBuilder: (context, state) => Consumer(
      builder: (context, ref, child) {
        final l10n = AppLocalizations.of(context)!;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.error),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.pageNotFound,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pageNotFoundDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(RouteNames.dashboard),
                  child: Text(l10n.goToDashboard),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
});

/// Navigation extension for easier routing
extension AppNavigation on BuildContext {
  void goToLogin() => go(RouteNames.login);
  void goToDashboard() => go(RouteNames.dashboard);
  void goToVehicleSelection() => go(RouteNames.vehicleSelection);
  
  void goToInspection([String? inspectionId]) => 
      go(RouteNames.inspection, extra: inspectionId);
  
  void goToInspectionDetails(String inspectionId) => 
      go(RouteNames.inspectionDetails.replaceFirst(':id', inspectionId));
  
  void goToDefectReporting(String inspectionId, String itemId) => 
      go(RouteNames.defectReporting, extra: {
        'inspectionId': inspectionId,
        'itemId': itemId,
      });
  
  void goToSignature(String inspectionId) => 
      go(RouteNames.signature, extra: inspectionId);
  
  void goToReportPreview(String inspectionId) => 
      go(RouteNames.reportPreview, extra: inspectionId);
  
  void goToSettings() => push(RouteNames.settings);
  void goToHelp() => go(RouteNames.help);
  void goToOfflineSync() => go(RouteNames.offlineSync);
  
  // Push methods for overlay navigation
  void pushInspection([String? inspectionId]) => 
      push(RouteNames.inspection, extra: inspectionId);
  
  void pushDefectReporting(String inspectionId, String itemId) => 
      push(RouteNames.defectReporting, extra: {
        'inspectionId': inspectionId,
        'itemId': itemId,
      });
  
  void pushSignature(String inspectionId) => 
      push(RouteNames.signature, extra: inspectionId);
}