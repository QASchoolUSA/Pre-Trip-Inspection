import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';
import 'auth/login_page.dart';
import 'dashboard/dashboard_page.dart';

/// Beautiful animated splash screen that initializes the app
/// Features:
/// - Animated truck logo with elastic bounce effect
/// - Gradient background with smooth transitions
/// - Pulsing animations and smooth text transitions
/// - Professional loading indicators
/// - Enhanced error handling with retry functionality
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    // Logo subtle rotation animation
    _logoRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    ));
    
    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    // Text fade animation
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    // Pulse animation for background
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimations() {
    // Start logo animation immediately
    _logoController.forward();
    
    // Start text animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _textController.forward();
      }
    });
    
    // Start pulse animation and repeat
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize the app
      await ref.read(appInitializationProvider.future);
      
      // Show a notification preview
      final notificationService = ref.read(notificationServiceProvider);
      if (notificationService.isSupported) {
        // Show a preview notification after app initialization
        Future.delayed(const Duration(seconds: 1), () {
          notificationService.showNotification(
            title: 'PTI Mobile App',
            body: 'App initialized successfully!',
            icon: 'assets/icons/icon-192.png',
          );
        });
      }
      
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlueDark,
              AppColors.primaryBlue,
              AppColors.primaryBlueLight,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo/Icon
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.white,
                                    AppColors.grey50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withValues(alpha: 0.3),
                                    blurRadius: 30 * _pulseAnimation.value,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                                    blurRadius: 40 * _pulseAnimation.value,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background glow effect
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.primaryBlueLight.withValues(alpha: 0.1),
                                          AppColors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Main custom app icon
                                  Image.asset(
                                    'assets/icons/icon-192.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),

                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Animated App Name
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppColors.white,
                              AppColors.grey200,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4.0,
                                  color: AppColors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // App Description with subtle animation
                        Text(
                          'Pre-Trip Inspection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white.withValues(alpha: 0.9),
                            letterSpacing: 1.0,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Professional tagline
                        Text(
                          'Professional • Reliable • Safe',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: AppColors.white.withValues(alpha: 0.7),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Enhanced loading indicator
                appInitialization.when(
                  data: (_) => const SizedBox.shrink(),
                  loading: () => Column(
                    children: [
                      // Custom loading animation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          // Inner spinning indicator
                          LoadingAnimationWidget.threeArchedCircle(
                            color: AppColors.white,
                            size: 35,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Animated loading text
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.05,
                            child: Text(
                              'Initializing System...',
                              style: TextStyle(
                                color: AppColors.white.withValues(
                                  alpha: 0.7 + (_pulseAnimation.value - 1.0) * 5,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preparing your inspection tools',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  error: (error, stack) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Initialization Failed',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unable to start the application',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _initializeApp(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Enhanced version info with build indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.successGreen.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successGreen.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Version ${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2024 PTI Mobile Solutions',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.white.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}