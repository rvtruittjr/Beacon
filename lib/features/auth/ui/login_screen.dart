import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showShake = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _showShake = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showShake = false);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final formContent = Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(AppSpacing.x2l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.all(AppRadius.x2l),
        boxShadow: isDark ? [] : AppShadows.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blockLime,
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    'B',
                    style: AppFonts.clashDisplay(
                      fontSize: 22,
                      color: AppColors.textOnLime,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Beacøn',
                style: AppFonts.clashDisplay(fontSize: 26, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            'Welcome back',
            style: AppFonts.clashDisplay(fontSize: 28, color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sign in to your account',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
            autofillHints: const [AutofillHints.password],
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null) ...[
            Text(
              _error!,
              style: AppFonts.inter(fontSize: 13, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthDivider(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 24),
              label: const Text('Continue with Google'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppFonts.inter(fontSize: 13, color: mutedColor),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );

    if (_showShake) {
      return formContent
          .animate()
          .shakeX(duration: 200.ms, hz: 4, amount: 8);
    }

    return formContent;
  }
}
