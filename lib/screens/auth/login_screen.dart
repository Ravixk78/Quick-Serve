import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Login failure. Please verify your credentials.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryNavy;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          // Elegant Background Ornaments
          Positioned(
            top: -60,
            left: -60,
            child: FadeInDown(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.premiumGold.withAlpha(isDark ? 30 : 50),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // High-End 3D Visual with Glow
                    Center(
                      child: SlideInDown(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withAlpha(5)
                                : Colors.black.withAlpha(5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.premiumGold.withAlpha(
                                  isDark ? 15 : 25,
                                ),
                                blurRadius: 40,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Container(
                            width: 190,
                            height: 190,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.premiumGold.withAlpha(10),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Lottie.network(
                              'https://lottie.host/80164b3c-99f5-4702-863a-bb3bda364235/7x8sOqB0Hj.json', // Realistic 3D Service Animation
                              fit: BoxFit.contain,
                              repeat: true,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.home_repair_service_rounded,
                                      size: 70,
                                      color: AppTheme.premiumGold,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 3,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      child: Column(
                        children: [
                          Text(
                            'QuickServe',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'WORLD-CLASS HOME SOLUTIONS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.premiumGold
                                  : AppTheme.primaryNavy,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Form Fields
                    _buildAnimatedField(
                      index: 1,
                      child: CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Your registered email',
                        prefixIcon: Icons.alternate_email_rounded,
                        validator: Validators.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedField(
                      index: 2,
                      child: CustomTextField(
                        controller: _passwordController,
                        label: 'Secure Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.shield_moon_outlined,
                        obscureText: true,
                        validator: Validators.validatePassword,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: Text(
                            'Restore Access?',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.premiumGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CustomButton(
                            text: 'Enter the Network',
                            onPressed: _handleLogin,
                            isLoading: authProvider.isLoading,
                            backgroundColor: AppTheme.premiumGold,
                            textColor: AppTheme.primaryNavy,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      delay: const Duration(milliseconds: 1000),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to QuickServe?",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              'Join Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.premiumGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 100 + 400),
      child: child,
    );
  }
}
