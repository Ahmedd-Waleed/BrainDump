/// App Theme Configuration
///
/// Defines light and dark themes for the entire application.

import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.neutralBg,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.neutralWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.neutralWhite,
      foregroundColor: AppColors.neutralBlack,
      elevation: 0,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(color: AppColors.neutralDark),
  );

  // ═══════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AppColors.darkBg,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
  );
}
