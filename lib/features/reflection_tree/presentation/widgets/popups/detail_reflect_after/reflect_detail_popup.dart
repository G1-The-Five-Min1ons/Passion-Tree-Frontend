import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/detail_reflect_after/ai_analysis_content.dart';
import 'package:passion_tree_frontend/features/reflection_tree/presentation/widgets/popups/detail_reflect_after/detail_reflect_content.dart';

class ReflectDetailPopup extends StatefulWidget {


  const ReflectDetailPopup({
    super.key,
  });

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReflectDetailPopup(),
    );
  }

  @override
  State<ReflectDetailPopup> createState() => _ReflectDetailPopupState();
}

class _ReflectDetailPopupState extends State<ReflectDetailPopup> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 380,
            height: 680,
            child: PixelBorderContainer(
              pixelSize: 4,
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //TODO: ดึงชื่อ node จริงมาแสดง
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.h3SemiBold.copyWith(color: AppColors.textPrimary),
                              children: [
                                const TextSpan(text: "Node : "),
                                TextSpan(
                                  //TODO: กำหนด maxline อีกทีหลังจากดึงอีโมจิมา
                                  text: "Biology",
                                  style: AppTypography.h3SemiBold.copyWith(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          Text("เดี๋ยวดึงอีโมจิจาก db มาแสดงอีกที", 
                            style: AppTypography.h3SemiBold.copyWith(color: AppColors.textPrimary)
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTabItem(title: "Reflection", index: 0),
                          const SizedBox(width: 16),
                          _buildTabItem(title: "AI Analysis", index: 1),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 350,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand,
                        ),
                        child: SingleChildScrollView(
                          child: _selectedTab == 0 
                            ? DetailReflectContent(
                              //TODO: ส่งค่าจาก db จริง
                              ) 
                            : AIAnalysisContent(
                              //TODO:เพิ่มค่าที่รับส่งจากตัว ai
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 8,
            top: 8,
            child: CloseIcon(
              color: AppColors.textSecondary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    bool isSelected = _selectedTab == index;

    final Color activeColor = AppColors.primaryBrand;
    final Color inactiveColor = AppColors.textSecondary;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        child: Text(
          title,
          style: isSelected 
          ? AppTypography.subtitleMedium.copyWith(color: AppColors.surface)
          : AppTypography.subtitleRegular.copyWith(color: AppColors.surface),
        ),
      ),
    );
  }
}