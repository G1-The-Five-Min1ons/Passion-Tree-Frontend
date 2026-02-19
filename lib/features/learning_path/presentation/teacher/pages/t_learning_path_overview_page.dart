import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/search_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/filter_section.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/teacher_tab_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_learning_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_status_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_create_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';

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

  static const String? mockUserId = "feee25bd-db4e-4850-bd2c-5788ce090032"; // Teacher user ID

  // Cache overview data
  LearningPathOverviewLoaded? _cachedOverview;

  @override
  void initState() {
    super.initState();
    
    // Fetch overview data from backend
    context.read<LearningPathBloc>().add(
      FetchLearningPathOverview(userId: mockUserId),
    );
    
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
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Learning Paths',
        showBackButton:
            _activeTab == 0 && _learningView == TeacherLearningView.status,
        onBackPressed:
            _activeTab == 0 && _learningView == TeacherLearningView.status
            ? () {
                setState(() {
                  _learningView = TeacherLearningView.main;
                });
              }
            : null,
      ),
      body: SafeArea(
        child: BlocBuilder<LearningPathBloc, LearningPathState>(
          builder: (context, state) {
            // Cache overview data when loaded
            if (state is LearningPathOverviewLoaded) {
              _cachedOverview = state;
            }

            // Show loading only if no cached data
            if ((state is LearningPathLoading || state is LearningPathInitial) && 
                _cachedOverview == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LearningPathError && _cachedOverview == null) {
              return Center(child: Text(state.message));
            }

            // Use cached overview data
            final overviewData = _cachedOverview;
            if (overviewData != null) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xmargin,
                    right: AppSpacing.xmargin,
                    top: AppSpacing.ymargin,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      const SizedBox(height: 20),

                      // ===== CONTENT =====
                      if (_activeTab == 0) ...[
                        if (_learningView == TeacherLearningView.main)
                          TeacherLearningTab(
                            allPaths: overviewData.allPaths,
                            enrolledPaths: overviewData.enrolledPaths,
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
                            enrolledPaths: overviewData.enrolledPaths,
                          ),
                      ] else ...[
                        TeacherCreateTab(
                          allPaths: overviewData.allPaths,
                          userId: mockUserId,
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
