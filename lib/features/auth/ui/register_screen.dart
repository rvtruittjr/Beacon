import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_form.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showShake = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) score++;
    if (password.length >= 10 &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = 'Passwords do not match.';
        _showShake = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showShake = false);
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (mounted) context.go('/onboarding');
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
            'Create your account',
            style: AppFonts.clashDisplay(fontSize: 28, color: textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Start managing your brand identity',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Your name',
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: AppSpacing.md),
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
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
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
          _buildPasswordStrength(),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _register(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
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
                'Already have an account? ',
                style: AppFonts.inter(fontSize: 13, color: mutedColor),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Sign in'),
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

  Widget _buildPasswordStrength() {
    return ListenableBuilder(
      listenable: _passwordController,
      builder: (context, _) {
        final strength = _passwordStrength;
        final colors = [AppColors.blockCoral, AppColors.blockYellow, AppColors.success];

        return Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < strength
                      ? colors[strength - 1]
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.all(AppRadius.full),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
