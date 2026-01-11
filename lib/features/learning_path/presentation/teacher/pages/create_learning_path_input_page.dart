import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_section.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_path_status_page.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/text_field.dart';

class CreateLearningPathInputPage extends StatefulWidget {
  const CreateLearningPathInputPage({super.key});

  @override
  State<CreateLearningPathInputPage> createState() =>
      _CreateLearningPathInputPageState();
}

class _CreateLearningPathInputPageState
    extends State<CreateLearningPathInputPage> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Create Learning Path',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xmargin,
              right: AppSpacing.xmargin,
              top: AppSpacing.ymargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                SizedBox(
                  height: 120, // เพิ่มความสูงเพื่อรองรับ subtitle
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create a New \nLearning Path',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),

                      const SizedBox(height: 20), // ระยะห่างตามที่ต้องการ

                      Text(
                        'Fill in details to start a new path for your students',
                        style: AppTypography.subtitleSemiBold.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ===== PREVIEW CARD =====
                Center(
                  child: Container(
                    height: 160,
                    width: 220,
                    color: colors.secondary.withValues(alpha: 0.25),
                    alignment: Alignment.center,
                    child: const Text('PREVIEW CARD'),
                  ),
                ),

                const SizedBox(height: 40),

                // ===== PATH TITLE : TITLE =====
                PixelTextField(
                  label: 'Path Title',
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Enter learning path title',
                  height: 46, // single line กำลังพอดี
                ),


                const SizedBox(height: 20),

                // ===== PATH TITLE : CONTENT =====
                Container(
                  height: 56,
                  width: double.infinity,
                  color: colors.surface.withValues(alpha: 0.3),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const Text('PATH TITLE INPUT'),
                ),

                const SizedBox(height: 40),

                // ===== UPLOAD COVER : TITLE =====
               const SizedBox(height: 60),
                Text(
                  'Upload Cover Image',
                  style: AppTypography.titleSemiBold.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 20),

                // ===== UPLOAD COVER : CONTENT =====
                Container(
                  height: 160,
                  width: double.infinity,
                  color: colors.primary.withValues(alpha: 0.15),
                  alignment: Alignment.center,
                  child: const Text('UPLOAD COVER'),
                ),

                const SizedBox(height: 40),

                // ===== OBJECTIVES : TITLE =====
                const SizedBox(height: 60),
                Text(
                  'Path Objectives',
                  style: AppTypography.titleSemiBold.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 20),

                // ===== OBJECTIVES : CONTENT =====
                Container(
                  height: 140,
                  width: double.infinity,
                  color: colors.surface.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(12),
                  child: const Text('OBJECTIVES INPUT'),
                ),

                const SizedBox(height: 40),

                // ===== DESCRIPTION : TITLE =====
                const SizedBox(height: 60),
                Text(
                  'Path Description',
                  style: AppTypography.titleSemiBold.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // ===== DESCRIPTION : CONTENT =====
                Container(
                  height: 140,
                  width: double.infinity,
                  color: colors.surface.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(12),
                  child: const Text('DESCRIPTION INPUT'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
