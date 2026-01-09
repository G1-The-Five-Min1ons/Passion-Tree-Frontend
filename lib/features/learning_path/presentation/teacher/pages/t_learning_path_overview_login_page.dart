import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/button_enums.dart';
import 'package:passion_tree_frontend/core/common_widgets/buttons/navigation_button.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_section.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/teacher_tab_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_create_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_learning_tab.dart';   
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_status_tab.dart';   
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';
enum TeacherLearningView { main, status }

class TeacherLearningPathOverviewPage extends StatefulWidget {
  const TeacherLearningPathOverviewPage({super.key});

  @override
  State<TeacherLearningPathOverviewPage> createState() =>
      _TeacherLearningPathOverviewPageState();
}

class _TeacherLearningPathOverviewPageState
    extends State<TeacherLearningPathOverviewPage> {
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _selectedCategory;
  RangeValues? _ratingRange;
  int? _maxModules;

  int _activeTab = 0; // 0 = Learning, 1 = Create
  TeacherLearningView _learningView = TeacherLearningView.main;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // ===== mock แยกสถานะ =====
    final inProgressCourses = allCourses
        .where((c) => c.status == CourseStatus.inProgress)
        .toList();

    final completedCourses = allCourses
        .where((c) => c.status == CourseStatus.completed)
        .toList();

    return Scaffold(
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
                  height: 72,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Learning Paths',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ===== SEARCH + FILTER =====
                Row(
                  children: [
                    Expanded(
                      child: LearningPathSearchBar(
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterSection(
                      selectedCategory: _selectedCategory,
                      ratingRange: _ratingRange,
                      maxModules: _maxModules,
                      onFiltersChanged: (category, rating, modules) {
                        setState(() {
                          _selectedCategory = category;
                          _ratingRange = rating;
                          _maxModules = modules;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ===== TAB BAR =====
                TeacherTabBar(
                  activeIndex: _activeTab,
                  onChanged: (index) {
                    setState(() {
                      _activeTab = index;

                      
                      if (_activeTab == 0) {
                        _learningView = TeacherLearningView.main;
                      }
                    });
                  },
                ),

                const SizedBox(height: 40),

                // ===== CONTENT =====
                if (_activeTab == 0) ...[
                  if (_learningView == TeacherLearningView.main)
                    TeacherLearningTab(
                      searchQuery: _searchController.text,
                      selectedCategory: _selectedCategory,
                      ratingRange: _ratingRange,
                      maxModules: _maxModules,
                      onOpenStatus: () {
                        setState(() {
                          _learningView = TeacherLearningView.status;
                        });
                      },
                    )
                  else
                    TeacherLearningPathStatus(
                      inProgressCourses: inProgressCourses,
                      completedCourses: completedCourses,
                    ),
                ] else ...[
                  TeacherCreateTab(
                    inProgressCourses: inProgressCourses,
                    completedCourses: completedCourses,
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
