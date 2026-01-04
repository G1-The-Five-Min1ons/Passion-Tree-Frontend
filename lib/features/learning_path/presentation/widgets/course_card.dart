import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';


class CourseCard extends StatelessWidget {
  CourseCard({super.key});

  static const double cardWidth = 180;
  static const double cardHeight = 245;

  // พื้นที่ content ที่ปลอดภัย (หักจากขอบ + padding ภายใน PixelTextField)
  static const double contentWidth = 173;
  static const double imageHeight = 82;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        children: [
          // ---------- Pixel Border ----------
          PixelTextField(
            label: '',
            height: cardHeight,
            width: cardWidth,
            hintText: '',
          ),

          // ---------- Content (ล็อกให้อยู่ในกรอบแน่ ๆ) ----------
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth, // สำคัญมาก
              height: cardHeight - 12, // กันล่างไม่ชนขอบ
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ================= IMAGE =================
                  SizedBox(
                    width: contentWidth,
                    height: imageHeight,
                    child: Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: Text(
                        'IMAGE',
                        style: AppPixelTypography.smallTitle,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ================= CONTENT SECTION =================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 12,
                                color: AppColors.surface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.more_horiz, size: 14),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Container(
                          height: 10,
                          width: 110,
                          color: AppColors.surface,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          height: 10,
                          width: contentWidth,
                          color: AppColors.surface,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 120,
                          color: AppColors.surface,
                        ),

                        const Spacer(),

                        Container(
                          height: 10,
                          width: 140,
                          color: AppColors.surface,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 90,
                          color: AppColors.surface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


