import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Standard card used throughout Vehicle Key Verifier V2.
///
/// Use this instead of creating individually styled Card widgets on each
/// screen. This keeps the app consistent and makes future redesigns easier.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = AppSpacing.cardPadding,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.showDivider = false,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color resolvedBackground = backgroundColor ??
        (isDark ? AppColors.card : Theme.of(context).colorScheme.surface);

    final Color resolvedBorder = borderColor ??
        (isDark ? AppColors.border : Colors.grey.shade300);

    final Widget content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null ||
              subtitle != null ||
              leading != null ||
              trailing != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  AppSpacing.gapRowMD,
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppText.cardTitle,
                        ),
                      if (subtitle != null) ...[
                        AppSpacing.gapXS,
                        Text(
                          subtitle!,
                          style: AppText.bodySecondary,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  AppSpacing.gapRowMD,
                  trailing!,
                ],
              ],
            ),
            if (showDivider) ...[
              AppSpacing.gapLG,
              const Divider(
                height: 1,
                color: AppColors.divider,
              ),
              AppSpacing.gapLG,
            ] else
              AppSpacing.gapLG,
          ],
          child,
        ],
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: resolvedBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}
