import 'package:flutter/material.dart';

// Headings / Titles — เคยเป็น pixel font (PressStart2P) เปลี่ยนมาใช้ Rubik
// เพื่อให้ตัวอักษรอ่านง่ายขึ้น แต่ยังคงชื่อคลาสเดิมไว้เพื่อหลีกเลี่ยงการแก้
// callsite ทั่วทั้งโปรเจกต์ ขนาดตัวอักษรปรับให้สมดุลกับฟอนต์ใหม่ (ฟอนต์
// pixel กว้างกว่าปกติ)
class AppPixelTypography {
  static const String fontFamily = 'Rubik';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle smallTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle littleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}

//Rubik (UI / Content)
class AppTypography {
  static const String fontFamily = 'Rubik';

  // ---------- SemiBold ----------
  static const TextStyle h1SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h2SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle h3SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitleSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodySemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle smallBodySemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ---------- Medium ----------
  static const TextStyle h1Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle h2Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle h3Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle subtitleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle smallBodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ---------- Regular ----------
  static const TextStyle h2Regular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle h3Regular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle titleRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle subtitleRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle smallBodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
