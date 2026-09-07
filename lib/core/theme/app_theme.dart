import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet600,
        primary: AppColors.violet600,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.violet050,
      textTheme: GoogleFonts.instrumentSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.violet900,
        displayColor: AppColors.violet900,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.violet050,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.violet600,
        ),
        iconTheme: const IconThemeData(color: AppColors.violet900),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.violet600,
        selectionColor: AppColors.violet200,
        selectionHandleColor: AppColors.violet600,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.violet900,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
