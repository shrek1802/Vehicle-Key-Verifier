import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trailing,
    this.copyable = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;
  final bool copyable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppSpacing.cardRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
                AppSpacing.gapRowMD,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppText.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (copyable)
                const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
