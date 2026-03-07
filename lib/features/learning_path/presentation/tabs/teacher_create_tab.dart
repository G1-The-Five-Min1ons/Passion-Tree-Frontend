import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/pixel_icon.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/app_button.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/create_learning_path_input_page.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/teacher_verification_page.dart';

class TeacherCreateTab extends StatefulWidget {
  final List<LearningPath> allPaths;
  final String? userId;

  const TeacherCreateTab({super.key, required this.allPaths, this.userId});

  @override
  State<TeacherCreateTab> createState() => _TeacherCreateTabState();
}

class _TeacherCreateTabState extends State<TeacherCreateTab> {
  int inProgressShown = 2;
  int completedShown = 2;
  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  Future<void> _onCreatePressed() async {
    try {
      final status = await _authRepository.getTeacherVerificationStatus();
      if (!mounted) return;

      if (!status.isVerified) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherVerificationPage(),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateLearningPathInputPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to check verification status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Filter paths by publishStatus
    final inProgressCourses = widget.allPaths
        .where((path) => path.publishStatus == "draft")
        .toList();
    final completedCourses = widget.allPaths
        .where((path) => path.publishStatus == "Published")
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Add button (top right) =====
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            variant: AppButtonVariant.iconOnly,
            icon: const PixelIcon('assets/icons/Pixel_plus.png', size: 16),
            onPressed: _onCreatePressed,
          ),
        ),

        const SizedBox(height: 20),

        // =====================================================
        // My Learning Paths - Drafts
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
                  BaseCourseCard.defaultWidth / BaseCourseCard.defaultHeight,
            ),

            itemBuilder: (context, index) {
              return PixelCourseCard(
                course: inProgressCourses[index],
                showMoreIcon: true,
                onEdit: () {
                  // TODO: Navigate to edit page
                },
                onDelete: () {
                  context.read<LearningPathBloc>().add(
                    DeleteLearningPathEvent(
                      pathId: inProgressCourses[index].id,
                      userId: widget.userId,
                    ),
                  );
                },
              );
            },
          ),

        if (inProgressShown < inProgressCourses.length)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More',
                    style: AppPixelTypography.smallTitle.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  NavigationButton(
                    direction: NavigationDirection.down,
                    onPressed: () {
                      setState(() {
                        inProgressShown += 2;
                      });
                    },
                  ),
                ],
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
                  BaseCourseCard.defaultWidth / BaseCourseCard.defaultHeight,
            ),
            itemBuilder: (context, index) {
              return PixelCourseCard(
                course: completedCourses[index],
                showMoreIcon: true,
                onEdit: () {
                  // TODO: Navigate to edit page
                },
                onDelete: () {
                  context.read<LearningPathBloc>().add(
                    DeleteLearningPathEvent(
                      pathId: completedCourses[index].id,
                      userId: widget.userId,
                    ),
                  );
                },
              );
            },
          ),

        if (completedShown < completedCourses.length)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More',
                    style: AppPixelTypography.smallTitle.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  NavigationButton(
                    direction: NavigationDirection.down,
                    onPressed: () {
                      setState(() {
                        completedShown += 2;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
