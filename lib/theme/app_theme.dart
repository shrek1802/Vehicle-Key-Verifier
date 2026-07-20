import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      useMaterial3: true,

      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.background,

      fontFamily: AppText.fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.card,
        error: AppColors.danger,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.backgroundElevated,
        foregroundColor: AppColors.textPrimary,
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      dividerColor: AppColors.divider,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,

        hintStyle: const TextStyle(
          color: AppColors.inputHint,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.fieldRadius,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.fieldRadius,
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: AppSpacing.fieldRadius,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),

          backgroundColor: AppColors.primary,

          foregroundColor: AppColors.onPrimary,

          textStyle: AppText.button,

          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonRadius,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),

          foregroundColor: AppColors.primaryLight,

          side: const BorderSide(
            color: AppColors.primaryLight,
          ),

          textStyle: AppText.buttonSecondary,

          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonRadius,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navigationBackground,

        indicatorColor: AppColors.navigationSelected,

        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryLight
                : AppColors.navigationUnselected,
          ),
        ),

        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppText.fontFamily,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryLight
                : AppColors.navigationUnselected,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: AppText.chip,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: AppText.display,
        headlineLarge: AppText.pageTitle,
        headlineMedium: AppText.sectionTitle,
        titleLarge: AppText.cardTitle,
        bodyLarge: AppText.bodyLarge,
        bodyMedium: AppText.body,
        labelLarge: AppText.button,
        bodySmall: AppText.caption,
      ),
    );
  }
}
