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
