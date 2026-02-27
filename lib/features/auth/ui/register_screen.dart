import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/beacon_colors.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final isWide = MediaQuery.sizeOf(context).width > 900;

    return Scaffold(
      backgroundColor: bgColor,
      body: isWide
          ? Row(
              children: [
                Expanded(child: _buildSplashPanel()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildForm(context),
              ),
            ),
    );
  }

  Widget _buildSplashPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.beacon.sidebarBg, context.beacon.sidebarSurface],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2l,
        vertical: AppSpacing.x2l,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(
                children: [
                  Builder(builder: (context) {
                    final accent = Theme.of(context).colorScheme.primary;
                    final onAccent = Theme.of(context).colorScheme.onPrimary;
                    return Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.all(AppRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          'B',
                          style: AppFonts.clashDisplay(
                            fontSize: 28,
                            color: onAccent,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Beacøn',
                    style: AppFonts.clashDisplay(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2l),
              // Tagline
              Text(
                'Start building your\nbrand today.',
                style: AppFonts.clashDisplay(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              // Feature bullets
              const _SplashFeature(
                icon: LucideIcons.palette,
                text: 'Build your visual identity',
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SplashFeature(
                icon: LucideIcons.mic2,
                text: 'Define your brand voice',
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SplashFeature(
                icon: LucideIcons.fileText,
                text: 'Export brand guidelines',
              ),
              const SizedBox(height: AppSpacing.x2l),
              // Decorative dots
              Row(
                children: [
                  _dot(AppColors.blockLime),
                  const SizedBox(width: AppSpacing.sm),
                  _dot(AppColors.blockViolet),
                  const SizedBox(width: AppSpacing.sm),
                  _dot(AppColors.blockCoral),
                  const SizedBox(width: AppSpacing.sm),
                  _dot(AppColors.blockYellow),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
        color: theme.colorScheme.surface,
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
              Builder(builder: (context) {
                final accent = Theme.of(context).colorScheme.primary;
                final onAccent = Theme.of(context).colorScheme.onPrimary;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.all(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      'B',
                      style: AppFonts.clashDisplay(
                        fontSize: 22,
                        color: onAccent,
                      ),
                    ),
                  ),
                );
              }),
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

class _SplashFeature extends StatelessWidget {
  const _SplashFeature({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: accent),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: AppFonts.inter(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
