import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pti_mobile_app/core/navigation/app_router.dart';
import 'package:pti_mobile_app/core/constants/app_constants.dart';
import 'package:pti_mobile_app/presentation/providers/app_providers.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('AppNavigation extension methods work correctly', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.goToDashboard(),
                    child: const Text('Go to Dashboard'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.goToLogin(),
                    child: const Text('Go to Login'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.goToVehicleSelection(),
                    child: const Text('Go to Vehicle Selection'),
                  ),
                ],
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const Scaffold(
              body: Text('Dashboard Page'),
            ),
          ),
          GoRoute(
            path: RouteNames.login,
            builder: (context, state) => const Scaffold(
              body: Text('Login Page'),
            ),
          ),
          GoRoute(
            path: RouteNames.vehicleSelection,
            builder: (context, state) => const Scaffold(
              body: Text('Vehicle Selection Page'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Test navigation to dashboard
      await tester.tap(find.text('Go to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Page'), findsOneWidget);

      // Navigate back to home
      router.go('/');
      await tester.pumpAndSettle();

      // Test navigation to login
      await tester.tap(find.text('Go to Login'));
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);

      // Navigate back to home
      router.go('/');
      await tester.pumpAndSettle();

      // Test navigation to vehicle selection
      await tester.tap(find.text('Go to Vehicle Selection'));
      await tester.pumpAndSettle();
      expect(find.text('Vehicle Selection Page'), findsOneWidget);
    });

    testWidgets('Router handles missing parameters gracefully', (WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go(RouteNames.signature),
                child: const Text('Go to Signature'),
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.signature,
            builder: (context, state) {
              final inspectionId = state.extra as String?;
              if (inspectionId == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(RouteNames.dashboard);
                });
                return const SizedBox.shrink();
              }
              return Scaffold(
                body: Text('Signature Page: $inspectionId'),
              );
            },
          ),
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const Scaffold(
              body: Text('Dashboard Page'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Test navigation to signature without parameters
      await tester.tap(find.text('Go to Signature'));
      await tester.pumpAndSettle();
      
      // Should redirect to dashboard due to missing parameters
      expect(find.text('Dashboard Page'), findsOneWidget);
    });

    test('RouteNames constants are properly defined', () {
      expect(RouteNames.splash, equals('/'));
      expect(RouteNames.login, equals('/login'));
      expect(RouteNames.dashboard, equals('/dashboard'));
      expect(RouteNames.vehicleSelection, equals('/vehicle-selection'));
      expect(RouteNames.inspection, equals('/inspection'));
      expect(RouteNames.signature, equals('/signature'));
      expect(RouteNames.reportPreview, equals('/report-preview'));
      expect(RouteNames.settings, equals('/settings'));
      expect(RouteNames.help, equals('/help'));
      expect(RouteNames.offlineSync, equals('/offline-sync'));
    });
  });
}