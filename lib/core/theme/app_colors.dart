import 'package:flutter/material.dart';

/// Pehchaan brand palette. One violet, one yellow, one near-black — never a third hue.
class AppColors {
  AppColors._();

  static const Color violet600 = Color(0xFF6614F5);
  static const Color violet900 = Color(0xFF1E0A46);
  static const Color violet800 = Color(0xFF23085C);
  static const Color violetPressed = Color(0xFF5410CC);

  static const Color yellow500 = Color(0xFFFBBA1B);
  static const Color yellowInk = Color(0xFF6B4400);

  static const Color violet100 = Color(0xFFF1EBFF);
  static const Color violet200 = Color(0xFFE8DFFF);
  static const Color violet050 = Color(0xFFF5F1FF);

  static const Color mutedText = Color(0xFF8A7BB5);
  static const Color textOnViolet = Color(0xFFE7DDFF);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEAE3FA);

  static const Color error = Color(0xFFB3261E);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x241E0A46), blurRadius: 32, offset: Offset(0, 12)),
  ];
}
