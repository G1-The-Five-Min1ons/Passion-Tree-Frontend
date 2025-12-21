import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBrand,
        secondary: AppColors.secondaryBrand,
        surface: AppColors.surface,
        error: AppColors.cancel,
        onPrimary: Colors.white, 
        onSurface: AppColors.textPrimary,
      ),
      
      scaffoldBackgroundColor: AppColors.background,

      //รอฟอนต์
      // textTheme: AppTypography.textTheme,
    );
  }
}