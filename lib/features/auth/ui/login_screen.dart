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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 768;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(child: _buildLeftPanel()),
                Expanded(child: Center(child: _buildForm(context))),
              ],
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildForm(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.all(AppSpacing.x2l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Beacøn',
            style: AppFonts.clashDisplay(
              fontSize: 48,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your brand, always lit.',
            style: AppFonts.caveat(
              fontSize: 32,
              color: AppColors.mutedDark,
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          // Decorative floating chips
          ..._buildFloatingChips(),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingChips() {
    final chips = [
      _DecoChip('Brand Kit', AppColors.blockViolet, -3),
      _DecoChip('Voice & Tone', AppColors.blockLime, 2),
      _DecoChip('Content Archive', AppColors.blockCoral, -1.5),
      _DecoChip('Audience', AppColors.blockYellow, 2.5),
    ];

    return chips.map((chip) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Transform.rotate(
          angle: chip.rotation * 3.14159 / 180,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: chip.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.all(AppRadius.sm),
              border: Border.all(color: chip.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              chip.label,
              style: TextStyle(
                color: chip.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: 6,
            duration: AppDurations.floater,
            curve: Curves.easeInOut,
          );
    }).toList();
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final formContent = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sign in to your account',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
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
              onPressed: () {
                // TODO: navigate to forgot password
              },
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null) ...[
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
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
                style: theme.textTheme.bodySmall,
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

class _DecoChip {
  final String label;
  final Color color;
  final double rotation;
  const _DecoChip(this.label, this.color, this.rotation);
}
