import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/node_detail.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/node/nodes_overview_core.dart';

class LearningCourseContent extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onStartJourney;
  final bool isEnrolled;
  final bool isEnrolling;
  final List<NodeDetail>? nodes;

  const LearningCourseContent({
    super.key,
    required this.title,
    required this.description,
    required this.onStartJourney,
    this.isEnrolled = false,
    this.isEnrolling = false,
    this.nodes,
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

        /// ===== COURSE MAP PREVIEW =====
        Container(
          width: double.infinity,
          height: 400,
          color: AppColors.background,
          child: nodes != null && nodes!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 600,
                      height: 900,
                      child: IgnorePointer(
                        child: NodesOverviewCore(
                          isEditable: false,
                          nodes: nodes!,
                          onNodeTap: (_) {}, // Disabled in preview
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: nodes == null
                      ? const CircularProgressIndicator()
                      : Text(
                          'No nodes available',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colors.onSurface),
                        ),
                ),
        ),

    

        /// ===== DESCRIPTION =====
        PixelBorderContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderColor: AppColors.cardBorder,
          fillColor: AppColors.surface,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3660), AppColors.surface],
          ),
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
        borderColor: AppColors.cardBorder,
        fillColor: AppColors.surface,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3660), AppColors.surface],
        ),
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
                      ?.copyWith(color: AppColors.title),
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
              child: Opacity(
                opacity: isEnrolling ? 0.6 : 1.0,
                child: AppButton(
                  variant: AppButtonVariant.text,
                  text: isEnrolling 
                      ? 'Enrolling...'
                      : (isEnrolled ? 'Continue Journey' : 'Start Journey'),
                  onPressed: isEnrolling ? () {} : onStartJourney,
                ),
              ),
            ),
          ],
        ),
      ),


      ],
    );
  }
}
