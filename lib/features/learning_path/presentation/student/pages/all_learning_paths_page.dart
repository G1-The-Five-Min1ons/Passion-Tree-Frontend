import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/base_course_card.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/course_card.dart';

class AllLearningPathsPage extends StatefulWidget {
  final List<LearningPath> paths;

  const AllLearningPathsPage({super.key, required this.paths});

  @override
  State<AllLearningPathsPage> createState() => _AllLearningPathsPageState();
}

class _AllLearningPathsPageState extends State<AllLearningPathsPage> {
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  int _shownCount = 0; // 0 = not yet initialized from viewport
  bool _isLoadingMore = false;

  // Load 1 additional row (2 items) at a time — matches scroll distance
  static const int _pageSize = 2;

  // Row height = card height + grid mainAxisSpacing
  static const double _rowHeight =
      BaseCourseCard.defaultHeight + 35.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shownCount == 0) {
      // Calculate how many items fill the current viewport on first build
      final mq = MediaQuery.of(context);
      final available =
          mq.size.height - kToolbarHeight - mq.padding.top - mq.padding.bottom;
      // +1 row as buffer so the next row is already loading before user hits bottom
      final rowsVisible = (available / _rowHeight).ceil() + 1;
      _shownCount = rowsVisible * 2; // 2 columns
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  List<LearningPath> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return widget.paths;
    return widget.paths
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q) ||
              c.instructor.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    final position = _scrollController.position;
    // Trigger load when within 1 row-height of the bottom
    if (position.pixels >= position.maxScrollExtent - _rowHeight &&
        _shownCount < _filtered.length) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    // Short delay gives the grid time to settle before adding more items
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _shownCount = (_shownCount + _pageSize).clamp(0, _filtered.length);
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filtered;

    // Guard: viewport count not ready yet
    if (_shownCount == 0) return const SizedBox();

    final shown = filtered.take(_shownCount).toList();
    final hasMore = _shownCount < filtered.length;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'All Learning Paths',
        showBackButton: true,
        onSearch: (q) => setState(() {
          _searchQuery = q;
          // Reset shown count to viewport size on new search
          _shownCount = _shownCount.clamp(2, _shownCount);
        }),
      ),
      body: SafeArea(
        child: filtered.isEmpty
            ? Center(
                child: Text(
                  'No learning paths found',
                  style: AppTypography.subtitleSemiBold.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              )
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.xmargin,
                      right: AppSpacing.xmargin,
                      top: AppSpacing.ymargin,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 35,
                            crossAxisSpacing: 12,
                            childAspectRatio:
                                BaseCourseCard.defaultWidth /
                                BaseCourseCard.defaultHeight,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            PixelCourseCard(course: shown[index]),
                        childCount: shown.length,
                      ),
                    ),
                  ),

                  /// Spinner while loading more / end-of-list label
                  SliverToBoxAdapter(
                    child: _isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : hasMore
                        ? const SizedBox(height: 32)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 40, top: 24),
                            child: Center(
                              child: Text(
                                '— ${filtered.length} paths —',
                                style: AppTypography.smallBodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
