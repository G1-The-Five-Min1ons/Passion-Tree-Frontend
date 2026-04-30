import 'package:flutter/material.dart';

import 'package:passion_tree_frontend/core/theme/typography.dart';

import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/recommendation_card.dart';

class PopularLearningPathsSection extends StatefulWidget {
  final List<LearningPath> paths;
  final bool hasEnrolledPaths;
  final bool isLoading;

  const PopularLearningPathsSection({
    super.key,
    required this.paths,
    required this.hasEnrolledPaths,
    this.isLoading = false,
  });

  @override
  State<PopularLearningPathsSection> createState() =>
      _PopularLearningPathsSectionState();
}

class _PopularLearningPathsSectionState
    extends State<PopularLearningPathsSection> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final paths = widget.paths;
    final hasEnrolledPaths = widget.hasEnrolledPaths;
    final isLoading = widget.isLoading;

    if (paths.isEmpty && !isLoading) return const SizedBox();

    final title = hasEnrolledPaths
        ? 'Recommendation'
        : 'Popular Learning Paths';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppPixelTypography.title.copyWith(color: colors.onPrimary),
        ),
        const SizedBox(height: 8),
        if (hasEnrolledPaths)
          Row(
            children: [
              Icon(
                Icons.swipe_right_alt,
                size: 18,
                color: colors.onPrimary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'Swipe right to see more recommendations',
                style: AppTypography.smallBodyMedium.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final computedHeight = ((screenHeight * 0.36).clamp(220.0, 420.0)) as double;

            return SizedBox(
              height: computedHeight,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemCount: paths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: RecommendationCard(course: paths[index]),
                        );
                      },
                    ),
            );
          },
        ),
        if (paths.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              paths.length.clamp(0, 7),
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _page == i ? 14 : 7,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _page == i
                      ? colors.primary
                      : colors.onPrimary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
