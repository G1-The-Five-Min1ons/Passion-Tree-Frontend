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

  // Cached filtered lists to avoid re-filtering on every build
  List<LearningPath> _draftPaths = [];
  List<LearningPath> _publishedPaths = [];
  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  @override
  void initState() {
    super.initState();
    _updateFilteredPaths();
  }

  @override
  void didUpdateWidget(TeacherCreateTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-filter only when data actually changes
    if (oldWidget.allPaths != widget.allPaths ||
        oldWidget.userId != widget.userId) {
      _updateFilteredPaths();
    }
  }

  /// Filter paths by userId and publishStatus
  /// Called only when data changes, not on every build
  void _updateFilteredPaths() {
    if (widget.userId == null) {
      _draftPaths = [];
      _publishedPaths = [];
      return;
    }

    // Filter paths by creatorId (only show user's own paths)
    final userPaths = widget.allPaths
        .where((path) => path.creatorId == widget.userId)
        .toList();

    // Separate by publish status
    _draftPaths = userPaths
        .where((path) => path.publishStatus.toLowerCase() == 'draft')
        .toList();

    _publishedPaths = userPaths
        .where((path) => path.publishStatus.toLowerCase() == 'published')
        .toList();
  }

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

  Future<void> _confirmDeletePath(LearningPath path) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Learning Path'),
          content: Text(
            'Are you sure you want to delete "${path.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (!mounted) return;
    context.read<LearningPathBloc>().add(
      DeleteLearningPathEvent(
        pathId: path.id,
        userId: widget.userId,
      ),
    );
  }

  /// Build section header with title and status
  Widget _buildSectionHeader(String status, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Learning Paths',
          style: AppPixelTypography.title.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: AppPixelTypography.smallTitle.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            children: [
              const TextSpan(text: 'Status : '),
              TextSpan(
                text: status,
                style: TextStyle(color: statusColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Build path grid with empty state and show more button
  Widget _buildPathGrid({
    required List<LearningPath> paths,
    required int shownCount,
    required VoidCallback onShowMore,
    required String emptyMessage,
  }) {
    final colors = Theme.of(context).colorScheme;

    if (paths.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTypography.subtitleSemiBold.copyWith(
            color: colors.onPrimary,
          ),
        ),
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paths.length < shownCount ? paths.length : shownCount,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 35,
            crossAxisSpacing: 12,
            childAspectRatio: 0.692,
          ),
          itemBuilder: (context, index) {
            return PixelCourseCard(
              course: paths[index],
              showMoreIcon: true,
              onCardTap: () {
                final bloc = context.read<LearningPathBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: TeacherNodesOverviewPage(
                        title: paths[index].title,
                        pathId: paths[index].id,
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
                        existingPath: paths[index],
                      ),
                    ),
                  ),
                );
              },
              onDelete: () {
                _confirmDeletePath(paths[index]);
              },
            );
          },
        ),
        if (shownCount < paths.length)
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
                    onPressed: onShowMore,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Use cached filtered lists instead of filtering on every build
    final inProgressCourses = _draftPaths;
    final completedCourses = _publishedPaths;

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
        _buildSectionHeader('Drafts', colors.secondary),
        _buildPathGrid(
          paths: inProgressCourses,
          shownCount: inProgressShown,
          onShowMore: () {
            setState(() {
              inProgressShown += 2;
            });
          },
          emptyMessage: 'No in-progress paths found',
        ),

        const SizedBox(height: 60),

        // =====================================================
        // My Learning Paths - Published
        // =====================================================
        _buildSectionHeader('Published', AppColors.status),
        _buildPathGrid(
          paths: completedCourses,
          shownCount: completedShown,
          onShowMore: () {
            setState(() {
              completedShown += 2;
            });
          },
          emptyMessage: 'No published paths found',
        ),
      ],
    );
  }
}
