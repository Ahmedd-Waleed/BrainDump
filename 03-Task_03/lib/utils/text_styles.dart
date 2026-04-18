import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Poppins';

  // ═══════════════════════════════════════
  //  TITLE — Large headings (Bold 700)
  // ═══════════════════════════════════════
  static const TextStyle title = TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.neutralBlack,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.neutralBlack,
    height: 1.3,
  );

  // ═══════════════════════════════════════
  //  HEADER — Section headings (SemiBold 600)
  // ═══════════════════════════════════════
  static const TextStyle header = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralBlack,
    height: 1.4,
  );

  static const TextStyle headerSmall = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralBlack,
    height: 1.4,
  );

  // ═══════════════════════════════════════
  //  REGULAR — Body text (Regular 400)
  // ═══════════════════════════════════════
  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralDark,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralDark,
    height: 1.5,
  );

  // ═══════════════════════════════════════
  //  BOLD — Emphasized text (Bold 700)
  // ═══════════════════════════════════════
  static const TextStyle bold = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.neutralBlack,
    height: 1.5,
  );

  static const TextStyle boldSmall = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.neutralBlack,
    height: 1.5,
  );

  // ═══════════════════════════════════════
  //  SUPPORTING
  // ═══════════════════════════════════════
  static const TextStyle caption = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralGray,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralWhite,
    height: 1.0,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralWhite,
    height: 1.0,
    letterSpacing: 0.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.3,
  );
}