import 'package:flutter/material.dart';

/// Central colour palette for Vehicle Key Verifier V2.
///
/// All screens and reusable widgets should use these colours rather than
/// defining their own colour values. This keeps the app consistent and makes
/// future design changes much easier.
abstract final class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Core backgrounds
  // ---------------------------------------------------------------------------

  /// Main application background.
  static const Color background = Color(0xFF121212);

  /// App bars and slightly raised background areas.
  static const Color backgroundElevated = Color(0xFF181818);

  /// Standard card background.
  static const Color card = Color(0xFF1E1E1E);

  /// Raised controls, dropdowns and highlighted surface areas.
  static const Color surface = Color(0xFF2A2A2A);

  /// Stronger raised surface used for selected or focused items.
  static const Color surfaceHigh = Color(0xFF333333);

  // ---------------------------------------------------------------------------
  // Brand colours
  // ---------------------------------------------------------------------------

  /// Main action colour.
  static const Color primary = Color(0xFF1976D2);

  /// Brighter blue used for focused controls and selected navigation items.
  static const Color primaryLight = Color(0xFF42A5F5);

  /// Darker blue used for pressed states.
  static const Color primaryDark = Color(0xFF0D47A1);

  /// Text and icons displayed on top of the primary colour.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Status colours
  // ---------------------------------------------------------------------------

  /// Verified database information and successful operations.
  static const Color verified = Color(0xFF2E7D32);

  /// Brighter verified colour for icons and chips.
  static const Color verifiedLight = Color(0xFF66BB6A);

  /// AI-generated or AI-assisted information.
  static const Color ai = Color(0xFFF57C00);

  /// Brighter AI colour for icons and highlighted text.
  static const Color aiLight = Color(0xFFFFA726);

  /// Warning or conditional information.
  static const Color warning = Color(0xFFFFB300);

  /// Errors, unsupported operations and destructive actions.
  static const Color danger = Color(0xFFD32F2F);

  /// Brighter error colour for warnings and status chips.
  static const Color dangerLight = Color(0xFFEF5350);

  /// General informational status.
  static const Color info = Color(0xFF0288D1);

  /// Unknown, untested or unavailable information.
  static const Color unknown = Color(0xFF757575);

  // ---------------------------------------------------------------------------
  // Text colours
  // ---------------------------------------------------------------------------

  /// Main headings and important content.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Supporting text, labels and subtitles.
  static const Color textSecondary = Color(0xFFBDBDBD);

  /// Less important metadata and disabled labels.
  static const Color textMuted = Color(0xFF8A8A8A);

  /// Disabled text and controls.
  static const Color textDisabled = Color(0xFF616161);

  /// Dark text used on bright warning or status colours.
  static const Color textOnLight = Color(0xFF121212);

  // ---------------------------------------------------------------------------
  // Borders and dividers
  // ---------------------------------------------------------------------------

  /// Standard border for cards, fields and outlined buttons.
  static const Color border = Color(0xFF3A3A3A);

  /// Stronger border for focused or selected controls.
  static const Color borderFocused = primaryLight;

  /// Standard divider colour.
  static const Color divider = Color(0xFF303030);

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Bottom navigation background.
  static const Color navigationBackground = Color(0xFF181818);

  /// Selected navigation item background.
  static const Color navigationSelected = Color(0xFF173A5E);

  /// Unselected navigation icon and label colour.
  static const Color navigationUnselected = Color(0xFF9E9E9E);

  // ---------------------------------------------------------------------------
  // Input fields
  // ---------------------------------------------------------------------------

  /// Search boxes, dropdowns and text fields.
  static const Color inputBackground = Color(0xFF242424);

  /// Placeholder and hint text.
  static const Color inputHint = Color(0xFF8D8D8D);

  // ---------------------------------------------------------------------------
  // Transparent status backgrounds
  // ---------------------------------------------------------------------------

  static const Color verifiedBackground = Color(0x332E7D32);
  static const Color aiBackground = Color(0x33F57C00);
  static const Color warningBackground = Color(0x33FFB300);
  static const Color dangerBackground = Color(0x33D32F2F);
  static const Color infoBackground = Color(0x330288D1);
  static const Color unknownBackground = Color(0x33757575);

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
}
