import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../dashboard/dashboard_page.dart';

/// Login page with PIN authentication
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto focus on the PIN input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final pin = _pinController.text.trim();
    
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    if (pin.length != 4) {
      setState(() {
        _errorMessage = 'PIN must be 4 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For demo purposes, accept PIN '1234'
      // In production, this would authenticate against a secure backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (pin == '1234') {
        // Set a demo user
        final demoUser = await ref.read(usersProvider.notifier).createUser(
          name: 'Demo Driver',
          cdlNumber: 'CDL123456',
          cdlExpiryDate: DateTime.now().add(const Duration(days: 365)),
          medicalCertExpiryDate: DateTime.now().add(const Duration(days: 180)),
          phoneNumber: '555-0123',
          email: 'demo@trucking.com',
        );
        
        ref.read(currentUserProvider.notifier).state = demoUser;
        
        // Navigate to dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid PIN. Try 1234 for demo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: false, // Prevent screen resizing when keyboard appears
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppConstants.largePadding,
                      AppConstants.largePadding,
                      AppConstants.largePadding,
                      MediaQuery.of(context).viewInsets.bottom + AppConstants.largePadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        Image.asset(
                          'assets/icons/icon-192.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Welcome Text
                        Text(
                          'Welcome to',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Pre-Trip Inspection System',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // PIN Input Card
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.largePadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Enter Your PIN',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // PIN Input Field
                                TextField(
                                  controller: _pinController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium,
                                  decoration: InputDecoration(
                                    hintText: '••••',
                                    counterText: '',
                                    errorText: _errorMessage,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius,
                                      ),
                                      borderSide: const BorderSide(
                                        color: AppColors.grey300,
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius,
                                      ),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) => _handleLogin(),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              AppColors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Demo Info
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.infoBlue.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: AppColors.infoBlue,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Demo Mode\nUse PIN: 1234',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.infoBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}