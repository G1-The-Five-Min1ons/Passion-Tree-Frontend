import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

const List<String> mockLearningPaths = [
  "Evolution & Origin of Life",
  "Genetics & Molecular Biology",
  "Human Biology & Physiology",
  "Cell Biology",
  "Anatomy",
];

class RecommendPopup extends StatelessWidget {
  const RecommendPopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RecommendPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelBorderContainer(
        pixelSize: 4,
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "NEXT\nLEARNING PATH",
                      textAlign: TextAlign.center,
                      style: AppPixelTypography.title,
                    ),
                  ),
                  const SizedBox(height: 38),
                  
                  Text(
                    "We recommend you",
                    style: AppTypography.subtitleRegular,
                  ),
                  const SizedBox(height: 16),

                  // TODO: ดึงมาจาก AI
                  ...mockLearningPaths.map((path) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PixelBorderContainer(
                      pixelSize: 3,
                      height: 38,
                      fillColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          path,
                          style: AppTypography.subtitleSemiBold,
                        ),
                      ),
                    )
                  ),),
                ],
              ),
            ),
            Positioned(
              right: -12,
              top: -12,
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