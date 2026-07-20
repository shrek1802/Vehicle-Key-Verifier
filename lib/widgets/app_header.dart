import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.title = 'Vehicle Key Verifier',
    this.subtitle = 'Professional UK Edition',
    this.icon = Icons.lock_outline_rounded,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double iconSize = compact ? 28 : 34;
    final double iconBoxSize = compact ? 48 : 58;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.45),
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: AppColors.primaryLight,
          ),
        ),
        AppSpacing.gapRowMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? AppText.sectionTitle
                    : AppText.pageTitle,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.pageSubtitle,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          AppSpacing.gapRowMD,
          trailing!,
        ],
      ],
    );
  }
}
