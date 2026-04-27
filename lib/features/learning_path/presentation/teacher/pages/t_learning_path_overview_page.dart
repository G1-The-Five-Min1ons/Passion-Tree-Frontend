import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/theme/theme.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/common_widgets/bars/appbar.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
// Filter section removed
import 'package:passion_tree_frontend/features/learning_path/presentation/widgets/teacher_tab_bar.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_learning_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_status_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/tabs/teacher_create_tab.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/teacher/pages/create_learning_path_input_page.dart';
import 'package:passion_tree_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:passion_tree_frontend/features/setting/presentation/pages/teacher_verification_page.dart';
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

  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  // Cache overview data
  LearningPathOverviewLoaded? _cachedOverview;

  Future<void> _onCreatePressed() async {
    try {
      final status = await _authRepository.getTeacherVerificationStatus();
      if (!mounted) return;

      if (status.applicationStatus != 'approved') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherVerificationPage(),
          ),
        );
        return;
      }

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to check verification status: $e',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cancel,
        ),
      );
    }
  }

  void _refreshOverviewAfterNodeMutation() {
    if (_userId == null || _userId!.isEmpty) return;

    // Refresh immediately so the module count on course cards updates without
    // the visible delay caused by waiting for another interaction.
    context.read<LearningPathBloc>().add(FetchLearningPathOverview());
  }

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    final storedUserId = await _authRepository.getUserId();
    if (!mounted) return;
    
    setState(() => _userId = storedUserId);
    
    // Fetch overview data from backend
    context.read<LearningPathBloc>().add(FetchLearningPathOverview());
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
            if (state is LearningPathDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }

            // Refetch overview when learning path or node is created/updated
            if (state is LearningPathCreated ||
                state is NodeCreated ||
                state is NodeUpdated ||
                state is NodeDeleted ||
                state is LearningPathUpdated) {
              _refreshOverviewAfterNodeMutation();
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
                      Row(
                        children: [
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
                          const Spacer(),
                          if (_activeTab == 1)
                            GestureDetector(
                              onTap: _onCreatePressed,
                              child: PixelBorderContainer(
                                pixelSize: 2,
                                fillColor: Theme.of(context).colorScheme.primary,
                                borderColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 3.8,
                                ),
                                child: Text(
                                  '+',
                                  style: AppPixelTypography.smallTitle.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
