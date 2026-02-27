import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../shared/widgets/app_button.dart';
import '../data/share_repository.dart';

class PasswordGateScreen extends ConsumerStatefulWidget {
  const PasswordGateScreen({super.key, required this.shareToken});
  final String shareToken;

  @override
  ConsumerState<PasswordGateScreen> createState() =>
      _PasswordGateScreenState();
}

class _PasswordGateScreenState extends ConsumerState<PasswordGateScreen>
    with SingleTickerProviderStateMixin {
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  int _attempts = 0;
  bool _locked = false;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebarBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Text(
                  'Beacøn',
                  style: AppFonts.clashDisplay(
                    fontSize: 28,
                    color: AppColors.blockYellow,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),

                // Lock icon
                Icon(
                  LucideIcons.lock,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Heading
                Text(
                  'This brand kit is protected.',
                  style: AppFonts.clashDisplay(
                    fontSize: 32,
                    color: AppColors.sidebarText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Subheading
                Text(
                  'Enter the password to view this brand kit.',
                  style: AppFonts.inter(
                    fontSize: 15,
                    color: AppColors.sidebarMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password field with shake
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    );
                  },
                  child: TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    autofocus: true,
                    enabled: !_locked,
                    style: const TextStyle(color: AppColors.sidebarText),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: AppColors.sidebarMuted),
                      filled: true,
                      fillColor: AppColors.sidebarSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.md),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Submit
                AppButton(
                  label: 'View brand kit',
                  isLoading: _loading,
                  isFullWidth: true,
                  onPressed: _locked || _loading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_locked) return;

    final pw = _passwordCtrl.text.trim();
    if (pw.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final valid = await ref
          .read(shareRepositoryProvider)
          .verifySharePassword(widget.shareToken, pw);

      if (valid) {
        if (mounted) {
          context.go('/share/${widget.shareToken}');
        }
      } else {
        _attempts++;
        _shakeCtrl.forward(from: 0);

        if (_attempts >= 5) {
          setState(() {
            _locked = true;
            _error =
                'Too many attempts. Please contact the brand owner.';
          });
        } else {
          setState(() {
            _error = 'Incorrect password. Please try again.';
          });
        }
      }
    } catch (_) {
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
