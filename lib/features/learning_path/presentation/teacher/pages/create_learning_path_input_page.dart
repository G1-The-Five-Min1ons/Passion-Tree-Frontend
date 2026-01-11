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

class CreateLearningPathInputPage extends StatelessWidget {
  const CreateLearningPathInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Create Learning Path',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xmargin,
            vertical: AppSpacing.ymargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Container(
                height: 96,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colors.primary.withValues(alpha: 0.25),
                alignment: Alignment.centerLeft,
                child: const Text('HEADER TITLE + SUBTITLE'),
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
              Container(
                height: 24,
                width: double.infinity,
                color: colors.surface.withValues(alpha: 0.6),
                alignment: Alignment.centerLeft,
                child: const Text('PATH TITLE'),
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
              Container(
                height: 24,
                width: double.infinity,
                color: colors.surface.withValues(alpha: 0.6),
                alignment: Alignment.centerLeft,
                child: const Text('UPLOAD COVER IMAGE'),
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
              Container(
                height: 24,
                width: double.infinity,
                color: colors.surface.withValues(alpha: 0.6),
                alignment: Alignment.centerLeft,
                child: const Text('PATH OBJECTIVES'),
              ),

              const SizedBox(height: 20),

              // ===== OBJECTIVES : CONTENT =====
              Container(
                height: 120,
                width: double.infinity,
                color: colors.surface.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(12),
                child: const Text('OBJECTIVES INPUT'),
              ),

              const SizedBox(height: 40),

              // ===== DESCRIPTION : TITLE =====
              Container(
                height: 24,
                width: double.infinity,
                color: colors.surface.withValues(alpha: 0.6),
                alignment: Alignment.centerLeft,
                child: const Text('PATH DESCRIPTION'),
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
    );
  }
}
