import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/material.dart' as lp;

class LearningNodeContent extends StatelessWidget {
  final String title;
  final String description;
  final List<lp.Material> materials;
  final VoidCallback onTakeQuiz;

  const LearningNodeContent({
    super.key,
    required this.title,
    required this.description,
    required this.materials,
    required this.onTakeQuiz,
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

        /// ===== VIDEO / COVER =====
        PixelBorderContainer(
          width: double.infinity,
          height: 180,
          borderColor: colors.primary,
          fillColor: colors.surface,
          child: const Center(child: Icon(Icons.play_circle_outline, size: 56)),
        ),

        const SizedBox(height: 24),

        /// ===== NODE DESCRIPTION =====
        PixelBorderContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderColor: colors.primary,
          fillColor: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Node Description',
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

        const SizedBox(height: 24),

        /// ===== LEARNING MATERIALS =====
        PixelBorderContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderColor: colors.primary,
          fillColor: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Materials',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...materials.map(
                (material) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: colors.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${material.type}: ${material.url}',
                          style: AppTypography.subtitleSemiBold.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        /// ===== TAKE QUIZ BUTTON =====
        Center(
          child: AppButton(
            variant: AppButtonVariant.text,
            text: 'Take Quiz',
            onPressed: onTakeQuiz,
          ),
        ),
      ],
    );
  }
}
