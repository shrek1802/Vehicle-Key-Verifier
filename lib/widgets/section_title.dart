import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.primaryLight,
              size: 24,
            ),
            AppSpacing.gapRowSM,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.sectionTitle,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppText.caption,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
