import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
// Filter section removed
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/teacher_tab_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_learning_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_status_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_create_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';

enum TeacherLearningView { main, status }

class TeacherLearningPathOverviewPage extends StatefulWidget {
  const TeacherLearningPathOverviewPage({super.key});

  @override
  State<TeacherLearningPathOverviewPage> createState() =>
      _TeacherLearningPathOverviewPageState();
}

class _TeacherLearningPathOverviewPageState
    extends State<TeacherLearningPathOverviewPage> {
  String _searchQuery = '';

  // Filter state
  // Filters removed

  int _activeTab = 0; // 0 = Learning, 1 = Create
  TeacherLearningView _learningView = TeacherLearningView.main;

  String? _userId;

  // Cache overview data
  LearningPathOverviewLoaded? _cachedOverview;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    final storedUserId = await getIt<IAuthRepository>().getUserId();
    if (!mounted) return;
    
    setState(() => _userId = storedUserId);
    
    // Fetch overview data from backend
    context.read<LearningPathBloc>().add(
      FetchLearningPathOverview(userId: storedUserId),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Learning Paths',
        showBackButton:
            _activeTab == 0 && _learningView == TeacherLearningView.status,
        onSearch: (q) => setState(() => _searchQuery = q),
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
        child: BlocListener<LearningPathBloc, LearningPathState>(
          listener: (context, state) {
            // Refetch overview when learning path or node is created/updated
            if (state is LearningPathCreated || 
                state is NodeCreated || 
                state is NodeUpdated ||
                state is LearningPathUpdated) {
              if (_userId != null && _userId!.isNotEmpty) {
                // Add a small delay to ensure backend is updated
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    context.read<LearningPathBloc>().add(
                      FetchLearningPathOverview(userId: _userId),
                    );
                  }
                });
              }
            }
          },
          child: BlocBuilder<LearningPathBloc, LearningPathState>(
            builder: (context, state) {
            // Cache overview data when loaded
            if (state is LearningPathOverviewLoaded) {
              _cachedOverview = state;
            }

            // Show loading only if no cached data
            if ((state is LearningPathLoading ||
                    state is LearningPathInitial) &&
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
                      // ===== SEARCH & FILTERS REMOVED =====

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
                            allPaths: overviewData.allPaths.where((path) {
                              final status = path.publishStatus.toLowerCase().trim();
                              return status == 'published' && status.isNotEmpty && status != 'null';
                            }).toList(),
                            enrolledPaths: overviewData.enrolledPaths,
                            searchQuery: _searchQuery,
                            selectedCategory: null,
                            ratingRange: null,
                            maxModules: null,
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
                          userId: _userId,
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
      ),
    );
  }
}
