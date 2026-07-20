import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.trailing,
    this.valueColor,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Widget? trailing;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 22,
              color: AppColors.primaryLight,
            ),
            AppSpacing.gapRowMD,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppText.body.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    return onTap == null
        ? tile
        : InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: tile,
          );
  }
}
