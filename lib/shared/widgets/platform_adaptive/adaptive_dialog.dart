import 'package:flutter/material.dart';

import '../../../core/config/design_tokens.dart';

class AdaptiveDialog {
  AdaptiveDialog._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    if (isDesktop) {
      return showDialog<T>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.lg),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.all(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(child: child),
        ],
      ),
    );
  }
}
