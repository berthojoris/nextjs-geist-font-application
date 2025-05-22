import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeConfig {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFF00BCD4);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Text Styles
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: background,
      error: error,
    ),
    textTheme: TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelMedium: labelMedium,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headlineMedium.copyWith(color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 12.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: EdgeInsets.all(16.sp),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: background,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: labelMedium.copyWith(color: primaryColor),
      unselectedLabelStyle: labelMedium,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: surfaceColor,
    ),
  );
}
