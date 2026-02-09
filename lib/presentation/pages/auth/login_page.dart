import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../../data/models/inspection_models.dart';

/// Login page with Email/Password authentication using Firebase
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.login(email, password);

      if (result.success && result.userData != null) {
        // Set the current user
        ref.read(currentUserProvider.notifier).state = User.fromJson(result.userData!);

        // Navigate to dashboard
        if (mounted) {
          context.goToDashboard();
        }
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Login failed. Please try again.';
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
      resizeToAvoidBottomInset: false,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(150 * 0.2237),
                          child: Image.asset(
                            'assets/icons/icon-192.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 24),

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

                        const SizedBox(height: 32),

                        // Login Card
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.largePadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 24),

                                // Email Input
                                TextField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Enter your email',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                      borderSide: const BorderSide(color: AppColors.grey300, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                                    ),
                                  ),
                                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                                ),

                                const SizedBox(height: 16),

                                // Password Input
                                TextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                      borderSide: const BorderSide(color: AppColors.grey300, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                                    ),
                                  ),
                                  onSubmitted: (_) => _handleLogin(),
                                ),

                                // Error Message
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorRed.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.errorRed.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.errorRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 24),

                                // Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(fontSize: 16),
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