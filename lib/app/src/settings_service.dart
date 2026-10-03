import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'colors.dart';

class SettingsService extends GetxService {
  // Montserrat Arabic contains both Arabic and English letters.
  final String font = 'ar_font';

  ThemeData getLightTheme() {
    return ThemeData(
      fontFamily: font,
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.color1,
        secondary: AppColors.accent,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primaryColor),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      timePickerTheme: TimePickerThemeData(dayPeriodColor: AppColors.color4),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, fontFamily: font),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.color4,
        selectedColor: AppColors.color3,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelStyle: TextStyle(
            color: AppColors.primaryColor, fontFamily: font, fontSize: 13),
      ),
      dividerTheme: DividerThemeData(color: AppColors.color4),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.color4.withOpacity(.6),
        prefixIconColor: AppColors.color1,
        suffixIconColor: AppColors.color2,
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppColors.color2, width: 1.5)),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22.0, height: 1.3),
        headlineSmall: TextStyle(fontSize: 16.0, height: 1.3),
        headlineMedium: TextStyle(fontSize: 18.0, height: 1.3),
        displaySmall: TextStyle(fontSize: 20.0, height: 1.3),
        displayMedium: TextStyle(fontSize: 22.0, height: 1.4),
        displayLarge: TextStyle(fontSize: 24.0, height: 1.4),
        titleSmall: TextStyle(fontSize: 14.0, height: 1.3),
        titleMedium: TextStyle(fontSize: 15.0, height: 1.3),
        bodyMedium: TextStyle(fontSize: 14.0, height: 1.4),
        bodyLarge: TextStyle(fontSize: 15.0, height: 1.4),
        bodySmall: TextStyle(fontSize: 12.0, height: 1.3),
      ),
    );
  }
}
