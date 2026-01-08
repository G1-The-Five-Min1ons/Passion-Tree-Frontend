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
import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';
import 'package:passion_tree_frontend/features/learning_path/data/mocks/course_mock.dart';

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

  // === NEW: State for controlling number of shown cards ===
  int _allListShownCount = 4;

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

    // === mock logic แยกสถานะ ===
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
                // ===== HEADER TITLE + NavigationButton =====
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Learning Paths',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Header → Search (40)
                const SizedBox(height: 40),

                // ===== SEARCH BAR & FILTER =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                ),

                 const SizedBox(height: 40),

                // ===== Tab Bar =====
                TeacherTabBar(
                  activeIndex: _activeTab,
                  onChanged: (index) {
                    setState(() {
                      _activeTab = index;
                    });
                  },
                ),

                // Title → Section (40)
                const SizedBox(height: 40),

                // ===== Content =====
                _activeTab == 0
                    ? TeacherLearningTab(
                        searchQuery: _searchController.text,
                        selectedCategory: _selectedCategory,
                        ratingRange: _ratingRange,
                        maxModules: _maxModules,
                      )
                    : TeacherCreateTab(
                        inProgressCourses: inProgressCourses,
                        completedCourses: completedCourses,
                      ),
                             
                // bottom safe spacing
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

