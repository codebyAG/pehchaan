import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Two type families only: Nunito for headings/prices, Instrument Sans for UI text.
/// Line-height stays >=1.4 wherever Devanagari and Latin can mix so मात्रा never clips.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle screenTitle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: AppColors.violet900,
  );

  static TextStyle sectionHeading = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.violet900,
  );

  static TextStyle bigNumber = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 52,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: Colors.white,
  );

  static TextStyle body = TextStyle(
    fontFamily: 'InstrumentSans',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.violet900,
  );

  static TextStyle buttonLabel = TextStyle(
    fontFamily: 'InstrumentSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle fieldLabel = TextStyle(
    fontFamily: 'InstrumentSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.mutedText,
  );

  static TextStyle eyebrow = TextStyle(
    fontFamily: 'InstrumentSans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.6,
    height: 1.3,
  );
}
