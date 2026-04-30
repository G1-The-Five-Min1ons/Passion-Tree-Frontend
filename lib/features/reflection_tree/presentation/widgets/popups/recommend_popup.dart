import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passion_tree_frontend/core/common_widgets/icons/close_icon.dart';
import 'package:passion_tree_frontend/core/di/injection.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/features/learning_path/data/datasources/learning_path_data_source.dart';
import 'package:passion_tree_frontend/features/learning_path/data/models/learning_path_api_model.dart';
import 'package:passion_tree_frontend/features/learning_path/domain/entities/learning_path.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:passion_tree_frontend/features/learning_path/presentation/student/pages/learning_course.dart';

class RecommendPopup extends StatefulWidget {
  final String treeId;

  const RecommendPopup({required this.treeId, super.key});

  static void show(BuildContext context, {required String treeId}) {
    showDialog(
      context: context,
      builder: (context) => RecommendPopup(treeId: treeId),
    );
  }

  @override
  State<RecommendPopup> createState() => _RecommendPopupState();
}

class _RecommendPopupState extends State<RecommendPopup> {
  static final Map<String, List<LearningPathApiModel>> _cachedRecommendations = {};

  List<LearningPathApiModel>? _recommendedPaths;
  bool _isLoading = true;
  final LearningPathDataSource _dataSource = getIt<LearningPathDataSource>();

  void _navigateToLearningPath(LearningPathApiModel path) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final course = LearningPath(
      id: path.id,
      title: path.title,
      description: path.description,
      objective: path.objective,
      coverImageUrl: path.coverImgUrl,
      rating: path.rating,
      publishStatus: path.publishStatus,
      instructor: path.instructor,
      students: path.students,
      modules: path.modules,
      creatorId: path.creatorId,
    );

    rootNavigator.pop();
    rootNavigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<LearningPathBloc>(),
          child: LearningCoursePage(course: course),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final cachedPaths = _cachedRecommendations[widget.treeId];
    if (cachedPaths != null) {
      _recommendedPaths = cachedPaths;
      _isLoading = false;
      return;
    }

    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final paths = await _dataSource.getRecommendedLearningPathsForTree(
        widget.treeId,
      );
      if (!mounted) return;
      setState(() {
        _cachedRecommendations[widget.treeId] = paths;
        _recommendedPaths = paths;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recommendedPaths = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: PixelBorderContainer(
        pixelSize: 4,
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "NEXT\nLEARNING PATH",
                      textAlign: TextAlign.center,
                      style: AppPixelTypography.title,
                    ),
                  ),
                  const SizedBox(height: 38),
                  
                  Text(
                    "We recommend",
                    style: AppTypography.subtitleRegular,
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: SizedBox(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_recommendedPaths == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Failed to load recommendations',
                        style: AppTypography.subtitleRegular.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    )
                  else
                    Builder(
                      builder: (context) {
                        final recommendedPaths = _recommendedPaths!.take(5).toList();

                        if (recommendedPaths.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No recommendations available',
                              style: AppTypography.subtitleRegular.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: recommendedPaths
                              .map((path) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => _navigateToLearningPath(path),
                                  child: PixelBorderContainer(
                                    pixelSize: 3,
                                    height: 38,
                                    fillColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        path.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.subtitleSemiBold,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                              .toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
            Positioned(
              right: -12,
              top: -12,
              child: IconTheme(
                data: const IconThemeData(size: 24),
                child: CloseIcon(
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}