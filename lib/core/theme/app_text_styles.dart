import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Two type families only: Nunito for headings/prices, Instrument Sans for UI text.
/// Line-height stays >=1.4 wherever Devanagari and Latin can mix so मात्रा never clips.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle screenTitle = GoogleFonts.nunito(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.violet900,
  );

  static TextStyle sectionHeading = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.violet900,
  );

  static TextStyle bigNumber = GoogleFonts.nunito(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: Colors.white,
  );

  static TextStyle body = GoogleFonts.instrumentSans(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.violet900,
  );

  static TextStyle buttonLabel = GoogleFonts.instrumentSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle fieldLabel = GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.mutedText,
  );

  static TextStyle eyebrow = GoogleFonts.instrumentSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.6,
    height: 1.3,
  );
}
