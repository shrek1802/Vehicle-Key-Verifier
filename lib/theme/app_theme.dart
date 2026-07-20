import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return _build(Brightness.light);
  }

  static ThemeData dark() {
    return _build(Brightness.dark);
  }

  static ThemeData _build(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;

    final background =
        dark ? AppColors.background : const Color(0xFFF5F7FA);

    final card =
        dark ? AppColors.card : Colors.white;

    final surface =
        dark ? AppColors.surface : const Color(0xFFF0F2F5);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppText.fontFamily,

      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor:
            dark ? AppColors.textPrimary : Colors.black87,
      ),

      cardTheme: CardThemeData(
        color: card,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: BorderSide(
            color: dark
                ? AppColors.border
                : Colors.grey.shade300,
          ),
        ),
      ),

      dividerColor: AppColors.divider,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,

        border: OutlineInputBorder(
          borderRadius: AppSpacing.fieldRadius,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.fieldRadius,
          borderSide: BorderSide(
            color: dark
                ? AppColors.border
                : Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.fieldRadius,
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonRadius,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
          ),
          textStyle: AppText.buttonSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonRadius,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark
            ? AppColors.navigationBackground
            : Colors.white,
        indicatorColor: AppColors.navigationSelected,
      ),

      textTheme: const TextTheme(
        displayLarge: AppText.display,
        headlineLarge: AppText.pageTitle,
        headlineMedium: AppText.sectionTitle,
        titleLarge: AppText.cardTitle,
        bodyLarge: AppText.bodyLarge,
        bodyMedium: AppText.body,
        bodySmall: AppText.caption,
      ),
    );
  }
}
