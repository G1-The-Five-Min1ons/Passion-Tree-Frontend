import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';

class TeacherCreateTab extends StatefulWidget {
  final List<Course> inProgressCourses;
  final List<Course> completedCourses;

  const TeacherCreateTab({
    super.key,
    required this.inProgressCourses,
    required this.completedCourses,
  });

  @override
  State<TeacherCreateTab> createState() => _TeacherCreateTabState();
}

class _TeacherCreateTabState extends State<TeacherCreateTab> {
  int inProgressShown = 2;
  int completedShown = 2;

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;
    final inProgressCourses = widget.inProgressCourses;
    final completedCourses = widget.completedCourses;
  

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // My Learning Paths - In progress
        // =====================================================
        Text(
          'My Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),

        const SizedBox(height: 20),

        RichText(
          text: TextSpan(
            style: AppPixelTypography.smallTitle.copyWith(
              color: colors.onPrimary,
            ),
            children: [
              const TextSpan(text: 'Status : '),
              TextSpan(
                text: 'Drafts',
                style: AppPixelTypography.smallTitle.copyWith(
                  color: colors.secondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        if (inProgressCourses.isEmpty)
          Center(
            child: Text(
              'No in-progress paths found',
              style: AppTypography.subtitleSemiBold.copyWith(
                color: colors.onPrimary,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inProgressCourses.length < inProgressShown
                ? inProgressCourses.length
                : inProgressShown,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio:
                  PixelCourseCard.cardWidth / PixelCourseCard.cardHeight,
            ),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: inProgressCourses[index]);
            },
          ),

        if (inProgressShown < inProgressCourses.length)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: NavigationButton(
                direction: NavigationDirection.down,
                onPressed: () {
                  setState(() {
                    inProgressShown += 2;
                  });
                },
              ),
            ),
          ),

        const SizedBox(height: 60),

        // =====================================================
        // My Learning Paths - Completed
        // =====================================================
        Text(
          'My Learning Paths',
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),

        const SizedBox(height: 20),

        RichText(
          text: TextSpan(
            style: AppPixelTypography.smallTitle.copyWith(
              color: colors.onPrimary,
            ),
            children: const [
              TextSpan(text: 'Status : '),
              TextSpan(
                text: 'Published',
                style: TextStyle(color: AppColors.status),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        if (completedCourses.isEmpty)
          Center(
            child: Text(
              'No completed paths found',
              style: AppTypography.subtitleSemiBold.copyWith(
                color: colors.onPrimary,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedCourses.length < completedShown
                ? completedCourses.length
                : completedShown,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio:
                  PixelCourseCard.cardWidth / PixelCourseCard.cardHeight,
            ),
            itemBuilder: (context, index) {
              return PixelCourseCard(course: completedCourses[index]);
            },
          ),

        if (completedShown < completedCourses.length)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: NavigationButton(
                direction: NavigationDirection.down,
                onPressed: () {
                  setState(() {
                    completedShown += 2;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
