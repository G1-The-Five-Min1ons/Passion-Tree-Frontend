import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';

class LearningCourseContent extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onStartJourney;
  final bool isEnrolled;

  const LearningCourseContent({
    super.key,
    required this.title,
    required this.description,
    required this.onStartJourney,
    this.isEnrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ===== HEADER =====
        SizedBox(
          height: 72,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: colors.onPrimary),
            ),
          ),
        ),

        const SizedBox(height: 24),

        /// ===== COURSE MAP PLACEHOLDER =====
        PixelBorderContainer(
          width: double.infinity,
          height: 200,
          borderColor: colors.primary,
          fillColor: colors.surface,
          child: Center(
            child: Text(
              'Course Lp',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurface),
            ),
          ),
        ),

        const SizedBox(height: 24),

        /// ===== DESCRIPTION =====
        PixelBorderContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderColor: colors.primary,
          fillColor: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: AppTypography.bodySemiBold.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        /// ===== READY TO EXPLORE =====
      PixelBorderContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        borderColor: colors.primary,
        fillColor: colors.surface,
        child: Column(
          children: [
            /// ===== TITLE (CENTER FIX) =====
            Center(
              child: SizedBox(
                width: double.infinity, 
                child: Text(
                  isEnrolled ? 'Continue Your Journey' : 'Ready To Explore?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: colors.primary),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ===== NODE IMAGE =====
            Center(
              child: Image.asset(
                'assets/images/learning_path/node/node_active.png',
                width: 90,
                height: 90,
              ),
            ),

            const SizedBox(height: 16),

            /// ===== BUTTON =====
            Center(
              child: AppButton(
                variant: AppButtonVariant.text,
                text: isEnrolled ? 'Continue Journey' : 'Start Journey',
                onPressed: onStartJourney,
              ),
            ),
          ],
        ),
      ),


      ],
    );
  }
}
