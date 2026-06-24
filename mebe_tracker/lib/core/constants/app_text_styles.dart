import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLg => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
        letterSpacing: -2,
      );
  static TextStyle get displayMd => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
        letterSpacing: -1,
      );
  static TextStyle get displaySm => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      );
  static TextStyle get headingLg => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );
  static TextStyle get headingMd => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );
  static TextStyle get headingSm => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );
  static TextStyle get bodyLg => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.body,
      );
  static TextStyle get bodyMd => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.body,
      );
  static TextStyle get bodySm => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      );
  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
        letterSpacing: 0.8,
      );
  static TextStyle get timerDisplay => GoogleFonts.nunito(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
        letterSpacing: -3,
      );
}
