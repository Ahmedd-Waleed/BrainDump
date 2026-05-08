/// App Color System
///
/// Provides color tokens for both light and dark themes.
/// Use AppColors for static colors, or context.colors for theme-aware colors.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════
  //  PRIMARY — AI Intelligence & Trust
  // ═══════════════════════════════════════
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryBg = Color(0xFFEEF2FF);
  static const Color primaryBgDark = Color(0xFF1E1B4B);

  // ═══════════════════════════════════════
  //  SECONDARY — Energy & Action
  // ═══════════════════════════════════════
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFD97706);
  static const Color secondaryBg = Color(0xFFFEF3C7);

  // ═══════════════════════════════════════
  //  NEUTRAL — Light Theme
  // ═══════════════════════════════════════
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralBg = Color(0xFFF8FAFC);
  static const Color neutralLight = Color(0xFFF1F5F9);
  static const Color neutralBorder = Color(0xFFE2E8F0);
  static const Color neutralGray = Color(0xFF94A3B8);
  static const Color neutralDark = Color(0xFF475569);
  static const Color neutralBlack = Color(0xFF0F172A);

  // ═══════════════════════════════════════
  //  NEUTRAL — Dark Theme
  // ═══════════════════════════════════════
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceLight = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ═══════════════════════════════════════
  //  SEMANTIC — Status & Feedback
  // ═══════════════════════════════════════
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════
  //  PRIORITY
  // ═══════════════════════════════════════
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // ═══════════════════════════════════════
  //  CATEGORY
  // ═══════════════════════════════════════
  static const Color categoryTask = Color(0xFF3B82F6);
  static const Color categoryIdea = Color(0xFF8B5CF6);
  static const Color categoryReminder = Color(0xFFF59E0B);
  static const Color categoryNote = Color(0xFF10B981);
  static const Color categoryErrand = Color(0xFFEC4899);
  static const Color categoryQuestion = Color(0xFF06B6D4);

  // ═══════════════════════════════════════
  //  GRADIENTS
  // ═══════════════════════════════════════
  static const LinearGradient micGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B5CF6)],
  );

  static const LinearGradient micRecordingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFF97316)],
  );

  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );
}

/// Theme-aware color helpers.
///
/// Usage: `context.colors.background` returns the right color
/// for current theme (light or dark).
class ThemeColors {
  final bool isDark;
  const ThemeColors(this.isDark);

  Color get background =>
      isDark ? AppColors.darkBg : AppColors.neutralBg;
  Color get surface =>
      isDark ? AppColors.darkSurface : AppColors.neutralWhite;
  Color get surfaceVariant =>
      isDark ? AppColors.darkSurfaceLight : AppColors.neutralLight;
  Color get border =>
      isDark ? AppColors.darkBorder : AppColors.neutralBorder;
  Color get textPrimary =>
      isDark ? AppColors.darkText : AppColors.neutralBlack;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.neutralDark;
  Color get textTertiary =>
      isDark ? AppColors.darkTextSecondary : AppColors.neutralGray;
  Color get primaryBg =>
      isDark ? AppColors.primaryBgDark : AppColors.primaryBg;
}

extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors =>
      ThemeColors(Theme.of(this).brightness == Brightness.dark);
}
