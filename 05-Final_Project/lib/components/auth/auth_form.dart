/// Auth Form Component
///
/// REQUIREMENT: A single custom component that handles BOTH
/// Sign In and Sign Up modes. This satisfies the assignment's
/// requirement: "SignIn/Up forms (make one custom component for both)."
///
/// The form switches between modes via [AuthMode]. Different
/// fields appear based on the mode.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../primary_button.dart';
import 'auth_text_field.dart';

enum AuthMode { signIn, signUp }

class AuthForm extends StatefulWidget {
  final AuthMode mode;
  final VoidCallback onToggleMode;
  final VoidCallback onSuccess;

  const AuthForm({
    super.key,
    required this.mode,
    required this.onToggleMode,
    required this.onSuccess,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isSignUp => widget.mode == AuthMode.signUp;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════
  //  VALIDATORS
  // ═══════════════════════════════════════

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _passwordCtrl.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ═══════════════════════════════════════
  //  SUBMIT HANDLER
  // ═══════════════════════════════════════

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();

      if (_isSignUp) {
        await authService.signUp(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          name: _nameCtrl.text,
        );
      } else {
        await authService.signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      }

      if (mounted) widget.onSuccess();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Name field (sign up only) ──────────
          if (_isSignUp) ...[
            AuthTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Enter your name',
              icon: Icons.person_outline,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
          ],

          // ── Email ──────────────────────────────
          AuthTextField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'name@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),

          // ── Password ───────────────────────────
          AuthTextField(
            controller: _passwordCtrl,
            label: 'Password',
            hint: 'At least 6 characters',
            icon: Icons.lock_outline,
            isPassword: true,
            validator: _validatePassword,
          ),

          // ── Confirm password (sign up only) ────
          if (_isSignUp) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmCtrl,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: _validateConfirm,
            ),
          ],

          // ── Forgot password (sign in only) ─────
          if (!_isSignUp) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Error message ──────────────────────
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_errorMessage != null) const SizedBox(height: 16),

          // ── Submit button ──────────────────────
          PrimaryButton(
            text: _isSignUp ? 'Create Account' : 'Sign In',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),

          const SizedBox(height: 20),

          // ── Toggle mode ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp
                    ? 'Already have an account? '
                    : "Don't have an account? ",
                style: AppTextStyles.bodySmall,
              ),
              GestureDetector(
                onTap: widget.onToggleMode,
                child: Text(
                  _isSignUp ? 'Sign In' : 'Sign Up',
                  style: AppTextStyles.boldSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(
        () => _errorMessage = 'Enter your email above first.',
      );
      return;
    }

    try {
      await context.read<AuthService>().sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }
}
