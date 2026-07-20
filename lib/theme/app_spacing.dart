import 'package:flutter/widgets.dart';

/// Standard spacing values used throughout the application.
///
/// Keeping spacing in one place makes the UI consistent.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(18));

  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(14));

  static const BorderRadius fieldRadius =
      BorderRadius.all(Radius.circular(14));

  static const EdgeInsets page =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16);

  static const EdgeInsets cardPadding =
      EdgeInsets.all(16);

  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(vertical: 8);

  static const SizedBox gapXS = SizedBox(height: xs);
  static const SizedBox gapSM = SizedBox(height: sm);
  static const SizedBox gapMD = SizedBox(height: md);
  static const SizedBox gapLG = SizedBox(height: lg);
  static const SizedBox gapXL = SizedBox(height: xl);

  static const SizedBox gapRowSM = SizedBox(width: sm);
  static const SizedBox gapRowMD = SizedBox(width: md);
  static const SizedBox gapRowLG = SizedBox(width: lg);
}
