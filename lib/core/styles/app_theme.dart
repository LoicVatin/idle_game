import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.light,
        onPrimary: AppColors.dark,
        secondary: AppColors.light,
        onSecondary: AppColors.dark,
        surface: AppColors.dark,
        onSurface: AppColors.light,
        error: AppColors.accent,
        onError: AppColors.dark,
        outline: AppColors.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.vt323TextTheme().apply(
        decorationColor: AppColors.light,
        bodyColor: AppColors.light,
        displayColor: AppColors.light,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: const BorderSide(color: AppColors.light, width: 2),
        ),
      ),
    );
  }
}
