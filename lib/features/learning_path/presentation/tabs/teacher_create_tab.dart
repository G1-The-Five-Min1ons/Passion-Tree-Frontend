
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
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/teacher_nodes_overview.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';

class TeacherCreateTab extends StatefulWidget {
  final List<LearningPath> allPaths;
  final String? userId;

  const TeacherCreateTab({
    super.key,
    required this.allPaths,
    this.userId,
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
    
    // Filter paths by creatorId (only show user's own paths) and publishStatus
    final userPaths = widget.userId != null
        ? widget.allPaths.where((path) => path.creatorId == widget.userId).toList()
        : <LearningPath>[];
    
    final inProgressCourses = userPaths
        .where((path) => path.publishStatus.toLowerCase() == "draft")
        .toList();
    final completedCourses = userPaths
        .where((path) => path.publishStatus.toLowerCase() == "published")
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
            onPressed: () {
              final bloc = context.read<LearningPathBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const CreateLearningPathInputPage(),
                  ),
                ),
              );
            },
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
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio: 0.692,
            ),

            itemBuilder: (context, index) {
              return PixelCourseCard(
                course: inProgressCourses[index],
                showMoreIcon: true,
                onCardTap: () {
                  final bloc = context.read<LearningPathBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: TeacherNodesOverviewPage(
                          title: inProgressCourses[index].title,
                          pathId: inProgressCourses[index].id,
                        ),
                      ),
                    ),
                  );
                },
                onEdit: () {
                  final bloc = context.read<LearningPathBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: CreateLearningPathInputPage(
                          existingPath: inProgressCourses[index],
                        ),
                      ),
                    ),
                  );
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
        // My Learning Paths - Published
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
              'No published paths found',
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
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 35,
              crossAxisSpacing: 12,
              childAspectRatio: 0.692,
            ),
            itemBuilder: (context, index) {
              return PixelCourseCard(
                course: completedCourses[index],
                showMoreIcon: true,
                onCardTap: () {
                  final bloc = context.read<LearningPathBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: TeacherNodesOverviewPage(
                          title: completedCourses[index].title,
                          pathId: completedCourses[index].id,
                        ),
                      ),
                    ),
                  );
                },
                onEdit: () {
                  final bloc = context.read<LearningPathBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: CreateLearningPathInputPage(
                          existingPath: completedCourses[index],
                        ),
                      ),
                    ),
                  );
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
