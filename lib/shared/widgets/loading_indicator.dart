import 'package:flutter/material.dart';

import '../../core/config/design_tokens.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.caption});

  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
            ),
          ],
        ],
      ),
    );
  }
}
