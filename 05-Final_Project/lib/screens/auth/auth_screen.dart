/// Auth Screen
///
/// Container screen for the AuthForm. Handles the visual layout,
/// branding (logo, gradient header), and toggling between modes.

import 'package:flutter/material.dart';

import '../../components/auth/auth_form.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.signIn;

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
    });
  }

  void _onSuccess() {
    // The AuthGate will detect the auth state change and navigate.
    // Nothing else to do here.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSignUp = _mode == AuthMode.signUp;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.neutralBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Gradient Header ──────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.authGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.neutralWhite
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: AppColors.neutralWhite,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'BrainDump',
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.neutralWhite,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      isSignUp ? 'Create account' : 'Welcome back',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.neutralWhite,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSignUp
                          ? 'Start capturing your thoughts'
                          : 'Sign in to continue capturing',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.neutralWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ─────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: AuthForm(
                  mode: _mode,
                  onToggleMode: _toggleMode,
                  onSuccess: _onSuccess,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
