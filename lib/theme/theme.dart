
// ==================== ARCHIVO: app_themes.dart ====================
import 'package:flutter/material.dart';

class AppColors {
  // Colores modo claro
  static const Color lightBackgroundPrimary = Color(0xFFD2E9F9);
  static const Color lightColorPrimary = Color(0xFF76C2FA);
  static const Color lightColorSecondary = Color(0xFFAAEEFA);
  static const Color lightTextDark = Color(0xFF333333);
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  // Colores modo oscuro
  static const Color darkBackgroundPrimary = Color(0xFF1A1F2E);
  static const Color darkColorPrimary = Color(0xFF5BA8E0);
  static const Color darkColorSecondary = Color(0xFF76C2FA);
  static const Color darkTextLight = Color(0xFFE8F4FD);
  static const Color darkSurface = Color(0xFF2A3441);
  static const Color darkSurfaceVariant = Color(0xFF374151);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackgroundPrimary,
  primaryColor: AppColors.lightColorPrimary,
  
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightTextDark,
    elevation: 2,
    shadowColor: AppColors.lightColorSecondary.withOpacity(0.3),
    iconTheme: IconThemeData(color: AppColors.lightColorPrimary),
  ),
  
  colorScheme: ColorScheme.light(
    primary: AppColors.lightColorPrimary,
    secondary: AppColors.lightColorSecondary,
    surface: AppColors.lightSurface,
    surfaceVariant: AppColors.lightSurface,
    background: AppColors.lightBackgroundPrimary,
    onPrimary: AppColors.lightSurface,
    onSecondary: AppColors.lightTextDark,
    onSurface: AppColors.lightTextDark,
    onBackground: AppColors.lightTextDark,
  ),
  
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.lightTextDark),
    bodyMedium: TextStyle(color: AppColors.lightTextDark),
    titleLarge: TextStyle(color: AppColors.lightTextDark, fontWeight: FontWeight.bold),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.lightBackgroundPrimary,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.lightColorSecondary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.lightColorSecondary.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.lightColorPrimary, width: 2),
    ),
    hintStyle: TextStyle(color: AppColors.lightTextDark.withOpacity(0.6)),
  ),
  
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightColorPrimary,
    foregroundColor: AppColors.lightSurface,
    elevation: 4,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackgroundPrimary,
  primaryColor: AppColors.darkColorPrimary,
  
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextLight,
    elevation: 2,
    shadowColor: AppColors.darkColorSecondary.withOpacity(0.3),
    iconTheme: IconThemeData(color: AppColors.darkColorPrimary),
  ),
  
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkColorPrimary,
    secondary: AppColors.darkColorSecondary,
    surface: AppColors.darkSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    background: AppColors.darkBackgroundPrimary,
    onPrimary: AppColors.darkSurface,
    onSecondary: AppColors.darkBackgroundPrimary,
    onSurface: AppColors.darkTextLight,
    onBackground: AppColors.darkTextLight,
  ),
  
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkTextLight),
    bodyMedium: TextStyle(color: AppColors.darkTextLight),
    titleLarge: TextStyle(color: AppColors.darkTextLight, fontWeight: FontWeight.bold),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkBackgroundPrimary,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.darkColorSecondary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.darkColorSecondary.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.darkColorPrimary, width: 2),
    ),
    hintStyle: TextStyle(color: AppColors.darkTextLight.withOpacity(0.6)),
  ),
  
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkColorPrimary,
    foregroundColor: AppColors.darkSurface,
    elevation: 4,
  ),
);

