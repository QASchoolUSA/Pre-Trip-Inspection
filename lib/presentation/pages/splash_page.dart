import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';
import 'auth/login_page.dart';
import 'dashboard/dashboard_page.dart';

/// Splash screen that initializes the app
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize the app
      await ref.read(appInitializationProvider.future);
      
      // Wait for at least 2 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to appropriate page
      if (mounted) {
        _navigateToNextPage();
      }
    } catch (e) {
      // Show error and retry option
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _navigateToNextPage() {
    final currentUser = ref.read(currentUserProvider);
    
    if (currentUser != null) {
      // User is already logged in, go to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      // No user logged in, go to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text('Failed to initialize the app:\n$error'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appInitialization = ref.watch(appInitializationProvider);
    
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping,
                  size: 64,
                  color: AppColors.primaryBlue,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // App Description
              const Text(
                'Pre-Trip Inspection',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              appInitialization.when(
                data: (_) => const SizedBox.shrink(),
                loading: () => Column(
                  children: [
                    LoadingAnimationWidget.threeArchedCircle(
                      color: AppColors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Initializing...',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                error: (error, stack) => Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Initialization failed',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _initializeApp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Version info
              Text(
                'Version ${AppConstants.appVersion}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}