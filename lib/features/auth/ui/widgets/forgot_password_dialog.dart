import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail});

  final String? initialEmail;

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return AdaptiveDialog.show(
      context: context,
      child: ForgotPasswordDialog(initialEmail: initialEmail),
    );
  }

  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  bool _isLoading = false;
  String? _error;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.initialEmail ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      if (!mounted) return;
      setState(() {
        _sent = true;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_sent) {
      return _buildSuccess(theme);
    }
    return _buildForm(theme);
  }

  Widget _buildForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset your password',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Enter your email and we'll send you a reset link.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? AppColors.mutedDark
                  : AppColors.mutedLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Send reset link',
            onPressed: _submit,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.mailCheck,
              size: 28,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Check your email',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We sent a password reset link to ${_emailController.text.trim()}. Click the link to set a new password.',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Back to login',
            onPressed: () => Navigator.of(context).pop(),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
