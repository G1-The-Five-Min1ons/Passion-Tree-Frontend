import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

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
      
      scaffoldBackgroundColor: AppColors.surface, //แก้ชั่วคราวจาก background เป็น surface จะได้ดูสี component ได้

      textTheme: TextTheme(
        // หัวข้อใหญ่สุด ใช้ Pixel Font
        displayLarge: AppPixelTypography.h1,
        displayMedium: AppPixelTypography.h2,
        displaySmall: AppPixelTypography.h3,

        // หัวข้อทั่วไป ใช้ Rubik SemiBold
        headlineMedium: AppTypography.h1SemiBold,
        headlineSmall: AppTypography.h2SemiBold,
        titleLarge: AppTypography.titleSemiBold, 

        // เนื้อหาทั่วไป ใช้ Rubik Regular/Medium
        bodyLarge: AppTypography.bodyRegular,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.smallBodyRegular,
        
        // สำหรับปุ่มหรือข้อความเน้น
        labelLarge: AppTypography.titleMedium,
      ),
    );
  }
}