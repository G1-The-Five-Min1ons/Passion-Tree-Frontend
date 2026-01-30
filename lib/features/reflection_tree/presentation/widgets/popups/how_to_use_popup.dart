import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class HowToUsePopup extends StatelessWidget {
  const HowToUsePopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HowToUsePopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 55),
      child: PixelBorderContainer(
        pixelSize: 4,
        padding: const EdgeInsets.all(22),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "HOW TO USE?",
                    style: AppPixelTypography.title,
                  ),
                  const SizedBox(height: 16),
                  
                  //ก้อนบน
                  Image.asset(
                    'assets/images/reflection/howtouse-pause.png',
                    width: 150,
                    filterQuality: FilterQuality.none,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "use 3",
                        style: AppPixelTypography.small,
                      ),
                      Image.asset(
                        'assets/icons/Pixel_heart.png',
                        width: 13,
                        height: 13,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "to ",
                        style: AppPixelTypography.small,
                      ),
                      Text(
                        "pause ",
                        style: AppPixelTypography.small.copyWith(color: AppColors.warning),
                      ),
                      Text(
                        "tree",
                        style: AppPixelTypography.small,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.textDisabled,
                            thickness: 1,
                          ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            'or',
                            style: AppTypography.subtitleSemiBold.copyWith(
                              color: AppColors.title,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //ก้อนล่าง
                  const SizedBox(height: 16),

                  Image.asset(
                    'assets/images/reflection/howtouse-retrieve.png',
                    width: 150,
                    filterQuality: FilterQuality.none,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "use 5",
                        style: AppPixelTypography.small,
                      ),
                      Image.asset(
                        'assets/icons/Pixel_heart.png',
                        width: 14,
                        height: 14,
                        filterQuality: FilterQuality.none,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "to ",
                        style: AppPixelTypography.small,
                      ),
                      Text(
                        "retrieve ",
                        style: AppPixelTypography.small.copyWith(color: AppColors.status),
                      ),
                      Text(
                        "tree",
                        style: AppPixelTypography.small,
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Want to add hearts? ",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        //TODO: เพิ่ม logic กดแล้วไป mission
                        "Go to missions",
                        style: AppTypography.bodySemiBold.copyWith(color: AppColors.title),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Positioned(
            right: -14,
            top: -14,
            child: IconTheme(
              data: const IconThemeData(size: 24),
              child: CloseIcon(
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}